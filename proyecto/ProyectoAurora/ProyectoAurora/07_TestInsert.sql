USE Com5600G08
GO
SET NOCOUNT ON

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

EXEC inserciones.TestInsertarSucursales
'C:\Users\PC\Desktop\ddbba\Informacion_complementaria.xlsx',
'C:\Users\PC\Desktop\ddbba\test_sucursal1.xlsx',
'C:\Users\PC\Desktop\ddbba\test_sucursal2.xlsx'