/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 3											#
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

--CREAMOS SCHEMA PARA BORRADO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'borrado')
    EXEC('CREATE SCHEMA borrado');
GO

-- Store Procedure para eliminación lógica en CATEGORIA (con borrado en cascada en PRODUCTO)
CREATE OR ALTER PROCEDURE borrado.EliminarCategoriaLogico
    @id_categoria INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Borrado lógico en la tabla 'CATEGORIA'
        UPDATE seguridad.CATEGORIA
        SET esValido = 0
        WHERE id = @id_categoria;

        -- Borrado lógico en cascada en la tabla 'PRODUCTO'
        UPDATE productos.PRODUCTO
        SET esValido = 0, fecha_eliminacion = GETDATE()
        WHERE id_categoria = @id_categoria;

        -- Borrado lógico en cascada en las tablas 'IMPORTADO', 'VARIOS' y 'ELECTRONICO'
        UPDATE productos.IMPORTADO
        SET esValido = 0
        WHERE id_producto IN (SELECT id_producto FROM productos.PRODUCTO WHERE id_categoria = @id_categoria);

        UPDATE productos.VARIOS
        SET esValido = 0
        WHERE id_producto IN (SELECT id_producto FROM productos.PRODUCTO WHERE id_categoria = @id_categoria);

        UPDATE productos.ELECTRONICO
        SET esValido = 0
        WHERE id_producto IN (SELECT id_producto FROM productos.PRODUCTO WHERE id_categoria = @id_categoria);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- PROCEDIMIENTO DE ELIMINACIÓN LÓGICA EN CASCADA
CREATE OR ALTER PROCEDURE borrado.EliminarCargoLogico
    @id_cargo INT
AS
BEGIN
    -- ELIMINACIÓN LÓGICA DE LOS EMPLEADOS ASOCIADOS AL CARGO
    UPDATE seguridad.EMPLEADO
    SET esValido = 0
    WHERE id_cargo = @id_cargo;

    -- ELIMINACIÓN LÓGICA DEL CARGO
    UPDATE seguridad.CARGO
    SET esValido = 0
    WHERE id = @id_cargo;
END;
GO



-- Store Procedure para eliminación física en SUCURSAL
CREATE OR ALTER PROCEDURE borrado.EliminarSucursalFisico
    @id_sucursal INT
AS
BEGIN
    DELETE FROM seguridad.SUCURSAL
    WHERE id = @id_sucursal;
END;
GO

-- Store Procedure para eliminación física en TELEFONO
CREATE OR ALTER PROCEDURE borrado.EliminarTelefonoFisico
    @id_sucursal INT
AS
BEGIN
    DELETE FROM seguridad.TELEFONO
    WHERE id_sucursal = @id_sucursal;
END;
GO

-- Store Procedure para eliminación lógica en EMPLEADO
CREATE OR ALTER PROCEDURE borrado.EliminarEmpleadoLogico
    @legajo INT
AS
BEGIN
    UPDATE seguridad.EMPLEADO
    SET esValido = 0
    WHERE legajo = @legajo;
END;
GO

-- Store Procedure para eliminación física en CARGO
CREATE OR ALTER PROCEDURE borrado.EliminarNotaCreditoFisico
    @id INT
AS
BEGIN
    DELETE FROM transacciones.NOTA_CREDITO
    WHERE id = @id;
END;
GO

-- Store Procedure para eliminación física en FACTURA
CREATE OR ALTER PROCEDURE borrado.EliminarFacturaFisico
    @id_factura CHAR(11)
AS
BEGIN
    DELETE FROM transacciones.FACTURA
    WHERE id = @id_factura;
END;
GO

-- Store Procedure para eliminación física en MEDIO_DE_PAGO
CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoFisico
    @id_medio INT
AS
BEGIN
    DELETE FROM transacciones.MEDIO_DE_PAGO
    WHERE id = @id_medio;
END;
GO

-- Store Procedure para eliminación física en VENTA
CREATE OR ALTER PROCEDURE borrado.EliminarVentaFisico
    @id_venta INT
AS
BEGIN
    DELETE FROM transacciones.VENTA
    WHERE id = @id_venta;
END;
GO

-- Store Procedure para eliminación física en IMPORTADO
CREATE OR ALTER PROCEDURE borrado.EliminarImportadoLogico
    @id_producto INT
AS
BEGIN
    UPDATE productos.IMPORTADO
    SET esValido = 0
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminación física en VARIOS
CREATE OR ALTER PROCEDURE borrado.EliminarVariosLogico
    @id_producto INT
AS
BEGIN
    UPDATE productos.VARIOS
    SET esValido = 0
    WHERE id_producto = @id_producto;
END;
GO

-- Store Procedure para eliminación lógica en ELECTRONICO
CREATE OR ALTER PROCEDURE borrado.EliminarElectronicoLogico
    @id_producto INT
AS
BEGIN
    UPDATE productos.ELECTRONICO
    SET esValido = 0
    WHERE id_producto = @id_producto;
END;
GO


-- Store Procedure para eliminación lógica en PRODUCTO
CREATE OR ALTER PROCEDURE borrado.EliminarProductoLogico
    @id_producto INT
AS
BEGIN
    UPDATE productos.PRODUCTO
    SET esValido = 0, fecha_eliminacion = GETDATE()
    WHERE id_producto = @id_producto;
END;
GO


