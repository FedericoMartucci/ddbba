/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 5											#
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

--CONFIGURACIONES PARA LA IMPORTACION
-- Habilita la visualización de opciones avanzadas en la configuración del motor
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
--Habilitamos el 'Ole Automation Procedures' para permitir al motor ejecutar comandos de automatización de objetos
EXEC sp_configure 'Ole Automation Procedures', 1;    
RECONFIGURE;
-- Volvemos a ocultar las opciones avanzadas para evitar cambios accidentales en configuraciones avanzadas
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO

--CREAMOS SCHEMA PARA REPORTES
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'reportes')
    EXEC('CREATE SCHEMA reportes');
GO

/*
				=====================================================
				=	Mensual: ingresando un mes y año determinado	=
				=	mostrar el total facturado por días de la		=
				=	semana, incluyendo sábado y domingo.			=
				=====================================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLFacturacionPorDiaSemana 
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50),
    @mes INT,
    @año INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT 
            FORMAT(v.fecha, 'dddd', 'es-ES') AS dia_de_la_semana,
            SUM(p.precio_unidad * v.cantidad) AS total_facturado
        FROM 
            transacciones.VENTA v
        JOIN 
            productos.PRODUCTO p ON v.id_producto = p.id_producto
        WHERE 
            MONTH(v.fecha) = @mes
            AND YEAR(v.fecha) = @año
        GROUP BY 
            FORMAT(v.fecha, 'dddd', 'es-ES'), DATEPART(WEEKDAY, v.fecha)
        ORDER BY 
            DATEPART(WEEKDAY, v.fecha)
        FOR XML RAW('DiaSemana'), ROOT('InformeFacturacion'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    -- Convierte el XML a NVARCHAR(MAX) para escribirlo en el archivo
    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    -- Crea el objeto FileSystemObject
    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    -- Crea el archivo en la ruta especificada
    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Escribe el contenido XML en el archivo
    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Cierra el archivo y destruye los objetos
    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLFacturacionPorDiaSemana 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes', 
    @nombreInforme = 'FacturacionPorDiaSemana', 
    @mes = 3, 
    @año = 2019;
GO

/*
				=============================================
				=	Trimestral: mostrar el total facturado	=
				=	por turnos de trabajo por mes.			=
				=============================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLFacturacionPorTurnoTrimestral 
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50),
    @año INT,
    @trimestre INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Calcula el primer y último mes del trimestre especificado
    DECLARE @mes_inicio INT = (@trimestre - 1) * 3 + 1;
    DECLARE @mes_fin INT = @mes_inicio + 2;

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT 
            e.turno AS turno,
            MONTH(v.fecha) AS mes,
            SUM(p.precio_unidad * v.cantidad) AS total_facturado
        FROM 
            transacciones.VENTA v
        JOIN 
            productos.PRODUCTO p ON v.id_producto = p.id_producto
        JOIN 
            seguridad.EMPLEADO e ON v.id_empleado = e.id_empleado
        WHERE 
            YEAR(v.fecha) = @año
            AND MONTH(v.fecha) BETWEEN @mes_inicio AND @mes_fin
        GROUP BY 
            e.turno, MONTH(v.fecha)
        FOR XML RAW('Turno'), ROOT('InformeFacturacionTrimestral'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    -- Convierte el XML a NVARCHAR(MAX) para escribirlo en el archivo
    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    -- Crea el objeto FileSystemObject
    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    -- Crea el archivo en la ruta especificada
    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Escribe el contenido XML en el archivo
    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Cierra el archivo y destruye los objetos
    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLFacturacionPorTurnoTrimestral 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes', 
    @nombreInforme = 'FacturacionPorTurnoTrimestral', 
    @año = 2019, 
    @trimestre = 1;
GO

/*
				==============================================================
				=	Por rango de fechas: ingresando un rango de fechas		 =
				=	a demanda, debe poder mostrar la cantidad de productos	 =
				=	vendidos en ese rango, ordenado de mayor a menor.		 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLProductosVendidosPorRango
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50),
    @fechaInicio DATE,
    @fechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT 
            p.id_producto AS id_producto,
            p.nombre_producto AS nombre_producto,
            SUM(v.cantidad) AS cantidad_total_vendida
        FROM 
            transacciones.VENTA v
        INNER JOIN 
            productos.PRODUCTO p ON v.id_producto = p.id_producto
        WHERE 
            v.fecha BETWEEN @fechaInicio AND @fechaFin
        GROUP BY 
            p.id_producto, p.nombre_producto
        ORDER BY 
            cantidad_total_vendida DESC
        FOR XML RAW('Producto'), ROOT('InformeProductosVendidos'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    -- Convierte el XML a NVARCHAR(MAX) para escribirlo en el archivo
    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    -- Crea el objeto FileSystemObject
    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    -- Crea el archivo en la ruta especificada
    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Escribe el contenido XML en el archivo
    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Cierra el archivo y destruye los objetos
    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLProductosVendidosPorRango 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes', 
    @nombreInforme = 'ProductosVendidosPorRango',
    @fechaInicio = '2019-01-01', 
    @fechaFin = '2019-03-31';
GO

/*
				==============================================================
				=	Por rango de fechas: ingresando un rango de fechas		 =
				=	a demanda, debe poder mostrar la cantidad de productos	 =
				=	vendidos en ese rango por sucursal, ordenado de mayor	 =
				=	a menor.												 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLProductosVendidosPorSucursal 
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50), 
    @fechaInicio DATE, 
    @fechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT 
            s.id AS id_sucursal,
            s.reemplazar_por AS nombre_sucursal,
            SUM(v.cantidad) AS cantidad_total_vendida
        FROM 
            transacciones.VENTA v
        JOIN 
            seguridad.SUCURSAL s ON v.id_sucursal = s.id
        WHERE 
            v.fecha BETWEEN @fechaInicio AND @fechaFin
        GROUP BY 
            s.id, s.reemplazar_por
        ORDER BY 
            cantidad_total_vendida DESC
        FOR XML RAW('Sucursal'), ROOT('InformeVentas'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    -- Convierte el XML a NVARCHAR(MAX) para escribirlo en el archivo
    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    -- Crea el objeto FileSystemObject
    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    -- Crea el archivo en la ruta especificada
    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Escribe el contenido XML en el archivo
    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Cierra el archivo y destruye los objetos
    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLProductosVendidosPorSucursal 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes', 
    @nombreInforme = 'ProductosVendidos', 
    @fechaInicio = '2019-01-01', 
    @fechaFin = '2019-03-31';
GO

/*
				======================================================================
				=		Mostrar los 5 productos más vendidos en un mes, por semana.	 =
				======================================================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLTop5ProductosPorSemana
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50),
    @mes INT,
    @año INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT 
            DATEPART(WEEK, v.fecha) AS semana,
            p.id_producto AS id_producto,
            p.nombre_producto AS nombre_producto,
            SUM(v.cantidad) AS total_vendido
        FROM 
            transacciones.VENTA v
        INNER JOIN 
            productos.PRODUCTO p ON v.id_producto = p.id_producto
        WHERE 
            MONTH(v.fecha) = @mes 
            AND YEAR(v.fecha) = @año
        GROUP BY 
            DATEPART(WEEK, v.fecha), p.id_producto, p.nombre_producto
        ORDER BY 
            DATEPART(WEEK, v.fecha), total_vendido DESC
        OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY
        FOR XML RAW('Producto'), ROOT('InformeTop5ProductosPorSemana'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLTop5ProductosPorSemana 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes', 
    @nombreInforme = 'Top5ProductosPorSemana',
    @mes = 3, 
    @año = 2019;
GO

/*
				==============================================================
				=		Mostrar los 5 productos menos vendidos en el mes.	 =
				==============================================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLProductosMenosVendidos 
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT TOP 5 
            p.id_producto AS id_producto,
            p.nombre_producto AS nombre_producto,
            SUM(v.cantidad) AS total_vendido
        FROM 
            transacciones.VENTA v
        INNER JOIN 
            productos.PRODUCTO p ON v.id_producto = p.id_producto
        WHERE 
            MONTH(v.fecha) = 3 -- MONTH(GETDATE()) 
            AND YEAR(v.fecha) = 2019 -- YEAR(GETDATE()) 
        GROUP BY 
            p.id_producto, p.nombre_producto
        ORDER BY 
            total_vendido ASC
        FOR XML RAW('Producto'), ROOT('InformeProductos'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    -- Convierte el XML a NVARCHAR(MAX) para escribirlo en el archivo
    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    -- Crea el objeto FileSystemObject
    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    -- Crea el archivo en la ruta especificada
    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Escribe el contenido XML en el archivo
    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    -- Cierra el archivo y destruye los objetos
    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLProductosMenosVendidos 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes', 
    @nombreInforme = 'ProductosMenosVendidos';
GO

/*
				=================================================
				=	Mostrar total acumulado de ventas (o sea	=
				=	tambien	mostrar el detalle) para una fecha	=
				=	y sucursal particulares						=
				=================================================
*/
CREATE OR ALTER PROCEDURE reportes.GenerarInformeXMLVentasPorFechaSucursal
    @rutaBase VARCHAR(100), 
    @nombreInforme VARCHAR(50),
    @fecha DATE,
    @idSucursal INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xmlData XML;
    DECLARE @filePath NVARCHAR(255) = @rutaBase + '\informe-' + @nombreInforme + '-' 
                                      + CONVERT(NVARCHAR, GETDATE(), 23) 
                                      + '_' 
                                      + REPLACE(CONVERT(NVARCHAR, GETDATE(), 108), ':', '-') 
                                      + '.xml';

    -- Ejecuta la consulta y guarda el resultado en @xmlData
    SELECT @xmlData = (
        SELECT 
            v.id AS id_venta,
            v.fecha AS fecha_venta,
            p.id_producto AS id_producto,
            p.nombre_producto AS nombre_producto,
            v.cantidad AS cantidad_vendida,
            (p.precio_unidad * v.cantidad) AS total_facturado
        FROM 
            transacciones.VENTA v
        INNER JOIN 
            productos.PRODUCTO p ON v.id_producto = p.id_producto
        WHERE 
            v.fecha = @fecha
            AND v.id_sucursal = @idSucursal
        FOR XML RAW('Venta'), ROOT('InformeVentasPorFechaSucursal'), ELEMENTS
    );

    DECLARE @fileSystem INT, @file INT, @hr INT, @xmlContent NVARCHAR(MAX);

    SET @xmlContent = CONVERT(NVARCHAR(MAX), @xmlData);

    EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fileSystem OUT;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear FileSystemObject';
        RETURN;
    END;

    EXEC @hr = sp_OAMethod @fileSystem, 'CreateTextFile', @file OUT, @filePath, 1;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al crear el archivo';
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    EXEC @hr = sp_OAMethod @file, 'Write', NULL, @xmlContent;
    IF @hr <> 0
    BEGIN
        PRINT 'Error al escribir en el archivo';
        EXEC sp_OAMethod @file, 'Close';
        EXEC sp_OADestroy @file;
        EXEC sp_OADestroy @fileSystem;
        RETURN;
    END;

    EXEC @hr = sp_OAMethod @file, 'Close';
    EXEC sp_OADestroy @file;
    EXEC sp_OADestroy @fileSystem;

    PRINT 'Archivo XML guardado exitosamente en ' + @filePath;
END;
GO

-- Ejemplo de uso
EXEC reportes.GenerarInformeXMLVentasPorFechaSucursal 
    @rutaBase = 'C:\Users\User\Desktop\ddbba\reportes',
    @nombreInforme = 'VentasPorFechaSucursal',
    @fecha = '2019-03-10', 
    @idSucursal = 2;
GO