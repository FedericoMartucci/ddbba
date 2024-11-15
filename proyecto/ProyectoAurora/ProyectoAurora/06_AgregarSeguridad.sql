/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 6											#
#															#
#   Integrantes:											#
#															#
#       Brocani, Agustin					40.931.870      #
#		Caruso Dellisanti, Carolina Belen	40.129.448		#
#       Martucci, Federico Ariel			44.690.247      #
#		Rivera, Victor						44.258.557		#
#															#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
*/
USE Com5600G08;
GO

/*
				==============================================================
				=		Procedure para configurar claves de encriptación	 =
				==============================================================
*/
-- Establece una clave simétrica para encriptar los datos sensibles en la tabla EMPLEADO.
-- Incluye una clave maestra y un certificado para cumplir con los requisitos de seguridad.
CREATE OR ALTER PROCEDURE seguridad.ConfigurarClavesEncriptacion
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


/*
				==============================================================
				=			Procedure para encriptar datos de empleado		 =
				==============================================================
*/
-- Encripta los datos sensibles en la tabla EMPLEADO usando la clave simétrica configurada previamente.
CREATE OR ALTER PROCEDURE seguridad.EncriptarDatosEmpleados
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

CREATE OR ALTER PROCEDURE seguridad.DesencriptarDatosEmpleados
AS
BEGIN
    -- Abre la clave simétrica utilizando el certificado
    OPEN SYMMETRIC KEY Clave_Empleados DECRYPTION BY CERTIFICATE Certificado_Empleados;

    -- Selecciona los datos desencriptados
    SELECT 
        dni = CAST(CAST(DECRYPTBYKEY(CAST(dni AS VARCHAR(11)))AS VARCHAR(11)) AS INT),   -- Desencriptamos y convertimos a VARCHAR
        direccion = CAST(DECRYPTBYKEY(direccion) AS VARCHAR(255)),  -- Desencriptamos y convertimos a VARCHAR
        email_empresa = CAST(DECRYPTBYKEY(email_empresa) AS VARCHAR(255)),
        email_personal = CAST(DECRYPTBYKEY(email_personal) AS VARCHAR(255)),
        CUIL = CAST(DECRYPTBYKEY(CUIL) AS VARCHAR(20))  -- Desencriptamos y convertimos a VARCHAR
    FROM seguridad.EMPLEADO;

    -- Cierra la clave simétrica
    CLOSE SYMMETRIC KEY Clave_Empleados;

    PRINT 'Datos de empleados desencriptados con éxito.';
END;
GO

/*
				==============================================================
				=		Procedure para crear roles y asignar permisos		 =
				==============================================================
*/
-- Define roles específicos y asigna permisos para que solo los Supervisores puedan generar notas de crédito.
CREATE OR ALTER PROCEDURE seguridad.CrearRolesYAsignarPermisos
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrador')
        CREATE ROLE Administrador;
	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Gerente')
        CREATE ROLE Gerente;
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
        CREATE ROLE Supervisor;
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Cajero')
        CREATE ROLE Cajero;

     -- Asignar permisos al Administrador para toda la base de datos
    GRANT CONTROL ON DATABASE::Com5600G08 TO Administrador;

    -- Permisos para el rol Cajero
    GRANT INSERT ON transacciones.VENTA TO Cajero;
    GRANT INSERT ON transacciones.MEDIO_DE_PAGO TO Cajero;
    GRANT INSERT ON transacciones.FACTURA TO Cajero;

    -- Permisos para el rol Supervisor
    GRANT INSERT ON transacciones.VENTA TO Supervisor;
    GRANT INSERT ON transacciones.MEDIO_DE_PAGO TO Supervisor;
    GRANT INSERT ON transacciones.FACTURA TO Supervisor;
    GRANT INSERT ON transacciones.NOTA_CREDITO TO Supervisor;
    GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::productos TO Supervisor;

    -- Permisos para el rol Gerente
	GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::transacciones TO Gerente;
    GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::productos TO Gerente;
    GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO Gerente;

	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioCajero')
		CREATE USER UsuarioCajero WITHOUT LOGIN;
	ALTER ROLE Cajero ADD MEMBER UsuarioCajero;

	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioSupervisor')
		CREATE USER UsuarioSupervisor WITHOUT LOGIN;
	ALTER ROLE Supervisor ADD MEMBER UsuarioSupervisor;

	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioGerente')
		CREATE USER UsuarioGerente WITHOUT LOGIN;
	ALTER ROLE Gerente ADD MEMBER UsuarioGerente;

	IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioAdministrador')
		CREATE USER UsuarioAdministrador WITHOUT LOGIN;
	ALTER ROLE Administrador ADD MEMBER UsuarioAdministrador;

    PRINT 'Roles y permisos asignados correctamente.';
END;
GO


/*
				==================================================
				=		Procedure para crear Nota de Crédito	 =
				==================================================
*/
-- Genera una nota de crédito solo si la factura está pagada y el usuario tiene el rol de Supervisor.
CREATE OR ALTER PROCEDURE seguridad.CrearNotaCredito
    @FacturaID CHAR(11),
    @MontoCredito DECIMAL(10, 2)
AS
BEGIN
    IF @MontoCredito <= 0
	BEGIN
		RAISERROR ('El monto debe ser un número positivo mayor a 0.', 16, 1);
		RETURN;
	END
	
	DECLARE @EstadoFactura BIT;

    -- Verificar que la factura esté pagada
    SELECT @EstadoFactura = estado FROM transacciones.FACTURA WHERE id = @FacturaID;

    IF @EstadoFactura = 1
    BEGIN
		INSERT INTO transacciones.NOTA_CREDITO (id_factura, monto)
		VALUES (@FacturaID, @MontoCredito);

		PRINT 'Nota de crédito generada con éxito.';
    END
    ELSE
    BEGIN
        RAISERROR ('Error: La factura debe estar pagada para generar una nota de crédito.', 16, 1);
    END
END;
GO


/*
				======================================
				=		Política de Respaldo		 =
				======================================
*/
-- Se define una política de respaldo completo semanal y diferencial diario para optimizar el tiempo y el espacio de almacenamiento.
/*
- Eficiencia en el Uso de Almacenamiento:
	-	Respaldo Completo: consume más espacio, pero minimiza el impacto de almacenamiento.
	-	Respaldo Diferencial: solo respalda los cambios desde el último respaldo completo,
		impacta en el almacenamiento, pero es mas rapido.
- Optimización del tiempo de Respaldo:
	-	Respaldo Completo: como los hacemos semanal, evitamos tiempos largos de inactividad.
	-	Respaldo Diferencial: son más rápidos de ejecutar que los completos, no afectamos
		mucho el rendimiento del sistema.
- Facilidad de Recuperación: combinamos el último respaldo completo con los respaldos
	diferenciales posteriores.
*/


/*
				======================================================
				=		Procedure para realizar backup semanal		 =
				======================================================
*/
CREATE OR ALTER PROCEDURE seguridad.RealizarRespaldoSemanal
AS
BEGIN
	DECLARE @archivoBackup VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\backups\Com5600G08_full-' + CONVERT(VARCHAR, GETDATE(), 23) 
                                    + '_' 
                                    + REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '-') 
                                    + '.bak';

    -- Respaldo completo semanal
    BACKUP DATABASE Com5600G08
    TO DISK = @archivoBackup
    WITH FORMAT, NAME = 'Respaldo Completo Semanal';
    
	PRINT 'Respaldo semanal realizado.'
END;
GO


/*
				======================================================
				=		Procedure para realizar backup diario		 =
				======================================================
*/
CREATE OR ALTER PROCEDURE seguridad.RealizarRespaldoDiario
AS
BEGIN
	DECLARE @archivoBackup VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\backups\Com5600G08_diff-' + CONVERT(VARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.bak';

    -- Respaldo diferencial diario
    BACKUP DATABASE Com5600G08
    TO DISK = @archivoBackup
    WITH DIFFERENTIAL, NAME = 'Respaldo Diferencial Diario';

    PRINT 'Respaldo diario realizado.';
END;
GO


/*
				=====================================================================
				=	Procedure para la ejecución completa del proceso de seguridad	=
				=====================================================================
*/
-- Procedimiento principal que ejecuta todos los procedimientos de configuración de seguridad y respaldo.
CREATE OR ALTER PROCEDURE seguridad.EjecutarProcesoSeguridad
AS
BEGIN TRY
    PRINT 'Iniciando configuración de seguridad...';
    
    -- Configurar Claves de Encriptación
    EXEC seguridad.ConfigurarClavesEncriptacion;

    -- Encriptar Datos de Empleados
    EXEC seguridad.EncriptarDatosEmpleados;
    
    -- Crear Roles y Asignar Permisos
    EXEC seguridad.CrearRolesYAsignarPermisos;

    -- Realizar backup semanal
    EXEC seguridad.RealizarRespaldoSemanal;
	
	-- Realizar backup diario
	EXEC seguridad.RealizarRespaldoDiario

    PRINT 'Proceso de configuración de seguridad completado exitosamente.';
END TRY
BEGIN CATCH
    RAISERROR ('Error durante la ejecución del proceso de seguridad.', 16, 1);
END CATCH;
GO

-- EXEC seguridad.EjecutarProcesoSeguridad

-- Testeo encriptacion comparando los campos dni, direccion, emails y cuil siendo distintos
-- Testeo encriptacion comparando los campos dni, direccion, emails y cuil siendo iguales