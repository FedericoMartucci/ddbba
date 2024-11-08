--CREAMOS LOS PROCEDURE NECESARIOS PARA LEVANTAR LOS ARCHIVOS QUE RECIBIMOS
USE Com5600G08
GO

--CONFIGURACIONES PARA LA IMPORTACION
-- Habilita la visualizaci�n de opciones avanzadas en la configuraci�n del motor
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
--Habilitamos el 'Ole Automation Procedures' para permitir al motor ejecutar comandos de automatizaci�n de objetos
EXEC sp_configure 'Ole Automation Procedures', 1;    
RECONFIGURE;
-- Volvemos a ocultar las opciones avanzadas para evitar cambios accidentales en configuraciones avanzadas
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO

--CREAMOS SCHEMA PARA INSERCIONES
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'inserciones')
    EXEC('CREATE SCHEMA inserciones');
GO
/*
				==============================================================
				=			Procedure para insertar las sucursales			 =
				==============================================================
*/

CREATE OR ALTER PROCEDURE inserciones.InsertarSucursales(@path VARCHAR(255))	--InformacionComplementaria
AS
BEGIN
    CREATE TABLE #TEMP_SUCURSAL (
        ciudad VARCHAR(20),
        reemplazar_por VARCHAR(30),
        direccion VARCHAR(100),
        horario VARCHAR(100),
        telefono CHAR(9) CHECK (telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
    );

	 -- Armar el comando din�mico para OPENROWSET con el path
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'INSERT INTO #TEMP_SUCURSAL (ciudad, reemplazar_por, direccion, horario, telefono)
                 SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
                 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [sucursal$]'');';

    -- Ejecutar el comando din�mico
    EXEC sp_executesql @sql;

	IF NOT EXISTS ( SELECT TOP 1 1 FROM #TEMP_SUCURSAL 
	WHERE 
	ciudad IS NOT NULL OR
	reemplazar_por IS NOT NULL OR
	direccion IS NOT NULL OR
	horario IS NOT NULL OR
	telefono IS NOT NULL
	)
    BEGIN
        EXEC SP_SQLEXEC 'DROP TABLE #TEMP_SUCURSAL;'
		RETURN;
    END

	INSERT INTO seguridad.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
	SELECT DISTINCT
    horario,
    ciudad,
    reemplazar_por,
    LTRIM(RTRIM(REPLACE(LEFT(direccion, CHARINDEX(',', direccion) - 1), '�', ''))) AS direccion,
    SUBSTRING(direccion, CHARINDEX(', B', direccion) + 2, 5) AS codigo_postal,
    SUBSTRING(direccion, CHARINDEX('Provincia', direccion) + 13, LEN(direccion)) AS provincia
	FROM #TEMP_SUCURSAL AS temp
	WHERE NOT EXISTS (
    SELECT 1
    FROM seguridad.SUCURSAL AS aurora
    WHERE aurora.horario = temp.horario
      AND aurora.ciudad = temp.ciudad
      AND aurora.reemplazar_por = temp.reemplazar_por
      AND aurora.direccion = LTRIM(RTRIM(REPLACE(LEFT(temp.direccion, CHARINDEX(',', temp.direccion) - 1), '�', '')))
      AND aurora.codigo_postal = SUBSTRING(temp.direccion, CHARINDEX(', B', temp.direccion) + 2, 5)
      AND aurora.provincia = SUBSTRING(temp.direccion, CHARINDEX('Provincia', temp.direccion) + 13, LEN(temp.direccion))
	);

    INSERT INTO seguridad.TELEFONO (id_sucursal, telefono)
	SELECT DISTINCT s.id, t.telefono
	FROM seguridad.SUCURSAL s
	JOIN #TEMP_SUCURSAL t ON s.reemplazar_por = t.reemplazar_por
	WHERE NOT EXISTS (
    SELECT 1
    FROM seguridad.TELEFONO tel
    WHERE tel.id_sucursal = s.id
      AND tel.telefono = t.telefono
	);

    DROP TABLE #TEMP_SUCURSAL;
END;
GO

/*
				==============================================================
				=			Procedure para insertar los empleados			 =
				==============================================================
*/

CREATE OR ALTER PROCEDURE inserciones.InsertarEmpleados(@path VARCHAR(255))	--InformacionComplementaria
AS
BEGIN
    CREATE TABLE #TEMP_EMPLEADO (
        legajo INT,
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        dni INT,
        direccion VARCHAR(150),
        email_empresa VARCHAR(100),
        email_personal VARCHAR(100),
        CUIL VARCHAR(11),
        cargo VARCHAR(50),
        sucursal VARCHAR(50),
        turno VARCHAR(50)
    );

	-- Armar el comando din�mico para OPENROWSET con el path
	DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'INSERT INTO #TEMP_EMPLEADO (legajo, nombre, apellido, dni, direccion, email_personal, email_empresa, CUIL, cargo, sucursal, turno)
                 SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
                 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [Empleados$]'')
				 WHERE [Legajo/ID] IS NOT NULL;';

    -- Ejecutar el comando din�mico
    EXEC sp_executesql @sql;

	IF NOT EXISTS ( SELECT TOP 1 1 FROM #TEMP_EMPLEADO 
	WHERE 
	legajo IS NOT NULL OR
	nombre IS NOT NULL OR
	apellido IS NOT NULL OR
	dni IS NOT NULL OR
	direccion IS NOT NULL OR 
	email_empresa IS NOT NULL OR
	email_personal IS NOT NULL OR
	cargo IS NOT NULL OR
	sucursal IS NOT NULL OR
	turno IS NOT NULL
	)
    BEGIN
        EXEC SP_SQLEXEC 'DROP TABLE #TEMP_EMPLEADO;'
		RETURN;
    END

    --Validamos no cargar datos duplicados
	INSERT INTO seguridad.CARGO (nombre)
	SELECT DISTINCT cargo
	FROM #TEMP_EMPLEADO
	WHERE cargo IS NOT NULL
	AND NOT EXISTS (
      SELECT 1
      FROM seguridad.CARGO c
      WHERE c.nombre = cargo
	);
    
	INSERT INTO seguridad.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno)
	SELECT DISTINCT
		e.legajo,
		e.nombre,
		e.apellido,
		e.dni,
		e.direccion,
		e.email_empresa,
		e.email_personal,
		e.CUIL,
		c.id AS id_cargo,
		s.id AS id_sucursal,
		e.turno
	FROM 
		#TEMP_EMPLEADO e
		LEFT JOIN seguridad.CARGO c ON e.cargo = c.nombre
		LEFT JOIN seguridad.SUCURSAL s ON e.sucursal = s.reemplazar_por
	WHERE NOT EXISTS (
    SELECT 1 
    FROM seguridad.EMPLEADO emp
    WHERE emp.legajo = e.legajo
	);

    DROP TABLE #TEMP_EMPLEADO;
END;
GO

/*
				==============================================================
				=			Procedure para insertar los medios de pago		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE inserciones.InsertarMediosDePago(@path VARCHAR(255))	--InformacionComplementaria
AS
BEGIN
	CREATE TABLE #TEMP_MEDIO_PAGO (
		descripcion_ingles VARCHAR(50),
		descripcion VARCHAR(50)
	);
	-- Armar el comando din�mico para OPENROWSET con el path
    DECLARE @sql NVARCHAR(MAX);
	
    SET @sql = N'INSERT INTO #TEMP_MEDIO_PAGO (descripcion_ingles, descripcion)
				 SELECT [F2], [F3]
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
				 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [medios de pago$]'');';

	-- Ejecutar el comando din�mico
    EXEC sp_executesql @sql;

	--Validamos que no se carguen duplicados

	INSERT INTO transacciones.MEDIO_DE_PAGO (descripcion_ingles, descripcion)
	SELECT DISTINCT
		t.descripcion_ingles,
		t.descripcion
	FROM #TEMP_MEDIO_PAGO t
	WHERE NOT EXISTS (
    SELECT 1
    FROM transacciones.MEDIO_DE_PAGO mp
    WHERE mp.descripcion_ingles = t.descripcion_ingles
      AND mp.descripcion = t.descripcion
	);
    
	DROP TABLE #TEMP_MEDIO_PAGO;
END;
GO

/*
				==============================================================
				=			Procedure para obtener el valor del dolar		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE ObtenerValorDolarCCL @retorno decimal(10,2) output
AS
BEGIN
    --Armamos el URL del llamado tal como hallamos en la doc de la API
    DECLARE @url NVARCHAR(256) = 'https://dolarapi.com/v1/dolares/contadoconliqui'
    DECLARE @Object INT
    DECLARE @json TABLE(respuesta NVARCHAR(MAX))    --Usamos una tabla variable
    DECLARE @respuesta NVARCHAR(MAX)

    EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT    --Creamos una instancia del objeto OLE, que nos permite hacer los llamados.
    EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE' --Definimos algunas propiedades del objeto para hacer una llamada HTTP Get.
    EXEC sp_OAMethod @Object, 'SEND' 
    EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --Se�alamos donde vamos a guardar la respuesta.

    -- Observe que si el SP devuelve una tabla lo podemos almacenar con INSERT
    INSERT @json 
        EXEC sp_OAGetProperty @Object, 'RESPONSETEXT' --Obtenemos el valor de la propiedad 'RESPONSETEXT' del objeto OLE luego de realizar la consulta.

    --SELECT respuesta FROM @json
    --SELECT TOP 1 CAST(JSON_VALUE(respuesta, '$.venta') AS DECIMAL(10, 2)) FROM @json
    SET @retorno = (SELECT TOP 1 CAST(JSON_VALUE(respuesta, '$.venta') AS DECIMAL(10, 2)) FROM @json)
END
GO

/*
				==============================================================
				=		Procedure para insertar productos electr�nicos		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE inserciones.InsertarProductosElectronicos(@path VARCHAR(255))
AS
BEGIN
    DECLARE @ret decimal(10,2);
    DECLARE @id_categoria INT;
	
	-- Verificar si existe la categor�a 'Accesorios Electronicos' y obtener su id
    SET @id_categoria = (SELECT id FROM seguridad.CATEGORIA WHERE descripcion = 'Accesorios Electronicos');

	-- Si la categor�a no existe, crear una nueva
    IF @id_categoria IS NULL
    BEGIN
        INSERT INTO seguridad.CATEGORIA (descripcion)
        VALUES ('Accesorios Electronicos');

		-- Obtener el id de la nueva categor�a
        SET @id_categoria = SCOPE_IDENTITY();
    END;

	-- Obtiene el valor del d�lar en pesos
    EXEC ObtenerValorDolarCCL @ret OUTPUT;

	-- Crear una tabla temporal para almacenar los datos del archivo de Excel
    CREATE TABLE #TEMP_ELECTRONICOS (
        nombre_producto VARCHAR(255),
        precio_unidad_en_dolares DECIMAL(10, 2)
    );

	-- Armar el comando din�mico para OPENROWSET con el path
    DECLARE @sql NVARCHAR(MAX);

	-- Cargar datos desde el archivo de Excel en la tabla temporal
    SET @sql = N'INSERT INTO #TEMP_ELECTRONICOS (nombre_producto, precio_unidad_en_dolares)
				 SELECT [Product], [Precio Unitario en dolares]
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
				 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [Sheet1$]'');';
	
    -- Ejecutar el comando din�mico
    EXEC sp_executesql @sql;
	
	-- Insertar en la tabla PRODUCTO utilizando los datos de #TEMP_ELECTRONICOS
    -- Ac�� convertimos el precio en d�lares a pesos
	--Validamos no cargar duplicados
	INSERT INTO productos.PRODUCTO (nombre_producto, precio_unidad, id_categoria)
	SELECT DISTINCT 
		nombre_producto, 
		precio_unidad_en_dolares * @ret AS precio_unidad, 
		@id_categoria AS id_categoria
	FROM #TEMP_ELECTRONICOS
	WHERE NOT EXISTS (
		SELECT 1
		FROM productos.PRODUCTO p
		WHERE p.nombre_producto = nombre_producto
		AND p.precio_unidad = precio_unidad_en_dolares * @ret
		AND p.id_categoria = @id_categoria
	);

	-- Insertar en la tabla ELECTRONICO utilizando los IDs reci�n generados en PRODUCTO
	--Validamos que no insertemos duplicados
	INSERT INTO productos.ELECTRONICO (id_producto, precio_unidad_en_dolares)
	SELECT DISTINCT 
		p.id_producto, 
		t.precio_unidad_en_dolares
	FROM productos.PRODUCTO p
	JOIN #TEMP_ELECTRONICOS t ON p.nombre_producto = t.nombre_producto
	WHERE p.precio_unidad = t.precio_unidad_en_dolares * @ret
	AND NOT EXISTS (
		SELECT 1
		FROM productos.ELECTRONICO e
		WHERE e.id_producto = p.id_producto
		AND e.precio_unidad_en_dolares = t.precio_unidad_en_dolares
	);

	-- Limpiar tabla temporal
    DROP TABLE #TEMP_ELECTRONICOS;
END;
GO

/*
				======================================================================
				=		Procedure para insertar categor�as de productos varios		 =
				======================================================================
*/
CREATE OR ALTER PROCEDURE inserciones.IngresarCategorias @pathCatalogos VARCHAR(255), @pathClasificacion VARCHAR(255)
AS
BEGIN
	CREATE TABLE #TEMP_CATEGORIAS (
		linea_producto VARCHAR(255),
		producto VARCHAR(255)
	);

	DECLARE @sql NVARCHAR(MAX);
	
	-- Cargar datos desde el archivo Excel en la tabla temporal #TempCategoriasExcel
	SET @sql = N'INSERT INTO #TEMP_CATEGORIAS (linea_producto, producto)
				SELECT [L�nea de producto], Producto
				FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
				''Excel 12.0;HDR=YES;IMEX=1;Database=' + @pathClasificacion + ''', 
				''SELECT * FROM [Clasificacion productos$]'');';

	-- Ejecutar el comando din�mico
    EXEC sp_executesql @sql;

	-- Paso 4: Insertar en la tabla CATEGORIA si la categor�a no existe
	DECLARE @id_categoria INT;

	-- Usar la tabla temporal #TempCategoriasExcel para obtener y asignar las categor�as a los productos en #TempCatalogo
	-- Primero, asegurarse de que todas las categor�as necesarias existen en la tabla seguridad.CATEGORIA
	INSERT INTO seguridad.CATEGORIA (descripcion)
	SELECT DISTINCT 
		linea_producto
	FROM #TEMP_CATEGORIAS
	WHERE NOT EXISTS (
		SELECT 1
		FROM seguridad.CATEGORIA c
		WHERE c.descripcion = linea_producto
	);
	
	CREATE TABLE #TEMP_CATALOGO (
		id INT,
		category VARCHAR(255),
		name VARCHAR(255),
		price DECIMAL(10, 2),
		reference_price DECIMAL(10, 2),
		reference_unit VARCHAR(50),
		date DATETIME
	);

	-- Importar datos usando OPENROWSET con el proveedor ACE para manejar comillas en campos de texto
	SET @sql = N'INSERT INTO #TEMP_CATALOGO (id, category, name, price, reference_price, reference_unit, date)
				SELECT * 
				FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
								''Text;HDR=YES;FMT=Delimited;Database=' + @pathCatalogos + ''', 
								''SELECT * FROM catalogo.csv'');';
	EXEC sp_executesql @sql;

	-- Paso 5: Insertar datos en la tabla PRODUCTO
	INSERT INTO productos.PRODUCTO (nombre_producto, precio_unidad, id_categoria)
	SELECT DISTINCT
		t.name, 
		t.price, 
		c.id AS id_categoria
	FROM 
		#TEMP_CATALOGO AS t
		JOIN #TEMP_CATEGORIAS AS ex ON t.category = ex.producto
		JOIN seguridad.CATEGORIA AS c ON ex.linea_producto = c.descripcion
	WHERE NOT EXISTS (
		SELECT 1
		FROM productos.PRODUCTO p
		WHERE p.nombre_producto = t.name
		AND p.precio_unidad = t.price
		AND p.id_categoria = c.id
);
	
	-- Paso 6: Insertar datos en la tabla VARIOS
	INSERT INTO productos.VARIOS (id_producto, fecha, hora, unidad_de_referencia)
	SELECT DISTINCT
	    p.id_producto,
	    CAST(t.date AS DATE),
	    CAST(t.date AS TIME(0)),
	    t.reference_unit
	FROM 
	    #TEMP_CATALOGO AS t
	    JOIN productos.PRODUCTO AS p 
	        ON t.name = p.nombre_producto
	        AND t.price = p.precio_unidad
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM productos.VARIOS v
	    WHERE v.id_producto = p.id_producto
	      AND v.fecha = CAST(t.date AS DATE)
	      AND v.hora = CAST(t.date AS TIME(0))
	      AND v.unidad_de_referencia = t.reference_unit
	);
	
	-- Limpiar tablas temporales
	DROP TABLE #TEMP_CATALOGO;
	DROP TABLE #TEMP_CATEGORIAS;
END
GO

/*
				==========================================================
				=		Procedure para insertar productos importados	 =
				==========================================================
*/
CREATE OR ALTER PROCEDURE inserciones.InsertarProductosImportados @path VARCHAR(255)
AS
BEGIN
	-- Paso 1: Crear una tabla temporal para cargar el archivo Excel
	CREATE TABLE #TEMPORAL_PRODUCTOS (
		IdProducto INT,
		NombreProducto VARCHAR(80),
		Proveedor VARCHAR(80),
		Categoria VARCHAR(30),
		CantidadPorUnidad VARCHAR(80),
		PrecioUnidad DECIMAL(10, 2)
	);
	
	DECLARE @sql NVARCHAR(MAX);

	-- Paso 2: Cargar datos desde el archivo Excel en la tabla temporal
	SET @sql = N'
		INSERT INTO #TEMPORAL_PRODUCTOS
		SELECT *
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @path + ''',
			''SELECT * FROM [Listado de Productos$]''
		);';

	EXEC sp_executesql @sql;

	-- Paso 3: Insertar categor�as que no existen en la tabla CATEGORIA
	--Validamos no cargar repetidos

	INSERT INTO seguridad.CATEGORIA (descripcion)
	SELECT DISTINCT Categoria
	FROM #TEMPORAL_PRODUCTOS t
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM seguridad.CATEGORIA c
	    WHERE c.descripcion = t.Categoria
	);

	-- Paso 4: Insertar productos
	-- Primero, insertamos los productos y luego los buscamos para llenar IMPORTADO
	DECLARE @nuevoId INT;

	-- Insertar los productos
	--Validamos
	INSERT INTO productos.PRODUCTO (nombre_producto, precio_unidad, id_categoria)
	SELECT DISTINCT
	    t.NombreProducto, 
	    t.PrecioUnidad, 
	    (SELECT id FROM seguridad.CATEGORIA WHERE descripcion = t.Categoria)
	FROM #TEMPORAL_PRODUCTOS t
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM productos.PRODUCTO p
	    WHERE p.nombre_producto = t.NombreProducto
	      AND p.precio_unidad = t.PrecioUnidad
	      AND p.id_categoria = (SELECT id FROM seguridad.CATEGORIA WHERE descripcion = t.Categoria)
	);
	
	-- Paso 5: Insertar en IMPORTADO usando los IDs de los productos insertados
	INSERT INTO productos.IMPORTADO (id_producto, proveedor, cantidad_por_unidad)
	SELECT DISTINCT
	    p.id_producto,  -- ID del producto de la tabla PRODUCTO
	    t.Proveedor, 
	    t.CantidadPorUnidad
	FROM 
	    #TEMPORAL_PRODUCTOS AS t
	JOIN productos.PRODUCTO AS p 
	    ON p.nombre_producto = t.NombreProducto 
	    AND p.precio_unidad = t.PrecioUnidad
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM productos.IMPORTADO i
	    WHERE i.id_producto = p.id_producto
	      AND i.proveedor = t.Proveedor
	      AND i.cantidad_por_unidad = t.CantidadPorUnidad
	);
	
	-- Paso 6: Limpiar las tablas temporales
	DROP TABLE #TEMPORAL_PRODUCTOS;
END
GO

/*
				==============================================================
				=		Procedure para insertar las ventas y facturas		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE inserciones.InsertarVentasRegistradas(@path VARCHAR(255))
AS
BEGIN

    BEGIN TRY
		-- Crear tabla temporal
		CREATE TABLE #TEMP_VENTAS (
			id_factura CHAR(11),
			tipo_de_factura CHAR CHECK (tipo_de_factura IN ('A', 'B', 'C')) NOT NULL,
			ciudad CHAR(9) CHECK (ciudad IN ('Yangon', 'Naypyitaw', 'Mandalay')) NOT NULL,
			tipo_de_cliente CHAR(6) CHECK (tipo_de_cliente IN ('Normal', 'Member')) NOT NULL,
			genero CHAR(6) CHECK (genero IN ('Male', 'Female')) NOT NULL,
			producto VARCHAR(255) NOT NULL,
			precio_unitario DECIMAL(10, 2) NOT NULL,
			cantidad SMALLINT NOT NULL, -- max 32767, min -32768
			fecha CHAR(10) NOT NULL,    -- formato: MM/DD/YYYY
			hora TIME(0) NOT NULL,
			medio_de_pago CHAR(11) CHECK (medio_de_pago IN ('Ewallet', 'Cash', 'Credit card')) NOT NULL,
			empleado INT NOT NULL,
			identificador_de_pago CHAR(23)
		);

		DECLARE @sql NVARCHAR(MAX);

		-- Comando BULK INSERT para cargar los datos desde un archivo CSV
		SET @sql = N'
			BULK INSERT #TEMP_VENTAS
			FROM ''' + @path + ''' 
			WITH
			(
				FIELDTERMINATOR = '';'',  -- Separador de campos
				ROWTERMINATOR = ''\n'',   -- Fin de l�nea
				CODEPAGE = ''65001'',     -- UTF-8
				FIRSTROW = 2              -- Iniciar desde la fila 2
			);
		';


		-- Ejecutar el SQL din�mico para el BULK INSERT
		EXEC sp_executesql @sql;

	END TRY
	BEGIN CATCH
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH
	-- Actualizar registros en la tabla temporal
	UPDATE #TEMP_VENTAS
	SET 
		producto = REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(
													producto,
													'á', '�'
												), 'é', '�'
											), 'í', '�'
										), '�-', '�'
									), '��', '�'
								), 'ó', '�'
							), 'ú', '�'
						), '��', '�'
					), 'ñ', '�'
				), '��', '�'
			), '�', ''
		),
		identificador_de_pago = CASE
			WHEN identificador_de_pago = '--' THEN NULL
			WHEN identificador_de_pago LIKE '''%' THEN SUBSTRING(identificador_de_pago, 2, 22)
			ELSE identificador_de_pago
		END,
		fecha = CONVERT(DATE, fecha, 101); -- Formato de fecha MM/DD/YYYY

	-- Insertar nuevos tipos de cliente en TIPO
    INSERT INTO seguridad.TIPO (nombre)
    SELECT DISTINCT tipo_de_cliente
    FROM #TEMP_VENTAS t
    WHERE NOT EXISTS (
        SELECT 1
        FROM seguridad.TIPO tp
        WHERE tp.nombre = t.tipo_de_cliente
    );

    -- Insertar nuevos clientes en CLIENTE
    INSERT INTO seguridad.CLIENTE (genero, id_tipo)
    SELECT DISTINCT
        t.genero,
        tp.id
    FROM #TEMP_VENTAS t
    INNER JOIN seguridad.TIPO tp ON tp.nombre = t.tipo_de_cliente
    WHERE NOT EXISTS (
        SELECT 1
        FROM seguridad.CLIENTE c
        WHERE c.genero = t.genero AND c.id_tipo = tp.id
    );

	--Validar que no sean duplicados
	INSERT INTO transacciones.FACTURA (id, tipo_de_factura)
	SELECT DISTINCT 
	    id_factura, 
	    tipo_de_factura
	FROM #TEMP_VENTAS
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM transacciones.FACTURA f
	    WHERE f.id = #TEMP_VENTAS.id_factura
	      AND f.tipo_de_factura = #TEMP_VENTAS.tipo_de_factura
	);

	INSERT INTO transacciones.VENTA (id_factura, id_sucursal, id_producto, cantidad, fecha, hora, id_medio_de_pago, legajo, identificador_de_pago)
	SELECT DISTINCT
	    f.id,
	    s.id,
	    p.id_producto,
	    t.cantidad,
	    t.fecha,
	    t.hora,
	    m.id,
	    e.legajo,
	    t.identificador_de_pago
	FROM #TEMP_VENTAS t
	INNER JOIN transacciones.FACTURA f ON f.id = t.id_factura
	INNER JOIN seguridad.SUCURSAL s ON s.ciudad = t.ciudad
	INNER JOIN productos.PRODUCTO p ON p.nombre_producto = t.producto AND p.precio_unidad = t.precio_unitario
	INNER JOIN transacciones.MEDIO_DE_PAGO m ON m.descripcion_ingles = t.medio_de_pago
	INNER JOIN seguridad.EMPLEADO e ON e.legajo = t.empleado
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM transacciones.VENTA v
	    WHERE v.id_factura = f.id
	      AND v.id_sucursal = s.id
	      AND v.id_producto = p.id_producto
	      AND v.cantidad = t.cantidad
	      AND v.fecha = t.fecha
	      AND v.hora = t.hora
	      AND v.id_medio_de_pago = m.id
	      AND v.legajo = e.legajo
	      AND v.identificador_de_pago = t.identificador_de_pago
	);
	DROP TABLE #TEMP_VENTAS
END;
GO

