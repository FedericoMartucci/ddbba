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

-- Defino un código de error con un mensaje asociado (eliminar algo que no existe)
EXEC sp_addmessage @msgnum = 130001, 
                   @severity = 16, 
                   @msgtext = 'No se puede eliminar algo que no existe.',
                   @replace = 'REPLACE';
GO

-- Defino un código de error con un mensaje asociado (eliminar algo que tiene referencias)
EXEC sp_addmessage @msgnum = 130002, 
                   @severity = 16, 
                   @msgtext = 'No se puede eliminar porque otros registros lo están referenciando con constraint not null.',
                   @replace = 'REPLACE';
GO

-- Test borrado lógico en cascada de categoría -> producto -> importado
CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaImportadoLogico
AS
BEGIN
    DECLARE @es_valido_categoria INT;
    DECLARE @es_validoProducto1 INT;
    DECLARE @es_validoImportado INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- Inserto dato de prueba en la tabla categoría
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el id de la categoría insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto producto asociado a la categoría insertada
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el id del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto importado asociado al producto
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);

    -- Muestra los datos insertados
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento eliminar categoría
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- Compruebo si la categoría se eliminó de forma lógica correctamente
    SELECT @es_valido_categoria = es_valido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@es_valido_categoria = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría.';

    -- Compruebo si los productos se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoProducto1 = es_valido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    IF (@es_validoProducto1 = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta producto.';

    -- Compruebo si los importados se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoImportado = es_valido FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    IF (@es_validoImportado = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta importado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta importado.';

    -- Muestra los datos después de la eliminación
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;

END;
GO

-- Ejecuto el test
EXEC borrado.TestEliminarCategoriaHastaImportadoLogico;
GO

-- Test borrado lógico en cascada de categoría -> producto -> electrónico
CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaElectronicoLogico
AS
BEGIN
    DECLARE @es_valido_categoria INT;
    DECLARE @es_validoProducto1 INT;
    DECLARE @es_validoElectronico INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- Inserto dato de prueba en la tabla categoría
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el id de la categoría insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto producto asociado a la categoría insertada
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el id del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto electrónico asociado al producto
    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, es_valido)
    VALUES (@id_producto, 20.00, 1);

    -- Muestra los datos insertados
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento eliminar categoría
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- Compruebo si la categoría se eliminó de forma lógica correctamente
    SELECT @es_valido_categoria = es_valido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@es_valido_categoria = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría.';

    -- Compruebo si los productos se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoProducto1 = es_valido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    IF (@es_validoProducto1 = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta producto.';

    -- Compruebo si los electrónicos se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoElectronico = es_valido FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    IF (@es_validoElectronico = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta electrónico exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta electrónico.';

    -- Muestra los datos posteriores al borrado lógico
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

END;
GO

-- Ejecuto el test
EXEC borrado.TestEliminarCategoriaHastaElectronicoLogico;
GO


-- Test borrado lógico en cascada de categoría -> producto -> varios
CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaHastaVariosLogico
AS
BEGIN

    DECLARE @es_valido_categoria INT;
    DECLARE @es_validoProducto1 INT;
    DECLARE @es_validoVarios INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;

    -- Inserto dato de prueba en la tabla categoría
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el id de la categoría insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto dato de prueba en la tabla producto
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el id del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto dato de prueba en la tabla varios
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, GETDATE(), GETDATE(), 'Unidad de prueba', 1);
    
    -- Muestro los datos insertados
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento eliminar categoría
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- Compruebo si la categoría se eliminó de forma lógica correctamente
    SELECT @es_valido_categoria = es_valido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@es_valido_categoria = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error esperado al intentar borrar categoría.';

    -- Compruebo si los productos se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoProducto1 = es_valido FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    IF (@es_validoProducto1 = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta producto.';

    -- Compruebo si los varios se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoVarios = es_valido FROM productos.VARIOS WHERE id_producto = @id_producto;
    IF (@es_validoVarios = 0)
        PRINT 'TEST PASADO - Borrado lógico de categoría en cascada hasta varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de categoría en cascada hasta varios.';

    -- Muestro los datos posteriores al borrado lógico
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;

END;
GO

-- Ejecuto el test
EXEC borrado.TestEliminarCategoriaHastaVariosLogico;
GO

-- Test borrado lógico en cascada de categoría -> producto -> importado
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaImportadoLogico
AS
BEGIN

    DECLARE @es_validoProducto INT;
    DECLARE @es_validoImportado INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- Inserto dato de prueba en la tabla categoría
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el id de la categoría insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto dato de prueba en la tabla producto
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el id del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto dato de prueba en la tabla importado
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);
        
    -- Muestro los datos insertados
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento eliminar producto (pasando el id de categoría como parámetro)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- Compruebo si el producto se eliminó de forma lógica correctamente
    SELECT @es_validoProducto = es_valido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@es_validoProducto = 0)
        PRINT 'TEST PASADO - Borrado lógico de producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en el borrado lógico de producto.';

    -- Compruebo si los importados se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoImportado = es_valido FROM productos.IMPORTADO WHERE id_producto = @id_producto;
        
    IF (@es_validoImportado = 0)
        PRINT 'TEST PASADO - Borrado lógico en cascada desde producto hasta importado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico en cascada desde producto hasta importado.';

    -- Muestro los datos posteriores al borrado lógico
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- Ejecuto el test
EXEC borrado.TestEliminarProductoHastaImportadoLogico;
GO



-- Test borrado lógico en cascada de producto -> varios
CREATE OR ALTER PROCEDURE borrado.TestEliminarProductoHastaVariosLogico
AS
BEGIN

    DECLARE @es_validoProducto INT;
    DECLARE @es_validoVarios INT;
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;

    -- Inserto dato de prueba en la tabla categoria
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el ID de la categoria insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto dato de prueba en la tabla producto
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el ID del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto dato de prueba en la tabla varios
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, '2024-11-12', '10:00:00', 'Unidad de prueba', 1);
        
    -- Muestro los datos insertados
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento eliminar producto (pasando el ID de categoria como parámetro)
    EXEC borrado.EliminarCategoriaLogico @id_categoria;

    -- Compruebo si el producto se eliminó de forma lógica correctamente
    SELECT @es_validoProducto = es_valido FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    IF (@es_validoProducto = 0)
        PRINT 'TEST PASADO - Borrado lógico del producto exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error al eliminar producto de forma lógica.';

    -- Compruebo si los varios se eliminaron en cascada de forma lógica correctamente
    SELECT @es_validoVarios = es_valido FROM productos.VARIOS WHERE id_producto = @id_producto;
    IF (@es_validoVarios = 0)
        PRINT 'TEST PASADO - Borrado lógico en cascada desde producto hasta varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico en cascada desde producto hasta varios.';

    -- Muestro los datos posteriores al borrado lógico
    SELECT * FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- Ejecuto el test
EXEC borrado.TestEliminarProductoHastaVariosLogico;
GO

-- Test borrado lógico de varios
CREATE OR ALTER PROCEDURE borrado.TestEliminarVariosLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_varios INT;

    -- Inserto un dato de prueba en la tabla categoria
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el ID de la categoria insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto un dato de prueba en la tabla producto
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el ID del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto un dato de prueba en la tabla varios
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, '2024-11-12', '12:00:00', 'Unidad prueba', 1);

    -- Obtengo el ID del varios insertado
    SET @id_varios = SCOPE_IDENTITY();

    -- Muestro los datos del varios antes de la eliminación lógica
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento para eliminar lógicamente el varios
    EXEC borrado.EliminarVariosLogico @id_producto;

    -- Verifico si la eliminación lógica fue exitosa
    IF EXISTS (SELECT 1 FROM productos.VARIOS WHERE id_producto = @id_producto AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de varios exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de varios';

    -- Muestro los datos del varios después de la eliminación lógica
    SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- Ejecuta el test
EXEC borrado.TestEliminarVariosLogico;
GO


-- Test borrado lógico de electrónico
CREATE OR ALTER PROCEDURE borrado.TestEliminarElectronicoLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_electronico INT;

    -- Inserto un dato de prueba en la tabla categoria
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el ID de la categoria insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto un dato de prueba en la tabla producto
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el ID del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto un dato de prueba en la tabla electronico
    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, es_valido)
    VALUES (@id_producto, 150, 1);

    -- Obtengo el ID del electronico insertado
    SET @id_electronico = SCOPE_IDENTITY();

    -- Muestro los datos del electronico antes de la eliminacion logica
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento para eliminar logicamente el electronico
    EXEC borrado.EliminarElectronicoLogico @id_producto;

    -- Verifico si la eliminacion logica fue exitosa
    IF EXISTS (SELECT 1 FROM productos.ELECTRONICO WHERE id_producto = @id_producto AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de electronico exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de varios exitoso';

    -- Muestro los datos del electronico despues de la eliminacion logica
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- Ejecuta el test
EXEC borrado.TestEliminarElectronicoLogico;
GO

-- Test borrado lógico de importados
CREATE OR ALTER PROCEDURE borrado.TestEliminarImportadoLogico
AS
BEGIN
    DECLARE @id_producto INT;
    DECLARE @id_categoria INT;
    DECLARE @id_importado INT;

    -- Inserto un dato de prueba en la tabla categoria
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);

    -- Obtengo el ID de la categoria insertada
    SET @id_categoria = SCOPE_IDENTITY();

    -- Inserto un dato de prueba en la tabla producto
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);

    -- Obtengo el ID del producto insertado
    SET @id_producto = SCOPE_IDENTITY();

    -- Inserto un dato de prueba en la tabla importado
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor 1', '10', 1);

    -- Obtengo el ID del importado insertado
    SET @id_importado = SCOPE_IDENTITY();

    -- Muestro los datos del importado antes de la eliminacion logica
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Ejecuto el procedimiento para eliminar logicamente el importado
    EXEC borrado.EliminarImportadoLogico @id_producto;

    -- Verifico si la eliminacion logica fue exitosa
    IF EXISTS (SELECT 1 FROM productos.IMPORTADO WHERE id_producto = @id_producto AND es_valido = 0)
        PRINT 'TEST PASADO - Borrado lógico de importado exitoso.';
    ELSE
        PRINT 'TEST FALLIDO - Error en borrado lógico de importad';

    -- Muestro los datos del importado despues de la eliminacion logica
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Elimino los datos de prueba
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;

END;
GO

-- Ejecuta el test
EXEC borrado.TestEliminarImportadoLogico;
GO

-- Test de eliminación lógica exitosa de cargo
CREATE OR ALTER PROCEDURE borrado.TestEliminarCargoLogico_Exitoso
AS
BEGIN
    DECLARE @id INT,
			@es_valido INT;

    -- Insertar cargo de prueba activo
    INSERT INTO seguridad.CARGO (nombre, es_valido) 
    VALUES ('Test Cargo', 1);
    SET @id = SCOPE_IDENTITY();

    -- Muestro los datos del cargo
    SELECT * FROM seguridad.CARGO WHERE id = @id;

    -- Intentar ejecutar el procedimiento de eliminación lógica
    BEGIN TRY
        EXEC borrado.EliminarCargoLogico @id;
		SELECT * FROM seguridad.CARGO WHERE id = @id;

        -- Verificar si la eliminación lógica fue exitosa
        SELECT @es_valido = es_valido FROM seguridad.CARGO WHERE id = @id;

        IF @es_valido = 0
			BEGIN
				PRINT 'TEST PASADO - Borrado lógico de cargo.';
			END
        ELSE
			BEGIN
				PRINT 'TEST FALLIDO - No se eliminó el registro de la tabla cargo.';
			END

    END TRY
    BEGIN CATCH
        -- Captura y muestra cualquier error inesperado
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH;

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
    BEGIN TRY
        DECLARE @id INT, @id_sucursal INT, @legajo INT;

        -- Inserta cargo de prueba activo
        INSERT INTO seguridad.CARGO (nombre, es_valido) VALUES ('Test Cargo', 1);
        SET @id = SCOPE_IDENTITY();

        -- Insertar sucursal de prueba
        INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
        VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
        SET @id_sucursal = SCOPE_IDENTITY();

        -- Calcular el legajo para el nuevo empleado
        SELECT @legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

        -- Insertar un empleado asociado al cargo
        INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno)
        VALUES (@legajo, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id, @id_sucursal, 'Mañana');

        -- Intentar ejecutar el procedimiento de eliminación lógica
        EXEC borrado.EliminarCargoLogico @id;

        PRINT 'TEST FALLIDO - No se produjo el error esperado al intentar eliminar el cargo con empleados asociados.';
    END TRY
    BEGIN CATCH
        -- Verificar si el error es el 130002
        IF ERROR_NUMBER() = 130002
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
			END
        ELSE
			BEGIN
				PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH;

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
    -- Declaro un id inexistente
    DECLARE @id_inexistente INT = -10,
			@id_inactivo INT;

    BEGIN TRY

	-- Muestro que no hay registros con ese id
		SELECT * FROM seguridad.CARGO WHERE id = @id_inexistente;

        EXEC borrado.EliminarCargoLogico @id_inexistente;  -- ID generado que no existe
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un cargo inexistente.';
    END TRY
    BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
			END
        ELSE
			BEGIN
				PRINT 'TEST FALLIDO - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH

    -- Insertar cargo de prueba inactivo
    INSERT INTO seguridad.CARGO (nombre, es_valido) VALUES ('Cargo Inactivo', 0);
    SET @id_inactivo = SCOPE_IDENTITY();

	-- Muestro el cargo inactivo
	SELECT * FROM seguridad.CARGO WHERE id = @id_inactivo;

    -- Intentar ejecutar el procedimiento de eliminación lógica en un cargo inactivo
    BEGIN TRY
        EXEC borrado.EliminarCargoLogico @id_inactivo;

        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un cargo inactivo.';
    END TRY
    BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
			END
        ELSE
			BEGIN
				PRINT 'TEST FALLIDO - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH

    -- Limpiar datos de prueba
    DELETE FROM seguridad.CARGO WHERE id = @id_inactivo;

END;
GO

-- Ejecutar el test
EXEC borrado.TestEliminarCargoLogico_InactivoOInexistente;
GO

-- BIEN

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

        -- Verifico si la eliminación lógica fue exitosa
        DECLARE @es_valido INT;
        SELECT @es_valido = es_valido FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

        IF @es_valido = 0
			BEGIN
				PRINT 'TEST PASADO - Borrado lógico de sucursal.';
			END
        ELSE
			BEGIN
				PRINT 'TEST FALLIDO - No se eliminó el registro de la tabla sucursal.';
			END

    END TRY
    BEGIN CATCH
        -- Capturo cualquier error inesperado
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH;

    -- Muestra el registro después de la eliminación lógica para confirmar el cambio
    SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    -- Elimino los datos de prueba físicamente
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

END;
GO

-- Ejecutar el test
EXEC borrado.TestEliminarSucursalExito;
GO

-- BIEN

CREATE OR ALTER PROCEDURE borrado.TestEliminarSucursalConEmpleados
AS
BEGIN
    BEGIN TRY
        DECLARE @id_cargo INT, @id_sucursal INT;

        -- Inserto cargo de prueba
        INSERT INTO seguridad.CARGO (nombre, es_valido)
        VALUES ('Cargo Prueba', 1);
        SET @id_cargo = SCOPE_IDENTITY();

        -- Inserto sucursal de prueba
        INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido)
        VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba', 1);
        SET @id_sucursal = SCOPE_IDENTITY();

        -- Inserto un empleado asociado a la sucursal y el cargo previamente insertado
        INSERT INTO seguridad.EMPLEADO (nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
        VALUES ('Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Mañana', 1);

        -- Muestro los registros insertados
        SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
        SELECT * FROM seguridad.EMPLEADO WHERE id_sucursal = @id_sucursal;

        -- Intento ejecutar el procedimiento de eliminación lógica
        EXEC borrado.EliminarSucursalLogico @id_sucursal;

        -- Si no ocurre un error, imprimo que el test ha fallado
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar la sucursal con empleados activos.';
    END TRY
    BEGIN CATCH
        -- Verificar si el error es el esperado (130002 - dependencias)
        IF ERROR_NUMBER() = 130002
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
			END
        ELSE
			BEGIN
				PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH;

    -- Limpiar los datos de prueba (eliminación física)
    DELETE FROM seguridad.EMPLEADO WHERE id_sucursal = @id_sucursal;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    DELETE FROM seguridad.CARGO WHERE id = @id_cargo;

END;
GO



-- TEST BORRADO LOGICO DE SUCURSAL NO ACTIVA O INEXISTENTE (DEBE DAR ERROR)
CREATE OR ALTER PROCEDURE borrado.TestEliminarSucursalNoActivaOInexistente
AS
BEGIN
    -- Obtengo el máximo id de la tabla y le sumo 1 para generar un id que no exista
    DECLARE @id_inexistente INT = -30;


    -- Intentar eliminar una sucursal inexistente
    BEGIN TRY

		-- Muestra que no hay registros con ese id
        SELECT * FROM seguridad.SUCURSAL WHERE id = @id_inexistente;

        -- Intento eliminar una sucursal con un id que no existe 
        EXEC borrado.EliminarSucursalLogico @id_inexistente;
        
        -- Si no lanza error, el test ha fallado
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar una sucursal inexistente.';
    END TRY
    
	BEGIN CATCH
        -- Comparar el número de error con 130001
        IF ERROR_NUMBER() = 130001
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
	
			END
		ELSE
			BEGIN
				PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
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
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
	
			END
		ELSE
			BEGIN
				PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH

    -- Elimino los datos de prueba físicamente si es necesario
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
END;
GO

-- EJECUTAR EL TEST
EXEC borrado.TestEliminarSucursalNoActivaOInexistente;
GO

-- BIEN

CREATE OR ALTER PROCEDURE borrado.TestEliminarEmpleadoLogico_Exitoso
AS
BEGIN
    BEGIN TRY
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

        -- Verificar eliminación
        SELECT * FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;

        -- Verificar que el empleado fue desactivado
        IF EXISTS (SELECT 1 FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo AND es_valido = 0)
            PRINT 'TEST PASADO - Borrado lógico de empleado exitoso.';
        ELSE
            PRINT 'TEST FALLIDO - Error en borrado lógico de empleado exitoso.';

        -- Limpiar datos de prueba
        DELETE FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;
        DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
        DELETE FROM seguridad.CARGO WHERE id = @id_cargo;

    END TRY
    BEGIN CATCH

        -- Capturar errores y mostrar mensaje
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Ejecutar el test
EXEC borrado.TestEliminarEmpleadoLogico_Exitoso;
GO

-- BIEN


-- Ejecutar el procedimiento de prueba
EXEC borrado.TestEliminarEmpleadoLogico_Exitoso;
GO

CREATE OR ALTER PROCEDURE borrado.TestEliminarEmpleadoNoExistenteOInactivo
AS
BEGIN
    BEGIN TRY
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

        -- Desactivar el empleado insertado (para probar la eliminación de un empleado inactivo)
        UPDATE seguridad.EMPLEADO SET es_valido = 0 WHERE legajo = @nuevo_legajo;

        -- Intentar eliminar un empleado que no existe (tomando el máximo legajo existente + 1)
        BEGIN TRY
            DECLARE @legajo_inexistente INT;
            SELECT @legajo_inexistente = MAX(legajo) + 1 FROM seguridad.EMPLEADO;
            EXEC borrado.EliminarEmpleadoLogico @legajo_inexistente;  -- Un legajo que no existe
            PRINT 'TEST FALLIDO - Se eliminó un empleado inexistente.';
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() = 130001
                PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
            ELSE
                THROW;
        END CATCH

        -- Intentar eliminar un empleado que está inactivo
        BEGIN TRY
            EXEC borrado.EliminarEmpleadoLogico @nuevo_legajo;  -- Empleado que está inactivo
            PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un empleado inactivo.';
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() = 130001
                PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
            ELSE
                THROW;
        END CATCH

        -- Limpiar datos de prueba
        DELETE FROM seguridad.EMPLEADO WHERE legajo = @nuevo_legajo;
        DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
        DELETE FROM seguridad.CARGO WHERE id = @id_cargo;

    END TRY
    BEGIN CATCH
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC borrado.TestEliminarEmpleadoNoExistenteOInactivo;
GO

-- BIEN

-- TEST DELETE TELEFONO ÉXITO
CREATE OR ALTER PROCEDURE borrado.TestEliminarTelefonoFisico
AS
BEGIN

    DECLARE @id_sucursal INT,
			@telefono_prueba CHAR (9) = '0000-0000';

	BEGIN TRY

	-- Insertar sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    
	SET @id_sucursal = SCOPE_IDENTITY();


    -- Insertar dato de prueba en la tabla TELEFONO
	INSERT INTO seguridad.TELEFONO (id_sucursal, telefono) VALUES (@id_sucursal, @telefono_prueba);
		
	SELECT * FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono_prueba;


		
        -- Ejecutar el procedimiento de eliminación pasándole un teléfono que no existe
        EXEC borrado.EliminarTelefonoFisico @id_sucursal = @id_sucursal, @telefono = '0000-0000';

        -- Verificar si el registro fue eliminado
        IF NOT EXISTS (SELECT 1 FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono_prueba)
        BEGIN
            PRINT 'TEST PASADO - Eliminación física de TELEFONO exitosa';
			SELECT * FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono_prueba;

        END
        ELSE
			BEGIN
				PRINT 'TEST FALLIDO - El teléfono no se eliminó correctamente';
			END
    END TRY
    BEGIN CATCH
        -- Capturar y mostrar el error si ocurre
        PRINT 'TEST FALLIDO - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Ejecutar la prueba
EXEC borrado.TestEliminarTelefonoFisico;
GO

-- BIEN

-- TEST DE ELIMINACIÓN FÍSICA DE TELÉFONO NO EXISTENTE (CASO DE FALLA)
CREATE OR ALTER PROCEDURE borrado.TestEliminarTelefonoFisico_Fallido
AS
BEGIN
    BEGIN TRY
        -- Inserto una sucursal de prueba activa
        INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia, es_valido)
        VALUES ('9:00-18:00', 'Ciudad de prueba', 'Reemplazo prueba', 'Calle de prueba 123', '54321', 'Provincia de Prueba', 1);
        DECLARE @id_sucursal INT = SCOPE_IDENTITY();  -- Capturo el ID de la sucursal insertada

		-- Muestro que el registro no existe

		SELECT * FROM seguridad.TELEFONO WHERE @id_sucursal = @id_sucursal AND telefono = '0000-0000';

        -- Intentar eliminar un teléfono que no existe para esta sucursal
        BEGIN TRY
            EXEC borrado.EliminarTelefonoFisico @id_sucursal = @id_sucursal, @telefono = '0000-0000';

            -- Si no se lanza error, significa que el test falló
            PRINT 'TEST FALLIDO - Se eliminó un teléfono inexistente.';
        END TRY
        BEGIN CATCH
            IF ERROR_NUMBER() = 130001
                PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
            ELSE
                THROW; -- Relanzar el error si no es el esperado
        END CATCH

        -- Eliminar la sucursal de prueba
        DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    END TRY
    BEGIN CATCH

        -- Manejar cualquier error inesperado fuera de los casos probados
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC borrado.TestEliminarTelefonoFisico_Fallido;
GO

-- BIEN

-- TEST DELETE VENTA
CREATE OR ALTER PROCEDURE borrado.TestEliminarVentaFisico
AS
BEGIN
    BEGIN TRY
        -- Declarar variables para el ID de la venta y las dependencias
        DECLARE @id_cliente INT,
                @id_producto INT,
                @id_medio_pago INT,
                @id_sucursal INT,
                @id_cargo INT,
                @legajo INT,
                @id_empleado INT,
                @id_categoria INT,
                @id_factura CHAR(11),
                @id_venta INT;

        -- Insertar un Cliente de prueba
        INSERT INTO seguridad.CLIENTE (genero) VALUES ('Female');
        SET @id_cliente = SCOPE_IDENTITY();

        -- Insertar una categoría de prueba
        INSERT INTO seguridad.CATEGORIA (descripcion) VALUES ('Categoria de prueba');
        SET @id_categoria = SCOPE_IDENTITY();

        -- Insertar un producto de prueba
        INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
        VALUES (100, 'Nombre prueba', @id_categoria, 1);
        SET @id_producto = SCOPE_IDENTITY();

        -- Insertar un medio de pago de prueba
        INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion_ingles, descripcion)
        VALUES ('Credit Card', 'Tarjeta de Crédito');
        SET @id_medio_pago = SCOPE_IDENTITY();

        -- Insertar una factura de prueba
        INSERT INTO transacciones.FACTURA (id, tipo_de_factura, estado)
        VALUES ('000-00-0000', 'A', 1);
        SET @id_factura = SCOPE_IDENTITY();

        -- Obtener el máximo legajo y sumarle 1
        SELECT @legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

        -- Insertar un empleado de prueba
        INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
        VALUES (@legajo, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Mañana', 1);
        SET @id_empleado = SCOPE_IDENTITY();

        -- Insertar una venta de prueba
        INSERT INTO transacciones.VENTA (id_factura, id_sucursal, id_producto, cantidad, fecha, hora, id_medio_de_pago, id_empleado, identificador_de_pago)
        VALUES (@id_factura, @id_sucursal, @id_producto, 5, '2024-11-13', '14:35:00', @id_medio_pago, @id_empleado, '1111222233334444555566');
        SET @id_venta = SCOPE_IDENTITY();

		-- Muestro la inserción del registro
		SELECT * FROM transacciones.VENTA WHERE id = @id_venta;

        -- Llamar al procedimiento de eliminación de venta
        EXEC borrado.EliminarVentaFisico @id_venta;

		-- Verifico que se haya eliiminado
		SELECT * FROM transacciones.VENTA WHERE id = @id_venta;

        -- Verificar si la venta se eliminó correctamente
        IF NOT EXISTS (SELECT 1 FROM transacciones.VENTA WHERE id = @id_venta)
            PRINT 'TEST PASADO - Eliminación física de venta exitosa';
        ELSE
            PRINT 'TEST FALLIDO - La venta no se eliminó correctamente';

        -- Limpiar datos de prueba
        DELETE FROM seguridad.CLIENTE WHERE id = @id_cliente;
        DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
        DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
        DELETE FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio_pago;
        DELETE FROM transacciones.FACTURA WHERE id = @id_factura;
        DELETE FROM seguridad.EMPLEADO WHERE legajo = @legajo;

    END TRY
    BEGIN CATCH
        -- Capturar y mostrar el mensaje de error en caso de problemas inesperados
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC borrado.TestEliminarVentaFisico;
GO

-- BIEN


-- TEST ELIMINAR CLIENTE QUE NO EXISTE (DEBE DAR ERROR)
CREATE OR ALTER PROCEDURE borrado.TestEliminarClienteInexistente
AS
BEGIN
    BEGIN TRY
        -- Declarar un ID de cliente inexistente
        DECLARE @id_cliente_inexistente INT = -1; -- ID que no existe en CLIENTE

        -- Mostrar el registro antes de intentar la eliminación (no debería existir)	
        SELECT * FROM seguridad.CLIENTE WHERE id = @id_cliente_inexistente;

        -- Intentar ejecutar el procedimiento de eliminación con un cliente inexistente
        EXEC borrado.EliminarClienteFisico @id_cliente = @id_cliente_inexistente;

        -- Si no se lanza error, el test falla
        PRINT 'TEST FALLIDO - No se generó error al intentar eliminar un cliente inexistente.';
    END TRY
    BEGIN CATCH

        IF ERROR_NUMBER() = 130001
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
			END
        ELSE
			BEGIN
				PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH
END;
GO

-- Ejecutar la prueba
EXEC borrado.TestEliminarClienteInexistente;
GO

-- BIEN

-- Test de eliminación física exitosa de TIPO
CREATE OR ALTER PROCEDURE borrado.TestEliminarTipoFisicoExitoso
AS
BEGIN

	DECLARE @id INT;
    
	-- Insertar un tipo de prueba
    INSERT INTO seguridad.TIPO (nombre) VALUES ('Tipo de Cliente Prueba');
    SET @id = SCOPE_IDENTITY();  -- Obtener el ID del tipo insertado

    BEGIN TRY

		-- Muestro el registro insertado
		SELECT * FROM seguridad.TIPO WHERE id = @id;

        -- Intentar eliminar físicamente el tipo
        EXEC borrado.EliminarTipoFisico @id;

		-- Muestro luego de la eliminación
		SELECT * FROM seguridad.TIPO WHERE id = @id;
        
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
    DECLARE @id_inexistente INT = -1;

    BEGIN TRY

		SELECT * FROM seguridad.TIPO WHERE id = @id_inexistente;
        -- Intentar eliminar el tipo inexistente
        EXEC borrado.EliminarTipoFisico @id_inexistente;
        
        PRINT 'TEST FALLIDO - No se produjo error al intentar eliminar un tipo inexistente.';
    END TRY
    BEGIN CATCH
        -- Verificar si el código de error es 130001
        IF ERROR_NUMBER() = 130001
			BEGIN
				PRINT 'TEST PASADO - ERROR ESPERADO: ' + ERROR_MESSAGE();
			END
        ELSE
			BEGIN
				PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
			END
    END CATCH
END;
GO

EXEC borrado.TestEliminarTipoFisicoError;
GO


CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoLogicoExitoso
AS
BEGIN
    BEGIN TRY
        DECLARE @id_medio INT;

        -- Insertar un medio de pago de prueba
        INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion_ingles, descripcion, es_valido)
        VALUES ('Test Payment Method', 'Método de Pago de Prueba', 1);

        -- Obtener el ID del medio de pago insertado
        SET @id_medio = SCOPE_IDENTITY();

        -- Verificar el medio de pago insertado (antes de la eliminación lógica)
        SELECT * FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio;

        -- Ejecutar el procedimiento para la eliminación lógica
        EXEC borrado.EliminarMedioDePagoLogico @id_medio;

        -- Verificar el medio de pago después de la eliminación lógica
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

        -- Limpieza de datos de prueba
        DELETE FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio;

    END TRY
    BEGIN CATCH

        -- Manejo de errores
        PRINT 'TEST PROBLEMS - ERROR INESPERADO: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


EXEC borrado.EliminarMedioDePagoLogicoExitoso;
GO

-- BIEN



CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoLogicoFallido
AS
BEGIN
    DECLARE @id_medio INT, @error_message NVARCHAR(255);

	BEGIN TRY
		-- Intentar eliminar un medio de pago con ID negativo
		BEGIN TRY
			EXEC borrado.EliminarMedioDePagoLogico -1;
			PRINT 'TEST FALLIDO - No se generó el error esperado para ID negativo';
		END TRY
		BEGIN CATCH
      
			IF ERROR_NUMBER() = 130001
				PRINT 'TEST PASADO - Error esperado al intentar eliminar medio de pago que no existe';
			ELSE
				THROW;
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
				THROW;
		END CATCH
	END TRY

	BEGIN CATCH
		PRINT 'TEST FALLIDO - Error inesperado: ' + ERROR_MESSAGE();
	END CATCH
END;
GO

EXEC borrado.EliminarMedioDePagoLogicoFallido;
GO

-- BIEN



CREATE OR ALTER PROCEDURE borrado.EliminarFacturaFisicoExitoso
AS
BEGIN
    DECLARE @id_factura CHAR(11) = '123-45-67890';

	BEGIN TRY
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
	END TRY

	BEGIN CATCH
		PRINT 'TEST FALLIDO - Error inesperado: ' + ERROR_MESSAGE();
	END CATCH
END;
GO

EXEC borrado.EliminarFacturaFisicoExitoso;
GO

-- BIEN


CREATE OR ALTER PROCEDURE borrado.EliminarNotaCreditoFisicoExitoso
AS
BEGIN
    DECLARE @id INT;
	
	BEGIN TRY

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

	END TRY

	BEGIN CATCH
		PRINT 'TEST FALLIDO - Error inesperado: ' + ERROR_MESSAGE();
	END CATCH
END;
GO

EXEC borrado.EliminarNotaCreditoFisicoExitoso;
GO


