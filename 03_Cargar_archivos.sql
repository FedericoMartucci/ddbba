--CARGAMOS TODOS LOS DATOS DE LOS ARCHIVOS Y MOSTRAMOS

USE Com5600G08

DECLARE @pathVentasRegistradas VARCHAR(255) = 'C:\importar\';
DECLARE @pathInformacionComplementaria VARCHAR(255) = 'C:\importar\Informacion_complementaria.xlsx';
DECLARE @pathCatalogo VARCHAR(255) = 'C:\importar\';
DECLARE @pathProductosElectronicos VARCHAR(255) = 'C:\importar\Electronic accessories.xlsx';
DECLARE @pathProductosImportados VARCHAR(255) = 'C:\importar\Productos_importados.xlsx';

EXEC InsertarSucursales @pathInformacionComplementaria;
EXEC InsertarEmpleados @pathInformacionComplementaria;
EXEC InsertarMediosDePago @pathInformacionComplementaria;
EXEC InsertarProductosElectronicos @pathProductosElectronicos
BEGIN TRY
EXEC IngresarCategorias @pathCatalogo, @pathInformacionComplementaria
END TRY
BEGIN CATCH
	PRINT 'ERROR: ' + ERROR_MESSAGE()
END CATCH
EXEC InsertarProductosImportados @pathProductosImportados
EXEC InsertarVentasRegistradas @pathVentasRegistradas
GO

SELECT * FROM aurora.SUCURSAL
GO

SELECT * FROM aurora.TELEFONO
GO

SELECT * FROM aurora.CARGO
GO

SELECT * FROM aurora.EMPLEADO
GO

SELECT * FROM aurora.MEDIO_DE_PAGO
GO

SELECT * FROM aurora.CATEGORIA
GO

SELECT * FROM aurora.PRODUCTO
GO

SELECT * FROM aurora.VARIOS
GO

SELECT * FROM aurora.ELECTRONICO
GO

SELECT * FROM aurora.IMPORTADO
GO

SELECT * FROM aurora.FACTURA
GO

SELECT * FROM aurora.VENTA
GO

use clase_2
/*
USE master
GO

DROP DATABASE Com5600G08
GO
*/