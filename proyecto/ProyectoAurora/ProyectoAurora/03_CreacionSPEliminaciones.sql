USE Com5600G08
GO

--CREAMOS SCHEMA PARA BORRADO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'borrado')
    EXEC('CREATE SCHEMA borrado');
GO

-- Store Procedure para eliminaci�n l�gica en CATEGORIA (con borrado en cascada en PRODUCTO)
CREATE OR ALTER PROCEDURE borrado.EliminarCategoriaLogico
    @id_categoria INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Borrado l�gico en la tabla 'CATEGORIA'
        UPDATE seguridad.CATEGORIA
        SET esValido = 0
        WHERE id = @id_categoria;

        -- Borrado l�gico en cascada en la tabla 'PRODUCTO'
        UPDATE productos.PRODUCTO
        SET esValido = 0
        WHERE id_categoria = @id_categoria;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Store Procedure para eliminaci�n f�sica en CARGO
CREATE OR ALTER PROCEDURE borrado.EliminarCargoFisico
    @id_cargo INT
AS
BEGIN
    DELETE FROM seguridad.CARGO
    WHERE id = @id_cargo;
END;
GO

-- Store Procedure para eliminaci�n f�sica en SUCURSAL
CREATE OR ALTER PROCEDURE borrado.EliminarSucursalFisico
    @id_sucursal INT
AS
BEGIN
    DELETE FROM seguridad.SUCURSAL
    WHERE id = @id_sucursal;
END;
GO

-- Store Procedure para eliminaci�n f�sica en TELEFONO
CREATE OR ALTER PROCEDURE borrado.EliminarTelefonoFisico
    @id_sucursal INT
AS
BEGIN
    DELETE FROM seguridad.TELEFONO
    WHERE id_sucursal = @id_sucursal;
END;
GO

-- Store Procedure para eliminaci�n l�gica en EMPLEADO
CREATE OR ALTER PROCEDURE borrado.EliminarEmpleadoLogico
    @legajo INT
AS
BEGIN
    UPDATE seguridad.EMPLEADO
    SET esValido = 0
    WHERE legajo = @legajo;
END;
GO

-- Store Procedure para eliminaci�n f�sica en CARGO
CREATE OR ALTER PROCEDURE borrado.EliminarNotaCreditoFisico
    @id INT
AS
BEGIN
    DELETE FROM transacciones.NOTA_CREDITO
    WHERE id = @id;
END;
GO

-- Store Procedure para eliminaci�n f�sica en FACTURA
CREATE OR ALTER PROCEDURE borrado.EliminarFacturaFisico
    @id_factura CHAR(11)
AS
BEGIN
    DELETE FROM transacciones.FACTURA
    WHERE id = @id_factura;
END;
GO

-- Store Procedure para eliminaci�n f�sica en MEDIO_DE_PAGO
CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoFisico
    @id_medio INT
AS
BEGIN
    DELETE FROM transacciones.MEDIO_DE_PAGO
    WHERE id = @id_medio;
END;
GO

-- Store Procedure para eliminaci�n f�sica en VENTA
CREATE OR ALTER PROCEDURE borrado.EliminarVentaFisico
    @id_venta INT
AS
BEGIN
    DELETE FROM transacciones.VENTA
    WHERE id = @id_venta;
END;
GO

-- Store Procedure para eliminaci�n f�sica en IMPORTADO
CREATE OR ALTER PROCEDURE borrado.EliminarImportadoFisico
    @id_producto INT
AS
BEGIN
    DELETE FROM productos.IMPORTADO
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminaci�n f�sica en VARIOS
CREATE OR ALTER PROCEDURE borrado.EliminarVariosFisico
    @id_producto INT
AS
BEGIN
    DELETE FROM productos.VARIOS
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminaci�n f�sica en ELECTRONICO
CREATE OR ALTER PROCEDURE borrado.EliminarElectronicoFisico
    @id_producto INT
AS
BEGIN
    DELETE FROM productos.ELECTRONICO
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminaci�n l�gica en PRODUCTO
CREATE OR ALTER PROCEDURE borrado.EliminarProductoLogico
    @id_producto INT
AS
BEGIN
    UPDATE productos.PRODUCTO
    SET esValido = 0
    WHERE id_producto = @id_producto;
END;
GO


