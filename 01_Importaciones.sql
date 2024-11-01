USE Com5600G08
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;    
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO

/*
				==============================================================
				=			Procedure para insertar las sucursales			 =
				==============================================================
*/

CREATE OR ALTER PROCEDURE InsertarSucursales(@path VARCHAR(255))	--InformacionComplementaria
AS
BEGIN
    CREATE TABLE #TEMP_SUCURSAL (
        ciudad VARCHAR(20) NOT NULL,
        reemplazar_por VARCHAR(30) NOT NULL,
        direccion VARCHAR(100) NOT NULL,
        horario VARCHAR(100) NOT NULL,
        telefono CHAR(9) CHECK (telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') NOT NULL
    );

	 -- Armar el comando dinámico para OPENROWSET con el path
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'INSERT INTO #TEMP_SUCURSAL (ciudad, reemplazar_por, direccion, horario, telefono)
                 SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
                 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [sucursal$]'');';

    -- Ejecutar el comando dinámico
    EXEC sp_executesql @sql;

    INSERT INTO aurora.SUCURSAL (horario, ciudad, reemplazar_por, direccion, codigo_postal, provincia)
    SELECT 
        horario,
        ciudad,
        reemplazar_por,
        LTRIM(RTRIM(REPLACE(LEFT(direccion, CHARINDEX(',', direccion) - 1), ' ', ''))) AS direccion,
        SUBSTRING(direccion, CHARINDEX(', B', direccion) + 2, 5) AS codigo_postal,
        SUBSTRING(direccion, CHARINDEX('Provincia', direccion) + 13, LEN(direccion)) AS provincia
    FROM #TEMP_SUCURSAL;

    INSERT INTO aurora.TELEFONO (id_sucursal, telefono)
    SELECT s.id, t.telefono
    FROM aurora.SUCURSAL s
    JOIN #TEMP_SUCURSAL t ON s.reemplazar_por = t.reemplazar_por;

    DROP TABLE #TEMP_SUCURSAL;
END;
GO

/*
				==============================================================
				=			Procedure para insertar los empleados			 =
				==============================================================
*/

CREATE OR ALTER PROCEDURE InsertarEmpleados(@path VARCHAR(255))	--InformacionComplementaria
AS
BEGIN
    CREATE TABLE #TEMP_EMPLEADO (
        legajo INT CONSTRAINT PK_TEMPEMPLEADO_LEGAJO PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR(50) NOT NULL,
        dni INT NOT NULL,
        direccion VARCHAR(150) NOT NULL,
        email_empresa VARCHAR(100) NOT NULL,
        email_personal VARCHAR(100),
        CUIL CHAR(11),
        cargo VARCHAR(50),
        sucursal VARCHAR(50),
        turno VARCHAR(50)
    );

	-- Armar el comando dinámico para OPENROWSET con el path
	DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'INSERT INTO #TEMP_EMPLEADO (legajo, nombre, apellido, dni, direccion, email_personal, email_empresa, CUIL, cargo, sucursal, turno)
                 SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
                 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [Empleados$]'')
				 WHERE [Legajo/ID] IS NOT NULL;';

    -- Ejecutar el comando dinámico
    EXEC sp_executesql @sql;

    INSERT INTO aurora.CARGO (nombre)
    SELECT DISTINCT cargo
    FROM #TEMP_EMPLEADO
    WHERE cargo IS NOT NULL AND cargo NOT IN (SELECT nombre FROM aurora.CARGO);

    INSERT INTO aurora.EMPLEADO (legajo, nombre, apellido, dni, direccion, email_empresa, email_personal, CUIL, id_cargo, id_sucursal, turno)
    SELECT 
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
        LEFT JOIN aurora.CARGO c ON e.cargo = c.nombre
        LEFT JOIN aurora.SUCURSAL s ON e.sucursal = s.reemplazar_por;

    DROP TABLE #TEMP_EMPLEADO;
END;
GO

/*
				==============================================================
				=			Procedure para insertar los medios de pago		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE InsertarMediosDePago(@path VARCHAR(255))	--InformacionComplementaria
AS
BEGIN
	-- Armar el comando dinámico para OPENROWSET con el path
    DECLARE @sql NVARCHAR(MAX);
	
    SET @sql = N'INSERT INTO aurora.MEDIO_DE_PAGO (descripcion_ingles, descripcion)
				 SELECT [F2], [F3]
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
				 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [medios de pago$]'');';
	
    -- Ejecutar el comando dinámico
    EXEC sp_executesql @sql;
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
    EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --Señalamos donde vamos a guardar la respuesta.

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
				=		Procedure para insertar productos electrónicos		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE InsertarProductosElectronicos(@path VARCHAR(255))
AS
BEGIN
    DECLARE @ret decimal(10,2);
    DECLARE @id_categoria INT;
	
	-- Verificar si existe la categoría 'Accesorios Electronicos' y obtener su id
    SET @id_categoria = (SELECT id FROM aurora.CATEGORIA WHERE descripcion = 'Accesorios Electronicos');

	-- Si la categoría no existe, crear una nueva
    IF @id_categoria IS NULL
    BEGIN
        INSERT INTO aurora.CATEGORIA (descripcion)
        VALUES ('Accesorios Electronicos');

		-- Obtener el id de la nueva categoría
        SET @id_categoria = SCOPE_IDENTITY();
    END;

	-- Obtiene el valor del dólar en pesos
    EXEC ObtenerValorDolarCCL @ret OUTPUT;

	-- Crear una tabla temporal para almacenar los datos del archivo de Excel
    CREATE TABLE #TEMP_ELECTRONICOS (
        nombre_producto VARCHAR(255),
        precio_unidad_en_dolares DECIMAL(10, 2)
    );

	-- Armar el comando dinámico para OPENROWSET con el path
    DECLARE @sql NVARCHAR(MAX);

	-- Cargar datos desde el archivo de Excel en la tabla temporal
    SET @sql = N'INSERT INTO #TEMP_ELECTRONICOS (nombre_producto, precio_unidad_en_dolares)
				 SELECT [Product], [Precio Unitario en dolares]
				 FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
				 ''Excel 12.0; HDR=YES; Database=' + @path + ''', 
                 ''SELECT * FROM [Sheet1$]'');';
	
    -- Ejecutar el comando dinámico
    EXEC sp_executesql @sql;
	
	-- Insertar en la tabla PRODUCTO utilizando los datos de ##TEMP_ELECTRONICOS
    -- Acáí convertimos el precio en dólares a pesos
    INSERT INTO aurora.PRODUCTO (nombre_producto, precio_unidad, id_categoria)
    SELECT nombre_producto, precio_unidad_en_dolares * @ret, @id_categoria
    FROM #TEMP_ELECTRONICOS;

	-- Insertar en la tabla ELECTRONICO utilizando los IDs recién generados en PRODUCTO
    INSERT INTO aurora.ELECTRONICO (id_producto, precio_unidad_en_dolares)
    SELECT DISTINCT p.id_producto, t.precio_unidad_en_dolares
    FROM aurora.PRODUCTO p
    JOIN #TEMP_ELECTRONICOS t ON p.nombre_producto = t.nombre_producto
    WHERE p.precio_unidad = t.precio_unidad_en_dolares * @ret;

	-- Limpiar tabla temporal
    DROP TABLE #TEMP_ELECTRONICOS;
END;
GO

/*
				======================================================================
				=		Procedure para insertar categorías de productos varios		 =
				======================================================================
*/
CREATE OR ALTER PROCEDURE IngresarCategorias @pathCatalogos VARCHAR(255), @pathClasificacion VARCHAR(255)
AS
BEGIN
	CREATE TABLE #TEMP_CATEGORIAS (
		linea_producto VARCHAR(255),
		producto VARCHAR(255)
	);

	DECLARE @sql NVARCHAR(MAX);
	
	-- Cargar datos desde el archivo Excel en la tabla temporal #TempCategoriasExcel
	SET @sql = N'INSERT INTO #TEMP_CATEGORIAS (linea_producto, producto)
				SELECT [Línea de producto], Producto
				FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
				''Excel 12.0;HDR=YES;IMEX=1;Database=' + @pathClasificacion + ''', 
				''SELECT * FROM [Clasificacion productos$]'');';

	-- Ejecutar el comando dinámico
    EXEC sp_executesql @sql;

	-- Paso 4: Insertar en la tabla CATEGORIA si la categoría no existe
	DECLARE @id_categoria INT;

	-- Usar la tabla temporal #TempCategoriasExcel para obtener y asignar las categorías a los productos en #TempCatalogo
	-- Primero, asegurarse de que todas las categorías necesarias existen en la tabla aurora.CATEGORIA
	INSERT INTO aurora.CATEGORIA (descripcion)
	SELECT DISTINCT linea_producto
	FROM #TEMP_CATEGORIAS
	WHERE linea_producto NOT IN (SELECT descripcion FROM aurora.CATEGORIA);
	
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
	INSERT INTO aurora.PRODUCTO (nombre_producto, precio_unidad, id_categoria)
	SELECT 
		t.name, 
		t.price, 
		c.id AS id_categoria
	FROM 
		#TEMP_CATALOGO AS t
		JOIN #TEMP_CATEGORIAS AS ex ON t.category = ex.producto
		JOIN aurora.CATEGORIA AS c ON ex.linea_producto = c.descripcion;
	
	-- Paso 6: Insertar datos en la tabla VARIOS
	INSERT INTO aurora.VARIOS (id_producto, fecha, hora, unidad_de_referencia)
	SELECT DISTINCT
		p.id_producto,
		CAST(t.date AS DATE),
		CAST(t.date AS TIME(0)),
		t.reference_unit
	FROM 
		#TEMP_CATALOGO AS t
		JOIN aurora.PRODUCTO AS p ON t.name = p.nombre_producto
		AND t.price = p.precio_unidad;
	
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
CREATE OR ALTER PROCEDURE InsertarProductosImportados @path VARCHAR(255)
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

	-- Paso 3: Insertar categorías que no existen en la tabla CATEGORIA
	INSERT INTO aurora.CATEGORIA (descripcion)
	SELECT DISTINCT Categoria
	FROM #TEMPORAL_PRODUCTOS
	WHERE Categoria NOT IN (SELECT descripcion FROM aurora.CATEGORIA);

	-- Paso 4: Insertar productos
	-- Primero, insertamos los productos y luego los buscamos para llenar IMPORTADO
	DECLARE @nuevoId INT;

	-- Insertar los productos
	INSERT INTO aurora.PRODUCTO (nombre_producto, precio_unidad, id_categoria)
	SELECT 
		NombreProducto, 
		PrecioUnidad, 
		(SELECT id FROM aurora.CATEGORIA WHERE descripcion = t.Categoria)
	FROM #TEMPORAL_PRODUCTOS AS t;
	
	-- Paso 5: Insertar en IMPORTADO usando los IDs de los productos insertados
	INSERT INTO aurora.IMPORTADO (id_producto, proveedor, cantidad_por_unidad)
	SELECT 
		p.id_producto,  -- ID del producto de la tabla PRODUCTO
		t.Proveedor, 
		t.CantidadPorUnidad
	FROM 
		#TEMPORAL_PRODUCTOS AS t
	JOIN aurora.PRODUCTO AS p ON p.nombre_producto = t.NombreProducto AND p.precio_unidad = t.PrecioUnidad; -- Busca el producto por nombre y precio
	
	-- Paso 6: Limpiar las tablas temporales
	DROP TABLE #TEMPORAL_PRODUCTOS;
END
GO

/*
				==============================================================
				=		Procedure para insertar las ventas y facturas		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE InsertarVentasRegistradas(@path VARCHAR(255))
AS
BEGIN
    BEGIN TRY
		CREATE TABLE #TEMP_VENTAS
		(
			id_factura char(11),
			tipo_de_factura char CHECK(tipo_de_factura IN('A', 'B', 'C')) NOT NULL,
			ciudad char(9) CHECK(ciudad IN('Yangon', 'Naypyitaw', 'Mandalay')) NOT NULL,
			tipo_de_cliente char(6) CHECK(tipo_de_cliente IN('Normal', 'Member')) NOT NULL,
			genero char(6) CHECK(genero IN('Male', 'Female')) NOT NULL, --Male - Female
			producto varchar(255) NOT NULL,
			precio_unitario decimal(10,2) NOT NULL,
			cantidad smallint NOT NULL,--maximo 32767 y minimo -32768
			fecha char(10) NOT NULL,--10/20/2011
			hora time(0) NOT NULL,
			medio_de_pago char(11) CHECK(medio_de_pago IN('Ewallet', 'Cash', 'Credit card')) NOT NULL,--Ewallet - Cash - Credit card
			empleado int NOT NULL,--257020
			identificador_de_pago CHAR(23) 
		)

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = N'
            BULK INSERT #TEMP_VENTAS
            FROM ''' + @path + '''
            WITH
            (
                FIELDTERMINATOR = '','';  -- Separador de campos, ajústalo si es necesario
                ROWTERMINATOR = ''\n'',   -- Fin de línea
                CODEPAGE = ''65001'',     -- UTF-8
                FIRSTROW = 2              -- Iniciar desde la fila 2
            ); 

			UPDATE #TEMP_VENTAS
			SET PRODUCTO = REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(PRODUCTO, 
																	''Ã¡'', ''á''),    
																	''Ã©'', ''é''),    
																	''Ã'', ''í''),  
																	''í-'', ''í''),  
																	''í³'', ''ó''),
																	''Ã³'', ''ó''),
																	''Ãº'', ''ú''),
																	''íº'', ''ú''),
																	''Ã±'', ''ñ''),
																	''í±'', ''ñ''),
																	''Â'', ''''),
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                ),
                                                IDENTIFICADOR_DE_PAGO = 
                                                CASE
                                                    WHEN IDENTIFICADOR_DE_PAGO = ''--'' THEN NULL
                                                    WHEN IDENTIFICADOR_DE_PAGO LIKE ''''''%''
                                                        THEN SUBSTRING(IDENTIFICADOR_DE_PAGO, 2, 22)
                                                    ELSE IDENTIFICADOR_DE_PAGO
                                                END,
                                                FECHA = CONVERT(DATE, FECHA, 101); 
        ';

        -- Ejecutar el SQL dinámico
        EXEC sp_executesql @sql;

    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
		
	INSERT INTO aurora.FACTURA (id, tipo_de_factura)
	SELECT id_factura, tipo_de_factura
	FROM #TEMP_VENTAS

	INSERT INTO aurora.VENTA (id_factura, id_sucursal, tipo_de_cliente, genero, id_producto, cantidad, fecha, hora, id_medio_de_pago, legajo, identificador_de_pago)
	SELECT
		f.id,
		s.id,
		t.tipo_de_cliente,
		t.genero,
		p.id_producto,
		t.cantidad,
		t.fecha,
		t.hora,
		m.id,
		e.legajo,
		t.identificador_de_pago
	FROM #TEMP_VENTAS t
	INNER JOIN aurora.FACTURA f ON f.id = t.id_factura
	INNER JOIN aurora.SUCURSAL s ON s.ciudad = t.ciudad
	INNER JOIN aurora.PRODUCTO p ON p.nombre_producto = t.producto AND p.precio_unidad = t.precio_unitario
	INNER JOIN aurora.MEDIO_DE_PAGO m ON m.descripcion_ingles = t.medio_de_pago
	INNER JOIN aurora.EMPLEADO e ON e.legajo = t.empleado

	DROP TABLE #TEMP_VENTAS
END;
GO

DECLARE @pathVentasRegistradas VARCHAR(255) = 'C:\Users\User\Desktop\Informacion_complementaria.xlsx';
DECLARE @pathInformacionComplementaria VARCHAR(255) = 'C:\Users\User\Desktop\Informacion_complementaria.xlsx';
DECLARE @pathCatalogo VARCHAR(255) = 'C:\Users\User\Desktop\Informacion_complementaria.xlsx';
DECLARE @pathProductosElectronicos VARCHAR(255) = 'C:\Users\User\Desktop\Electronic accessories.xlsx';
DECLARE @pathProductosImportados VARCHAR(255) = 'C:\Users\User\Desktop\Informacion_complementaria.xlsx'

EXEC InsertarSucursales @pathInformacionComplementaria;
EXEC InsertarEmpleados @pathInformacionComplementaria;
EXEC InsertarMediosDePago @pathInformacionComplementaria;
EXEC InsertarProductosElectronicos @pathProductosElectronicos
EXEC IngresarCategorias @pathCatalogo, @pathInformacionComplementaria
EXEC InsertarProductosImportados @pathProductosImportados
EXEC InsertarVentasRegistradas @pathVentasRegistradas
GO

SELECT * FROM aurora.SUCURSAL
GO

SELECT * FROM aurora.TELEFONO
GO

SELECT * FROM aurora.CARGO
GO

SELECT * FROM aurora.EMPLEADO
GO

SELECT * FROM aurora.MEDIO_DE_PAGO
GO

SELECT * FROM aurora.CATEGORIA
GO

SELECT * FROM aurora.PRODUCTO
GO

SELECT * FROM aurora.VARIOS
GO

SELECT * FROM aurora.ELECTRONICO
GO

SELECT * FROM aurora.IMPORTADO
GO

SELECT * FROM aurora.FACTURA
GO

SELECT * FROM aurora.VENTA
GO


/*
USE master
GO

DROP DATABASE Com5600G08
GO
*/

/*****************************************************************************************/

