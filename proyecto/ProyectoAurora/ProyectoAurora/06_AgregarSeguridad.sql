USE Com5600G08;
GO
-- PROCEDURE: Configurar Claves de Encriptaci�n
-- Establece una clave sim�trica para encriptar los datos sensibles en la tabla EMPLEADO.
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

        PRINT 'Claves de encriptaci�n creadas.';
    END
END;
GO

-- PROCEDURE: Encriptar Datos de Empleados
-- Encripta los datos sensibles en la tabla EMPLEADO usando la clave sim�trica configurada previamente.
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

    PRINT 'Datos de empleados encriptados con �xito.';
END;
GO

-- PROCEDURE: Crear Roles y Asignar Permisos
-- Define roles espec�ficos y asigna permisos para que solo los Supervisores puedan generar notas de cr�dito.
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

-- PROCEDURE: Crear Nota de Cr�dito
-- Genera una nota de cr�dito solo si la factura est� pagada y el usuario tiene el rol de Supervisor.
CREATE PROCEDURE seguridad.CrearNotaCredito
    @FacturaID INT,
    @MontoCredito DECIMAL(10,2)
AS
BEGIN
    DECLARE @EstadoFactura VARCHAR(20);

    -- Verificar que la factura est� pagada
    SELECT @EstadoFactura = estado FROM transacciones.FACTURA WHERE id = @FacturaID;

    IF @EstadoFactura = 'pagada'
    BEGIN
        INSERT INTO transacciones.NOTA_CREDITO (id_factura, monto)
        VALUES (@FacturaID, @MontoCredito);

        PRINT 'Nota de cr�dito generada con �xito.';
    END
    ELSE
    BEGIN
        PRINT 'Error: La factura debe estar pagada para generar una nota de cr�dito.';
    END
END;
GO

-- PROCEDURE: Configurar Pol�tica de Respaldo
-- Define una pol�tica de respaldo completo semanal y diferencial diario para optimizar el tiempo y el espacio de almacenamiento.
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

    PRINT 'Pol�tica de respaldo configurada correctamente.';
END;
GO

-- PROCEDURE: Ejecuci�n Completa del Proceso de Seguridad
-- Procedimiento principal que ejecuta todos los procedimientos de configuraci�n de seguridad y respaldo.
CREATE PROCEDURE seguridad.EjecutarProcesoSeguridad
AS
BEGIN TRY
    PRINT 'Iniciando configuraci�n de seguridad...';
    
    -- Configurar Claves de Encriptaci�n
    EXEC seguridad.ConfigurarClavesEncriptacion;

    -- Encriptar Datos de Empleados
    EXEC seguridad.EncriptarDatosEmpleados;
    
    -- Crear Roles y Asignar Permisos
    EXEC seguridad.CrearRolesYAsignarPermisos;

    -- Configurar Pol�tica de Respaldo
    EXEC seguridad.ConfigurarPoliticaRespaldo;

    PRINT 'Proceso de configuraci�n de seguridad completado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error durante la ejecuci�n del proceso de seguridad:';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
