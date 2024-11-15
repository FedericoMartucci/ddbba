/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 4											#
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
--CARGAMOS TODOS LOS DATOS DE LOS ARCHIVOS Y MOSTRAMOS
USE Com5600G08

DECLARE @pathVentasRegistradas VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Ventas_registradas.csv';
DECLARE @pathInformacionComplementaria VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Informacion_complementaria.xlsx';
DECLARE @pathCatalogo VARCHAR(255) = 'C:\Users\User\Desktop\ddbba';
DECLARE @pathProductosElectronicos VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Electronic accessories.xlsx';
DECLARE @pathProductosImportados VARCHAR(255) = 'C:\Users\User\Desktop\ddbba\Productos_importados.xlsx'

EXEC inserciones.InsertarSucursales @pathInformacionComplementaria;
EXEC inserciones.InsertarEmpleados @pathInformacionComplementaria;
EXEC inserciones.InsertarMediosDePago @pathInformacionComplementaria;
EXEC inserciones.InsertarProductosElectronicos @pathProductosElectronicos
EXEC inserciones.IngresarCategorias @pathCatalogo, @pathInformacionComplementaria
EXEC inserciones.InsertarProductosImportados @pathProductosImportados
EXEC inserciones.InsertarVentasRegistradas @pathVentasRegistradas
GO

SELECT * FROM seguridad.SUCURSAL
GO

SELECT * FROM seguridad.TELEFONO
GO

SELECT * FROM seguridad.CARGO
GO

SELECT * FROM seguridad.EMPLEADO
GO

SELECT * FROM transacciones.MEDIO_DE_PAGO
GO

SELECT * FROM seguridad.CATEGORIA
GO

SELECT * FROM productos.PRODUCTO
GO

SELECT * FROM productos.VARIOS
GO

SELECT * FROM productos.ELECTRONICO
GO

SELECT * FROM productos.IMPORTADO
GO

SELECT * FROM transacciones.FACTURA
GO

SELECT * FROM transacciones.VENTA
GO

SELECT * FROM transacciones.NOTA_CREDITO
GO