--Setup
USE GD1C2025
GO
-- Limpieza de tablas y esquemas
DROP TABLE IF EXISTS DROP_DATABASE.Detalle_Factura
DROP TABLE IF EXISTS DROP_DATABASE.Envio
DROP TABLE IF EXISTS DROP_DATABASE.Factura
DROP TABLE IF EXISTS DROP_DATABASE.Detalle_Compra
DROP TABLE IF EXISTS DROP_DATABASE.Cancelacion
DROP TABLE IF EXISTS DROP_DATABASE.Detalle_Pedido
DROP TABLE IF EXISTS DROP_DATABASE.Pedido
DROP TABLE IF EXISTS DROP_DATABASE.Compra
DROP TABLE IF EXISTS DROP_DATABASE.Sillon
DROP TABLE IF EXISTS DROP_DATABASE.Modelo
DROP TABLE IF EXISTS DROP_DATABASE.Madera
DROP TABLE IF EXISTS DROP_DATABASE.Relleno
DROP TABLE IF EXISTS DROP_DATABASE.Tela
DROP TABLE IF EXISTS DROP_DATABASE.Material
DROP TABLE IF EXISTS DROP_DATABASE.Medida
DROP TABLE IF EXISTS DROP_DATABASE.Sucursal
DROP TABLE IF EXISTS DROP_DATABASE.Proveedor
DROP TABLE IF EXISTS DROP_DATABASE.Cliente
DROP TABLE IF EXISTS DROP_DATABASE.Domicilio
DROP TABLE IF EXISTS DROP_DATABASE.Localidad
DROP TABLE IF EXISTS DROP_DATABASE.Provincia
DROP SCHEMA IF EXISTS DROP_DATABASE
GO
-- Creación del esquema
CREATE SCHEMA DROP_DATABASE
GO
--Creación de tablas
CREATE TABLE DROP_DATABASE.Provincia (
	Provincia_ID BIGINT IDENTITY(1,1),
	Provincia_Nombre NVARCHAR(255),
	CONSTRAINT PK_Provincia PRIMARY KEY (Provincia_ID),
	CONSTRAINT UQ_Provincia_Nombre UNIQUE(Provincia_Nombre)
)

CREATE TABLE DROP_DATABASE.Localidad (
	Localidad_ID BIGINT IDENTITY(1,1),
	Localidad_Nombre NVARCHAR(255),
	Localidad_Provincia BIGINT,
	CONSTRAINT PK_Localidad PRIMARY KEY (Localidad_ID),
	CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (Localidad_Provincia) REFERENCES DROP_DATABASE.Provincia,
	CONSTRAINT UQ_Localidad_Nombre_Provincia UNIQUE(Localidad_Nombre, Localidad_Provincia)
)

CREATE TABLE DROP_DATABASE.Domicilio (
	Domicilio_ID BIGINT IDENTITY(1,1),
	Domicilio_Direccion NVARCHAR(255),
	Domicilio_Localidad BIGINT,
	CONSTRAINT PK_Domicilio PRIMARY KEY (Domicilio_ID),
	CONSTRAINT FK_Domicilio_Provincia FOREIGN KEY (Domicilio_Localidad) REFERENCES DROP_DATABASE.Localidad,
	CONSTRAINT UQ_Domicilio_Direccion_Localidad UNIQUE(Domicilio_Direccion, Domicilio_Localidad)
)

CREATE TABLE DROP_DATABASE.Material (
	Material_ID BIGINT IDENTITY(1,1),
	Material_Tipo NVARCHAR(255),
	Material_Nombre NVARCHAR(255),
	Material_Descripcion NVARCHAR(255),
	Material_Precio DECIMAL(38,2),
	CONSTRAINT PK_Material PRIMARY KEY (Material_ID),
	CONSTRAINT CK_Material_Tipo CHECK (Material_Tipo IN ('MADERA', 'TELA', 'RELLENO')),
	CONSTRAINT UQ_Material_Tipo_Nombre_Descripcion  UNIQUE(Material_Tipo, Material_Nombre, Material_Descripcion)
)

CREATE TABLE DROP_DATABASE.Madera (
	Madera_ID BIGINT FOREIGN KEY REFERENCES DROP_DATABASE.Material,
	Madera_Color NVARCHAR(255),
	Madera_Dureza NVARCHAR(255),
	CONSTRAINT PK_Madera PRIMARY KEY (Madera_ID),
	CONSTRAINT FK_Madera_Material FOREIGN KEY (Madera_ID) REFERENCES DROP_DATABASE.Material
)

CREATE TABLE DROP_DATABASE.Tela (
	Tela_ID BIGINT,
	Tela_Color NVARCHAR(255),
	Tela_Textura NVARCHAR(255),
	CONSTRAINT PK_Tela PRIMARY KEY (Tela_ID),
	CONSTRAINT FK_Tela_Material FOREIGN KEY (Tela_ID) REFERENCES DROP_DATABASE.Material
)

CREATE TABLE DROP_DATABASE.Relleno (
	Relleno_ID BIGINT,
	Relleno_Densidad DECIMAL(38,2),
	CONSTRAINT PK_Relleno PRIMARY KEY (Relleno_ID),
	CONSTRAINT FK_Relleno_Material FOREIGN KEY (Relleno_ID) REFERENCES DROP_DATABASE.Material
)

CREATE TABLE DROP_DATABASE.Medida (
	Medida_ID BIGINT IDENTITY(1,1),
	Medida_Alto DECIMAL(18,2),
	Medida_Ancho DECIMAL(18,2),
	Medida_Profundidad DECIMAL(18,2),
	Medida_Precio DECIMAL(18,2),
	CONSTRAINT PK_Medida PRIMARY KEY (Medida_ID),
	CONSTRAINT UQ_Medida_Alto_Ancho_Profundidad UNIQUE(Medida_Alto, Medida_Ancho, Medida_Profundidad)
)

CREATE TABLE DROP_DATABASE.Modelo (
	Modelo_Codigo BIGINT,
	Modelo_Nombre NVARCHAR(255),
	Modelo_Descripcion NVARCHAR(255),
	Modelo_Precio DECIMAL(18,2),
	CONSTRAINT PK_Modelo PRIMARY KEY (Modelo_Codigo)
)

CREATE TABLE DROP_DATABASE.Sillon (
	Sillon_Codigo BIGINT,
	Sillon_Modelo BIGINT,
	Sillon_Medida BIGINT,
	Sillon_Madera BIGINT,
	Sillon_Tela BIGINT,
	Sillon_Relleno BIGINT,
	CONSTRAINT PK_Sillon PRIMARY KEY (Sillon_Codigo),
	CONSTRAINT FK_Sillon_Modelo FOREIGN KEY (Sillon_Modelo) REFERENCES DROP_DATABASE.Modelo,
	CONSTRAINT FK_Sillon_Medida FOREIGN KEY (Sillon_Medida) REFERENCES DROP_DATABASE.Medida,
	CONSTRAINT FK_Sillon_Madera FOREIGN KEY (Sillon_Madera) REFERENCES DROP_DATABASE.Material,
	CONSTRAINT FK_Sillon_Tela FOREIGN KEY (Sillon_Tela) REFERENCES DROP_DATABASE.Material,
	CONSTRAINT FK_Sillon_Relleno FOREIGN KEY (Sillon_Relleno) REFERENCES DROP_DATABASE.Material
)

CREATE TABLE DROP_DATABASE.Cliente (
	Cliente_ID BIGINT IDENTITY(1,1),
	Cliente_DNI BIGINT,
	Cliente_Domicilio BIGINT,
	Cliente_Nombre NVARCHAR(255),
	Cliente_Apellido NVARCHAR(255),
	Cliente_Telefono NVARCHAR(255),
	Cliente_Fecha_Nacimiento DATETIME2(6),
	Cliente_Mail NVARCHAR(255),
	CONSTRAINT PK_Cliente PRIMARY KEY (Cliente_ID),
	CONSTRAINT FK_Cliente_Domicilio FOREIGN KEY (Cliente_Domicilio) REFERENCES DROP_DATABASE.Domicilio,
	CONSTRAINT UQ_Cliente_DNI_Apellido_Nombre UNIQUE(Cliente_DNI, Cliente_Apellido, Cliente_Nombre)
)

CREATE TABLE DROP_DATABASE.Proveedor (
	Proveedor_ID BIGINT IDENTITY(1,1),
	Proveedor_CUIT NVARCHAR(255),
	Proveedor_Razon_Social NVARCHAR(255),
	Proveedor_Domicilio BIGINT,
	Proveedor_Telefono NVARCHAR(255),
	Proveedor_Mail NVARCHAR(255),
	CONSTRAINT PK_Proveedor PRIMARY KEY (Proveedor_ID),
	CONSTRAINT FK_Proveedor_Domicilio FOREIGN KEY (Proveedor_Domicilio) REFERENCES DROP_DATABASE.Domicilio,
	CONSTRAINT UQ_Proveedor_CUIT UNIQUE(Proveedor_CUIT)
)

CREATE TABLE DROP_DATABASE.Sucursal (
	Sucursal_Numero BIGINT,
	Sucursal_Domicilio BIGINT,
	Sucursal_Telefono NVARCHAR(255),
	Sucursal_Mail NVARCHAR(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (Sucursal_Numero),
	CONSTRAINT FK_Sucursal_Domicilio FOREIGN KEY (Sucursal_Domicilio) REFERENCES DROP_DATABASE.Domicilio
)

CREATE TABLE DROP_DATABASE.Pedido (
	Pedido_Numero DECIMAL(18,0),
	Pedido_Sucursal BIGINT,
	Pedido_Cliente BIGINT,
	Pedido_Fecha DATETIME2(6) DEFAULT GETDATE(),
	Pedido_Estado NVARCHAR(255) DEFAULT 'PENDIENTE',
	Pedido_Total DECIMAL(18,2),	
	CONSTRAINT PK_Pedido PRIMARY KEY (Pedido_Numero),
	CONSTRAINT FK_Pedido_Sucursal FOREIGN KEY (Pedido_Sucursal) REFERENCES DROP_DATABASE.Sucursal,
	CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (Pedido_Cliente) REFERENCES DROP_DATABASE.Cliente,
	CONSTRAINT CK_Pedido_Estado CHECK (Pedido_Estado IN ('PENDIENTE', 'CANCELADO', 'ENTREGADO'))
)

CREATE TABLE DROP_DATABASE.Cancelacion (
	Cancelacion_Pedido DECIMAL(18,0),
	Cancelacion_Fecha DATETIME2(6),
	Cancelacion_Motivo VARCHAR(255),
	CONSTRAINT PK_Cancelacion PRIMARY KEY (Cancelacion_Pedido),
	CONSTRAINT FK_Cancelacion_Pedido FOREIGN KEY (Cancelacion_Pedido) REFERENCES DROP_DATABASE.Pedido
)

CREATE TABLE DROP_DATABASE.Detalle_Pedido (
	Detalle_Pedido_Sillon BIGINT,
	Detalle_Pedido_Pedido DECIMAL(18,0),
	Detalle_Pedido_Cantidad BIGINT,
	Detalle_Pedido_Precio DECIMAL(18,2),
	Detalle_Pedido_Subtotal DECIMAL(18,2),
	CONSTRAINT PK_Detalle_Pedido PRIMARY KEY (Detalle_Pedido_Sillon),
	CONSTRAINT FK_Detalle_Pedido_Sillon FOREIGN KEY (Detalle_Pedido_Sillon) REFERENCES DROP_DATABASE.Sillon,
	CONSTRAINT FK_Detalle_Pedido_Pedido FOREIGN KEY (Detalle_Pedido_Pedido) REFERENCES DROP_DATABASE.Pedido
)

CREATE TABLE DROP_DATABASE.Compra (
	Compra_Numero DECIMAL(18,0),
	Compra_Sucursal BIGINT,
	Compra_Proveedor BIGINT,
	Compra_Fecha DATETIME2(6),
	Compra_Total DECIMAL(18,2),
	CONSTRAINT PK_Compra PRIMARY KEY (Compra_Numero),
	CONSTRAINT FK_Compra_Sucursal FOREIGN KEY (Compra_Sucursal) REFERENCES DROP_DATABASE.Sucursal,
	CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (Compra_Proveedor) REFERENCES DROP_DATABASE.Proveedor
)

CREATE TABLE DROP_DATABASE.Detalle_Compra (
	Detalle_Compra_Compra DECIMAL(18,0),
	Detalle_Compra_Material BIGINT,
	Detalle_Compra_Cantidad DECIMAL(18,0),
	Detalle_Compra_Precio DECIMAL(18,2),
	Detalle_Compra_Subtotal DECIMAL(18,2),
	CONSTRAINT PK_Compra_Detalle PRIMARY KEY (Detalle_Compra_Compra, Detalle_Compra_Material),
	CONSTRAINT FK_Compra_Detalle_Compra FOREIGN KEY (Detalle_Compra_Compra) REFERENCES DROP_DATABASE.Compra,
	CONSTRAINT FK_Compra_Detalle_Material FOREIGN KEY (Detalle_Compra_Material) REFERENCES DROP_DATABASE.Material
)

CREATE TABLE DROP_DATABASE.Factura (
	Factura_Numero BIGINT,
	Factura_Cliente BIGINT,
	Factura_Sucursal BIGINT,
	Factura_Pedido DECIMAL(18,0),
	Factura_Fecha DATETIME2(6),
	Factura_Total DECIMAL(38,2),
	CONSTRAINT PK_Factura PRIMARY KEY (Factura_Numero),
	CONSTRAINT FK_Factura_Cliente FOREIGN KEY (Factura_Cliente) REFERENCES DROP_DATABASE.Cliente,
	CONSTRAINT FK_Factura_Sucursal FOREIGN KEY (Factura_Sucursal) REFERENCES DROP_DATABASE.Sucursal,
	CONSTRAINT FK_Factura_Pedido FOREIGN KEY (Factura_Pedido) REFERENCES DROP_DATABASE.Pedido
)

CREATE TABLE DROP_DATABASE.Envio (
	Envio_Numero DECIMAL(18,0),
	Envio_Factura BIGINT,
	Envio_Fecha_Programada DATETIME2(6),
	Envio_Fecha_Entrega DATETIME2(6),
	Envio_Importe_Translado DECIMAL(18,2),
	Envio_Importe_Subida DECIMAL(18,2),
	Envio_Importe_Total DECIMAL(18,2),
	CONSTRAINT PK_Envio PRIMARY KEY (Envio_Numero),
	CONSTRAINT FK_Envio_Factura FOREIGN KEY (Envio_Factura) REFERENCES DROP_DATABASE.Factura
)

CREATE TABLE DROP_DATABASE.Detalle_Factura (
	Detalle_Factura_Detalle_Pedido BIGINT,
	Detalle_Factura_Factura BIGINT,
	Detalle_Factura_Cantidad DECIMAL(18,0),
	Detalle_Factura_Precio DECIMAL(18,2),
	Detalle_Factura_Subtotal DECIMAL(18,2),
	CONSTRAINT PK_Detalle_Factura PRIMARY KEY (Detalle_Factura_Detalle_Pedido, Detalle_Factura_Factura),
	CONSTRAINT FK_Detalle_Factura_Detalle_Pedido FOREIGN KEY (Detalle_Factura_Detalle_Pedido) REFERENCES DROP_DATABASE.Detalle_Pedido,
	CONSTRAINT FK_Detalle_Factura_Factura FOREIGN KEY (Detalle_Factura_Factura) REFERENCES DROP_DATABASE.Factura
)

GO
--Triggers
CREATE TRIGGER CK_Madera ON DROP_DATABASE.Madera AFTER INSERT
AS
IF EXISTS (
    SELECT 1
    FROM inserted i
    JOIN DROP_DATABASE.Material m ON m.Material_ID = i.Madera_ID
    WHERE m.Material_Tipo <> 'MADERA'
)
	THROW 50000, 'Solo se pueden insertar materiales de tipo MADERA en esta tabla.', 1
GO

CREATE TRIGGER CK_Tela ON DROP_DATABASE.Tela AFTER INSERT
AS
IF EXISTS (
    SELECT 1
	FROM inserted i
    JOIN DROP_DATABASE.Material m ON m.Material_ID = i.Tela_ID
    WHERE m.Material_Tipo <> 'TELA'
)
	THROW 50001, 'Solo se pueden insertar materiales de tipo TELA en esta tabla.', 1
GO

CREATE TRIGGER CK_Relleno ON DROP_DATABASE.Relleno AFTER INSERT
AS
IF EXISTS (
   	SELECT 1
    FROM inserted i
    JOIN DROP_DATABASE.Material m ON m.Material_ID = i.Relleno_ID
    WHERE m.Material_Tipo <> 'RELLENO'
)
    THROW 50002, 'Solo se pueden insertar materiales de tipo RELLENO en esta tabla.', 1

GO

CREATE TRIGGER CK_Cancelacion ON DROP_DATABASE.Cancelacion AFTER INSERT
AS
IF EXISTS (
	SELECT 1
	FROM inserted i
	JOIN DROP_DATABASE.Pedido p ON p.Pedido_Numero = i.Cancelacion_Pedido
	WHERE p.Pedido_Estado <> 'CANCELADO'
)
	THROW 50003, 'No se puede cancelar un pedido que no está en estado CANCELADO.', 1
GO

CREATE TRIGGER CK_Sillon ON DROP_DATABASE.Sillon AFTER INSERT
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM inserted 
		LEFT JOIN DROP_DATABASE.Madera ON Madera_ID = Sillon_Madera
		WHERE Sillon_Madera IS NOT NULL AND Madera_ID IS NULL
	)
		THROW 50004, 'El tipo de Sillon_Madera debe ser MADERA.', 1;
	IF EXISTS (
		SELECT 1
		FROM inserted 
		LEFT JOIN DROP_DATABASE.Tela ON Tela_ID = Sillon_Tela
		WHERE Sillon_Tela IS NOT NULL AND Tela_ID IS NULL
	)
		THROW 50005, 'El tipo de Sillon_Tela debe ser TELA.', 1;
	IF EXISTS (
		SELECT 1
		FROM inserted 
		LEFT JOIN DROP_DATABASE.Relleno ON Relleno_ID = Sillon_Relleno
		WHERE Sillon_Relleno IS NOT NULL AND Relleno_ID IS NULL
	)
		THROW 50006, 'El tipo de Sillon_Relleno debe ser RELLENO.', 1;
END
GO

--Insert Nivel 1 (Tablas sin dependencias)
-- Tabla provincia
INSERT INTO DROP_DATABASE.Provincia (
	Provincia_Nombre	
)
SELECT DISTINCT 
	Cliente_Provincia
FROM gd_esquema.Maestra
WHERE Cliente_Provincia IS NOT NULL

UNION

SELECT DISTINCT 
	Sucursal_Provincia
FROM gd_esquema.Maestra
WHERE Sucursal_Provincia IS NOT NULL

UNION

SELECT DISTINCT 
	Proveedor_Provincia
FROM gd_esquema.Maestra
WHERE Proveedor_Provincia IS NOT NULL


INSERT INTO DROP_DATABASE.Material (
	Material_Tipo,
	Material_Nombre,
	Material_Descripcion,
	Material_Precio
)
SELECT DISTINCT 
	Material_Tipo,
	Material_Nombre,
	Material_Descripcion,
	Material_Precio
FROM gd_esquema.Maestra
WHERE Material_Nombre IS NOT NULL 
	AND Material_Descripcion IS NOT NULL


INSERT INTO DROP_DATABASE.Medida (
	Medida_Alto,
	Medida_Ancho,
	Medida_Profundidad,
	Medida_Precio
)
SELECT DISTINCT
	Sillon_Medida_Alto,
	Sillon_Medida_Ancho,
	Sillon_Medida_Profundidad,
	Sillon_Medida_Precio 
FROM gd_esquema.Maestra 
WHERE Sillon_Medida_Alto IS NOT NULL 
	AND Sillon_Medida_Ancho IS NOT NULL 
	AND Sillon_Medida_Profundidad IS NOT NULL


INSERT INTO DROP_DATABASE.Modelo (
	Modelo_Codigo,
	Modelo_Nombre,
	Modelo_Descripcion,
	Modelo_Precio
)
SELECT DISTINCT
	Sillon_Modelo_Codigo,
	Sillon_Modelo,
	Sillon_Modelo_Descripcion,
	Sillon_Modelo_Precio
FROM gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo IS NOT NULL


--Nivel 2
INSERT INTO DROP_DATABASE.Localidad (
	Localidad_Nombre,
	Localidad_Provincia
)
SELECT DISTINCT 
	Cliente_Localidad, 
	Provincia_ID
FROM gd_esquema.Maestra 
JOIN  DROP_DATABASE.Provincia ON Provincia_Nombre = Cliente_Provincia

UNION

SELECT DISTINCT 
	Proveedor_Localidad, 
	Provincia_ID
FROM gd_esquema.Maestra 
JOIN DROP_DATABASE.Provincia ON Provincia_Nombre = Proveedor_Provincia

UNION

SELECT DISTINCT 
	Sucursal_Localidad, 
	Provincia_ID
FROM gd_esquema.Maestra 
JOIN DROP_DATABASE.Provincia ON Provincia_Nombre = Sucursal_Provincia


INSERT INTO DROP_DATABASE.Tela (
	Tela_ID,
	Tela_Color,
	Tela_Textura
)
SELECT DISTINCT 
	Material_ID, 
	Tela_Color, 
	Tela_Textura
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Material mat ON mat.Material_Nombre = mas.Material_Nombre
	AND mat.Material_Descripcion = mas.Material_Descripcion
WHERE mat.Material_Tipo = 'TELA'


INSERT INTO DROP_DATABASE.Madera (
	Madera_ID,
	Madera_Color,
	Madera_Dureza
)
SELECT DISTINCT 
	Material_ID, 
	Madera_Color, 
	Madera_Dureza
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Material mat ON mat.Material_Nombre = mas.Material_Nombre
	AND mat.Material_Descripcion = mas.Material_Descripcion
WHERE mat.Material_Tipo = 'MADERA'


INSERT INTO DROP_DATABASE.Relleno (
	Relleno_ID,
	Relleno_Densidad
)
SELECT DISTINCT 
	Material_ID, 
	Relleno_Densidad
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Material mat ON mat.Material_Nombre = mas.Material_Nombre
	AND mat.Material_Descripcion = mas.Material_Descripcion
WHERE mat.Material_Tipo = 'RELLENO'

--Nivel 3
INSERT INTO DROP_DATABASE.Domicilio (
	Domicilio_Direccion,
	Domicilio_Localidad
)
SELECT DISTINCT 
	Sucursal_Direccion, 
	Localidad_ID  
FROM gd_esquema.Maestra
JOIN DROP_DATABASE.Localidad ON Localidad_Nombre = Sucursal_Localidad
JOIN DROP_DATABASE.Provincia ON Provincia_ID = Localidad_Provincia
WHERE Provincia_Nombre = Sucursal_Provincia 

UNION

SELECT DISTINCT 
	Cliente_Direccion, 
	Localidad_ID
FROM gd_esquema.Maestra
JOIN DROP_DATABASE.Localidad ON Localidad_Nombre = Cliente_Localidad
JOIN DROP_DATABASE.Provincia ON Provincia_ID = Localidad_Provincia
WHERE Provincia_Nombre = Cliente_Provincia

UNION

SELECT DISTINCT 
	Proveedor_Direccion, 
	Localidad_ID
FROM gd_esquema.Maestra
JOIN DROP_DATABASE.Localidad ON Localidad_Nombre = Proveedor_Localidad
JOIN DROP_DATABASE.Provincia ON Provincia_ID = Localidad_Provincia
WHERE Provincia_Nombre = Proveedor_Provincia

-- No se pueden insertar los 3 materiales a la vez
INSERT INTO DROP_DATABASE.Sillon (
	Sillon_Codigo, 
	Sillon_Medida, 
	Sillon_Modelo,
	Sillon_Tela, 
	Sillon_Madera,
	Sillon_Relleno
)
SELECT DISTINCT 
    mas.Sillon_codigo, 
    Medida_ID, 
    mas.Sillon_Modelo_Codigo, 
    mat.Material_ID,
	mat2.Material_ID,
	mat3.Material_ID
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Medida ON Sillon_Medida_Alto = Medida_Alto
	AND Sillon_Medida_Ancho = Medida_Ancho
	AND Sillon_Medida_Profundidad = Medida_Profundidad
JOIN gd_esquema.Maestra mas2 ON mas2.Sillon_Codigo = mas.Sillon_Codigo
	and mas2.Material_Tipo = 'MADERA'
JOIN gd_esquema.Maestra mas3 ON mas3.Sillon_Codigo = mas.Sillon_Codigo
	AND mas3.Material_Tipo = 'RELLENO'
JOIN DROP_DATABASE.Material mat ON mat.Material_Nombre = mas.Material_Nombre
	AND mat.Material_Descripcion = mas.Material_Descripcion
JOIN DROP_DATABASE.Material mat2 ON mat2.Material_Nombre = mas2.Material_Nombre
	AND mat2.Material_Descripcion = mas2.Material_Descripcion
JOIN DROP_DATABASE.Material mat3 ON mat3.Material_Nombre = mas3.Material_Nombre
	AND mat3.Material_Descripcion = mas3.Material_Descripcion
WHERE mas.Material_Tipo = 'TELA'

-- Nivel 4
INSERT INTO DROP_DATABASE.Cliente (
	Cliente_Dni, 
	Cliente_Domicilio,
	Cliente_Nombre,
	Cliente_Apellido,
	Cliente_Telefono,
	Cliente_Fecha_Nacimiento,
	Cliente_Mail
)
SELECT DISTINCT 
	Cliente_Dni, 
	Domicilio_ID,
	Cliente_Nombre,
	Cliente_Apellido,
	Cliente_Telefono,
	Cliente_FechaNacimiento,
	Cliente_Mail
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Domicilio ON Domicilio_Direccion  = Cliente_Direccion
JOIN DROP_DATABASE.Localidad ON Localidad_ID = Domicilio_Localidad
JOIN DROP_DATABASE.Provincia ON Provincia_ID  = Localidad_Provincia
WHERE Cliente_Localidad = Localidad_Nombre
	AND Cliente_Provincia = Provincia_Nombre


INSERT INTO DROP_DATABASE.Sucursal (
	Sucursal_Numero,
	Sucursal_Domicilio,
	Sucursal_telefono,
	Sucursal_mail
)
SELECT DISTINCT
	Sucursal_NroSucursal,
	Domicilio_ID,
	Sucursal_telefono,
	Sucursal_mail
FROM gd_esquema.Maestra
JOIN DROP_DATABASE.Domicilio ON Domicilio_Direccion = Sucursal_Direccion
JOIN DROP_DATABASE.Localidad ON Localidad_ID = Domicilio_Localidad 
JOIN DROP_DATABASE.Provincia ON Provincia_ID  = Localidad_Provincia 
WHERE Sucursal_Localidad  = Localidad_Nombre 
	AND Sucursal_Provincia  = Provincia_Nombre 

INSERT INTO DROP_DATABASE.Proveedor (
	Proveedor_Cuit,
	Proveedor_Razon_Social,
	Proveedor_Domicilio,
	Proveedor_Telefono,
	Proveedor_Mail
)
SELECT DISTINCT
	Proveedor_Cuit,
	Proveedor_RazonSocial,
	Domicilio_ID,
	Proveedor_Telefono,
	Proveedor_Mail 
FROM gd_esquema.Maestra
JOIN DROP_DATABASE.Domicilio ON Domicilio_Direccion  = Proveedor_Direccion  
JOIN DROP_DATABASE.Localidad ON  Localidad_ID = Domicilio_Localidad 
JOIN DROP_DATABASE.Provincia ON Provincia_ID  = Localidad_Provincia 
WHERE Proveedor_Localidad  = Localidad_Nombre 
	AND Proveedor_Provincia  = Provincia_Nombre 

-- Nivel 5
INSERT INTO DROP_DATABASE.Pedido (
	Pedido_Numero,
	Pedido_Sucursal,
	Pedido_Cliente,
	Pedido_Fecha,
	Pedido_Estado,
	Pedido_Total
)
SELECT DISTINCT
	Pedido_Numero,
	Sucursal_Numero,
	Cliente_ID,
	Pedido_Fecha,
	Pedido_Estado,
	Pedido_Total 
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Sucursal s ON s.Sucursal_Numero = mas.Sucursal_NroSucursal
JOIN DROP_DATABASE.Cliente c ON c.Cliente_DNI = mas.Cliente_Dni
	AND c.Cliente_Apellido = mas.Cliente_Apellido
	AND c.Cliente_Nombre = mas.Cliente_Nombre
WHERE Pedido_Numero IS NOT NULL AND Factura_Numero IS NULL


INSERT INTO DROP_DATABASE.Compra (
	Compra_Numero,
	Compra_Sucursal,
	Compra_Proveedor,
	Compra_Fecha,
	Compra_Total
)
SELECT DISTINCT
	Compra_Numero,
	s.Sucursal_Numero,
	p.Proveedor_ID,
	Compra_Fecha,
	Compra_Total 
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Sucursal s ON s.Sucursal_Numero = mas.Sucursal_NroSucursal
JOIN DROP_DATABASE.Proveedor p ON p.Proveedor_CUIT = mas.Proveedor_Cuit
WHERE Compra_Numero IS NOT NULL

-- Nivel 6
INSERT INTO DROP_DATABASE.Cancelacion (
	Cancelacion_Pedido,
	Cancelacion_Fecha,
	Cancelacion_Motivo
)
SELECT DISTINCT
	Pedido_Numero,
	Pedido_Cancelacion_Fecha,
	Pedido_Cancelacion_Motivo
FROM gd_esquema.Maestra mas
WHERE Pedido_Cancelacion_Motivo IS NOT NULL


INSERT INTO DROP_DATABASE.Factura (
	Factura_Numero,
	Factura_Cliente,
	Factura_Sucursal,
	Factura_Pedido,
	Factura_Fecha,
	Factura_Total
)
SELECT DISTINCT
	Factura_Numero,
	Cliente_ID,
	Sucursal_NroSucursal,
	Pedido_Numero,
	Factura_Fecha,
	Factura_Total
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Cliente c on c.Cliente_DNI = mas.Cliente_Dni
	AND c.Cliente_Apellido = mas.Cliente_Apellido
	AND c.Cliente_Nombre = mas.Cliente_Nombre
WHERE Factura_Numero IS NOT NULL AND Pedido_Numero IS NOT NULL


INSERT INTO DROP_DATABASE.Detalle_Compra (
	Detalle_Compra_Compra,
	Detalle_Compra_Material,
	Detalle_Compra_Cantidad,
	Detalle_Compra_Precio,
	Detalle_Compra_Subtotal
)
SELECT DISTINCT
	Compra_Numero,
	Material_ID,
	Detalle_Compra_Cantidad,
	Detalle_Compra_Precio,
	Detalle_Compra_SubTotal
FROM gd_esquema.Maestra mas
JOIN DROP_DATABASE.Material mat ON mat.Material_Nombre = mas.Material_Nombre
	AND mat.Material_Descripcion = mas.Material_Descripcion
	AND mat.Material_Tipo = mas.Material_Tipo
WHERE Compra_Numero IS NOT NULL


INSERT INTO DROP_DATABASE.Detalle_Pedido (
	Detalle_Pedido_Sillon,
	Detalle_Pedido_Pedido,
	Detalle_Pedido_Cantidad,
	Detalle_Pedido_Precio,
	Detalle_Pedido_Subtotal
)
SELECT DISTINCT
	Sillon_Codigo,
	Pedido_Numero,
	Detalle_Pedido_Cantidad,
	Detalle_Pedido_Precio,
	Detalle_Pedido_SubTotal
FROM gd_esquema.Maestra mas
WHERE Detalle_Pedido_Cantidad IS NOT NULL
	AND Sillon_Codigo IS NOT NULL

-- Nivel 7
INSERT INTO DROP_DATABASE.Envio (
	Envio_Numero,
	Envio_Factura,
	Envio_Fecha_Programada,
	Envio_Fecha_Entrega,
	Envio_Importe_Translado,
	Envio_Importe_Subida,
	Envio_Importe_Total
)
SELECT DISTINCT
	Envio_Numero,
	Factura_Numero,
	Envio_Fecha_Programada,
	Envio_Fecha,
	Envio_ImporteTraslado,
	Envio_importeSubida,
	Envio_Total
FROM gd_esquema.Maestra
WHERE Envio_Numero IS NOT NULL


INSERT INTO DROP_DATABASE.Detalle_Factura(
	Detalle_Factura_Detalle_Pedido,
	Detalle_Factura_Factura,
	Detalle_Factura_Cantidad,
	Detalle_Factura_Precio,
	Detalle_Factura_Subtotal
)
SELECT DISTINCT
	Detalle_Pedido_Sillon,
	Factura_Numero,
	Detalle_Pedido_Cantidad,
	Detalle_Pedido_Precio,
	Detalle_Pedido_SubTotal
FROM DROP_DATABASE.Detalle_Pedido
JOIN  DROP_DATABASE.Factura ON Detalle_Pedido_Pedido = Factura_Pedido
WHERE Factura_Numero IS NOT NULL
