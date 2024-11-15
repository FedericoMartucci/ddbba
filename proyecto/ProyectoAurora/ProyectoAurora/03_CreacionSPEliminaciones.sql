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
        -- Verificar si la categoría existe y está activa
        IF NOT EXISTS (SELECT 1 FROM seguridad.CATEGORIA WHERE id = @id_categoria AND es_valido = 1)
        BEGIN
            RAISERROR(130001, 16, 1);
            RETURN;
        END

        -- Borrado lógico en la tabla 'CATEGORIA'
        UPDATE seguridad.CATEGORIA
        SET es_valido = 0
        WHERE id = @id_categoria;

        -- Borrado lógico en cascada en la tabla 'PRODUCTO'
        UPDATE productos.PRODUCTO
        SET es_valido = 0, fecha_eliminacion = GETDATE()
        WHERE id_categoria = @id_categoria;

        -- Borrado lógico en cascada en las tablas 'IMPORTADO', 'VARIOS' y 'ELECTRONICO'
        UPDATE productos.IMPORTADO
        SET es_valido = 0
        WHERE id_producto IN (SELECT id_producto FROM productos.PRODUCTO WHERE id_categoria = @id_categoria);

        UPDATE productos.VARIOS
        SET es_valido = 0
        WHERE id_producto IN (SELECT id_producto FROM productos.PRODUCTO WHERE id_categoria = @id_categoria);

        UPDATE productos.ELECTRONICO
        SET es_valido = 0
        WHERE id_producto IN (SELECT id_producto FROM productos.PRODUCTO WHERE id_categoria = @id_categoria);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- Procedimiento de eliminación lógica en CARGO
CREATE OR ALTER PROCEDURE borrado.EliminarCargoLogico
    @id_cargo INT
AS
BEGIN
    -- Verificar si el cargo existe y está activo
    IF NOT EXISTS (SELECT 1 FROM seguridad.CARGO WHERE id = @id_cargo AND es_valido = 1)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    -- Verificar si hay empleados asociados al cargo
    IF EXISTS (SELECT 1 FROM seguridad.EMPLEADO WHERE id_cargo = @id_cargo AND es_valido = 1)
    BEGIN
        RAISERROR(130002, 16, 1);
        RETURN;
    END

    -- Eliminar lógica del cargo
    UPDATE seguridad.CARGO
    SET es_valido = 0
    WHERE id = @id_cargo;
    
END;
GO


-- Store Procedure para eliminación lógica en SUCURSAL
CREATE OR ALTER PROCEDURE borrado.EliminarSucursalLogico
    @id_sucursal INT
AS
BEGIN
    -- Verificar si la sucursal existe y está activa (es_valido = 1)
    IF NOT EXISTS (SELECT 1 FROM seguridad.SUCURSAL WHERE id = @id_sucursal AND es_valido = 1)
    BEGIN
        -- Lanzar un error si la sucursal no existe o no está activa
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    -- Verificar si hay empleados asociados a la sucursal
    IF EXISTS (SELECT 1 FROM seguridad.EMPLEADO WHERE id_sucursal = @id_sucursal AND es_valido = 1)
    BEGIN
        -- Lanzar un error si existen empleados en la sucursal
        RAISERROR(130002, 16, 1);
        RETURN;
    END

    -- Actualizar es_valido a 0 para realizar la eliminación lógica
    UPDATE seguridad.SUCURSAL
    SET es_valido = 0
    WHERE id = @id_sucursal;

END;
GO


-- Store Procedure para eliminación física en TELEFONO (modificado)
CREATE OR ALTER PROCEDURE borrado.EliminarTelefonoFisico
    @id_sucursal INT,
	@telefono CHAR (9)
AS
BEGIN
    -- Verificar si existe un teléfono asociado a la sucursal
    IF NOT EXISTS (SELECT 1 FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal AND telefono = @telefono )
    BEGIN
        -- Lanzar un error si no existe el teléfono
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    -- Realizar la eliminación física
    DELETE FROM seguridad.TELEFONO
    WHERE id_sucursal = @id_sucursal;

END;
GO


-- Store Procedure para eliminación lógica de EMPLEADO
CREATE OR ALTER PROCEDURE borrado.EliminarEmpleadoLogico
    @legajo INT
AS
BEGIN
    -- Verificar si el empleado está activo
    IF NOT EXISTS (SELECT 1 FROM seguridad.EMPLEADO WHERE legajo = @legajo AND es_valido = 1)
    BEGIN
        -- Lanzar un error si el empleado no está activo
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    -- Realizar la eliminación lógica (marcar es_valido = 0)
    UPDATE seguridad.EMPLEADO
    SET es_valido = 0
    WHERE legajo = @legajo;

END;
GO


-- Store Procedure para eliminación física en NOTA DE CRÉDITO

CREATE OR ALTER PROCEDURE borrado.EliminarNotaCreditoFisico
    @id INT
AS
BEGIN
    -- Verificar si la nota de crédito existe
    IF NOT EXISTS (SELECT 1 FROM transacciones.NOTA_CREDITO WHERE id = @id)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    DELETE FROM transacciones.NOTA_CREDITO
    WHERE id = @id;
END;
GO


-- Store Procedure para eliminación física en FACTURA
CREATE OR ALTER PROCEDURE borrado.EliminarFacturaFisico
    @id_factura CHAR(11)
AS
BEGIN
    -- Verificar si la factura existe
    IF NOT EXISTS (SELECT 1 FROM transacciones.FACTURA WHERE id = @id_factura)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    DELETE FROM transacciones.FACTURA
    WHERE id = @id_factura;
END;
GO


-- Store Procedure para eliminación física en MEDIO_DE_PAGO
CREATE OR ALTER PROCEDURE borrado.EliminarMedioDePagoLogico
    @id_medio INT
AS
BEGIN

    -- Verificar si el medio de pago existe
    IF NOT EXISTS (SELECT 1 FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio AND es_valido = 1)
    BEGIN
        RAISERROR(130001, 16, 1);;
        RETURN;
    END

    -- Realizar el borrado lógico estableciendo es_valido en 0
    UPDATE transacciones.MEDIO_DE_PAGO
    SET es_valido = 0
    WHERE id = @id_medio;
END;
GO



-- Store Procedure para eliminación física en VENTA
CREATE OR ALTER PROCEDURE borrado.EliminarVentaFisico
    @id_venta INT
AS
BEGIN
    -- Verificar si la venta existe
    IF NOT EXISTS (SELECT 1 FROM transacciones.VENTA WHERE id = @id_venta)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    DELETE FROM transacciones.VENTA
    WHERE id = @id_venta;
END;
GO


-- Store Procedure para eliminación física en IMPORTADO
CREATE OR ALTER PROCEDURE borrado.EliminarImportadoLogico
    @id_producto INT
AS
BEGIN
    -- Verificar si el producto existe y está activo
    IF NOT EXISTS (SELECT 1 FROM productos.IMPORTADO WHERE id_producto = @id_producto AND es_valido = 1)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    UPDATE productos.IMPORTADO
    SET es_valido = 0
    WHERE id_producto = @id_producto;
END;
GO


-- Store Procedure para eliminación física en VARIOS
CREATE OR ALTER PROCEDURE borrado.EliminarVariosLogico
    @id_producto INT
AS
BEGIN
    -- Verificar si el producto existe y está activo
    IF NOT EXISTS (SELECT 1 FROM productos.VARIOS WHERE id_producto = @id_producto AND es_valido = 1)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    UPDATE productos.VARIOS
    SET es_valido = 0
    WHERE id_producto = @id_producto;
END;
GO


-- Store Procedure para eliminación lógica en ELECTRONICO
CREATE OR ALTER PROCEDURE borrado.EliminarElectronicoLogico
    @id_producto INT
AS
BEGIN
    -- Verificar si el producto existe y está activo
    IF NOT EXISTS (SELECT 1 FROM productos.ELECTRONICO WHERE id_producto = @id_producto AND es_valido = 1)
    BEGIN
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    UPDATE productos.ELECTRONICO
    SET es_valido = 0
    WHERE id_producto = @id_producto;
END;
GO




CREATE OR ALTER PROCEDURE borrado.EliminarClienteFisico
    @id_cliente INT
AS
BEGIN
    -- Verificar si el cliente existe
    IF NOT EXISTS (SELECT 1 FROM seguridad.CLIENTE WHERE id = @id_cliente)
    BEGIN
        -- Lanzar un error si el cliente no existe
        RAISERROR(130001, 16, 1);
        RETURN;
    END

    -- Realizar la eliminación física
    DELETE FROM seguridad.CLIENTE
    WHERE id = @id_cliente;

END;
GO


-- Procedimiento para eliminar físicamente un registro de la tabla TIPO
CREATE OR ALTER PROCEDURE borrado.EliminarTipoFisico
    @id INT
AS
BEGIN
        -- Verificamos si el tipo existe
        IF NOT EXISTS (SELECT 1 FROM seguridad.TIPO WHERE id = @id)
        BEGIN
            RAISERROR(130001, 16, 1);  -- Error si no existe el tipo
			RETURN;
        END

        -- Si pasa la validación, eliminamos el tipo de manera física
        DELETE FROM seguridad.TIPO WHERE id = @id;


END;
GO

