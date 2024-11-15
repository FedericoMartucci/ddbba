/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 2											#
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

--CREAMOS SCHEMA PARA ACTUALIZACIONES
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'actualizaciones')
    EXEC('CREATE SCHEMA actualizaciones');
GO

SET NOCOUNT ON;
GO

-- Stored Procedure para actualizar la tabla CARGO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarCargo
    @id INT,
    @nombre VARCHAR(100) = NULL
AS
BEGIN
    UPDATE seguridad.CARGO
    SET nombre = COALESCE(@nombre, nombre)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla CLIENTE
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarCliente
    @id INT,
    @genero VARCHAR(6) = NULL,
    @id_tipo INT = NULL
AS
BEGIN
    UPDATE seguridad.CLIENTE
    SET 
        genero = COALESCE(@genero, genero),
        id_tipo = COALESCE(@id_tipo, id_tipo)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla CATEGORIA
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarCategoria
    @id INT,
    @descripcion VARCHAR(50) = NULL,
    @es_valido INT = NULL
AS
BEGIN
    UPDATE seguridad.CATEGORIA
    SET 
        descripcion = COALESCE(@descripcion, descripcion),
        es_valido = COALESCE(@es_valido, es_valido)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla SUCURSAL
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarSucursal
    @id INT,
    @horario VARCHAR(50) = NULL,
    @ciudad VARCHAR(50) = NULL,
    @reemplazar_por VARCHAR(255) = NULL,
    @direccion VARCHAR(50) = NULL,
    @codigo_postal CHAR(5) = NULL,
    @provincia VARCHAR(50) = NULL
AS
BEGIN
    UPDATE seguridad.SUCURSAL
    SET 
        horario = COALESCE(@horario, horario),
        ciudad = COALESCE(@ciudad, ciudad),
        reemplazar_por = COALESCE(@reemplazar_por, reemplazar_por),
        direccion = COALESCE(@direccion, direccion),
        codigo_postal = COALESCE(@codigo_postal, codigo_postal),
        provincia = COALESCE(@provincia, provincia)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla TELEFONO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarTelefono
    @id_sucursal INT,
    @telefono CHAR(9) = NULL
AS
BEGIN
    UPDATE seguridad.TELEFONO
    SET telefono = COALESCE(@telefono, telefono)
    WHERE id_sucursal = @id_sucursal;
END;
GO

-- Stored Procedure para actualizar la tabla EMPLEADO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarEmpleado
	@id_empleado INT,
    @legajo INT = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
	@dni VARBINARY(256) = NULL,
    @direccion VARBINARY(512) = NULL,
    @email_empresa VARBINARY(512) = NULL,
    @email_personal VARBINARY(512) = NULL,
    @CUIL VARBINARY(256) = NULL,
    @id_cargo INT = NULL,
    @id_sucursal INT = NULL,
    @turno VARCHAR(50) = NULL,
    @es_valido INT = NULL
AS
BEGIN
    -- Actualiza la tabla con los valores proporcionados
    UPDATE seguridad.EMPLEADO
    SET 
        legajo = COALESCE(@legajo, legajo),
        nombre = COALESCE(@nombre, nombre),
        apellido = COALESCE(@apellido, apellido),
        dni = COALESCE(@dni,dni),
        direccion = COALESCE(@direccion,direccion),
        email_empresa = COALESCE(@email_empresa,email_empresa),
        email_personal = COALESCE(@email_personal, email_personal),
        CUIL = COALESCE(@CUIL, CUIL),
        id_cargo = COALESCE(@id_cargo, id_cargo),
        id_sucursal = COALESCE(@id_sucursal, id_sucursal),
        turno = COALESCE(@turno, turno),
        es_valido = COALESCE(@es_valido, es_valido)
    WHERE id_empleado = @id_empleado;
END;
GO

-- Stored Procedure para actualizar la tabla PRODUCTO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarProducto
    @id_producto INT,
    @precio_unidad DECIMAL(10, 2) = NULL,
    @nombre_producto VARCHAR(100) = NULL,
    @id_categoria INT = NULL,
    @fecha_eliminacion DATE = NULL,
    @es_valido INT = NULL
AS
BEGIN
    UPDATE productos.PRODUCTO
    SET 
        precio_unidad = COALESCE(@precio_unidad, precio_unidad),
        nombre_producto = COALESCE(@nombre_producto, nombre_producto),
        id_categoria = COALESCE(@id_categoria, id_categoria),
        fecha_eliminacion = COALESCE(@fecha_eliminacion, fecha_eliminacion),
        es_valido = COALESCE(@es_valido, es_valido)
    WHERE id_producto = @id_producto;
END;
GO

-- Stored Procedure para actualizar la tabla FACTURA
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarFactura
    @id_factura INT,
    @id CHAR(11) = NULL,
    @tipo_de_factura CHAR = NULL,
    @estado BIT = NULL
AS
BEGIN
    UPDATE transacciones.FACTURA
    SET 
        tipo_de_factura = COALESCE(@tipo_de_factura, tipo_de_factura),
        estado = COALESCE(@estado, estado)
    WHERE id_factura = @id_factura;
END;
GO

-- Stored Procedure para actualizar la tabla NOTA_CREDITO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarNotaCredito
    @id INT,
    @monto DECIMAL(10, 2) = NULL,
    @id_factura CHAR(11) = NULL
AS
BEGIN
    UPDATE transacciones.NOTA_CREDITO
    SET 
        monto = COALESCE(@monto, monto),
        id_factura = COALESCE(@id_factura, id_factura)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla MEDIO_DE_PAGO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarMedioDePago
    @id INT,
    @descripcion_ingles VARCHAR(50) = NULL,
    @descripcion VARCHAR(50) = NULL
AS
BEGIN
    UPDATE transacciones.MEDIO_DE_PAGO
    SET 
        descripcion_ingles = COALESCE(@descripcion_ingles, descripcion_ingles),
        descripcion = COALESCE(@descripcion, descripcion)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla VENTA
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarVenta
    @id INT,
    @id_factura CHAR(11) = NULL,
    @id_sucursal INT = NULL,
    @id_producto INT = NULL,
    @cantidad SMALLINT = NULL,
    @fecha DATE = NULL,
    @hora TIME(0) = NULL,
    @id_medio_de_pago INT = NULL,
    @id_empleado INT = NULL,
    @identificador_de_pago VARCHAR(22) = NULL
AS
BEGIN
    UPDATE transacciones.VENTA
    SET 
        id_factura = COALESCE(@id_factura, id_factura),
        id_sucursal = COALESCE(@id_sucursal, id_sucursal),
        id_producto = COALESCE(@id_producto, id_producto),
        cantidad = COALESCE(@cantidad, cantidad),
        fecha = COALESCE(@fecha, fecha),
        hora = COALESCE(@hora, hora),
        id_medio_de_pago = COALESCE(@id_medio_de_pago, id_medio_de_pago),
        id_empleado = COALESCE(@id_empleado, id_empleado),
        identificador_de_pago = COALESCE(@identificador_de_pago, identificador_de_pago)
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla IMPORTADO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarImportado
    @id_producto INT,
    @proveedor VARCHAR(255) = NULL,
    @cantidad_por_unidad VARCHAR(255) = NULL
AS
BEGIN
    UPDATE productos.IMPORTADO
    SET 
        proveedor = COALESCE(@proveedor, proveedor),
        cantidad_por_unidad = COALESCE(@cantidad_por_unidad, cantidad_por_unidad)
    WHERE id_producto = @id_producto;
END;
GO

-- Stored Procedure para actualizar la tabla VARIOS
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarVarios
    @id_producto INT,
    @fecha DATE = NULL,
    @hora TIME(0) = NULL,
    @unidad_de_referencia VARCHAR(50) = NULL
AS
BEGIN
    UPDATE productos.VARIOS
    SET 
        fecha = COALESCE(@fecha, fecha),
        hora = COALESCE(@hora, hora),
        unidad_de_referencia = COALESCE(@unidad_de_referencia, unidad_de_referencia)
    WHERE id_producto = @id_producto;
END;
GO

-- Stored Procedure para actualizar la tabla ELECTRONICO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarElectronico
    @id_producto INT,
    @precio_unidad_en_dolares DECIMAL(10, 2) = NULL
AS
BEGIN
    UPDATE productos.ELECTRONICO
    SET 
        precio_unidad_en_dolares = COALESCE(@precio_unidad_en_dolares, precio_unidad_en_dolares)
    WHERE id_producto = @id_producto;
END;
GO

CREATE OR ALTER PROCEDURE actualizaciones.ActualizarTipo
	@id INT,
	@nombre VARCHAR(50)
AS
BEGIN

	UPDATE seguridad.TIPO 
	SET nombre = @nombre
	WHERE id = @id;
END;
GO



