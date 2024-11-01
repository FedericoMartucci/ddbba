
-- CREACION DE LA BASE DE DATOS 'Com5600G08'

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com5600G08')
BEGIN
    CREATE DATABASE Com5600G08;
END;

GO

USE Com5600G08;

GO

-- CREACION DEL SCHEMA 'aurora'

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'aurora')
BEGIN
    EXEC('CREATE SCHEMA aurora');
END;

-- CREACION DE LAS TABLAS DENTRO DEL SCHEMA 'aurora'

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.CARGO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.CARGO (
        id INT IDENTITY(1, 1) CONSTRAINT PK_CARGO_ID PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL
    );
END;

/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.TIPO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.TIPO (
        id INT CONSTRAINT PK_TIPO_ID PRIMARY KEY,
        nombre VARCHAR(255) NOT NULL
    );
END;
*/

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.CATEGORIA') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.CATEGORIA (
        id INT IDENTITY (1, 1) CONSTRAINT PK_CATEGORIA_ID PRIMARY KEY,
        descripcion VARCHAR(50)
    );
END;

/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.CLIENTE') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.CLIENTE (
        id INT CONSTRAINT PK_CLIENTE_ID PRIMARY KEY,
        genero VARCHAR(6) CHECK (genero IN ('male', 'female')),
        id_tipo INT,
        CONSTRAINT FK_ID_TIPO_CLIENTE_TIPO FOREIGN KEY (id_tipo) REFERENCES aurora.TIPO(id)
    );
END;
*/

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.SUCURSAL') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.SUCURSAL (
        id INT IDENTITY(1, 1) CONSTRAINT PK_SUCURSAL_ID PRIMARY KEY,
        horario VARCHAR(50),
        ciudad VARCHAR(50),
		reemplazar_por VARCHAR(255),
        direccion VARCHAR(50),
        codigo_postal CHAR(5),
        provincia VARCHAR(50)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.TELEFONO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.TELEFONO (
        id_sucursal INT CONSTRAINT PK_TELEFONO_IDSUCURSAL PRIMARY KEY,
		telefono CHAR(9) CHECK (telefono LIKE ('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')) NOT NULL,
		CONSTRAINT FK_IDSUCURSAL_TELEFONO_SUCURSAL FOREIGN KEY (id_sucursal) REFERENCES aurora.SUCURSAL(id)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.EMPLEADO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.EMPLEADO (
        legajo INT CONSTRAINT PK_EMPLEADO_LEGAJO PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR(50) NOT NULL,
        dni INT NOT NULL,
		direccion VARCHAR(150) NOT NULL,
        email_empresa VARCHAR(100) NOT NULL,
        email_personal VARCHAR(100),
        CUIL CHAR(11),
        id_cargo INT,
		id_sucursal INT,
        turno VARCHAR(50),
        CONSTRAINT FK_ID_CARGO_EMPLEADO_CARGO FOREIGN KEY (id_cargo) REFERENCES aurora.CARGO(id),
		CONSTRAINT FK_ID_SUCURSAL_EMPLEADO_SUCURSAL FOREIGN KEY (id_sucursal) REFERENCES aurora.SUCURSAL(id)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.PRODUCTO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.PRODUCTO (
        id_producto INT IDENTITY(1, 1) CONSTRAINT PK_PRODUCTO_ID PRIMARY KEY,
        precio_unidad DECIMAL(10, 2),
        nombre_producto VARCHAR(100) NOT NULL,
		id_categoria INT,
		CONSTRAINT FK_ID_CATEGORIA_PRODUCTO_CATEGORIA FOREIGN KEY (id_categoria) REFERENCES aurora.CATEGORIA(id)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.FACTURA') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.FACTURA (
        id CHAR(11) CHECK (id LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]') CONSTRAINT PK_FACTURA_ID PRIMARY KEY,
        tipo_de_factura CHAR CHECK(tipo_de_factura IN('A', 'B', 'C')) NOT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.MEDIO_DE_PAGO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.MEDIO_DE_PAGO (
        id INT IDENTITY(1, 1) CONSTRAINT PK_MEDIO_DE_PAGO_ID PRIMARY KEY,
        descripcion_ingles VARCHAR(50) NOT NULL,
		descripcion VARCHAR(50) NOT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.VENTA') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.VENTA (
        id INT IDENTITY(1, 1) CONSTRAINT PK_VENTA_ID PRIMARY KEY,
        id_factura CHAR(11) CHECK (id_factura LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
        id_sucursal INT,
		tipo_de_cliente CHAR(6) CHECK(tipo_de_cliente IN('Normal', 'Member')) NOT NULL,
		genero VARCHAR(6) CHECK(genero IN('Male', 'Female')) NOT NULL, --Male - Female
        id_producto INT,
        cantidad SMALLINT  NOT NULL, --maximo 32767 y minimo -32768
        fecha DATE NOT NULL,
        hora TIME(0) NOT NULL,
        id_medio_de_pago INT,
        legajo INT,
        identificador_de_pago VARCHAR(22)
		CHECK
		(
			(LEN(identificador_de_pago) = 22 AND identificador_de_pago NOT LIKE '%[^0-9]%') OR	--Ewallet
			(identificador_de_pago LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') OR	--Credit card
			(identificador_de_pago IS NULL) --Cash
		), --LONGITUD MAXIMA 22 y SOLO CARACTERES NUMEROS o 4NUMEROS-4NUMEROS-4NUMEROS-4NUMEROS o NULL,
        CONSTRAINT FK_ID_MEDIO_DE_PAGO_VENTA_MEDIO_DE_PAGO FOREIGN KEY (id_medio_de_pago) REFERENCES aurora.MEDIO_DE_PAGO(id),
        CONSTRAINT FK_LEGAJO_VENTA_EMPLEADO FOREIGN KEY (legajo) REFERENCES aurora.EMPLEADO(legajo),
        CONSTRAINT FK_ID_PRODUCTO_VENTA_PRODUCTO FOREIGN KEY (id_producto) REFERENCES aurora.PRODUCTO(id_producto),
        CONSTRAINT FK_ID_SUCURSAL_VENTA_SUCURSAL FOREIGN KEY (id_sucursal) REFERENCES aurora.SUCURSAL(id),
        CONSTRAINT FK_ID_FACTURA_VENTA_FACTURA FOREIGN KEY (id_factura) REFERENCES aurora.FACTURA(id)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.IMPORTADO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.IMPORTADO (
        id_producto INT CONSTRAINT PK_IMPORTADO_ID PRIMARY KEY,
        proveedor VARCHAR(255),
        cantidad_por_unidad VARCHAR(255),
        CONSTRAINT FK_ID_PRODUCTO_IMPORTADO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES aurora.PRODUCTO(id_producto)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.VARIOS') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.VARIOS (
        id_producto INT CONSTRAINT PK_VARIOS_ID PRIMARY KEY,
        fecha DATE,
        hora TIME(0),
        unidad_de_referencia VARCHAR(50),
        CONSTRAINT FK_ID_PRODUCTO_VARIOS_PRODUCTO FOREIGN KEY (id_producto) REFERENCES aurora.PRODUCTO(id_producto)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aurora.ELECTRONICO') AND type in (N'U'))
BEGIN
    CREATE TABLE aurora.ELECTRONICO (
        id_producto INT CONSTRAINT PK_ELECTRONICO_ID PRIMARY KEY,
        precio_unidad_en_dolares DECIMAL(10, 2),
        CONSTRAINT FK_ID_PRODUCTO_ELECTRONICO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES aurora.PRODUCTO(id_producto)
    );
END;
GO

