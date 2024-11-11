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
	DECLARE @todoOK VARCHAR(100) = 'SP InsertarSucursales funciona correctamente para el caso ';

	print 'TestInsertarSucursales:';
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

	PRINT CHAR(10);
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
	DECLARE @todoOK VARCHAR(100) = 'SP InsertarEmpleados funciona correctamente para el caso ';

	print 'TestInsertarEmpleados:';
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

	PRINT CHAR(10);
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
	DECLARE @todoOK VARCHAR(100) = 'SP InsertarMediosDePago funciona correctamente para el caso ';

	print 'TestInsertarMediosDePago:';
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

		PRINT CHAR(10);
END

GO

CREATE OR ALTER PROCEDURE inserciones.TestInsertarProductosElectronicos
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),  
	@pathCaso3 VARCHAR(255) 
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnProducto INT;
	DECLARE @cantidadDeFilasAntesEnElectronico INT;
	DECLARE @cantidadDeFilasDespuesEnProducto INT;
	DECLARE @cantidadDeFilasDespuesEnElectronico INT;
	DECLARE @todoOK VARCHAR(100) = 'SP InsertarProductosElectronicos funciona correctamente para el caso ';
	
	print 'TestInsertarProductosElectronicos:' + CHAR(10)
	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.ELECTRONICO
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnElectronico = (SELECT COUNT(1) FROM productos.ELECTRONICO)

	EXEC inserciones.InsertarProductosElectronicos @pathCaso1;
	
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.ELECTRONICO
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnElectronico = (SELECT COUNT(1) FROM productos.ELECTRONICO)

	IF(@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR @cantidadDeFilasAntesEnElectronico <> @cantidadDeFilasDespuesEnElectronico)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'
	
	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.ELECTRONICO
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnElectronico = (SELECT COUNT(1) FROM productos.ELECTRONICO)

	EXEC inserciones.InsertarProductosElectronicos @pathCaso2;
	
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.ELECTRONICO
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnElectronico = (SELECT COUNT(1) FROM productos.ELECTRONICO)

	IF(@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR @cantidadDeFilasAntesEnElectronico <> @cantidadDeFilasDespuesEnElectronico)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'	
	
	--CASO 3: cargar archivo vacio.
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.ELECTRONICO
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnElectronico = (SELECT COUNT(1) FROM productos.ELECTRONICO)

	EXEC inserciones.InsertarProductosElectronicos @pathCaso3;
	
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.ELECTRONICO
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnElectronico = (SELECT COUNT(1) FROM productos.ELECTRONICO)

	IF(@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR @cantidadDeFilasAntesEnElectronico <> @cantidadDeFilasDespuesEnElectronico)
		RAISERROR ('Error raised in TRY block.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'


	PRINT CHAR(10);
END

GO

DECLARE @pathInformacionComplementaria VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\Informacion_complementaria.xlsx';
DECLARE @pathCaso2 VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\test-caso2-insert.xlsx';
DECLARE @pathCaso3 VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\test-caso3-insert.xlsx';
DECLARE @pathProductosElectronicos VARCHAR(255) = 'C:\Users\PC\Desktop\ddbba\Electronic accessories.xlsx';

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

EXEC inserciones.TestInsertarProductosElectronicos 
@pathProductosElectronicos, 
NULL,
NULL;
--ERROR en InsertarProductosElectronicos -> ADMITE DUPLICADOS: Analizar id_producto
	SELECT nombre_producto, id_categoria, COUNT(1) 
	FROM productos.PRODUCTO GROUP BY nombre_producto, id_categoria
	HAVING COUNT(1) > 1

	SELECT * FROM productos.PRODUCTO
	WHERE nombre_producto = '20in Monitor'