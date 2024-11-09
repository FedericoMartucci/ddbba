USE Com5600G08;

GO

SET NOCOUNT ON;

GO

CREATE OR ALTER PROCEDURE borrado.TestEliminarCategoriaLogico
AS
BEGIN

    DECLARE @esValidoCategoria INT;
    DECLARE @esValidoProducto1 INT;
    DECLARE @esValidoProducto2 INT;
    DECLARE @id_categoria INT;

    -- INSERTO DATO DE PRUEBA EN LA TABLA CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, esValido)
    VALUES ('Categoria de prueba', 1);

    -- OBTENGO EL ID DE LA CATEGORIA INSERTADA
    SET @id_categoria = SCOPE_IDENTITY();

    INSERT INTO productos.PRODUCTO (nombre_producto, id_categoria, esValido)
    VALUES 
        ('Producto 1', @id_categoria, 1),
        ('Producto 2', @id_categoria, 1);
	
	SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
	SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;

    -- CASO 1: ESTA EJECUCION DEBE SER EXITOSA
    EXEC borrado.EliminarCategoriaLogico @id_categoria = @id_categoria;

    -- COMPRUEBO SI LA CATEGORIA SE ELIMIN� DE FORMA LOGICA CORRECTAMENTE
    SELECT @esValidoCategoria = esValido FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    IF (@esValidoCategoria = 0)
        PRINT 'CATEGOR�A ELIMINADA DE FORMA L�GICA CORRECTAMENTE.';
    ELSE
        PRINT 'ERROR - LA CATEGOR�A NO FUE ELIMINADA DE FORMA L�GICA CORRECTAMENTE.';

    -- COMPRUEBO SI LOS PRODUCTOS SE ELIMINARON DE FORMA L�GICA CORRECTAMENTE
    SELECT @esValidoProducto1 = esValido FROM productos.PRODUCTO WHERE id_producto = 1;
    SELECT @esValidoProducto2 = esValido FROM productos.PRODUCTO WHERE id_producto = 2;

    IF (@esValidoProducto1 = 0 AND @esValidoProducto2 = 0)
        PRINT 'PRODUCTOS DE ESA CATEGOR�A ELIMINADOS DE FORMA L�GICA CORRECTAMENTE.';
    ELSE
        PRINT 'ERROR - PRODUCTOS DE ESA CATEGOR�A NO FUERON ELIMINADOS CORRECTAMENTE.';

    -- INTENTO BORRAR UNA CATEGOR�A INEXISTENTE
    BEGIN TRY
        EXEC borrado.EliminarCategoriaLogico @id_categoria = 999;
        PRINT 'NO SE GENER� ERROR AL ELIMINAR UNA CATEGOR�A INEXISTENTE.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR - SE GENER� UNA EXCEPCI�N AL ELIMINAR UNA CATEGOR�A INEXISTENTE.';
    END CATCH;

	SELECT * FROM seguridad.CATEGORIA WHERE id = @id_categoria;
	SELECT * FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;

    -- ELIMINO LOS DATOS DE PRUEBA
    DELETE FROM productos.PRODUCTO WHERE id_categoria = @id_categoria;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
END;
GO

EXEC borrado.TestEliminarCategoriaLogico;


