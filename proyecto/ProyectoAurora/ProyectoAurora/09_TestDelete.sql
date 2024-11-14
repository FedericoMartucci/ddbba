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

-- DEFINO UN CODIGO DE ERROR CON UN MENSAJE ASOCIADO (ELIMINAR ALGO QUE NO EXISTE)
EXEC sp_addmessage @msgnum = 130001, 
                   @severity = 16, 
                   @msgtext = 'No se puede eliminar el cliente porque no existe.',
                   @replace = 'REPLACE';
GO

-- DEFINO UN CODIGO DE ERROR CON UN MENSAJE ASOCIADO (ELIMINAR ALGO QUE TIENE FK ASOCIADAS)
EXEC sp_addmessage @msgnum = 130002, 
                   @severity = 16, 
                   @msgtext = 'No se puede eliminar porque otros registros lo están referenciando.',
                   @replace = 'REPLACE';
GO

-- TEST BORRADO LOGICO EN CASCADA DE CATEGORIA -> PRODUCTO -> IMPORTADO
CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaImportadoLogico
AS
BEGIN
    DECLARE @es_valido_categoria INT;
    DECLARE @es_validoProducto1 INT;
    DECLARE @es_validoImportado INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    
    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    SET @id_producto = SCOPE_IDENTITY();

    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);

    -- MUESTRA LOS DATOS INSERTADOS
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR CATEGORIA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @es_valido_categoria = es_valido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@es_valido_categoria = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoProducto1 = es_valido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    IF (@es_validoProducto1 = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta producto.';

    -- COMPRUEBO SI LOS IMPORTADOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoImportado = es_valido FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    IF (@es_validoImportado = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta importado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta importado.';

    -- MUESTRA LOS DATOS DESPUES DE LA ELIMINACION
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

-- TEST BORRADO LOGICO EN CASCADA DE CATEGORIA -> PRODUCTO -> ELECTRÓNICO
CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaElectronicoLogico
AS
BEGIN
    DECLARE @es_valido_categoria INT;
    DECLARE @es_validoProducto1 INT;
    DECLARE @es_validoElectronico INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    SET @id_producto = SCOPE_IDENTITY();

    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, es_valido)
    VALUES (@id_producto, 20.00, 1);

    -- MUESTRO LOS DATOS INSERTADOS
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR CATEGORIA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @es_valido_categoria = es_valido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@es_valido_categoria = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoProducto1 = es_valido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    IF (@es_validoProducto1 = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta producto.';

    -- COMPRUEBO SI LOS ELECTRONICOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoElectronico = es_valido FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    IF (@es_validoElectronico = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta electronico exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta electronico.';

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

    DECLARE @es_valido_categoria INT;
    DECLARE @es_validoProducto1 INT;
    DECLARE @es_validoVarios INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    SET @id_producto = SCOPE_IDENTITY();

    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, GETDATE(), GETDATE(), 'Unidad de prueba', 1);
    
    -- MUESTRO LOS DATOS INSERTADOS
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR CATEGORIA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @es_valido_categoria = es_valido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@es_valido_categoria = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error esperado al intentar borrar categoría.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoProducto1 = es_valido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    IF (@es_validoProducto1 = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta producto.';

    -- COMPRUEBO SI LOS VARIOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoVarios = es_valido FROM productos.VARIOS WHERE id_producto = @id_producto;
    IF (@es_validoVarios = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta varios.';

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

-- EJECUTO EL TEST
EXEC borrado.TestEliminarCategoriaHastaVariosLogico;
GO

-- TEST BORRADO LOGICO EN CASCADA DE CATEGORIA -> PRODUCTO -> IMPORTADO
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaImportadoLogico
AS
BEGIN

    DECLARE @es_validoProducto INT;
    DECLARE @es_validoImportado INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA IMPORTADO
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);
        
    -- MUESTRO LOS DATOS INSERTADOS
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR PRODUCTO (PASANDO EL ID DE CATEGORÍA COMO PARÁMETRO)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- COMPRUEBO SI EL PRODUCTO SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @es_validoProducto = es_valido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@es_validoProducto = 0)
        PRINT 'TEST PASADO - Borrado lógico de producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en el borrado lógico de producto.';

    -- COMPRUEBO SI LOS IMPORTADOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoImportado = es_valido FROM productos.IMPORTADO WHERE id_producto = @id_producto;
        
    IF (@es_validoImportado = 0)
        PRINT 'TEST PASADO - Borrado lógico en cascada desde producto hasta importado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico en cascada desde producto hasta importado.';

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

GO

-- TEST BORRADO LOGICO EN CASCADA DE PRODUCTO -> VARIOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaVariosLogico
AS
BEGIN

    DECLARE @es_validoProducto INT;
    DECLARE @es_validoVarios INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA VARIOS
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, '2024-11-12', '10:00:00', 'Unidad de prueba', 1);
        
    -- MUESTRA LOS DATOS INSERTADOS
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR PRODUCTO (PASANDO EL ID DE CATEGORÍA COMO PARÁMETRO)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- COMPRUEBO SI EL PRODUCTO SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @es_validoProducto = es_valido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@es_validoProducto = 0)
        PRINT 'TEST PASADO - Borrado lógico del producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error al eliminar producto de forma lógica.';

    -- COMPRUEBO SI LOS VARIOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoVarios = es_valido FROM productos.VARIOS WHERE id_producto = @id_producto;
    IF (@es_validoVarios = 0)
        PRINT 'TEST PASADO - Borrado lógico en cascada desde producto hasta varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico en cascada desde producto hasta varios.';

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


-- TEST BORRADO LOGICO EN CASCADA DE PRODUCTO -> VARIOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaVariosLogico
AS
BEGIN

    DECLARE @es_validoProducto INT;
    DECLARE @es_validoVarios INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;


    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO DATO DE PRUEBA EN LA TABLA VARIOS
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, '2024-11-12', '10:00:00', 'Unidad de prueba', 1);
        
    -- MUESTRA LOS DATOS INSERTADOS
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO ELIMINAR PRODUCTO (PASANDO EL ID DE CATEGORÍA COMO PARÁMETRO)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- COMPRUEBO SI EL PRODUCTO SE ELIMINÓ DE FORMA LOGICA CORRECTAMENTE
    SELECT @es_validoProducto = es_valido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@es_validoProducto = 0)
        PRINT 'TEST PASADO - Borrado lógico del producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error al eliminar producto de forma lógica.';

    -- COMPRUEBO SI LOS VARIOS SE ELIMINARON EN CASCADA DE FORMA LÓGICA CORRECTAMENTE
    SELECT @es_validoVarios = es_valido FROM productos.VARIOS WHERE id_producto = @id_producto;
    IF (@es_validoVarios = 0)
        PRINT 'TEST PASADO - Borrado lógico en cascada desde producto hasta varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico en cascada desde producto hasta varios.';

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
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA VARIOS
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, '2024-11-12', '12:00:00', 'Unidad prueba', 1);

    -- OBTENGO EL ID DEL VARIOS INSERTADO
    SET @id_varios = SCOPE_IDENTITY();

    -- MUESTRO LOS DATOS DEL VARIOS ANTES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO PARA ELIMINAR LOGICAMENTE EL VARIOS
    EXEC borrado.EliminarVariosLogico @id_producto;

    -- VERIFICO SI LA ELIMINACION LOGICA FUE EXITOSA
    IF EXISTS (SELECT 1 FROM productos.VARIOS WHERE id_producto = @id_producto AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de varios';

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
GO


-- TEST BORRADO LOGICO DE ELECTRONICO
CREATE OR ALTER PROCEDURE borrado.TestEliminarElectronicoLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_electronico INT;


    -- INSERTO UN DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA ELECTRONICO
    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, es_valido)
    VALUES (@id_producto, 150, 1);

    -- OBTENGO EL ID DEL ELECTRONICO INSERTADO
    SET @id_electronico = SCOPE_IDENTITY();

    -- MUESTRO LOS DATOS DEL ELECTRONICO ANTES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO PARA ELIMINAR LOGICAMENTE EL ELECTRONICO
    EXEC borrado.EliminarElectronicoLogico @id_producto;

    -- VERIFICO SI LA ELIMINACION LOGICA FUE EXITOSA
    IF EXISTS (SELECT 1 FROM productos.ELECTRONICO WHERE id_producto = @id_producto AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de electronico exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de varios exitoso';

    -- MUESTRO LOS DATOS DEL ELECTRONICO DESPUES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

   
    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
 

END;
GO

-- EJECUTA EL TEST
EXEC borrado.TestEliminarElectronicoLogico;
GO

-- TEST BORRADO LOGICO DE IMPORTADOS
CREATE OR ALTER PROCEDURE borrado.TestEliminarImportadoLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_importado INT;


    -- INSERTO UN DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA PRODUCTO
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- OBTENGO EL ID DEL PRODUCTO INSERTADO
    SET @id_producto = SCOPE_IDENTITY();

    -- INSERTO UN DATO DE PRUEBA EN LA TABLA IMPORTADO
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);

    -- OBTENGO EL ID DEL IMPORTADO INSERTADO
    SET @id_importado = SCOPE_IDENTITY();

    -- MUESTRO LOS DATOS DEL IMPORTADO ANTES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- EJECUTO EL PROCEDIMIENTO PARA ELIMINAR LOGICAMENTE EL IMPORTADO
    EXEC borrado.EliminarImportadoLogico @id_producto;

    -- VERIFICO SI LA ELIMINACION LOGICA FUE EXITOSA
    IF EXISTS (SELECT 1 FROM productos.IMPORTADO WHERE id_producto = @id_producto AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de importado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de importad';

    -- MUESTRO LOS DATOS DEL IMPORTADO DESPUES DE LA ELIMINACION LOGICA
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;




    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
 

END;
GO

-- EJECUTA EL TEST
EXEC borrado.TestEliminarImportadoLogico;
GO


-- Test de eliminación lógica exitosa de cargo
CREATE OR ALTER PROCEDURE borrado.TestEliminarCargoLogico_Exitoso
AS
BEGIN
    DECLARE @id INT;

    -- Insertar cargo de prueba activo
    INSERT INTO seguridad.CARGO (nombre, es_valido) 
    VALUES ('Test Cargo', 1);
    SET @id = SCOPE_IDENTITY();

    -- Intentar ejecutar el procedimiento de eliminación lógica
    BEGIN TRY
        EXEC borrado.EliminarCargoLogico @id;

        -- Si no hay error, el cargo fue desactivado correctamente
        PRINT 'TEST PASADO - Borrado lógico de cargo.';
    END TRY
    BEGIN CATCH
        -- Captura los errores del procedimiento de eliminación
        PRINT 'TEST FALLIDO - Error en borrado lógico de cargo';
    END CATCH

    -- Limpiar datos de prueba
    DELETE FROM seguridad.CARGO WHERE id = @id;

END;
GO

-- Ejecutar el test
EXEC borrado.TestEliminarCargoLogico_Exitoso;
GO


-- Test de eliminación lógica fallida por empleados asociados al cargo
CREATE OR ALTER PROCEDURE borrado.TestEliminarCargoLogico_EmpleadoAsociado
AS
BEGIN
    -- Inserta cargo de prueba activo
    INSERT INTO seguridad.CARGO (nombre, es_valido) VALUES ('Test Cargo', 1);
    DECLARE @id INT = SCOPE_IDENTITY();

    -- Insertar sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    DECLARE @id_sucursal INT = SCOPE_IDENTITY();

    -- Insertar un empleado asociado al cargo
    INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno)
    VALUES (123, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id, @id_sucursal, 'Mañana');

    -- Intentar ejecutar el procedimiento de eliminación lógica
    BEGIN TRY
        EXEC borrado.EliminarCargoLogico @id;
        PRINT 'TEST FALLIDO - No se produjo el error esperado al intentar eliminar el cargo con empleados asociados.';
    END TRY
    BEGIN CATCH
        -- Si el error se captura (por ejemplo, por empleados asociados), mostrar el mensaje esperado
        PRINT 'TEST PASADO - Error esperado al intentar eliminar cargo con empleados asociados.';
    END CATCH

    -- Limpiar datos de prueba
    DELETE FROM seguridad.EMPLEADO WHERE id_cargo = @id;
    DELETE FROM seguridad.CARGO WHERE id = @id;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

END;
GO


-- Ejecutar el test
EXEC borrado.TestEliminarCargoLogico_EmpleadoAsociado;
GO


-- Test de eliminación lógica fallida por cargo inexistente o inactivo
CREATE OR ALTER PROCEDURE borrado.TestEliminarCargoLogico_InactivoOInexistente
AS
BEGIN
    -- Obtener el valor máximo de id de la tabla CARGO y sumarle 1 para obtener un id inexistente
    DECLARE @id_inexistente INT;

    -- Si no hay registros en la tabla, MAX(id) será NULL, así que manejamos ese caso
    SELECT @id_inexistente = ISNULL(MAX(id), 0) + 1 FROM seguridad.CARGO;

    -- Intentar eliminar un cargo que no existe (usando MAX(id) + 1)
    BEGIN TRY
        EXEC borrado.EliminarCargoLogico @id_inexistente;  -- ID generado que no existe
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un cargo inexistente.';
    END TRY
    BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
        BEGIN
            PRINT 'TEST PASADO - Error esperado al intentar eliminar cargo inexistente con código de error 130001.';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error no esperado. Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        END
    END CATCH

    -- Insertar cargo de prueba inactivo
    INSERT INTO seguridad.CARGO (nombre, es_valido) VALUES ('Cargo Inactivo', 0);
    DECLARE @id INT = SCOPE_IDENTITY();

    -- Intentar ejecutar el procedimiento de eliminación lógica en un cargo inactivo
    BEGIN TRY
        EXEC borrado.EliminarCargoLogico @id;
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un cargo inactivo.';
    END TRY
    BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
        BEGIN
            PRINT 'TEST PASADO - Error esperado al intentar eliminar cargo inactivo con código de error 130001.';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error no esperado. Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        END
    END CATCH

    -- Limpiar datos de prueba
    DELETE FROM seguridad.CARGO WHERE id = @id;

END;
GO


-- Ejecutar el test
EXEC borrado.TestEliminarCargoLogico_InactivoOInexistente;
GO




-- TEST BORRADO LÓGICO DE SUCURSAL
CREATE OR ALTER PROCEDURE borrado.TestEliminarSucursalExito
AS
BEGIN
    DECLARE @id_sucursal INT;

    -- Inserto sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba', 1);
    SET @id_sucursal = SCOPE_IDENTITY();

    -- Muestra la sucursal insertada
    SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    -- Intento de ejecución del procedimiento de eliminación lógica
    BEGIN TRY
        -- Llamo al procedimiento para eliminación lógica
        EXEC borrado.EliminarSucursalLogico @id_sucursal;

        -- Mensaje en caso de éxito
        PRINT 'TEST PASADO - Borrado lógico de sucursal.';

    END TRY
    BEGIN CATCH
        -- Capturo cualquier error que ocurra durante la ejecución
        PRINT 'TEST FALLIDO - Error en Borrado lógico de sucursal.';
    END CATCH

    -- Muestra el registro después de la eliminación lógica
    SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    -- Elimino los datos de prueba físicamente
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarSucursalExito;
GO


-- TEST BORRADO LÓGICO DE SUCURSAL CON EMPLEADOS ACTIVOS TRABAJANDO EN ELLA (DEBE DAR ERROR)
CREATE OR ALTER PROCEDURE borrado.TestEliminarSucursalConEmpleados
AS
BEGIN
    -- Inserto cargo de prueba
    INSERT INTO seguridad.CARGO (nombre, es_valido)
    VALUES ('Cargo Prueba', 1);
    DECLARE @id_cargo INT = SCOPE_IDENTITY();

    -- Inserto sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba', 1);
    DECLARE @id_sucursal INT = SCOPE_IDENTITY();

    -- Inserto un empleado asociado a la sucursal y el cargo previamente insertado
    INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
    VALUES (123, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Mañana', 1);

    -- Muestro los registros insertados
    SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    SELECT * FROM seguridad.EMPLEADO WHERE id_sucursal = @id_sucursal;

    BEGIN TRY
        -- Llamo al procedimiento para eliminación lógica, debería lanzar un error
        EXEC borrado.EliminarSucursalLogico @id_sucursal;
        
        -- Si no ocurre un error, imprimo que el test ha fallado
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar la sucursal con empleados activos';
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, imprimo que el test ha pasado
        PRINT 'TEST PASADO - Error esperado al intentar eliminar sucursal con empleado activo';
    END CATCH

    -- Elimino los datos de prueba físicamente
    DELETE FROM seguridad.EMPLEADO WHERE id_sucursal = @id_sucursal;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    DELETE FROM seguridad.CARGO WHERE id = @id_cargo;
END;
GO

EXEC borrado.TestEliminarSucursalConEmpleados;
GO




-- TEST BORRADO LOGICO DE SUCURSAL NO ACTIVA O INEXISTENTE (DEBE DAR ERROR)
CREATE OR ALTER PROCEDURE borrado.TestEliminarSucursalNoActivaOInexistente
AS
BEGIN
    -- Obtengo el máximo id de la tabla y le sumo 1 para generar un id que no exista
    DECLARE @id_inexistente INT;
    SELECT @id_inexistente = ISNULL(MAX(id), 0) + 1 FROM seguridad.SUCURSAL;

    -- Intentar eliminar una sucursal inexistente (usando el máximo id + 1)
    BEGIN TRY
        -- Intento eliminar una sucursal con un id que no existe (id máximo + 1)

		-- Muestra que no hay registros con ese id
        SELECT * FROM seguridad.SUCURSAL WHERE id = @id_inexistente;

        EXEC borrado.EliminarSucursalLogico @id_inexistente;
        
        -- Si no lanza error, el test ha fallado
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar una sucursal inexistente.';
    END TRY
    BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
        BEGIN
            PRINT 'TEST PASADO - Error esperado al intentar eliminar una sucursal inexistente con código de error 130001.';
	
		END
        
		ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error no esperado. Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        END
    END CATCH

    -- Intentar eliminar una sucursal no activa
    BEGIN TRY
        -- Inserto sucursal de prueba como inactiva
        INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido)
        VALUES ('9:00-18:00', 'Ciudad Inactiva', 'Reemplazo prueba', 'Calle Inactiva 456', '54321', 'Provincia de Prueba', 0);
        DECLARE @id_sucursal INT = SCOPE_IDENTITY();

        -- Muestra el registro insertado
        SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

        -- Intento eliminar lógicamente la sucursal (debería lanzar error)
        EXEC borrado.EliminarSucursalLogico @id_sucursal;

        -- Muestra el registro eliminado
        SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
        
	
        -- Si no lanza error, el test ha fallado
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar una sucursal no activa.';
    END TRY
    BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
        BEGIN
            PRINT 'TEST PASADO - Error esperado al intentar eliminar una sucursal no activa con código de error 130001.';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error no esperado. Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        END
    END CATCH

    -- Elimino los datos de prueba físicamente si es necesario
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
END;
GO


-- EJECUTAR EL TEST
EXEC borrado.TestEliminarSucursalNoActivaOInexistente;
GO


-- Procedimiento de prueba para eliminación lógica exitosa de EMPLEADO
CREATE OR ALTER PROCEDURE borrado.TestEliminarEmpleadoLogico_Exitoso
AS
BEGIN
    -- Insertar un cargo de prueba y capturar su id
    INSERT INTO seguridad.CARGO (nombre) VALUES ('Cargo de prueba');
    DECLARE @id_cargo INT = SCOPE_IDENTITY();

    -- Insertar una sucursal de prueba y capturar su id
    INSERT INTO seguridad.SUCURSAL (ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido, horario)
    VALUES ('Ciudad de prueba', 'N/A', 'Calle Falsa 123', '12345', 'Provincia de prueba', 1, '9:00 - 18:00');
    DECLARE @id_sucursal INT = SCOPE_IDENTITY();

    -- Obtener el máximo legajo existente y sumarle 1 para asegurar un legajo único
    DECLARE @nuevo_legajo INT;
    SELECT @nuevo_legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

    -- Insertar un empleado de prueba asociado a la sucursal y cargo, en estado activo
    INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
    VALUES (@nuevo_legajo, 'Test', 'Empleado', 12345678, 'Calle Falsa 456', 'test@empresa.com', 'test@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Tarde', 1);
    
    -- Verificar inserción
    SELECT * FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;

    -- Ejecutar la eliminación lógica
    EXEC borrado.EliminarEmpleadoLogico @nuevo_legajo;

    -- Verificar que el empleado fue desactivado
    IF EXISTS (SELECT 1 FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de empleado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de empleado exitoso.';

    -- Limpiar datos de prueba
    DELETE FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    DELETE FROM seguridad.CARGO WHERE id = @id_cargo;
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC borrado.TestEliminarEmpleadoLogico_Exitoso;
GO

CREATE OR ALTER PROCEDURE borrado.TestEliminarEmpleadoNoExistenteOInactivo
AS
BEGIN
    -- Insertar un cargo de prueba y capturar su id
    INSERT INTO seguridad.CARGO (nombre) VALUES ('Cargo de prueba');
    DECLARE @id_cargo INT = SCOPE_IDENTITY();

    -- Insertar una sucursal de prueba y capturar su id
    INSERT INTO seguridad.SUCURSAL (ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido, horario)
    VALUES ('Ciudad de prueba', 'N/A', 'Calle Falsa 123', '12345', 'Provincia de prueba', 1, '9:00 - 18:00');
    DECLARE @id_sucursal INT = SCOPE_IDENTITY();

    -- Obtener el máximo legajo existente y sumarle 1 para asegurar un legajo único
    DECLARE @nuevo_legajo INT;
    SELECT @nuevo_legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

    -- Insertar un empleado de prueba asociado a la sucursal y cargo, en estado activo
    INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
    VALUES (@nuevo_legajo, 'Test', 'Empleado', 12345678, 'Calle Falsa 456', 'test@empresa.com', 'test@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Tarde', 1);
    
    -- Verificar inserción del empleado activo
    SELECT * FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;

    -- Desactivar el empleado insertado (para probar la eliminación de un empleado inactivo)
    UPDATE seguridad.EMPLEADO SET es_valido = 0 WHERE legajo = @nuevo_legajo;

    -- Intentar eliminar un empleado que no existe (tomando el máximo legajo existente + 1)
    DECLARE @legajo_inexistente INT;
    SELECT @legajo_inexistente = MAX(legajo) + 1 FROM seguridad.EMPLEADO;

    BEGIN TRY
        EXEC borrado.EliminarEmpleadoLogico @legajo_inexistente;  -- Un legajo que no existe
    END TRY
    BEGIN CATCH
        PRINT 'TEST PASADO - Error esperado al intentar eliminar un empleado no existente.';
    END CATCH

    -- Intentar eliminar un empleado que está inactivo
    BEGIN TRY
        EXEC borrado.EliminarEmpleadoLogico @nuevo_legajo;  -- Empleado que está inactivo
    END TRY
    BEGIN CATCH
        PRINT 'TEST PASADO - Error esperado al intentar eliminar un empleado inactivo.';
    END CATCH

    -- Limpiar datos de prueba
    DELETE FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    DELETE FROM seguridad.CARGO WHERE id = @id_cargo;
END;
GO


-- Ejecutar el procedimiento de prueba
EXEC borrado.TestEliminarEmpleadoNoExistenteOInactivo;
GO

-- TEST DELETE TELEFONO ÉXITO
CREATE OR ALTER PROCEDURE borrado.TestEliminarTelefonoFisico
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id_sucursal INT,
			@telefono_prueba CHAR (9) = '1234-5678';

	-- Insertar sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    
	SET @id_sucursal = SCOPE_IDENTITY();


    -- Insertar dato de prueba en la tabla TELEFONO
	INSERT INTO seguridad.TELEFONO (id_sucursal, telefono) VALUES (@id_sucursal, @telefono_prueba);
		
	SELECT * FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono_prueba;

    BEGIN TRY
        -- Ejecutar el procedimiento de eliminación
        EXEC borrado.EliminarTelefonoFisico @id_sucursal = @id_sucursal;

        -- Verificar si el registro fue eliminado
        IF NOT EXISTS (SELECT 1 FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono_prueba)
        BEGIN
            PRINT 'TEST PASADO - Eliminación física de TELEFONO exitosa';
			SELECT * FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono_prueba;

        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error en la eliminación de teléfono';
        END
    END TRY
    BEGIN CATCH
        -- Capturar y mostrar el error si ocurre
        PRINT 'TEST FALLIDO - Error al ejecutar Eliminación Física de TELEFONO';
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Ejecutar la prueba
EXEC borrado.TestEliminarTelefonoFisico;
GO

-- TEST DE ELIMINACIÓN FÍSICA DE TELÉFONO NO EXISTENTE (CASO DE FALLA)
CREATE OR ALTER PROCEDURE borrado.TestEliminarTelefonoFisico_Fallido
AS
BEGIN
    -- Inserto una sucursal de prueba activa
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido)
    VALUES ('9:00-18:00', 'Ciudad de prueba', 'Reemplazo prueba', 'Calle de prueba 123', '54321', 'Provincia de Prueba', 1);
    DECLARE @id_sucursal INT = SCOPE_IDENTITY();  -- Capturo el ID de la sucursal insertada

    BEGIN TRY
        -- Intento eliminar un teléfono que no existe para esta sucursal (id_sucursal no tiene teléfono asociado)
        EXEC borrado.EliminarTelefonoFisico @id_sucursal = @id_sucursal;

        -- Si no se lanza el error, el test ha fallado
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un teléfono inexistente.';
    END TRY
    BEGIN CATCH
        -- Capturo y manejo el error, no es necesario concatenar el mensaje
        PRINT 'TEST PASADO - Error esperado al intentar eliminar un teléfono inexistente.';
    END CATCH

    -- Elimino la sucursal de prueba
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
END;
GO

-- Ejecutar el test
EXEC borrado.TestEliminarTelefonoFisico_Fallido;
GO

-- TEST DELETE VENTA
CREATE OR ALTER PROCEDURE borrado.TestEliminarVentaFisico
AS
BEGIN
    -- Declarar variables para el ID de la venta y las dependencias
    DECLARE @id_cliente INT,
            @id_producto INT,
            @id_medio_pago INT,
            @id_sucursal INT,
            @id_cargo INT,
            @legajo INT,
            @id_empleado INT,
            @id_categoria INT,
            @id_factura char (11),
            @id_venta INT;

	BEGIN TRY 
		-- Insertar un Cliente de prueba
		INSERT INTO seguridad.CLIENTE (genero) VALUES ('Female');
		SET @id_cliente = SCOPE_IDENTITY();  -- Obtener el ID del cliente insertado

		-- Insertar una categoría de prueba
		INSERT INTO seguridad.CATEGORIA (descripcion) VALUES ('Categoria de prueba');
		SET @id_categoria = SCOPE_IDENTITY();  -- Obtener el ID de la categoría insertada

		-- Insertar un producto de prueba
		INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
		VALUES (100, 'Nombre prueba', @id_categoria, 1);
		SET @id_producto = SCOPE_IDENTITY();  -- Obtener el ID del producto insertado

		-- Insertar un medio de pago de prueba
		INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion_ingles, descripcion)
		VALUES ('Credit Card', 'Tarjeta de Crédito');
		SET @id_medio_pago = SCOPE_IDENTITY();  -- Obtener el ID del medio de pago insertado

		-- Insertar una factura de prueba
		INSERT INTO transacciones.FACTURA (id, tipo_de_factura, estado)
		VALUES ('000-00-0000', 'A', 1);
		SET @id_factura = SCOPE_IDENTITY();  -- Obtener el ID de la factura insertada

		-- Obtener el máximo legajo y sumarle 1
		SELECT @legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

		-- Insertar un empleado de prueba
		INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
		VALUES (@legajo, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Mañana', 1);
		SET @id_empleado = SCOPE_IDENTITY();  -- Obtener el ID del empleado insertado

		-- Insertar una venta de prueba
		INSERT INTO transacciones.VENTA (id_factura, id_sucursal, id_producto, cantidad, fecha, hora, id_medio_de_pago, id_empleado, identificador_de_pago)
		VALUES (@id_factura, @id_sucursal, @id_producto, 5, '2024-11-13', '14:35:00', @id_medio_pago, @id_empleado, '1111222233334444555566');
		SET @id_venta = SCOPE_IDENTITY();  -- Obtener el ID de la venta insertada

	END TRY

	BEGIN CATCH 
		PRINT 'Error inesperado en la insercion de los datos.';
		RETURN;
	END CATCH

    -- Mostrar la venta insertada
    SELECT * FROM transacciones.VENTA WHERE id = @id_venta;

    BEGIN TRY
        -- Llamar al procedimiento de eliminación de venta
        EXEC borrado.EliminarVentaFisico @id_venta;

		-- Mostrar la venta borrada
		SELECT * FROM transacciones.VENTA WHERE id = @id_venta;

        PRINT 'TEST PASADO - Eliminación física de venta exitosa';
    END TRY

    BEGIN CATCH
        PRINT 'TEST FALLIDO - Error en la eliminación física de venta';
    END CATCH

    -- Eliminar todos los datos de prueba insertados
    DELETE FROM transacciones.VENTA WHERE id = @id_venta;
    DELETE FROM seguridad.EMPLEADO WHERE legajo = @id_empleado;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio_pago;
    DELETE FROM transacciones.FACTURA WHERE @id_factura = @id_factura;
    DELETE FROM seguridad.CLIENTE WHERE id = @id_cliente;
END;
GO

-- EJECUTO EL TEST
EXEC borrado.TestEliminarVentaFisico;
GO

-- TEST ELIMINAR CLIENTE QUE NO EXISTE (DEBE DAR ERROR)
CREATE OR ALTER PROCEDURE borrado.TestEliminarClienteInexistente
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id_cliente_inexistente INT = -1;  -- ID que no existe en CLIENTE

    BEGIN TRY
        -- Intentar ejecutar el procedimiento de eliminación con un cliente inexistente
        EXEC borrado.EliminarClienteFisico @id_cliente = @id_cliente_inexistente;

        -- Si no se lanza el error, el test falla
        PRINT 'TEST FALLIDO - No se generó error al intentar eliminar un cliente inexistente';
    END TRY
    BEGIN CATCH
        -- Capturar y verificar el número y mensaje de error
    SELECT 
        ERROR_NUMBER() AS NumeroDeError,
        ERROR_MESSAGE() AS MensajeDeError;

        IF ERROR_NUMBER() = 130001
        BEGIN
            PRINT 'TEST PASADO - Error capturado con el número correcto (13001) al intentar eliminar un cliente inexistente';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Número de error inesperado: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        END
    END CATCH;
END;
GO

-- Ejecutar la prueba
EXEC borrado.TestEliminarClienteInexistente;
GO

-- Test de eliminación física exitosa
CREATE OR ALTER PROCEDURE borrado.TestEliminarTipoFisicoExitoso
AS
BEGIN
    -- Insertar un tipo de prueba
    INSERT INTO seguridad.TIPO (nombre) VALUES ('Tipo de Cliente Prueba');
    DECLARE @id INT = SCOPE_IDENTITY();  -- Obtener el ID del tipo insertado

    BEGIN TRY
        -- Intentar eliminar físicamente el tipo
        EXEC borrado.EliminarTipoFisico @id;
        
        -- Verificar si el tipo fue realmente eliminado
        IF NOT EXISTS (SELECT 1 FROM seguridad.TIPO WHERE id = @id)
        BEGIN
            PRINT 'TEST PASADO - Tipo eliminado físicamente con éxito.';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - No se pudo eliminar físicamente el tipo.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'TEST FALLIDO - Error inesperado: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC borrado.TestEliminarTipoFisicoExitoso;
GO

-- Test de eliminación física fallida por tipo inexistente (debe dar error 130001)
CREATE OR ALTER PROCEDURE borrado.TestEliminarTipoFisicoError
AS
BEGIN
    -- Intentar eliminar un tipo con un id que no existe
    DECLARE @id_inexistente INT;
    SELECT @id_inexistente = ISNULL(MAX(id), 0) + 1 FROM seguridad.TIPO;  -- Generar un id inexistente

    BEGIN TRY
        -- Intentar eliminar el tipo inexistente
        EXEC borrado.EliminarTipoFisico @id_inexistente;
        
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un tipo inexistente.';
    END TRY
    BEGIN CATCH
        -- Verificar si el código de error es 130001
        IF ERROR_NUMBER() = 130001
        BEGIN
            PRINT 'TEST PASADO - Error esperado al intentar eliminar un tipo inexistente con código de error ' + CAST(ERROR_NUMBER() AS VARCHAR (15));
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error no esperado. Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        END
    END CATCH
END;
GO

EXEC borrado.TestEliminarTipoFisicoError;
GO


CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoLogicoExitoso
AS
BEGIN
    DECLARE @id_medio INT;

    -- Inserta un medio de pago de prueba
    INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion_ingles, descripcion, es_valido)
    VALUES ('Test Payment Method', 'Método de Pago de Prueba', 1);

    -- Obtener el ID del medio de pago insertado
    SET @id_medio = SCOPE_IDENTITY();

	SELECT * FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio;

    -- Ejecutar el procedimiento para la eliminación lógica
    EXEC borrado.EliminarMedioDePagoLogico @id_medio;

	SELECT * FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio;


    -- Verificar si el medio de pago está marcado como no válido
    IF EXISTS (SELECT 1 FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio AND es_valido = 0)
    BEGIN
        PRINT 'TEST PASADO - Borrado lógico de medio de pago exitoso';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en el borrado lógico';
    END
END;
GO

EXEC borrado.EliminarMedioDePagoLogicoExitoso;
GO

CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoLogicoFallido
AS
BEGIN
    DECLARE @id_medio INT, @error_message NVARCHAR(255);

    -- Intentar eliminar un medio de pago con ID negativo
    BEGIN TRY
        EXEC borrado.EliminarMedioDePagoLogico -1;
        PRINT 'TEST FALLIDO - No se generó el error esperado para ID negativo';
    END TRY
    BEGIN CATCH
      
        IF ERROR_NUMBER() = 130001
            PRINT 'TEST PASADO - Error esperado al intentar eliminar ID que no existe';
        ELSE
            PRINT 'TEST FALLIDO - Error inesperado: ' + @error_message;
    END CATCH

    -- Insertar un medio de pago y marcarlo como no válido para el segundo caso de prueba
    INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion_ingles, descripcion, es_valido)
    VALUES ('Test Payment Method', 'Método de Pago de Prueba', 1);

    -- Obtener el ID del medio de pago insertado
    SET @id_medio = SCOPE_IDENTITY();

    -- Marcar como no válido
    UPDATE transacciones.MEDIO_DE_PAGO
    SET es_valido = 0
    WHERE id = @id_medio;

    -- Caso 2: Intentar eliminar un medio de pago que ya está marcado como no válido
    BEGIN TRY
        EXEC borrado.EliminarMedioDePagoLogico @id_medio;
        PRINT 'TEST FALLIDO - No se generó el error esperado para un registro no válido';
    END TRY
    BEGIN CATCH
	        IF ERROR_NUMBER() = 130001
            PRINT 'TEST PASADO - Error esperado al intentar eliminar medio de pago no válido';
        ELSE
            PRINT 'TEST FALLIDO - Error inesperado: ' + @error_message;
    END CATCH
END;
GO

EXEC borrado.EliminarMedioDePagoLogicoFallido;
GO

CREATE OR ALTER PROCEDURE borrado.EliminarFacturaFisicoExitoso
AS
BEGIN
    DECLARE @id_factura CHAR(11) = '123-45-67890';

    -- Insertar una factura de prueba
    INSERT INTO transacciones.FACTURA (id, tipo_de_factura, estado)
    VALUES (@id_factura, 'A', 1);

    -- Ver inserción de la factura
	SELECT * FROM transacciones.FACTURA WHERE id = @id_factura;

    -- Ejecutar el procedimiento para la eliminación física de la factura
    EXEC borrado.EliminarFacturaFisico @id_factura;

	SELECT * FROM transacciones.FACTURA WHERE id = @id_factura;

    -- Verificar si la factura fue eliminada
    IF NOT EXISTS (SELECT 1 FROM transacciones.FACTURA WHERE id = @id_factura)
    BEGIN
        PRINT 'TEST PASADO - Eliminación física de factura exitosa.';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - La factura no se eliminó correctamente.';
    END
END;
GO

EXEC borrado.EliminarFacturaFisicoExitoso;
GO


CREATE OR ALTER PROCEDURE borrado.EliminarNotaCreditoFisicoExitoso
AS
BEGIN
    DECLARE @id INT;

    -- Insertar una nota de crédito de prueba
    INSERT INTO transacciones.NOTA_CREDITO (monto)
    VALUES (1000.00);

    -- Obtener el ID de la nota de crédito recién insertada
    SET @id = SCOPE_IDENTITY();

    -- Ver que la nota de crédito fue insertada correctamente
    SELECT * FROM transacciones.NOTA_CREDITO WHERE id = @id;

    -- Ejecutar el procedimiento para la eliminación física de la nota de crédito
    EXEC borrado.EliminarNotaCreditoFisico @id;

    -- Ver que la nota de crédito fue eliminada correctamente
    SELECT * FROM transacciones.NOTA_CREDITO WHERE id = @id;

    -- Verificar si la nota de crédito fue eliminada
    IF NOT EXISTS (SELECT 1 FROM transacciones.NOTA_CREDITO WHERE id = @id)
    BEGIN
        PRINT 'TEST PASADO - Eliminación física de nota de crédito exitosa.';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la eliminación física de nota de crédito.';
    END
END;
GO

EXEC borrado.EliminarNotaCreditoFisicoExitoso;
GO


