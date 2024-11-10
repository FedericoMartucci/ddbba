/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 7											#
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
USE Com5600G08
GO
SET NOCOUNT ON
GO
CREATE OR ALTER PROCEDURE inserciones.TestInsertarSucursales
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),  
	@pathCaso3 VARCHAR(255) 
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnSucursal INT;
	DECLARE @cantidadDeFilasAntesEnTelefono INT;
	DECLARE @cantidadDeFilasDespuesEnSucursal INT;
	DECLARE @cantidadDeFilasDespuesEnTelefono INT;
	DECLARE @todoOK VARCHAR(60) = 'SP InsertarSucursales funciona correctamente para el caso ';

	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasAntesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasAntesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)

	EXEC inserciones.InsertarSucursales @pathCaso1;

	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasDespuesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasDespuesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)

	IF(@cantidadDeFilasAntesEnSucursal <> @cantidadDeFilasDespuesEnSucursal OR @cantidadDeFilasAntesEnTelefono <> @cantidadDeFilasDespuesEnTelefono)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasAntesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasAntesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)

	EXEC inserciones.InsertarSucursales @pathCaso2;

	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasDespuesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasDespuesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)

	IF(@cantidadDeFilasAntesEnSucursal <> @cantidadDeFilasDespuesEnSucursal OR @cantidadDeFilasAntesEnTelefono <> @cantidadDeFilasDespuesEnTelefono)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'

	--CASO 3: cargar archivo vacio.
	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasAntesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasAntesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)

	EXEC inserciones.InsertarSucursales @pathCaso3;

	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasDespuesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasDespuesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)

	IF(@cantidadDeFilasAntesEnSucursal <> @cantidadDeFilasDespuesEnSucursal OR @cantidadDeFilasAntesEnTelefono <> @cantidadDeFilasDespuesEnTelefono)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'
END

GO

CREATE OR ALTER PROCEDURE inserciones.TestInsertarEmpleados
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),  
	@pathCaso3 VARCHAR(255) 
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnCargo INT;
	DECLARE @cantidadDeFilasAntesEnEmpleado INT;
	DECLARE @cantidadDeFilasDespuesEnCargo INT;
	DECLARE @cantidadDeFilasDespuesEnEmpleado INT;
	DECLARE @todoOK VARCHAR(60) = 'SP InsertarEmpleados funciona correctamente para el caso ';

	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasAntesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasAntesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	EXEC inserciones.InsertarEmpleados @pathCaso1;

	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasDespuesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasDespuesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	IF(@cantidadDeFilasAntesEnCargo <> @cantidadDeFilasDespuesEnCargo OR @cantidadDeFilasAntesEnEmpleado <> @cantidadDeFilasDespuesEnEmpleado)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasAntesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasAntesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	EXEC inserciones.InsertarEmpleados @pathCaso2;

	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasDespuesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasDespuesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	IF(@cantidadDeFilasAntesEnCargo <> @cantidadDeFilasDespuesEnCargo OR @cantidadDeFilasAntesEnEmpleado <> @cantidadDeFilasDespuesEnEmpleado)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'
	
	--CASO 3: cargar archivo vacio.
	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasAntesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasAntesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	EXEC inserciones.InsertarEmpleados @pathCaso3;

	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasDespuesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasDespuesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	IF(@cantidadDeFilasAntesEnCargo <> @cantidadDeFilasDespuesEnCargo OR @cantidadDeFilasAntesEnEmpleado <> @cantidadDeFilasDespuesEnEmpleado)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'
END

GO

CREATE OR ALTER PROCEDURE inserciones.TestInsertarMediosDePago
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),  
	@pathCaso3 VARCHAR(255) 
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnMediosDePago INT;
	DECLARE @cantidadDeFilasDespuesEnMediosDePago INT;
	DECLARE @todoOK VARCHAR(62) = 'SP InsertarMediosDePago funciona correctamente para el caso ';

	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasAntesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	EXEC inserciones.InsertarMediosDePago @pathCaso1
	
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasDespuesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	IF(@cantidadDeFilasAntesEnMediosDePago <> @cantidadDeFilasDespuesEnMediosDePago)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'
	
	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasAntesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	EXEC inserciones.InsertarMediosDePago @pathCaso2
	
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasDespuesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	IF(@cantidadDeFilasAntesEnMediosDePago <> @cantidadDeFilasDespuesEnMediosDePago)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'
	
	--CASO 3: cargar archivo vacio.
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasAntesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	EXEC inserciones.InsertarMediosDePago @pathCaso3
	
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasDespuesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	IF(@cantidadDeFilasAntesEnMediosDePago <> @cantidadDeFilasDespuesEnMediosDePago)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'
END

GO

DECLARE @pathInformacionComplementaria VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\Informacion_complementaria.xlsx';
DECLARE @pathCaso2 VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\test-caso2-insert.xlsx';
DECLARE @pathCaso3 VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\test-caso3-insert.xlsx';

EXEC inserciones.TestInsertarSucursales
@pathInformacionComplementaria,
@pathCaso2,
@pathCaso3;

EXEC inserciones.TestInsertarEmpleados
@pathInformacionComplementaria, 
@pathCaso2, 
@pathCaso3;

EXEC inserciones.TestInsertarMediosDePago
@pathInformacionComplementaria, 
@pathCaso2, 
@pathCaso3;