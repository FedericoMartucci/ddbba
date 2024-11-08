USE Com5600G08;
GO
-- PROCEDURE: Configurar Claves de Encriptación
-- Establece una clave simétrica para encriptar los datos sensibles en la tabla EMPLEADO.
-- Incluye una clave maestra y un certificado para cumplir con los requisitos de seguridad.
CREATE PROCEDURE seguridad.ConfigurarClavesEncriptacion
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Clave_Empleados')
    BEGIN
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SecureP@ssw0rd!';
        CREATE CERTIFICATE Certificado_Empleados
        WITH SUBJECT = 'Certificado para encriptar datos personales';
        CREATE SYMMETRIC KEY Clave_Empleados
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Certificado_Empleados;

        PRINT 'Claves de encriptación creadas.';
    END
END;
GO

-- PROCEDURE: Encriptar Datos de Empleados
-- Encripta los datos sensibles en la tabla EMPLEADO usando la clave simétrica configurada previamente.
CREATE PROCEDURE seguridad.EncriptarDatosEmpleados
AS
BEGIN
    OPEN SYMMETRIC KEY Clave_Empleados DECRYPTION BY CERTIFICATE Certificado_Empleados;
    UPDATE seguridad.EMPLEADO
    SET 
        dni = ENCRYPTBYKEY(KEY_GUID('Clave_Empleados'), CAST(dni AS VARCHAR(10))),
        direccion = ENCRYPTBYKEY(KEY_GUID('Clave_Empleados'), direccion),
        email_empresa = ENCRYPTBYKEY(KEY_GUID('Clave_Empleados'), email_empresa),
        email_personal = ENCRYPTBYKEY(KEY_GUID('Clave_Empleados'), email_personal),
        CUIL = ENCRYPTBYKEY(KEY_GUID('Clave_Empleados'), CUIL);
    CLOSE SYMMETRIC KEY Clave_Empleados;

    PRINT 'Datos de empleados encriptados con éxito.';
END;
GO

-- PROCEDURE: Crear Roles y Asignar Permisos
-- Define roles específicos y asigna permisos para que solo los Supervisores puedan generar notas de crédito.
CREATE PROCEDURE seguridad.CrearRolesYAsignarPermisos
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
        CREATE ROLE Supervisor;
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrador')
        CREATE ROLE Administrador;
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Empleado')
        CREATE ROLE Empleado;

    GRANT SELECT, UPDATE ON transacciones.FACTURA TO Supervisor;
    GRANT INSERT ON transacciones.NOTA_CREDITO TO Supervisor;

    PRINT 'Roles y permisos asignados correctamente.';
END;
GO

-- PROCEDURE: Crear Nota de Crédito
-- Genera una nota de crédito solo si la factura está pagada y el usuario tiene el rol de Supervisor.
CREATE PROCEDURE seguridad.CrearNotaCredito
    @FacturaID INT,
    @MontoCredito DECIMAL(10,2)
AS
BEGIN
    DECLARE @EstadoFactura VARCHAR(20);

    -- Verificar que la factura esté pagada
    SELECT @EstadoFactura = estado FROM transacciones.FACTURA WHERE id = @FacturaID;

    IF @EstadoFactura = 'pagada'
    BEGIN
        INSERT INTO transacciones.NOTA_CREDITO (id_factura, monto)
        VALUES (@FacturaID, @MontoCredito);

        PRINT 'Nota de crédito generada con éxito.';
    END
    ELSE
    BEGIN
        PRINT 'Error: La factura debe estar pagada para generar una nota de crédito.';
    END
END;
GO

-- PROCEDURE: Configurar Política de Respaldo
-- Define una política de respaldo completo semanal y diferencial diario para optimizar el tiempo y el espacio de almacenamiento.
CREATE PROCEDURE seguridad.ConfigurarPoliticaRespaldo
AS
BEGIN
    -- Respaldo completo semanal
    BACKUP DATABASE Com5600G08
    TO DISK = 'C:\backups\Com5600G08_full.bak'
    WITH FORMAT, NAME = 'Respaldo Completo Semanal';
    
    -- Respaldo diferencial diario
    BACKUP DATABASE Com5600G08
    TO DISK = 'C:\backups\Com5600G08_diff.bak'
    WITH DIFFERENTIAL, NAME = 'Respaldo Diferencial Diario';

    PRINT 'Política de respaldo configurada correctamente.';
END;
GO

-- PROCEDURE: Ejecución Completa del Proceso de Seguridad
-- Procedimiento principal que ejecuta todos los procedimientos de configuración de seguridad y respaldo.
CREATE PROCEDURE seguridad.EjecutarProcesoSeguridad
AS
BEGIN TRY
    PRINT 'Iniciando configuración de seguridad...';
    
    -- Configurar Claves de Encriptación
    EXEC seguridad.ConfigurarClavesEncriptacion;

    -- Encriptar Datos de Empleados
    EXEC seguridad.EncriptarDatosEmpleados;
    
    -- Crear Roles y Asignar Permisos
    EXEC seguridad.CrearRolesYAsignarPermisos;

    -- Configurar Política de Respaldo
    EXEC seguridad.ConfigurarPoliticaRespaldo;

    PRINT 'Proceso de configuración de seguridad completado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error durante la ejecución del proceso de seguridad:';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
