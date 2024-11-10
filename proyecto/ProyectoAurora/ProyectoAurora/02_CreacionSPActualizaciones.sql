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

-- Stored Procedure para actualizar la tabla CARGO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarCargo
    @id INT,
    @nombre VARCHAR(100)
AS
BEGIN
    UPDATE seguridad.CARGO
    SET nombre = @nombre
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla CLIENTE
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarCliente
    @id INT,
    @genero VARCHAR(6),
    @id_tipo INT
AS
BEGIN
    UPDATE seguridad.CLIENTE
    SET genero = @genero,
        id_tipo = @id_tipo
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla CATEGORIA
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarCategoria
    @id INT,
    @descripcion VARCHAR(50),
    @esValido INT
AS
BEGIN
    UPDATE seguridad.CATEGORIA
    SET descripcion = @descripcion,
        esValido = @esValido
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla SUCURSAL
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarSucursal
    @id INT,
    @horario VARCHAR(50),
    @ciudad VARCHAR(50),
    @reemplazar_por VARCHAR(255),
    @direccion VARCHAR(50),
    @codigo_postal CHAR(5),
    @provincia VARCHAR(50)
AS
BEGIN
    UPDATE seguridad.SUCURSAL
    SET horario = @horario,
        ciudad = @ciudad,
        reemplazar_por = @reemplazar_por,
        direccion = @direccion,
        codigo_postal = @codigo_postal,
        provincia = @provincia
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla TELEFONO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarTelefono
    @id_sucursal INT,
    @telefono CHAR(9)
AS
BEGIN
    UPDATE seguridad.TELEFONO
    SET telefono = @telefono
    WHERE id_sucursal = @id_sucursal;
END;
GO

-- Stored Procedure para actualizar la tabla EMPLEADO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarEmpleado
    @legajo INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @direccion VARCHAR(150),
    @email_empresa VARCHAR(100),
    @email_personal VARCHAR(100),
    @CUIL CHAR(11),
    @id_cargo INT,
    @id_sucursal INT,
    @turno VARCHAR(50),
    @esValido INT
AS
BEGIN
    UPDATE seguridad.EMPLEADO
    SET nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        direccion = @direccion,
        email_empresa = @email_empresa,
        email_personal = @email_personal,
        CUIL = @CUIL,
        id_cargo = @id_cargo,
        id_sucursal = @id_sucursal,
        turno = @turno,
        esValido = @esValido
    WHERE legajo = @legajo;
END;
GO

-- Stored Procedure para actualizar la tabla PRODUCTO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarProducto
    @id_producto INT,
    @precio_unidad DECIMAL(10, 2),
    @nombre_producto VARCHAR(100),
    @id_categoria INT,
    @fecha_eliminacion DATE,
    @esValido INT
AS
BEGIN
    UPDATE productos.PRODUCTO
    SET precio_unidad = @precio_unidad,
        nombre_producto = @nombre_producto,
        id_categoria = @id_categoria,
        fecha_eliminacion = @fecha_eliminacion,
        esValido = @esValido
    WHERE id_producto = @id_producto;
END;
GO

-- Stored Procedure para actualizar la tabla FACTURA
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarFactura
    @id CHAR(11),
    @tipo_de_factura CHAR,
    @estado BIT
AS
BEGIN
    UPDATE transacciones.FACTURA
    SET tipo_de_factura = @tipo_de_factura,
        estado = @estado
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla NOTA_CREDITO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarNotaCredito
    @id INT,
    @monto DECIMAL(10, 2),
    @id_factura CHAR(11)
AS
BEGIN
    UPDATE transacciones.NOTA_CREDITO
    SET monto = @monto,
        id_factura = @id_factura
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla MEDIO_DE_PAGO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarMedioDePago
    @id INT,
    @descripcion_ingles VARCHAR(50),
    @descripcion VARCHAR(50)
AS
BEGIN
    UPDATE transacciones.MEDIO_DE_PAGO
    SET descripcion_ingles = @descripcion_ingles,
        descripcion = @descripcion
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla VENTA
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarVenta
    @id INT,
    @id_factura CHAR(11),
    @id_sucursal INT,
    @id_producto INT,
    @cantidad SMALLINT,
    @fecha DATE,
    @hora TIME(0),
    @id_medio_de_pago INT,
    @legajo INT,
    @identificador_de_pago VARCHAR(22)
AS
BEGIN
    UPDATE transacciones.VENTA
    SET id_factura = @id_factura,
        id_sucursal = @id_sucursal,
        id_producto = @id_producto,
        cantidad = @cantidad,
        fecha = @fecha,
        hora = @hora,
        id_medio_de_pago = @id_medio_de_pago,
        legajo = @legajo,
        identificador_de_pago = @identificador_de_pago
    WHERE id = @id;
END;
GO

-- Stored Procedure para actualizar la tabla IMPORTADO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarImportado
    @id_producto INT,
    @proveedor VARCHAR(255),
    @cantidad_por_unidad VARCHAR(255)
AS
BEGIN
    UPDATE productos.IMPORTADO
    SET proveedor = @proveedor,
        cantidad_por_unidad = @cantidad_por_unidad
    WHERE id_producto = @id_producto;
END;
GO

-- Stored Procedure para actualizar la tabla VARIOS
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarVarios
    @id_producto INT,
    @fecha DATE,
    @hora TIME(0),
    @unidad_de_referencia VARCHAR(50)
AS
BEGIN
    UPDATE productos.VARIOS
    SET fecha = @fecha,
        hora = @hora,
        unidad_de_referencia = @unidad_de_referencia
    WHERE id_producto = @id_producto;
END;
GO

-- Stored Procedure para actualizar la tabla ELECTRONICO
CREATE OR ALTER PROCEDURE actualizaciones.ActualizarElectronico
    @id_producto INT,
    @precio_unidad_en_dolares DECIMAL(10, 2)
AS
BEGIN
    UPDATE productos.ELECTRONICO
    SET precio_unidad_en_dolares = @precio_unidad_en_dolares
    WHERE id_producto = @id_producto;
END;
GO

