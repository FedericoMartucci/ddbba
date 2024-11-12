/*
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#               Bases de Datos Aplicadas					#
#															#
#   Script Nro: 0											#
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
-- CREACION DE LA BASE DE DATOS 'Com5600G08'
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com5600G08')
BEGIN
    CREATE DATABASE Com5600G08;
END;
GO

USE Com5600G08;
GO

-- CREACION DE LOS SCHEMAS
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'seguridad')
    EXEC('CREATE SCHEMA seguridad');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'transacciones')
    EXEC('CREATE SCHEMA transacciones');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'productos')
    EXEC('CREATE SCHEMA productos');


/*
				==============================================================
				=	 Creación de las tablas dentro del schema seguridad		 =
				==============================================================
*/

--CREAMOS LA TABLA 'CARGO' SI NO EXISTE PREVIAMENTE, LA MISMA METODOLOGIA SE APLICA AL RESTO DE LAS TABLAS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.CARGO') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.CARGO (
        id INT IDENTITY(1, 1) CONSTRAINT PK_CARGO_ID PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
		esValido BIT NOT NULL DEFAULT 1,
    );
END;


--CREAMOS LA TABLA 'TIPO' que tendrá los distintos tipos de cliente
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.TIPO') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.TIPO (
        id INT IDENTITY(1, 1) CONSTRAINT PK_TIPO_ID PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL
    );
END;


--CREAMOS LA TABLA 'CATEGORIA'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.CATEGORIA') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.CATEGORIA (
        id INT IDENTITY (1, 1) CONSTRAINT PK_CATEGORIA_ID PRIMARY KEY,
        descripcion VARCHAR(50),
		esValido BIT NOT NULL DEFAULT 1,
    );
END;


--CREAMOS LA TABLA 'CLIENTE'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.CLIENTE') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.CLIENTE (
        id INT IDENTITY(1, 1) CONSTRAINT PK_CLIENTE_ID PRIMARY KEY,
        genero VARCHAR(6) CHECK (genero IN ('male', 'female')),
        id_tipo INT,
        CONSTRAINT FK_ID_TIPO_CLIENTE_TIPO FOREIGN KEY (id_tipo) REFERENCES seguridad.TIPO(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
END;


--CREAMOS LA TABLA 'SUCURSAL'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.SUCURSAL') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.SUCURSAL (
        id INT IDENTITY(1, 1) CONSTRAINT PK_SUCURSAL_ID PRIMARY KEY,
        horario VARCHAR(50) NOT NULL,
        ciudad VARCHAR(50) NOT NULL,
		reemplazar_por VARCHAR(255) NOT NULL,
        direccion VARCHAR(50) NOT NULL,
        codigo_postal CHAR(5) NOT NULL,
        provincia VARCHAR(50) NOT NULL
    );
END;


--CREAMOS LA TABLA 'TELEFONO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.TELEFONO') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.TELEFONO (
        id_sucursal INT CONSTRAINT PK_TELEFONO_IDSUCURSAL PRIMARY KEY,
        telefono CHAR(9) CHECK (telefono LIKE ('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')) NOT NULL,
        CONSTRAINT FK_IDSUCURSAL_TELEFONO_SUCURSAL FOREIGN KEY (id_sucursal) REFERENCES seguridad.SUCURSAL(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
END;


--CREAMOS LA TABLA 'EMPLEADO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'seguridad.EMPLEADO') AND type in (N'U'))
BEGIN
    CREATE TABLE seguridad.EMPLEADO (
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
        esValido BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_ID_CARGO_EMPLEADO_CARGO FOREIGN KEY (id_cargo) REFERENCES seguridad.CARGO(id)
        ON UPDATE CASCADE,
        CONSTRAINT FK_ID_SUCURSAL_EMPLEADO_SUCURSAL FOREIGN KEY (id_sucursal) REFERENCES seguridad.SUCURSAL(id)
        ON UPDATE CASCADE
    );
END;

/*
				=============================================================
				=	 Creación de las tablas dentro del schema productos		=
				=============================================================
*/

--CREAMOS LA TABLA 'PRODUCTO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'productos.PRODUCTO') AND type in (N'U'))
BEGIN
    CREATE TABLE productos.PRODUCTO (
        id_producto INT IDENTITY(1, 1) CONSTRAINT PK_PRODUCTO_ID PRIMARY KEY,
        precio_unidad DECIMAL(10, 2),
        nombre_producto VARCHAR(100) NOT NULL,
        id_categoria INT,
        fecha_creacion DATE NOT NULL DEFAULT GETDATE(),
        fecha_eliminacion DATE,
        esValido BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_ID_CATEGORIA_PRODUCTO_CATEGORIA FOREIGN KEY (id_categoria) REFERENCES seguridad.CATEGORIA(id)
        ON UPDATE CASCADE
    );
END;


--CREAMOS LA TABLA 'IMPORTADO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'productos.IMPORTADO') AND type in (N'U'))
BEGIN
    CREATE TABLE productos.IMPORTADO (
        id_producto INT CONSTRAINT PK_IMPORTADO_ID PRIMARY KEY,
        proveedor VARCHAR(255),
        cantidad_por_unidad VARCHAR(255),
		esValido BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_ID_PRODUCTO_IMPORTADO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES productos.PRODUCTO(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
END;



--CREAMOS LA TABLA 'VARIOS'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'productos.VARIOS') AND type in (N'U'))
BEGIN
    CREATE TABLE productos.VARIOS (
        id_producto INT CONSTRAINT PK_VARIOS_ID PRIMARY KEY,
        fecha DATE,
        hora TIME(0),
        unidad_de_referencia VARCHAR(50),
        esValido BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_ID_PRODUCTO_VARIOS_PRODUCTO FOREIGN KEY (id_producto) REFERENCES productos.PRODUCTO(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
END;


--CREAMOS LA TABLA 'ELECTRONICO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'productos.ELECTRONICO') AND type in (N'U'))
BEGIN
    CREATE TABLE productos.ELECTRONICO (
        id_producto INT CONSTRAINT PK_ELECTRONICO_ID PRIMARY KEY,
        precio_unidad_en_dolares DECIMAL(10, 2),
        esValido BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_ID_PRODUCTO_ELECTRONICO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES productos.PRODUCTO(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
END;

/*
				===============================================================
				=	 Creación de las tablas dentro del schema transacciones	  =
				===============================================================
*/

--CREAMOS LA TABLA 'FACTURA'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'transacciones.FACTURA') AND type in (N'U'))
BEGIN
    CREATE TABLE transacciones.FACTURA (
        id CHAR(11) CHECK (id LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]') CONSTRAINT PK_FACTURA_ID PRIMARY KEY,
        tipo_de_factura CHAR CHECK(tipo_de_factura IN('A', 'B', 'C')) NOT NULL,
		estado BIT NOT NULL DEFAULT 1 -- 1 para 'pagada' y 0 para 'no pagada'
	);
END;

--CREAMOS LA TABLA 'NOTA_CREDITO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'transacciones.NOTA_CREDITO') AND type in (N'U'))
BEGIN
    CREATE TABLE transacciones.NOTA_CREDITO (
        id INT IDENTITY(1, 1) CONSTRAINT PK_NOTA_CREDITO_ID PRIMARY KEY,        
        monto DECIMAL (10, 2),
        id_factura CHAR(11) CHECK (id_factura LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
        CONSTRAINT FK_ID_FACTURA FOREIGN KEY (id_factura) REFERENCES transacciones.FACTURA(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
END;


--CREAMOS LA TABLA 'MEDIO DE PAGO'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'transacciones.MEDIO_DE_PAGO') AND type in (N'U'))
BEGIN
    CREATE TABLE transacciones.MEDIO_DE_PAGO (
        id INT IDENTITY(1, 1) CONSTRAINT PK_MEDIO_DE_PAGO_ID PRIMARY KEY,
        descripcion_ingles VARCHAR(50) NOT NULL,
		descripcion VARCHAR(50) NOT NULL
    );
END;

--CREAMOS LA TABLA 'VENTA'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'transacciones.VENTA') AND type in (N'U'))
BEGIN
    CREATE TABLE transacciones.VENTA (
        id INT IDENTITY(1, 1) CONSTRAINT PK_VENTA_ID PRIMARY KEY,
        id_factura CHAR(11) CHECK (id_factura LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
        id_sucursal INT,
        id_producto INT,
        cantidad SMALLINT  NOT NULL, --maximo 32767 y minimo -32768
        fecha DATE NOT NULL,
        hora TIME(0) NOT NULL,
        id_medio_de_pago INT,
        legajo INT,
        identificador_de_pago VARCHAR(22)
        CHECK
        (
            (LEN(identificador_de_pago) = 22 AND identificador_de_pago NOT LIKE '%[^0-9]%') OR identificador_de_pago IS NULL
        ),
        CONSTRAINT FK_ID_FACTURA_VENTA_FACTURA FOREIGN KEY (id_factura) REFERENCES transacciones.FACTURA(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        CONSTRAINT FK_ID_SUCURSAL_VENTA_SUCURSAL FOREIGN KEY (id_sucursal) REFERENCES seguridad.SUCURSAL(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        CONSTRAINT FK_ID_PRODUCTO_VENTA_PRODUCTO FOREIGN KEY (id_producto) REFERENCES productos.PRODUCTO(id_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        CONSTRAINT FK_ID_MEDIO_DE_PAGO_VENTA_MEDIO_DE_PAGO FOREIGN KEY (id_medio_de_pago) REFERENCES transacciones.MEDIO_DE_PAGO(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        CONSTRAINT FK_LEGAJO_VENTA_EMPLEADO FOREIGN KEY (legajo) REFERENCES seguridad.EMPLEADO(legajo)
        --ON DELETE CASCADE
        --ON UPDATE CASCADE
    );
END;

