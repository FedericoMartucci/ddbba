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

SET NOCOUNT ON;
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
        PRINT 'TEST PASADO - Actualización de EMPLEADO exitosa';
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
        PRINT 'TEST PASADO - Actualización de PRODUCTO exitosa';
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
        PRINT 'TEST PASADO - Actualicación de CATEGORÍA exitosa.';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de la descripción.';
    END;

    -- Mostrar el registro actualizado
    SELECT * FROM seguridad.CATEGORIA WHERE id = @id;
	DELETE FROM seguridad.CATEGORIA WHERE id = @id;

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
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarFactura
AS
BEGIN
    -- Declarar variables para almacenar el resultado de la prueba
    DECLARE @resultadoEstado BIT,
			@id_factura INT,
			@id_prueba CHAR(11) = '999-99-9999',
			@id_insertado CHAR(11);
    

    
	BEGIN TRY
		-- Insertar un registro de prueba en la tabla FACTURA
		INSERT INTO transacciones.FACTURA (id, tipo_de_factura, estado)
		VALUES (@id_prueba, 'A', 0); 
		SET @id_factura = SCOPE_IDENTITY();

	END TRY

	BEGIN CATCH
		PRINT 'Error en la inserción de factura';
	END CATCH


	BEGIN TRY

		SELECT * from transacciones.FACTURA WHERE @id_factura = @id_factura;

        -- Ejecutar el procedimiento almacenado para actualizar el estado
        EXEC actualizaciones.ActualizarFactura
            @id_factura = @id_factura,
            @estado = 1; -- Cambiar el estado a 1 (activo)
		
		SELECT * from transacciones.FACTURA WHERE @id_factura = @id_factura;

        -- Verificar que la actualización se haya realizado correctamente
        SELECT @resultadoEstado = estado, @id_insertado = id
        FROM transacciones.FACTURA
        WHERE @id_factura = @id_factura;



        -- Comprobar el resultado y devolver un mensaje
        IF @id_insertado = @id_prueba AND @resultadoEstado = 1 
            PRINT 'TEST PASADO - Actualizacion de FACTURA exitosa.';
        ELSE
            PRINT 'TEST FALLIDO - El estado no fue actualizado correctamente.';
 
		DELETE FROM transacciones.FACTURA WHERE id_factura = @id_factura;
        

    END TRY

    BEGIN CATCH
        -- En caso de error, revertir la transacción y mostrar un mensaje de error
        PRINT 'Error durante la prueba: ' + ERROR_MESSAGE();
    END CATCH



END;
GO

EXEC actualizaciones.TestActualizarFactura;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarNotaCredito
AS
BEGIN

    -- Declarar variables para almacenar el resultado de la prueba
    DECLARE @resultadoEstado BIT,
			@id_factura INT,
			@id_factura_actualizado INT,
			@id_prueba CHAR(11) = '999-99-9999',
			@id_nota_credito INT,
			@monto DECIMAL = 100,
			@monto_nuevo DECIMAL = 500,
			@monto_actualizado DECIMAL;

	 BEGIN TRY

		-- Insertar un registro de prueba en la tabla FACTURA
		INSERT INTO transacciones.FACTURA (id, tipo_de_factura, estado)
		VALUES (@id_prueba, 'A', 0); 
		SET @id_factura = SCOPE_IDENTITY();

		INSERT INTO transacciones.NOTA_CREDITO (monto, id_factura)
		VALUES (@monto, @id_factura);
		SET @id_nota_credito = SCOPE_IDENTITY();


		SELECT * FROM transacciones.NOTA_CREDITO WHERE @id_nota_credito =  @id_nota_credito;
		
		EXEC actualizaciones.actualizarNotaCredito 
		@id = @id_nota_credito, 
		@monto = @monto_nuevo;

		SELECT * FROM transacciones.NOTA_CREDITO WHERE @id_nota_credito =  @id_nota_credito;
		
		SELECT @monto_actualizado = monto, @id_factura_actualizado = id_factura FROM transacciones.NOTA_CREDITO

		IF (@monto_actualizado = @monto_nuevo AND @id_factura_actualizado = @id_factura)			PRINT 'TEST PASADO - Actualizacion de NOTA DE CREDITO exitosa'
		ELSE 
			PRINT 'TEST FALLIDO - Error en la actualización de nota de crédito';
		

	END TRY

	BEGIN CATCH
		PRINT 'ERROR EN EL TEST - Error inesperado en la insercion de los datos o ejecución del procedure';
	END CATCH

	DELETE FROM transacciones.NOTA_CREDITO WHERE id = @id_nota_credito;
	DELETE FROM transacciones.FACTURA WHERE @id_factura = @id_factura;

END;
GO

EXEC actualizaciones.TestActualizarNotaCredito;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarTipo
AS
BEGIN
    -- Declarar variables para el ID del registro de prueba y el resultado esperado
    DECLARE @idPrueba INT;
    DECLARE @nombrePruebaOriginal VARCHAR(50) = 'NombrePrueba';
    DECLARE @nombreActualizado VARCHAR(50) = 'NombreActualizado';
    DECLARE @nombreResultado VARCHAR(50);

    BEGIN TRY
        INSERT INTO seguridad.TIPO (nombre)
        VALUES (@nombrePruebaOriginal);

        -- Obtener el ID del registro insertado
        SET @idPrueba = SCOPE_IDENTITY();

		SELECT * FROM seguridad.TIPO WHERE id = @idPrueba;

        EXEC actualizaciones.ActualizarTipo
            @id = @idPrueba,
            @nombre = @nombreActualizado;

		SELECT * FROM seguridad.TIPO WHERE id = @idPrueba;

        SELECT @nombreResultado = nombre
        FROM seguridad.TIPO
        WHERE id = @idPrueba;

		
        -- Comparar el resultado con el valor esperado y devolver un mensaje
        IF @nombreResultado = @nombreActualizado
        BEGIN
            PRINT 'TEST PASADO - Actualizacion de TIPO de cliente exitosa.';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - El tipo de cliente no fue actualizado correctamente.';
        END

        -- Eliminar el registro de prueba
        DELETE FROM seguridad.TIPO WHERE id = @idPrueba;
        
    END TRY

    BEGIN CATCH
        -- Mostrar un mensaje de error en caso de falla
        PRINT 'Error durante la prueba: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC actualizaciones.TestActualizarTipo;
GO


CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarCliente
AS
BEGIN
    DECLARE @id_tipo INT;
    DECLARE @id_cliente INT;
    DECLARE @nuevo_genero VARCHAR(6) = 'male';
    DECLARE @genero_actual VARCHAR(6);
    DECLARE @id_tipo_actual INT;

    BEGIN TRY
        -- Insertar un registro de prueba en TIPO y capturar el ID
        INSERT INTO seguridad.TIPO (nombre) VALUES ('Tipo de prueba');
        SET @id_tipo = SCOPE_IDENTITY();

        -- Insertar un registro de prueba en CLIENTE y capturar el ID
        INSERT INTO seguridad.CLIENTE (genero, id_tipo) VALUES ('female', @id_tipo);
        SET @id_cliente = SCOPE_IDENTITY();

		SELECT * FROM seguridad.CLIENTE WHERE id = @id_cliente;

        -- Ejecutar el procedimiento de actualización para cambiar el género a 'male'
        EXEC actualizaciones.ActualizarCliente @id = @id_cliente, @genero = @nuevo_genero;

        -- Verificar que el género se haya actualizado correctamente y que id_tipo se mantenga igual
        SELECT @genero_actual = genero, @id_tipo_actual = id_tipo 
        FROM seguridad.CLIENTE 
        WHERE id = @id_cliente;

		SELECT * FROM seguridad.CLIENTE WHERE id = @id_cliente;

        IF @genero_actual = @nuevo_genero AND @id_tipo_actual = @id_tipo
        BEGIN
            PRINT 'TEST PASADO - Actualizacion de CLIENTE exitosa.';
        END
        ELSE
        BEGIN
            PRINT 'TEST FALLIDO - Error en la actualizacion de cliente.';
        END

    END TRY
    BEGIN CATCH
        PRINT 'TEST PROBLEM - Error inesperado durante la insercion de datos o ejecucion del procedure.';
    END CATCH

    -- Limpiar los datos de prueba
    DELETE FROM seguridad.CLIENTE WHERE id = @id_cliente;
    DELETE FROM seguridad.TIPO WHERE id = @id_tipo;

END;
GO

EXEC actualizaciones.TestActualizarCliente;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarSucursal
AS
BEGIN

    DECLARE @id_sucursal INT;
    DECLARE @ciudad_nueva VARCHAR(50) = 'Ciudad Actualizada';

    -- Insertar sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad Vieja', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    SET @id_sucursal = SCOPE_IDENTITY();

	SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;

    -- Ejecutar el procedimiento para actualizar solo el campo provincia
    EXEC actualizaciones.ActualizarSucursal 
        @id = @id_sucursal, 
        @ciudad = @ciudad_nueva;

	SELECT * FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
	

    -- Verificar si la actualización fue exitosa en el campo 'provincia' y los demás campos no fueron modificados
    IF EXISTS (
        SELECT 1 FROM seguridad.SUCURSAL 
        WHERE id = @id_sucursal
        AND provincia = 'Provincia de prueba'
        AND horario = '9:00-18:00'
        AND ciudad = @ciudad_nueva
        AND reemplazar_por = 'Reemplazo prueba'
        AND direccion = 'Calle Falsa 123'
        AND codigo_postal = '12345'
    )
    BEGIN
        PRINT 'TEST PASADO - Actualización de SUCURSAL exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de sucursal';
    END

    -- Eliminar la sucursal de prueba
    DELETE FROM seguridad.SUCURSAL WHERE id = @id_sucursal;
    
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC actualizaciones.TestActualizarSucursal;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarVarios
AS
BEGIN

    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;
    DECLARE @unidad_nueva VARCHAR(50) = 'Unidad Modificada';

    -- Insertar categoría de prueba
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);
    SET @id_categoria = SCOPE_IDENTITY();

    -- Insertar producto de prueba asociado a la categoría
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);
    SET @id_producto = SCOPE_IDENTITY();

    -- Insertar registro de prueba en VARIOS asociado al producto
    INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia, es_valido)
    VALUES (@id_producto, GETDATE(), CONVERT(TIME, GETDATE()), 'Unidad de prueba', 1);

	-- Muestro el registro insertado antes de la actualización
	SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;

    -- Almacenar los valores iniciales para verificar que no cambien
    DECLARE @fecha_original DATE;
    DECLARE @hora_original TIME(0);
    SET @fecha_original = (SELECT fecha FROM productos.VARIOS WHERE id_producto = @id_producto);
    SET @hora_original = (SELECT hora FROM productos.VARIOS WHERE id_producto = @id_producto);


    -- Ejecutar el procedimiento para actualizar solo el campo unidad_de_referencia
    EXEC actualizaciones.ActualizarVarios 
        @id_producto = @id_producto, 
        @unidad_de_referencia = @unidad_nueva;

	-- Muestro el registro actualizado
	SELECT * FROM productos.VARIOS WHERE id_producto = @id_producto;
    
	-- Verificar si la actualización fue exitosa y los demás campos no fueron modificados
    IF EXISTS (
        SELECT 1 FROM productos.VARIOS 
        WHERE id_producto = @id_producto
        AND unidad_de_referencia = @unidad_nueva
        AND fecha = @fecha_original
        AND hora = @hora_original
    )
    BEGIN
        PRINT 'TEST PASADO - Actualización de VARIOS exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de VARIOS';
    END

    -- Eliminar los datos de prueba de las tablas
    DELETE FROM productos.VARIOS WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC actualizaciones.TestActualizarVarios;
GO


CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarImportado
AS
BEGIN

    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;
    DECLARE @nuevo_proveedor VARCHAR(255) = 'Proveedor Modificado';
    DECLARE @nueva_cantidad_por_unidad VARCHAR(255) = '20';

    -- Insertar categoría de prueba
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);
    SET @id_categoria = SCOPE_IDENTITY();

    -- Insertar producto de prueba asociado a la categoría
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);
    SET @id_producto = SCOPE_IDENTITY();

    -- Insertar registro de prueba en IMPORTADO asociado al producto
    INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad, es_valido)
    VALUES (@id_producto, 'Proveedor Viejo', '10', 1);

    -- Mostrar el registro antes de la actualización
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Almacenar los valores iniciales para verificar que no cambien
    DECLARE @proveedor_original VARCHAR(255);
    DECLARE @cantidad_original VARCHAR(255);
    SET @proveedor_original = (SELECT proveedor FROM productos.IMPORTADO WHERE id_producto = @id_producto);
    SET @cantidad_original = (SELECT cantidad_por_unidad FROM productos.IMPORTADO WHERE id_producto = @id_producto);

    -- Ejecutar el procedimiento para actualizar los campos proveedor y cantidad_por_unidad
    EXEC actualizaciones.ActualizarImportado 
        @id_producto = @id_producto, 
        @proveedor = @nuevo_proveedor, 
        @cantidad_por_unidad = @nueva_cantidad_por_unidad;

    -- Mostrar el registro después de la actualización
    SELECT * FROM productos.IMPORTADO WHERE id_producto = @id_producto;

    -- Verificar si la actualización fue exitosa y los demás campos no fueron modificados
    IF EXISTS (
        SELECT 1 FROM productos.IMPORTADO 
        WHERE id_producto = @id_producto
        AND proveedor = @nuevo_proveedor
        AND cantidad_por_unidad = @nueva_cantidad_por_unidad
    )
    BEGIN
        PRINT 'TEST PASADO - Actualización de IMPORTADO exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de IMPORTADO';
    END

    -- Eliminar los datos de prueba de las tablas
    DELETE FROM productos.IMPORTADO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC actualizaciones.TestActualizarImportado;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarElectronico
AS
BEGIN

    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;
    DECLARE @nuevo_precio_unidad_en_dolares DECIMAL(10, 2) = 30.00;

    -- Insertar categoría de prueba
    INSERT INTO seguridad.CATEGORIA (descripcion, es_valido)
    VALUES ('Categoria de prueba', 1);
    SET @id_categoria = SCOPE_IDENTITY();

    -- Insertar producto de prueba asociado a la categoría
    INSERT INTO productos.PRODUCTO (precio_unidad, nombre_producto, id_categoria, es_valido)
    VALUES (100, 'Nombre prueba', @id_categoria, 1);
    SET @id_producto = SCOPE_IDENTITY();

    -- Insertar registro de prueba en ELECTRONICO asociado al producto
    INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares, es_valido)
    VALUES (@id_producto, 20.00, 1);

    -- Mostrar el registro antes de la actualización
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- Ejecutar el procedimiento para actualizar el campo precio_unidad_en_dolares
    EXEC actualizaciones.ActualizarElectronico 
        @id_producto = @id_producto, 
        @precio_unidad_en_dolares = @nuevo_precio_unidad_en_dolares;

    -- Mostrar el registro después de la actualización
    SELECT * FROM productos.ELECTRONICO WHERE id_producto = @id_producto;

    -- Verificar si la actualización fue exitosa y los demás campos no fueron modificados
    IF EXISTS (
        SELECT 1 FROM productos.ELECTRONICO 
        WHERE id_producto = @id_producto
        AND precio_unidad_en_dolares = @nuevo_precio_unidad_en_dolares
    )
    BEGIN
        PRINT 'TEST PASADO - Actualización de ELECTRONICO exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de ELECTRONICO';
    END

    -- Eliminar los datos de prueba de las tablas
    DELETE FROM productos.ELECTRONICO WHERE id_producto = @id_producto;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    
END;
GO

-- Ejecutar el procedimiento de prueba
EXEC actualizaciones.TestActualizarElectronico;
GO

CREATE OR ALTER PROCEDURE actualizaciones.TestActualizarVenta
AS
BEGIN

    DECLARE @id_cliente INT;
    DECLARE @id_cargo INT;
    DECLARE @id_categoria INT;
    DECLARE @id_producto INT;
    DECLARE @id_medio_pago INT;
    DECLARE @id_sucursal INT;
    DECLARE @id_factura CHAR(11);
    DECLARE @legajo INT;
    DECLARE @id_empleado INT;
    DECLARE @id_venta INT;
    DECLARE @nuevo_cantidad SMALLINT = 500;

    -- Insertar un cliente de prueba
    INSERT INTO seguridad.CLIENTE (genero) VALUES ('Female');
    SET @id_cliente = SCOPE_IDENTITY();

    -- Insertar una categoría de prueba
    INSERT INTO seguridad.CATEGORIA (descripcion) VALUES ('Categoria de prueba');
    SET @id_categoria = SCOPE_IDENTITY();

    -- Insertar un producto de prueba asociado a la categoría
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

    -- Insertar dato de prueba
    INSERT INTO seguridad.CARGO (nombre) VALUES ('Administrativo');
    SET @id_cargo = SCOPE_IDENTITY();

    -- Obtener el máximo legajo y sumarle 1 para el nuevo empleado
    SELECT @legajo = ISNULL(MAX(legajo), 0) + 1 FROM seguridad.EMPLEADO;

    -- Insertar un empleado de prueba
    INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno, es_valido)
    VALUES (@legajo, 'Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan@empresa.com', 'juan@gmail.com', '20123456789', @id_cargo, @id_sucursal, 'Mañana', 1);
    SET @id_empleado = SCOPE_IDENTITY();

    -- Insertar sucursal de prueba
    INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    VALUES ('9:00-18:00', 'Ciudad de Prueba', 'Reemplazo prueba', 'Calle Falsa 123', '12345', 'Provincia de Prueba');
    SET @id_sucursal = SCOPE_IDENTITY();

    -- Insertar una venta de prueba
    INSERT INTO transacciones.VENTA (id_factura, id_sucursal, id_producto, cantidad, fecha, hora, id_medio_de_pago, id_empleado, identificador_de_pago)
    VALUES (@id_factura, @id_sucursal, @id_producto,  5, '2024-11-13', '14:35:00', @id_medio_pago, @id_empleado, '1111222233334444555566');
    SET @id_venta = SCOPE_IDENTITY();

    -- Mostrar el registro de VENTA antes de la actualización
    SELECT * FROM transacciones.VENTA WHERE id = @id_venta;

    -- Ejecutar el procedimiento para actualizar el campo cantidad
    EXEC actualizaciones.ActualizarVenta 
        @id = @id_venta, 
        @cantidad = @nuevo_cantidad;

    -- Mostrar el registro de VENTA después de la actualización
    SELECT * FROM transacciones.VENTA WHERE id = @id_venta;

    -- Verificar si la actualización fue exitosa y los demás campos no fueron modificados
    IF EXISTS (
        SELECT 1 FROM transacciones.VENTA 
        WHERE id = @id_venta
        AND cantidad = @nuevo_cantidad
    )
    BEGIN
        PRINT 'TEST PASADO - Actualización de VENTA exitosa';
    END
    ELSE
    BEGIN
        PRINT 'TEST FALLIDO - Error en la actualización de VENTA';
    END

    -- Eliminar los datos de prueba de las tablas
    DELETE FROM transacciones.VENTA WHERE id = @id_venta;
    DELETE FROM seguridad.EMPLEADO WHERE legajo = @legajo;
    DELETE FROM transacciones.FACTURA WHERE id = @id_factura;
    DELETE FROM transacciones.MEDIO_DE_PAGO WHERE id = @id_medio_pago;
    DELETE FROM productos.PRODUCTO WHERE id_producto = @id_producto;
    DELETE FROM seguridad.CATEGORIA WHERE id = @id_categoria;
    DELETE FROM seguridad.CLIENTE WHERE id = @id_cliente;

END;
GO

-- Ejecutar el procedimiento de prueba
EXEC actualizaciones.TestActualizarVenta;
GO




