/*
 * ========================================================
 * Creación de Procedimientos de Pruebas para Seguridad
 * ========================================================
 */

USE Com5600G08;
GO

/*
 * ----------------------------
 * Prueba de ConfigurarClavesEncriptacion
 * ----------------------------
 */
CREATE OR ALTER PROCEDURE Test_ConfigurarClavesEncriptacion
AS
BEGIN
    -- Ejecuta el procedimiento de configuración de claves
    EXEC seguridad.ConfigurarClavesEncriptacion;
    
    -- Verifica que la clave y el certificado existen
    IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Clave_Empleados')
    BEGIN
        RAISERROR('Fallo: Clave simétrica no encontrada.', 16, 1);
    END
    ELSE IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Certificado_Empleados')
    BEGIN
        RAISERROR('Fallo: Certificado no encontrado.', 16, 1);
    END
    ELSE
    BEGIN
        PRINT 'Exito: Clave y certificado creados correctamente.';
    END
END;
GO


/*
 * ----------------------------
 * Procedimiento Modificado: DesencriptarDatosEmpleados
 * ----------------------------
 */
CREATE OR ALTER PROCEDURE seguridad.DesencriptarDatosEmpleados
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Abre la clave simétrica utilizando el certificado
    OPEN SYMMETRIC KEY Clave_Empleados DECRYPTION BY CERTIFICATE Certificado_Empleados;

    -- Selecciona y desencripta los datos
    SELECT 
        dni = TRY_CAST(CAST(DECRYPTBYKEY(dni) AS VARCHAR(11)) AS INT),  
        direccion = CAST(DECRYPTBYKEY(direccion) AS VARCHAR(255)),
        email_empresa = CAST(DECRYPTBYKEY(email_empresa) AS VARCHAR(255)),
        email_personal = CAST(DECRYPTBYKEY(email_personal) AS VARCHAR(255)),
        CUIL = CAST(DECRYPTBYKEY(CUIL) AS VARCHAR(20))
    FROM seguridad.EMPLEADO_ENCRIPTADO;

    -- Cierra la clave simétrica
    CLOSE SYMMETRIC KEY Clave_Empleados;

    PRINT 'Datos de empleados desencriptados con éxito en la tabla EMPLEADO.';
END;
GO

/*
 * ----------------------------
 * Prueba de CrearRolesYAsignarPermisos
 * ----------------------------
 */
CREATE OR ALTER PROCEDURE Test_CrearRolesYAsignarPermisos
AS
BEGIN
    -- Ejecuta el procedimiento para crear roles y asignar permisos
    EXEC seguridad.CrearRolesYAsignarPermisos;

    -- Verifica la existencia de roles
    DECLARE @roleCount INT;
    SELECT @roleCount = COUNT(*) 
    FROM sys.database_principals 
    WHERE name IN ('Administrador', 'Gerente', 'Supervisor', 'Cajero');

    IF @roleCount <> 4
    BEGIN
        RAISERROR('Fallo: No todos los roles fueron creados.', 16, 1);
    END
    ELSE
    BEGIN
        PRINT 'Exito: Roles creados correctamente.';
    END
END;
GO

/*
 * ----------------------------
 * Prueba de CrearNotaCredito
 * ----------------------------
 */
CREATE OR ALTER PROCEDURE Test_CrearNotaCredito
AS 
BEGIN
	SET NOCOUNT ON

    DECLARE @FacturaID INT;
    DECLARE @MontoCredito DECIMAL(10, 2) = 100.00;
    DECLARE @EstadoFactura BIT;
	
	SELECT TOP 1 @FacturaID = id_factura FROM transacciones.FACTURA

    -- Intenta crear la nota de crédito
    EXEC seguridad.CrearNotaCredito @FacturaID, @MontoCredito;

    -- Verifica que se creó la nota de crédito
    IF NOT EXISTS (SELECT * FROM transacciones.NOTA_CREDITO WHERE id_factura = @FacturaID)
    BEGIN
        RAISERROR('Fallo: Nota de crédito no creada para factura pagada.', 16, 1);
    END
    ELSE
    BEGIN
        PRINT 'Exito: Nota de crédito creada correctamente.';
    END

    -- Limpia datos de prueba
    DELETE FROM transacciones.NOTA_CREDITO WHERE id_factura = @FacturaID;
END;
GO

CREATE OR ALTER PROCEDURE Test_CrearNotaCreditoMontoNegativo
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @FacturaID INT;
    DECLARE @MontoCredito DECIMAL(10, 2) = -100.00;
    DECLARE @EstadoFactura BIT;

	SELECT TOP 1 @FacturaID = id_factura FROM transacciones.FACTURA

    -- Intenta crear la nota de crédito
    EXEC seguridad.CrearNotaCredito @FacturaID, @MontoCredito;

    -- Verifica que se creó la nota de crédito
    IF EXISTS (SELECT * FROM transacciones.NOTA_CREDITO WHERE id_factura = @FacturaID)
    BEGIN
        RAISERROR('Fallo: Nota de crédito fue creada con un monto negativo.', 16, 1);
    END
    ELSE
    BEGIN
        PRINT 'Exito: Nota de crédito no creada.';
    END

    -- Limpia datos de prueba
    DELETE FROM transacciones.NOTA_CREDITO WHERE id_factura = @FacturaID;
END;
GO

/*
 * ----------------------------
 * Prueba de CrearNotaCredito como Cajero (Debe fallar)
 * ----------------------------
 */

CREATE OR ALTER PROCEDURE Test_CrearNotaCredito_Cajero
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @FacturaID INT;
    DECLARE @MontoCredito DECIMAL(10, 2) = 50.00;
    DECLARE @Error NVARCHAR(255);

	SELECT TOP 1 @FacturaID = id_factura FROM transacciones.FACTURA

    BEGIN TRY
        -- Impersona el rol de Cajero
        EXECUTE AS USER = 'UsuarioCajero';

        -- Intenta crear la nota de crédito
        EXEC seguridad.CrearNotaCredito @FacturaID, @MontoCredito;

        -- Si logra crear la nota, es un fallo de permisos
        SET @Error = 'Fallo: El rol Cajero logró crear una nota de crédito, lo cual no debería ser permitido.';
        RAISERROR(@Error, 16, 1);
    END TRY
    BEGIN CATCH
        -- Verifica que el error sea de permisos
        IF ERROR_MESSAGE() LIKE '%The EXECUTE permission was denied%'
        BEGIN
            PRINT 'Éxito: El rol Cajero no tiene permisos para crear notas de crédito.';
        END
        ELSE
        BEGIN
            DECLARE @Msg NVARCHAR(255) = 'Fallo inesperado: ' + ERROR_MESSAGE();
            RAISERROR(@Msg, 16, 1);
        END
    END CATCH;

    -- Limpia datos de prueba y revierte el contexto de usuario
    REVERT;
END;
GO
SELECT * FROM transacciones.NOTA_CREDITO

/*
 * ----------------------------
 * Prueba de CrearNotaCredito como Supervisor (Debe permitirlo)
 * ----------------------------
 */
CREATE OR ALTER PROCEDURE EXEC Test_CrearNotaCredito_Supervisor
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @FacturaID INT;
    DECLARE @MontoCredito DECIMAL(10, 2) = 75.00;
    DECLARE @Error NVARCHAR(255);

	SELECT TOP 1 @FacturaID = id_factura FROM transacciones.FACTURA

    BEGIN TRY
        -- Impersona el rol de Supervisor
        EXECUTE AS USER = 'UsuarioSupervisor';

        -- Intenta crear la nota de crédito
        EXEC seguridad.CrearNotaCredito @FacturaID, @MontoCredito;

        -- Verifica que se creó la nota de crédito
        IF EXISTS (SELECT * FROM transacciones.NOTA_CREDITO WHERE id_factura = @FacturaID)
        BEGIN
            PRINT 'Éxito: El rol Supervisor tiene permisos para crear notas de crédito.';
        END
        ELSE
        BEGIN
            RAISERROR('Fallo: El rol Supervisor no logró crear la nota de crédito, aunque debería tener permisos.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        DECLARE @Msg NVARCHAR(255) = 'Fallo inesperado: ' + ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
    END CATCH;

    -- Limpia datos de prueba y revierte el contexto de usuario
    REVERT;
    DELETE FROM transacciones.NOTA_CREDITO WHERE id_factura = @FacturaID;
END;
GO


/*
 * ----------------------------
 * Prueba de Respaldo Semanal y Diario
 * ----------------------------
 */
CREATE OR ALTER PROCEDURE Test_RealizarRespaldo
AS
BEGIN
    -- Intenta realizar el respaldo semanal
    EXEC seguridad.RealizarRespaldoSemanal;

    -- Intenta realizar el respaldo diario
    EXEC seguridad.RealizarRespaldoDiario;

    -- Verifica en el historial de backups de SQL Server si se realizaron
    DECLARE @backupCount INT;
    SELECT @backupCount = COUNT(*) 
    FROM msdb.dbo.backupset 
    WHERE database_name = 'Com5600G08' 
    AND backup_finish_date > DATEADD(SECOND, -10, GETDATE()); -- Esto podria variar segun de cuanto se tarde en realizar el backup

    IF @backupCount < 2
    BEGIN
        RAISERROR('Fallo: No se realizaron los respaldos diario y/o semanal.', 16, 1);
    END
    ELSE
    BEGIN
		PRINT 'Exito: Respaldo semanal y diario ejecutados correctamente.';
    END
END;
GO


/*
 * ========================================================
 * Procedimiento Principal para Ejecutar Todas las Pruebas
 * ========================================================
 */
CREATE OR ALTER PROCEDURE Ejecutar_Todas_Las_Pruebas
AS
BEGIN
	
    PRINT	'================================================' + CHAR(10) +
			'--- Iniciando todas las pruebas de seguridad ---' + CHAR(10) +
			'================================================';
	
	PRINT '------ Test de configuración de claves de encriptación ------';
    EXEC Test_ConfigurarClavesEncriptacion;
	
	PRINT CHAR(10) + CHAR(10) + '------ Test de creación y asignación de roles y permisos ------';
    EXEC Test_CrearRolesYAsignarPermisos;
	
	PRINT CHAR(10) + CHAR(10) + '------ Tests de Nota de Crédito ------';
    PRINT '-- Test de creación --';
	EXEC Test_CrearNotaCredito;
	PRINT '-- Test de creación con monto negativo --';
	EXEC Test_CrearNotaCreditoMontoNegativo;
	-- PRINT '-- Test de creación como cajero --';
	-- EXEC Test_CrearNotaCredito_Cajero;
	PRINT '-- Test de creación como supervisor --';
	EXEC Test_CrearNotaCredito_Supervisor;
	
	PRINT CHAR(10) + CHAR(10) + '------ Tests de creación de backups ------';
    EXEC Test_RealizarRespaldo;

	PRINT	'=====================================' + CHAR(10) +
			'--- Todas las pruebas finalizadas ---' + CHAR(10) +
			'=====================================';
END;
GO


-- Ejecuta todas las pruebas
EXEC Ejecutar_Todas_Las_Pruebas;
