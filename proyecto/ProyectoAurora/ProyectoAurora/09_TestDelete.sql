/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 9											#
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

SET NOCOUNT ON;

GO

-- TEST BORRADO LOGICO EN CASCADA DE CATEGORIA -> PRODUCTO -> IMPORTADO

CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaImportadoLogico
AS
BEGIN

    DECLARE @esValidoCategoria INT;
    DECLARE @esValidoProducto1 INT;
    DECLARE @esValidoImportado INT;
    DECLARE @id_categoria INT;
	DECLARE @id_producto INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (precio_unidad,	nombre_producto, id_categoria, esValido)
    VALUES (100,  'Nombre prueba', @id_categoria, 1);

	SET @id_producto = SCOPE_IDENTITY();

    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, esValido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);
	
	SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
	SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
	SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR CATEGORIA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoCategoria = esValido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@esValidoCategoria = 0)
        PRINT 'Categoría eliminada de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar categoría de forma lógica.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE

    SELECT @esValidoProducto1 = esValido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;

    IF (@esValidoProducto1 = 0)
        PRINT 'Productos de esa categoría eliminados de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar productos de esa categoría de forma lógica.';

    -- COMPRUEBO SI LOS IMPORTADOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
	
	SELECT @esValidoImportado = esValido FROM productos.IMPORTADO WHERE id_producto = @id_producto;
	
	IF (@esValidoImportado = 0)
        PRINT 'Productos importados de esa categoría eliminados de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar productos importados de esa categoría.';

	SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
	SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
	SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;

END;
GO

-- EJECUTO EL TEST

EXEC borrado.TestEliminarCategoriaHastaImportadoLogico;
GO


-- TEST BORRADO LOGICO EN CASCADA DE CATEGORIA -> PRODUCTO -> ELECTRONICO

CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaElectronicoLogico
AS
BEGIN

    DECLARE @esValidoCategoria INT;
    DECLARE @esValidoProducto1 INT;
    DECLARE @esValidoElectronico INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES 
        (100,  'Nombre prueba', @id_categoria, 1);

    SET @id_producto = SCOPE_IDENTITY();

    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, esValido)
    VALUES (@id_producto, 20.00, 1);
    
    -- MUESTRO LOS DATOS INSERTADOS
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR CATEGORIA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoCategoria = esValido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@esValidoCategoria = 0)
        PRINT 'Categoría eliminada de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar categoría de forma lógica.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoProducto1 = esValido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;

    IF (@esValidoProducto1 = 0)
        PRINT 'Productos de esa categoría eliminados de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar productos de esa categoría de forma lógica.';

    -- COMPRUEBO SI LOS ELECTRONICOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoElectronico = esValido FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    
    IF (@esValidoElectronico = 0)
        PRINT 'Productos electrónicos de esa categoría eliminados de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar productos electrónicos de esa categoría.';

    -- MUESTRO LOS DATOS POSTERIORES AL BORRADO LÓGICO
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarCategoriaHastaElectronicoLogico;
GO

-- TEST BORRADO LOGICO EN CASCADA DE CATEGORIA -> PRODUCTO -> VARIOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaVariosLogico
AS
BEGIN

    DECLARE @esValidoCategoria INT;
    DECLARE @esValidoProducto1 INT;
    DECLARE @esValidoVarios INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES 
        (100,  'Nombre prueba', @id_categoria, 1);

    SET @id_producto = SCOPE_IDENTITY();

    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, esValido)
    VALUES (@id_producto, GETDATE(), GETDATE(), 'Unidad de prueba', 1);
    
    -- MUESTRO LOS DATOS INSERTADOS
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR CATEGORIA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoCategoria = esValido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@esValidoCategoria = 0)
        PRINT 'Categoría eliminada de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar categoría de forma lógica.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoProducto1 = esValido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;

    IF (@esValidoProducto1 = 0)
        PRINT 'Productos de esa categoría eliminados de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar productos de esa categoría de forma lógica.';

    -- COMPRUEBO SI LOS VARIOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoVarios = esValido FROM productos.VARIOS WHERE id_producto = @id_producto;
    
    IF (@esValidoVarios = 0)
        PRINT 'Productos varios de esa categoría eliminados de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar productos varios de esa categoría.';

    -- MUESTRO LOS DATOS POSTERIORES AL BORRADO LÓGICO
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;

END;
GO

-- EJECUCTO EL TEST
EXEC borrado.TestEliminarCategoriaHastaVariosLogico;


-- TEST BORRADO LOGICO EN CASCADA DE PRODUCTO -> IMPORTADO
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaImportadoLogico
AS
BEGIN

    DECLARE @esValidoProducto INT;
    DECLARE @esValidoImportado INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA IMPORTADO
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, esValido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);
    
    -- MUESTRO LOS DATOS INSERTADOS
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR PRODUCTO (PASANDO EL ID DE CATEGORÍA COMO PARÁMETRO)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- COMPRUEBO SI EL PRODUCTO SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoProducto = esValido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@esValidoProducto = 0)
        PRINT 'Producto eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar producto de forma lógica.';

    -- COMPRUEBO SI LOS IMPORTADOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoImportado = esValido FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    
    IF (@esValidoImportado = 0)
        PRINT 'Producto importado eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar producto importado de forma lógica.';

    -- MUESTRO LOS DATOS POSTERIORES AL BORRADO LÓGICO
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarProductoHastaImportadoLogico;


-- TEST BORRADO LOGICO EN CASCADA DE PRODUCTO -> ELECTRONICO
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaElectronicoLogico
AS
BEGIN

    DECLARE @esValidoProducto INT;
    DECLARE @esValidoElectronico INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA ELECTRONICO
    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, esValido)
    VALUES (@id_producto, 50, 1);
    
    -- MUESTRA LOS DATOS INSERTADOS
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR PRODUCTO (PASANDO EL ID DE CATEGORÍA COMO PARÁMETRO)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- COMPRUEBO SI EL PRODUCTO SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoProducto = esValido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@esValidoProducto = 0)
        PRINT 'Producto eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar producto de forma lógica.';

    -- COMPRUEBO SI LOS ELECTRONICOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoElectronico = esValido FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    
    IF (@esValidoElectronico = 0)
        PRINT 'Producto electrónico eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar producto electrónico de forma lógica.';

    -- MUESTRO LOS DATOS POSTERIORES AL BORRADO LÓGICO
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarProductoHastaElectronicoLogico;

-- TEST BORRADO LOGICO EN CASCADA DE PRODUCTO -> VARIOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaVariosLogico
AS
BEGIN

    DECLARE @esValidoProducto INT;
    DECLARE @esValidoVarios INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA VARIOS
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, esValido)
    VALUES (@id_producto, '2024-11-12', '10:00:00', 'Unidad de prueba', 1);
    
    -- MUESTRA LOS DATOS INSERTADOS
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR PRODUCTO (PASANDO EL ID DE CATEGORÍA COMO PARÁMETRO)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- COMPRUEBO SI EL PRODUCTO SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoProducto = esValido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@esValidoProducto = 0)
        PRINT 'Producto eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar producto de forma lógica.';

    -- COMPRUEBO SI LOS VARIOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @esValidoVarios = esValido FROM productos.VARIOS WHERE id_producto = @id_producto;
    
    IF (@esValidoVarios = 0)
        PRINT 'Producto eliminado de la tabla VARIOS forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar producto de la tabla VARIOS de forma lógica.';

    -- MUESTRO LOS DATOS POSTERIORES AL BORRADO LÓGICO
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarProductoHastaVariosLogico;

GO


-- TEST BORRADO LOGICO DE VARIOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarVariosLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_varios INT;

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA VARIOS
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, esValido)
    VALUES (@id_producto, '2024-11-12', '12:00:00', 'Unidad prueba', 1);

    -- OBTENGO EL ID DEL VARIOS INSERTADO
    SET @id_varios = SCOPE_IDENTITY();

    -- MUESTRO LOS DATOS DEL VARIOS ANTES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO PARA ELIMINAR LOGICAMENTE EL VARIOS
    EXEC borrado.EliminarVariosLogico @id_producto;

    -- VERIFICO SI LA ELIMINACION LOGICA FUE EXITOSA
    IF EXISTS (SELECT 1 FROM productos.VARIOS WHERE id_producto = @id_producto AND esValido = 0)
        PRINT 'El producto se ha eliminado de la tabla VARIOS de forma lógica exitosamente';
    ELSE
        PRINT 'Error al eliminar producto de la tabla VARIOS de forma lógica';

    -- MUESTRO LOS DATOS DEL VARIOS DESPUES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- EJECUTA EL TEST
EXEC borrado.TestEliminarVariosLogico;

-- TEST BORRADO LOGICO DE ELECTRONICO
CREATE OR ALTER PROCEDURE borrado.TestEliminarElectronicoLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_electronico INT;

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA ELECTRONICO
    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, esValido)
    VALUES (@id_producto, 150, 1);

    -- OBTENGO EL ID DEL ELECTRONICO INSERTADO
    SET @id_electronico = SCOPE_IDENTITY();

    -- MUESTRO LOS DATOS DEL ELECTRONICO ANTES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO PARA ELIMINAR LOGICAMENTE EL ELECTRONICO
    EXEC borrado.EliminarElectronicoLogico @id_producto;

    -- VERIFICO SI LA ELIMINACION LOGICA FUE EXITOSA
    IF EXISTS (SELECT 1 FROM productos.ELECTRONICO WHERE id_producto = @id_producto AND esValido = 0)
        PRINT 'El producto se ha eliminado de la tabla ELECTRONICO de forma lógica exitosamente';
    ELSE
        PRINT 'Error al eliminar producto de la tabla ELECTRONICO de forma lógica';

    -- MUESTRO LOS DATOS DEL ELECTRONICO DESPUES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarElectronicoLogico;

-- TEST BORRADO LOGICO DE IMPORTADOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarImportadoLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_importado INT;

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, esValido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA IMPORTADO
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, esValido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);

    -- OBTENGO EL ID DEL IMPORTADO INSERTADO
    SET @id_importado = SCOPE_IDENTITY();

    -- MUESTRO LOS DATOS DEL IMPORTADO ANTES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO PARA ELIMINAR LOGICAMENTE EL IMPORTADO
    EXEC borrado.EliminarImportadoLogico @id_producto;

    -- VERIFICO SI LA ELIMINACION LOGICA FUE EXITOSA
    IF EXISTS (SELECT 1 FROM productos.IMPORTADO WHERE id_producto = @id_producto AND esValido = 0)
        PRINT 'El producto se ha eliminado de la tabla IMPORTADOS de forma lógica exitosamente';
    ELSE
        PRINT 'Error al eliminar producto de la tabla IMPORTADOS de forma lógica';

    -- MUESTRO LOS DATOS DEL IMPORTADO DESPUES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarImportadoLogico;


-- TEST BORRADO LOGICO EN CASCADA CARGO -> EMPLEADO
CREATE OR ALTER PROCEDURE borrado.TestEliminarCargoLogico
AS
BEGIN
    -- INSERTO SUCURSAL DE PRUEBA
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba' , 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    DECLARE @id_sucursal INT = SCOPE_IDENTITY();

    -- INSERTO CARGO DE PRUEBA CON EL CAMPO esValido EN 1 (ACTIVO)
    INSERT INTO seguridad.CARGO (nombre, esValido) VALUES ('Test Cargo', 1);
    DECLARE @id INT = SCOPE_IDENTITY();

    -- INSERTO UN EMPLEADO DE PRUEBA ASOCIADO AL CARGO INSERTADO Y A LA SUCURSAL CREADA
    INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno)
    VALUES (123, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id, @id_sucursal, 'Mañana');

    -- MUESTRO LOS REGISTROS INSERTADOS
    SELECT * FROM seguridad.CARGO WHERE id = @id;
    SELECT * FROM seguridad.EMPLEADO WHERE id_cargo = @id;
    SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    -- EJECUTO EL PROCEDIMIENTO DE ELIMINACIÓN LÓGICA
    EXEC borrado.EliminarCargoLogico @id;

    -- VERIFICO QUE EL CARGO SE HAYA ELIMINADO DE FORMA LÓGICA CORRECTAMENTE
    IF EXISTS (SELECT 1 FROM seguridad.CARGO WHERE id = @id AND esValido = 0)
        PRINT 'El cargo fue eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar el cargo de forma lógica.';

    -- VERIFICO QUE EL EMPLEADO SE HAYA ELIMINADO DE FORMA LÓGICA CORRECTAMENTE
    IF EXISTS (SELECT 1 FROM seguridad.EMPLEADO WHERE id_cargo = @id AND esValido = 0)
        PRINT 'El empleado fue eliminado de forma lógica exitosamente.';
    ELSE
        PRINT 'Error al eliminar empleado de forma lógica.';

    -- MUESTRO LOS RESULTADOS POSTERIORES A LA ELIMINACIÓN LÓGICA
    SELECT * FROM seguridad.CARGO WHERE id = @id;
    SELECT * FROM seguridad.EMPLEADO WHERE id_cargo = @id;
    SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM seguridad.EMPLEADO WHERE id_cargo = @id;
    DELETE FROM seguridad.CARGO WHERE id = @id;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarCargoLogico;


