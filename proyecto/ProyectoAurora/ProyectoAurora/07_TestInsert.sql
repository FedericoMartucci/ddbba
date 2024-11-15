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

	PRINT 'TestInsertarSucursales:';
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
		RAISERROR ('Error en SP InsertarSucursales. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasAntesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL) + 2
	SET @cantidadDeFilasAntesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO) + 2

	EXEC inserciones.InsertarSucursales @pathCaso2;

	SELECT * FROM seguridad.SUCURSAL
	SELECT * FROM seguridad.TELEFONO
	SET @cantidadDeFilasDespuesEnSucursal = (SELECT COUNT(1) FROM seguridad.SUCURSAL)
	SET @cantidadDeFilasDespuesEnTelefono = (SELECT COUNT(1) FROM seguridad.TELEFONO)
	
	IF(@cantidadDeFilasAntesEnSucursal <> @cantidadDeFilasDespuesEnSucursal OR @cantidadDeFilasAntesEnTelefono <> @cantidadDeFilasDespuesEnTelefono)
		RAISERROR ('Error en SP InsertarSucursales. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'

	DELETE FROM seguridad.SUCURSAL
	WHERE ciudad IN ('Madrid', 'Washington D. C.')
	AND reemplazar_por IN ('Laferrere','Gonzalez Catan')

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
		RAISERROR ('Error en SP InsertarSucursales. Se insertaron tuplas vacias.', 16, 1 );
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

	PRINT 'TestInsertarEmpleados:';
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
		RAISERROR ('Error en SP InsertarEmpleados. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasAntesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasAntesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO) + 2

	EXEC inserciones.InsertarEmpleados @pathCaso2;

	SELECT * FROM seguridad.CARGO
	SELECT * FROM seguridad.EMPLEADO
	SET @cantidadDeFilasDespuesEnCargo = (SELECT COUNT(1) FROM seguridad.CARGO)
	SET @cantidadDeFilasDespuesEnEmpleado = (SELECT COUNT(1) FROM seguridad.EMPLEADO)

	IF(@cantidadDeFilasAntesEnCargo <> @cantidadDeFilasDespuesEnCargo OR @cantidadDeFilasAntesEnEmpleado <> @cantidadDeFilasDespuesEnEmpleado)
		RAISERROR ('Error en SP InsertarEmpleados. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'
	
	DELETE FROM seguridad.EMPLEADO
	WHERE email_empresa IN ('AGUSTIN_BROCANI@cs.com', 'viktor2008_tuturrito@cs.com')
	AND email_personal IN ('AGUSTIN_BROCANI@gmail.com','viktor2008_tuturrito@gmail.com')
		
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
		RAISERROR ('Error en SP InsertarEmpleados. Se insertaron tuplas vacias.', 16, 1 );
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

	PRINT 'TestInsertarMediosDePago:';
	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasAntesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	EXEC inserciones.InsertarMediosDePago @pathCaso1
	
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasDespuesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	IF(@cantidadDeFilasAntesEnMediosDePago <> @cantidadDeFilasDespuesEnMediosDePago)
		RAISERROR ('Error en SP InsertarMediosDePago. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'
	
	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasAntesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	EXEC inserciones.InsertarMediosDePago @pathCaso2

	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasDespuesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	IF(@cantidadDeFilasAntesEnMediosDePago <> @cantidadDeFilasDespuesEnMediosDePago)
		RAISERROR ('Error en SP InsertarMediosDePago. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas. Error a mostrarse:'
	
	--CASO 3: cargar archivo vacio.
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasAntesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	EXEC inserciones.InsertarMediosDePago @pathCaso3
	
	SELECT * FROM transacciones.MEDIO_DE_PAGO
	SET @cantidadDeFilasDespuesEnMediosDePago = (SELECT COUNT(1) FROM transacciones.MEDIO_DE_PAGO)
	
	IF(@cantidadDeFilasAntesEnMediosDePago <> @cantidadDeFilasDespuesEnMediosDePago)
		RAISERROR ('Error en SP InsertarMediosDePago. Se insertaron tuplas vacias.', 16, 1 );
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
	
	PRINT 'TestInsertarProductosElectronicos:' + CHAR(10)
	
	--CASO 1: volver a cargar mismo archivo con tuplas extra distintas.
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
		RAISERROR ('Error en SP InsertarProductosElectronicos. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'	
	
	--CASO 2: cargar archivo vacio.
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
		RAISERROR ('Error en SP InsertarProductosElectronicos. Se insertaron tuplas vacias.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'

	PRINT CHAR(10);
END

GO

CREATE OR ALTER PROCEDURE inserciones.TestIngresarCategorias
	@pathCatalogo VARCHAR(255),
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),
	@pathCaso3 VARCHAR(255)
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnCategoria INT;
	DECLARE @cantidadDeFilasAntesEnProducto INT;
	DECLARE @cantidadDeFilasAntesEnVarios INT;
	DECLARE @cantidadDeFilasDespuesEnCategoria INT;
	DECLARE @cantidadDeFilasDespuesEnProducto INT;
	DECLARE @cantidadDeFilasDespuesEnVarios INT;
	DECLARE @todoOK VARCHAR(100) = 'SP TestIngresarCategorias funciona correctamente para el caso ';

	PRINT 'TestIngresarCategorias:' + CHAR(10)
	
	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.VARIOS
	SET @cantidadDeFilasAntesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnVarios = (SELECT COUNT(1) FROM productos.VARIOS)

	EXEC inserciones.IngresarCategorias @pathCatalogo, @pathCaso1
	
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.VARIOS

	SET @cantidadDeFilasDespuesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnVarios = (SELECT COUNT(1) FROM productos.VARIOS)

	IF(
		@cantidadDeFilasAntesEnCategoria <> @cantidadDeFilasDespuesEnCategoria OR
		@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR
		@cantidadDeFilasAntesEnVarios <> @cantidadDeFilasDespuesEnVarios
	)
		RAISERROR ('Error en SP IngresarCategorias. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.VARIOS
	SET @cantidadDeFilasAntesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnVarios = (SELECT COUNT(1) FROM productos.VARIOS)

	EXEC inserciones.IngresarCategorias @pathCatalogo, @pathCaso2

	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.VARIOS
	SET @cantidadDeFilasDespuesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnVarios = (SELECT COUNT(1) FROM productos.VARIOS)

	IF(
		@cantidadDeFilasAntesEnCategoria <> @cantidadDeFilasDespuesEnCategoria OR
		@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR
		@cantidadDeFilasAntesEnVarios <> @cantidadDeFilasDespuesEnVarios
	)
		RAISERROR ('Error en SP IngresarCategorias. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'	

	--CASO 3: cargar archivo vacio.
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.VARIOS
	SET @cantidadDeFilasAntesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnVarios = (SELECT COUNT(1) FROM productos.VARIOS)
	
	EXEC inserciones.IngresarCategorias @pathCatalogo, @pathCaso3

	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.VARIOS
	SET @cantidadDeFilasDespuesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnVarios = (SELECT COUNT(1) FROM productos.VARIOS)

	IF(
		@cantidadDeFilasAntesEnCategoria <> @cantidadDeFilasDespuesEnCategoria OR
		@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR
		@cantidadDeFilasAntesEnVarios <> @cantidadDeFilasDespuesEnVarios
	)
		RAISERROR ('Error en SP IngresarCategorias. Se insertaron tuplas vacias.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'

	PRINT CHAR(10);
END

GO

CREATE OR ALTER PROCEDURE inserciones.TestInsertarProductosImportados
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),  
	@pathCaso3 VARCHAR(255) 
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnCategoria INT;
	DECLARE @cantidadDeFilasAntesEnProducto INT;
	DECLARE @cantidadDeFilasAntesEnImportado INT;

	DECLARE @cantidadDeFilasDespuesEnCategoria INT;
	DECLARE @cantidadDeFilasDespuesEnProducto INT;
	DECLARE @cantidadDeFilasDespuesEnImportado INT;
	DECLARE @todoOK VARCHAR(100) = 'SP InsertarProductosImportados funciona correctamente para el caso ';
	
	PRINT 'TestInsertarProductosImportados:' + CHAR(10);

	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.IMPORTADO
	SET @cantidadDeFilasAntesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnImportado = (SELECT COUNT(1) FROM productos.IMPORTADO)

	EXEC inserciones.InsertarProductosImportados @pathCaso1
	
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.IMPORTADO
	SET @cantidadDeFilasDespuesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnImportado = (SELECT COUNT(1) FROM productos.IMPORTADO)

	IF(
		@cantidadDeFilasAntesEnCategoria <> @cantidadDeFilasDespuesEnCategoria OR
		@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR
		@cantidadDeFilasAntesEnImportado <> @cantidadDeFilasDespuesEnImportado
	)
		RAISERROR ('Error en SP InsertarProductosImportados. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.IMPORTADO
	SET @cantidadDeFilasAntesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnImportado = (SELECT COUNT(1) FROM productos.IMPORTADO)


	EXEC inserciones.InsertarProductosImportados @pathCaso2
	
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.IMPORTADO
	SET @cantidadDeFilasDespuesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnImportado = (SELECT COUNT(1) FROM productos.IMPORTADO)

	IF(
		@cantidadDeFilasAntesEnCategoria <> @cantidadDeFilasDespuesEnCategoria OR
		@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR
		@cantidadDeFilasAntesEnImportado <> @cantidadDeFilasDespuesEnImportado
	)
		RAISERROR ('Error en SP InsertarProductosImportados. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'	

	--CASO 3: cargar archivo vacio.
	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.IMPORTADO
	SET @cantidadDeFilasAntesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasAntesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasAntesEnImportado = (SELECT COUNT(1) FROM productos.IMPORTADO)
	
	EXEC inserciones.InsertarProductosImportados @pathCaso3

	SELECT * FROM seguridad.CATEGORIA
	SELECT * FROM productos.PRODUCTO
	SELECT * FROM productos.IMPORTADO
	SET @cantidadDeFilasDespuesEnCategoria = (SELECT COUNT(1) FROM seguridad.CATEGORIA)
	SET @cantidadDeFilasDespuesEnProducto = (SELECT COUNT(1) FROM productos.PRODUCTO)
	SET @cantidadDeFilasDespuesEnImportado = (SELECT COUNT(1) FROM productos.IMPORTADO)

	IF(
		@cantidadDeFilasAntesEnCategoria <> @cantidadDeFilasDespuesEnCategoria OR
		@cantidadDeFilasAntesEnProducto <> @cantidadDeFilasDespuesEnProducto OR
		@cantidadDeFilasAntesEnImportado <> @cantidadDeFilasDespuesEnImportado
	)
		RAISERROR ('Error en SP InsertarProductosImportados. Se insertaron tuplas vacias.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'

	PRINT CHAR(10);
END

GO

CREATE OR ALTER PROCEDURE inserciones.TestInsertarVentasRegistradas
	@pathCaso1 VARCHAR(255), 
	@pathCaso2 VARCHAR(255),  
	@pathCaso3 VARCHAR(255) 
AS
BEGIN
	DECLARE @cantidadDeFilasAntesEnTipo INT;
	DECLARE @cantidadDeFilasAntesEnCliente INT;
	DECLARE @cantidadDeFilasAntesEnFactura INT;
	DECLARE @cantidadDeFilasAntesEnVenta INT;

	DECLARE @cantidadDeFilasDespuesEnTipo INT;
	DECLARE @cantidadDeFilasDespuesEnCliente INT;
	DECLARE @cantidadDeFilasDespuesEnFactura INT;
	DECLARE @cantidadDeFilasDespuesEnVenta INT;

	DECLARE @todoOK VARCHAR(100) = 'SP InsertarVentasRegistradas funciona correctamente para el caso ';

	PRINT 'TestInsertarVentasRegistradas:' + CHAR(10);

	--CASO 1: volver a cargar mismo archivo
	SELECT * FROM seguridad.TIPO
	SELECT * FROM seguridad.CLIENTE
	SELECT * FROM transacciones.FACTURA
	SELECT * FROM transacciones.VENTA
	SET @cantidadDeFilasAntesEnTipo = (SELECT COUNT(1) FROM seguridad.TIPO)
	SET @cantidadDeFilasAntesEnCliente = (SELECT COUNT(1) FROM seguridad.CLIENTE)
	SET @cantidadDeFilasAntesEnFactura = (SELECT COUNT(1) FROM transacciones.FACTURA)
	SET @cantidadDeFilasAntesEnVenta = (SELECT COUNT(1) FROM transacciones.VENTA)

	EXEC inserciones.InsertarVentasRegistradas @pathCaso1

	SELECT * FROM seguridad.TIPO
	SELECT * FROM seguridad.CLIENTE
	SELECT * FROM transacciones.FACTURA
	SELECT * FROM transacciones.VENTA
	SET @cantidadDeFilasDespuesEnTipo = (SELECT COUNT(1) FROM seguridad.TIPO)
	SET @cantidadDeFilasDespuesEnCliente = (SELECT COUNT(1) FROM seguridad.CLIENTE)
	SET @cantidadDeFilasDespuesEnFactura = (SELECT COUNT(1) FROM transacciones.FACTURA)
	SET @cantidadDeFilasDespuesEnVenta = (SELECT COUNT(1) FROM transacciones.VENTA)

	IF(
		@cantidadDeFilasAntesEnTipo <> @cantidadDeFilasDespuesEnTipo OR
		@cantidadDeFilasAntesEnCliente <> @cantidadDeFilasDespuesEnCliente OR
		@cantidadDeFilasAntesEnFactura <> @cantidadDeFilasDespuesEnFactura OR
		@cantidadDeFilasAntesEnVenta <> @cantidadDeFilasDespuesEnVenta
	)
	BEGIN
		RAISERROR ('Error en SP InsertarVentasRegistradas. Se cargaron registros duplicados.', 16, 1 );
	END
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo.'

	--CASO 2: volver a cargar mismo archivo con tuplas extra distintas.
	SELECT * FROM seguridad.TIPO
	SELECT * FROM seguridad.CLIENTE
	SELECT * FROM transacciones.FACTURA
	SELECT * FROM transacciones.VENTA
	SET @cantidadDeFilasAntesEnTipo = (SELECT COUNT(1) FROM seguridad.TIPO)
	SET @cantidadDeFilasAntesEnCliente = (SELECT COUNT(1) FROM seguridad.CLIENTE)
	SET @cantidadDeFilasAntesEnFactura = (SELECT COUNT(1) FROM transacciones.FACTURA)
	SET @cantidadDeFilasAntesEnVenta = (SELECT COUNT(1) FROM transacciones.VENTA)

	EXEC inserciones.InsertarVentasRegistradas @pathCaso2
	
	SELECT * FROM seguridad.TIPO
	SELECT * FROM seguridad.CLIENTE
	SELECT * FROM transacciones.FACTURA
	SELECT * FROM transacciones.VENTA
	SET @cantidadDeFilasDespuesEnTipo = (SELECT COUNT(1) FROM seguridad.TIPO)
	SET @cantidadDeFilasDespuesEnCliente = (SELECT COUNT(1) FROM seguridad.CLIENTE)
	SET @cantidadDeFilasDespuesEnFactura = (SELECT COUNT(1) FROM transacciones.FACTURA)
	SET @cantidadDeFilasDespuesEnVenta = (SELECT COUNT(1) FROM transacciones.VENTA)

	IF(
		@cantidadDeFilasAntesEnTipo <> @cantidadDeFilasDespuesEnTipo OR
		@cantidadDeFilasAntesEnCliente <> @cantidadDeFilasDespuesEnCliente OR
		@cantidadDeFilasAntesEnFactura <> @cantidadDeFilasDespuesEnFactura OR
		@cantidadDeFilasAntesEnVenta <> @cantidadDeFilasDespuesEnVenta
	)
		RAISERROR ('Error en SP InsertarVentasRegistradas. Se cargaron registros duplicados.', 16, 1 );
	ELSE
		PRINT @todoOK + 'volver a cargar mismo archivo con tuplas extra distintas.'	

	--CASO 3: cargar archivo vacio.
	SELECT * FROM seguridad.TIPO
	SELECT * FROM seguridad.CLIENTE
	SELECT * FROM transacciones.FACTURA
	SELECT * FROM transacciones.VENTA
	SET @cantidadDeFilasAntesEnTipo = (SELECT COUNT(1) FROM seguridad.TIPO)
	SET @cantidadDeFilasAntesEnCliente = (SELECT COUNT(1) FROM seguridad.CLIENTE)
	SET @cantidadDeFilasAntesEnFactura = (SELECT COUNT(1) FROM transacciones.FACTURA)
	SET @cantidadDeFilasAntesEnVenta = (SELECT COUNT(1) FROM transacciones.VENTA)

	EXEC inserciones.InsertarVentasRegistradas @pathCaso3

	SELECT * FROM seguridad.TIPO
	SELECT * FROM seguridad.CLIENTE
	SELECT * FROM transacciones.FACTURA
	SELECT * FROM transacciones.VENTA
	SET @cantidadDeFilasDespuesEnTipo = (SELECT COUNT(1) FROM seguridad.TIPO)
	SET @cantidadDeFilasDespuesEnCliente = (SELECT COUNT(1) FROM seguridad.CLIENTE)
	SET @cantidadDeFilasDespuesEnFactura = (SELECT COUNT(1) FROM transacciones.FACTURA)
	SET @cantidadDeFilasDespuesEnVenta = (SELECT COUNT(1) FROM transacciones.VENTA)

	IF(
		@cantidadDeFilasAntesEnTipo <> @cantidadDeFilasDespuesEnTipo OR
		@cantidadDeFilasAntesEnCliente <> @cantidadDeFilasDespuesEnCliente OR
		@cantidadDeFilasAntesEnFactura <> @cantidadDeFilasDespuesEnFactura OR
		@cantidadDeFilasAntesEnVenta <> @cantidadDeFilasDespuesEnVenta
	)
		RAISERROR ('Error en SP InsertarVentasRegistradas. Se insertaron tuplas vacias.', 16, 1 );
	ELSE
		PRINT @todoOK + 'cargar archivo vacio.'

	PRINT CHAR(10);
END

GO

DECLARE @pathInformacionComplementaria VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Informacion_complementaria.xlsx';
DECLARE @pathCaso2 VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\test-caso2-insert.xlsx';
DECLARE @pathCaso3 VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\test-caso3-insert.xlsx';

DECLARE @pathProductosImportados VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Productos_importados.xlsx'
DECLARE @pathCaso2PI VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\test-caso2-insertProductosImportados.xlsx';
DECLARE @pathCaso3PI VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\test-caso3-insertProductosImportados.xlsx';

DECLARE @pathVentasRegistradas VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Ventas_registradas.csv'
DECLARE @pathCaso2VR VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\test-caso2-insertVentasRegistradas.csv';
DECLARE @pathCaso3VR VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\test-caso3-insertVentasRegistradas.csv';

DECLARE @pathProductosElectronicos VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Electronic accessories.xlsx';
DECLARE @pathCatalogo VARCHAR(255) = 'C:\Users\User\Desktop\ddbba';

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

/*ERROR A CORREGIR: INSERTA DUPLICADOS*/
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

EXEC inserciones.TestIngresarCategorias
@pathCatalogo,
@pathInformacionComplementaria,
@pathCaso2,
@pathCaso3

EXEC inserciones.TestInsertarProductosImportados
@pathProductosImportados,
@pathCaso2PI,
@pathCaso3PI

EXEC inserciones.TestInsertarVentasRegistradas
@pathVentasRegistradas,
@pathCaso2VR,
@pathCaso3VR