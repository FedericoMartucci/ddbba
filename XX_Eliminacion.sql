-- Store Procedure para eliminación lógica en CATEGORIA (con borrado en cascada en PRODUCTO)
CREATE PROCEDURE aurora.EliminarCategoriaLogico
    @id_categoria INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Borrado lógico en la tabla 'CATEGORIA'
        UPDATE aurora.CATEGORIA
        SET esValido = 0
        WHERE id = @id_categoria;

        -- Borrado lógico en cascada en la tabla 'PRODUCTO'
        UPDATE aurora.PRODUCTO
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

-- Store Procedure para eliminación física en CARGO
CREATE PROCEDURE aurora.EliminarCargoFisico
    @id_cargo INT
AS
BEGIN
    DELETE FROM aurora.CARGO
    WHERE id = @id_cargo;
END;
GO

-- Store Procedure para eliminación física en SUCURSAL
CREATE PROCEDURE aurora.EliminarSucursalFisico
    @id_sucursal INT
AS
BEGIN
    DELETE FROM aurora.SUCURSAL
    WHERE id = @id_sucursal;
END;
GO

-- Store Procedure para eliminación física en TELEFONO
CREATE PROCEDURE aurora.EliminarTelefonoFisico
    @id_sucursal INT
AS
BEGIN
    DELETE FROM aurora.TELEFONO
    WHERE id_sucursal = @id_sucursal;
END;
GO

-- Store Procedure para eliminación lógica en EMPLEADO
CREATE PROCEDURE aurora.EliminarEmpleadoLogico
    @legajo INT
AS
BEGIN
    UPDATE aurora.EMPLEADO
    SET esValido = 0
    WHERE legajo = @legajo;
END;
GO

-- Store Procedure para eliminación física en FACTURA
CREATE PROCEDURE aurora.EliminarFacturaFisico
    @id_factura CHAR(11)
AS
BEGIN
    DELETE FROM aurora.FACTURA
    WHERE id = @id_factura;
END;
GO

-- Store Procedure para eliminación física en MEDIO_DE_PAGO
CREATE PROCEDURE aurora.EliminarMedioDePagoFisico
    @id_medio INT
AS
BEGIN
    DELETE FROM aurora.MEDIO_DE_PAGO
    WHERE id = @id_medio;
END;
GO

-- Store Procedure para eliminación física en VENTA
CREATE PROCEDURE aurora.EliminarVentaFisico
    @id_venta INT
AS
BEGIN
    DELETE FROM aurora.VENTA
    WHERE id = @id_venta;
END;
GO

-- Store Procedure para eliminación física en IMPORTADO
CREATE PROCEDURE aurora.EliminarImportadoFisico
    @id_producto INT
AS
BEGIN
    DELETE FROM aurora.IMPORTADO
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminación física en VARIOS
CREATE PROCEDURE aurora.EliminarVariosFisico
    @id_producto INT
AS
BEGIN
    DELETE FROM aurora.VARIOS
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminación física en ELECTRONICO
CREATE PROCEDURE aurora.EliminarElectronicoFisico
    @id_producto INT
AS
BEGIN
    DELETE FROM aurora.ELECTRONICO
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminación lógica en PRODUCTO
CREATE PROCEDURE aurora.EliminarProductoLogico
    @id_producto INT
AS
BEGIN
    UPDATE aurora.PRODUCTO
    SET esValido = 0
    WHERE id_producto = @id_producto;
END;
GO

 SP_EXECUTESQL


