/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 8											#
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

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarCargo 
AS
BEGIN
    -- Preparación del entorno de prueba
    SET NOCOUNT ON;
    DECLARE @id INT;
    DECLARE @nombre_original NVARCHAR(50), @nombre_actualizado NVARCHAR(50);

    -- Insertar dato de prueba
    INSERT INTO seguridad.CARGO (nombre) VALUES ('Administrativo');
    SET @id = SCOPE_IDENTITY();

    -- Almacenar el valor original
    SELECT @nombre_original = nombre FROM seguridad.CARGO WHERE id = @id;
    
    -- Mostrar el registro insertado
    SELECT * FROM seguridad.CARGO WHERE id = @id;

    -- Ejecutar el procedimiento de actualización
    EXEC actualizaciones.ActualizarCargo @id = @id, @nombre = 'Gerente';

    -- Almacenar el valor actualizado
    SELECT @nombre_actualizado = nombre FROM seguridad.CARGO WHERE id = @id;

    -- Verificar el resultado de la actualización
    IF  @nombre_actualizado = 'Gerente'
        PRINT 'TEST PASADO - Actualización de CARGO exitosa';
    ELSE
        PRINT 'TEST FALLIDO - Error en la actualización de CARGO';

    -- Mostrar el registro actualizado
    SELECT * FROM seguridad.CARGO WHERE id = @id;

    -- Eliminar el registro de prueba
    DELETE FROM seguridad.CARGO WHERE id = @id;
END;
GO

-- Ejecutar la prueba
EXEC actualizaciones.TestActualizarCargo;
GO


CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarEmpleado
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @legajo INT;
    DECLARE @id_empleado INT;
    DECLARE @id_cargo INT;
    DECLARE @id_sucursal INT;
    DECLARE @nombre_original NVARCHAR(50), @apellido_original NVARCHAR(50), @dni_original INT, 
            @direccion_original NVARCHAR(150), @email_empresa_original NVARCHAR(100), 
            @email_personal_original NVARCHAR(100), @CUIL_original CHAR(11),
            @id_cargo_original INT, @id_sucursal_original INT, @turno_original NVARCHAR(50), 
            @es_valido_original INT;


    -- Insertar dato de prueba en la tabla EMPLEADO
    INSERT INTO seguridad.CARGO (nombre) VALUES ('Cargo de prueba');
    SET @id_cargo = SCOPE_IDENTITY();

    -- Insertar sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    SET @id_sucursal = SCOPE_IDENTITY();

    -- Obtener el valor máximo de legajo y sumarle 1
    SELECT @legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

    INSERT INTO seguridad.EMPLEADO 
        (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
    VALUES 
        (@legajo, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'jperez@empresa.com', 'jperez@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Mañana', 1);
	
	SET @id_empleado = SCOPE_IDENTITY();

    -- Almacenar los valores originales
    SELECT @nombre_original = nombre, @apellido_original = apellido, @dni_original = dni,
           @direccion_original = direccion, @email_empresa_original = email_empresa,
           @email_personal_original = email_personal, @CUIL_original = CUIL,
           @id_cargo_original = id_cargo, @id_sucursal_original = id_sucursal,
           @turno_original = turno, @es_valido_original = es_valido
    FROM seguridad.EMPLEADO 
    WHERE legajo = @legajo;

    -- Ejecutar el procedimiento de actualización solo para el campo apellido
    EXEC actualizaciones.ActualizarEmpleado 
        @id_empleado = @id_empleado, @apellido = 'Gomez';

    -- Verificar si solo el campo apellido se ha actualizado
    IF (@nombre_original = (SELECT nombre FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       ('Gomez' = (SELECT apellido FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@dni_original = (SELECT dni FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@direccion_original = (SELECT direccion FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@email_empresa_original = (SELECT email_empresa FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@email_personal_original = (SELECT email_personal FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@CUIL_original = (SELECT CUIL FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@id_cargo_original = (SELECT id_cargo FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@id_sucursal_original = (SELECT id_sucursal FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@turno_original = (SELECT turno FROM seguridad.EMPLEADO WHERE legajo = @legajo)) AND
       (@es_valido_original = (SELECT es_valido FROM seguridad.EMPLEADO WHERE legajo = @legajo))
    BEGIN
        PRINT 'TEST PASADO - Actualización de empleado exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de empleado';
    END;

    -- Eliminar el registro de prueba
    DELETE FROM seguridad.EMPLEADO WHERE legajo = @legajo;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    DELETE FROM seguridad.CARGO WHERE id = @id_cargo;
END;
GO

EXEC actualizaciones.TestActualizarEmpleado;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarProducto
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id_producto INT,
            @id_categoria INT,
            @precio_nuevo DECIMAL(10,2) = 200,
            @nombre_producto_original NVARCHAR(100), 
            @precio_unidad_original DECIMAL(10, 2),
            @id_categoria_original INT, 
            @fecha_eliminacion_original DATE, 
            @es_valido_original INT;

    -- Insertar dato de prueba en la tabla CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);
    SET @id_categoria = SCOPE_IDENTITY();

    -- Insertar dato de prueba en la tabla PRODUCTO
    INSERT INTO productos.PRODUCTO (nombre_producto, precio_unidad, id_categoria, fecha_eliminacion, es_valido)
    VALUES ('Producto Original', 100, @id_categoria, NULL, 1);
    SELECT @id_producto = SCOPE_IDENTITY();

    -- Almacenar los valores originales
    SELECT @nombre_producto_original = nombre_producto, 
           @precio_unidad_original = precio_unidad, 
           @id_categoria_original = id_categoria, 
           @fecha_eliminacion_original = fecha_eliminacion,
           @es_valido_original = es_valido
    FROM productos.PRODUCTO 
    WHERE id_producto = @id_producto;

    -- Ejecutar el procedimiento de actualización
    EXEC actualizaciones.ActualizarProducto 
        @id_producto = @id_producto, 
        @precio_unidad = @precio_nuevo;

    -- Verificar el resultado
    IF (@precio_unidad_original != (SELECT precio_unidad FROM productos.PRODUCTO WHERE id_producto = @id_producto))
        PRINT 'TEST PASADO - Actualización exitosa';
    ELSE
        PRINT 'TEST FALLIDO - Error en la actualización';

    -- Eliminar el registro de prueba
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
END;
GO

-- Ejecutar la prueba
EXEC actualizaciones.TestActualizarProducto;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarMedioDePago
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT,
            @descripcion_original VARCHAR(50),
            @descripcion_ingles_original VARCHAR(50),
            @descripcion_nueva VARCHAR(50) = 'Descripción Nueva',
            @descripcion_ingles_nueva VARCHAR(50) = 'New Description';

    -- Insertar dato de prueba en la tabla MEDIO_DE_PAGO
    INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion, descripcion_ingles)
    VALUES ('Descripción Original', 'Original Description');
    SELECT @id = SCOPE_IDENTITY();

    -- Almacenar los valores originales
    SELECT @descripcion_original = descripcion, 
           @descripcion_ingles_original = descripcion_ingles
    FROM transacciones.MEDIO_DE_PAGO 
    WHERE id = @id;

    -- Ejecutar el procedimiento de actualización
    EXEC actualizaciones.ActualizarMedioDePago 
        @id = @id, 
        @descripcion = @descripcion_nueva, 
        @descripcion_ingles = @descripcion_ingles_nueva;

    -- Verificar la actualización
    IF (@descripcion_nueva = (SELECT descripcion FROM transacciones.MEDIO_DE_PAGO WHERE id = @id)) 
       AND (@descripcion_ingles_nueva = (SELECT descripcion_ingles FROM transacciones.MEDIO_DE_PAGO WHERE id = @id))
    BEGIN
        PRINT 'TEST PASADO - Actualización de MEDIO DE PAGO exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de MEDIO DE PAGO';
    END;

    -- Eliminar el registro de prueba
    DELETE FROM transacciones.MEDIO_DE_PAGO WHERE id = @id;
END;
GO

-- Ejecutar la prueba
EXEC actualizaciones.TestActualizarMedioDePago;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarCategoria
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT,
            @descripcion_original VARCHAR(50),
            @descripcion_nueva VARCHAR(50) = 'Nueva Descripción';

    -- Inserto dato de prueba en la tabla CATEGORIA
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Descripción Original', 1);

    -- Obtener el ID de la categoría insertada
    SELECT @id = SCOPE_IDENTITY();

    -- Almacenar los valores originales
    SELECT @descripcion_original = descripcion
    FROM seguridad.CATEGORIA
    WHERE id = @id;

    -- Mostrar la categoría original
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id;

    -- Ejecutar el procedimiento de actualización (modificar solo la descripción)
    EXEC actualizaciones.ActualizarCategoria 
        @id = @id, 
        @descripcion = @descripcion_nueva,  -- Actualizamos solo 'descripcion'
        @es_valido = NULL;                  -- No modificamos 'es_valido'

    -- Verificar si la descripción se ha actualizado
    IF (@descripcion_original != (SELECT descripcion FROM seguridad.CATEGORIA WHERE id = @id))
    BEGIN
        PRINT 'TEST PASADO - Descripción actualizada correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de la descripción.';
    END;

    -- Mostrar el registro actualizado
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id;

END;
GO

-- Ejecutar la prueba
EXEC actualizaciones.TestActualizarCategoria;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarTelefono
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_sucursal INT,
            @telefono_original CHAR(9),
            @telefono_nuevo CHAR(9) = '5555-5555';

    -- Insertar dato de prueba en la tabla SUCURSAL
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    SET @id_sucursal = SCOPE_IDENTITY();

    -- Insertar dato de prueba en la tabla TELEFONO
    INSERT INTO seguridad.TELEFONO (id_sucursal, telefono)
    VALUES (@id_sucursal, '0000-0000');

    -- Almacenar el valor original del teléfono
    SELECT @telefono_original = telefono 
    FROM seguridad.TELEFONO 
    WHERE id_sucursal = @id_sucursal;

    SELECT *
    FROM seguridad.TELEFONO 
    WHERE id_sucursal = @id_sucursal AND telefono = @telefono_original;

    -- Ejecutar el procedimiento de actualización
    EXEC actualizaciones.ActualizarTelefono 
        @id_sucursal = @id_sucursal, 
        @telefono = @telefono_nuevo;

    SELECT *
    FROM seguridad.TELEFONO 
    WHERE id_sucursal = @id_sucursal;

    -- Verificar si el teléfono ha sido actualizado
    DECLARE @telefono_actualizado CHAR(9);

    SELECT @telefono_actualizado = telefono
    FROM seguridad.TELEFONO 
    WHERE  id_sucursal = @id_sucursal AND  id_sucursal = @id_sucursal;

    IF (@telefono_actualizado = @telefono_nuevo)
    BEGIN
        PRINT 'TEST PASADO - Actualización de TELEFONO exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de TELEFONO';
    END;

    -- Eliminar los registros de prueba
    DELETE FROM seguridad.TELEFONO WHERE id_sucursal = @id_sucursal;
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
END;
GO

-- Ejecutar la prueba
EXEC actualizaciones.TestActualizarTelefono;
