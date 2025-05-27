--Setup
USE GD1C2025
GO
CREATE SCHEMA DD
GO

--Creaci�n de tablas

CREATE TABLE DD.Provincia (
	Provincia_ID BIGINT IDENTITY(1,1),
	Provincia_Nombre NVARCHAR(255),
	CONSTRAINT PK_Provincia PRIMARY KEY (Provincia_ID)
)

CREATE TABLE DD.Localidad (
	Localidad_ID BIGINT IDENTITY(1,1),
	Localidad_Nombre NVARCHAR(255),
	Localidad_Provincia BIGINT,
	CONSTRAINT PK_Localidad PRIMARY KEY (Localidad_ID),
	CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (Localidad_Provincia) REFERENCES DD.Provincia
)

CREATE TABLE DD.Domicilio (
	Domicilio_ID BIGINT IDENTITY(1,1),
	Domicilio_Direccion NVARCHAR(255),
	Domicilio_Localidad BIGINT FOREIGN KEY REFERENCES DD.Localidad,
	CONSTRAINT PK_Domicilio PRIMARY KEY (Domicilio_ID),
	CONSTRAINT FK_Domicilio_Provincia FOREIGN KEY (Domicilio_Localidad) REFERENCES DD.Localidad
)

CREATE TABLE DD.Material (
	Material_ID BIGINT IDENTITY(1,1),
	Material_Tipo NVARCHAR(255),
	Material_Nombre NVARCHAR(255),
	Material_Descripcion NVARCHAR(255),
	Material_Precio DECIMAL(38,2),
	CONSTRAINT PK_Material PRIMARY KEY (Material_ID),
	CONSTRAINT CK_Material_Tipo CHECK (Material_Tipo IN ('MADERA', 'TELA', 'RELLENO'))
)

CREATE TABLE DD.Madera (
	Madera_ID BIGINT FOREIGN KEY REFERENCES DD.Material,
	Madera_Color NVARCHAR(255),
	Madera_Dureza NVARCHAR(255),
	CONSTRAINT PK_Madera PRIMARY KEY (Madera_ID),
	CONSTRAINT FK_Madera_Material FOREIGN KEY (Madera_ID) REFERENCES DD.Material
)

CREATE TABLE DD.Tela (
	Tela_ID BIGINT,
	Tela_Color NVARCHAR(255),
	Tela_Textura NVARCHAR(255),
	CONSTRAINT PK_Tela PRIMARY KEY (Tela_ID),
	CONSTRAINT FK_Tela_Material FOREIGN KEY (Tela_ID) REFERENCES DD.Material
)

CREATE TABLE DD.Relleno (
	Relleno_ID BIGINT,
	Relleno_Densidad DECIMAL(38,2),
	CONSTRAINT PK_Relleno PRIMARY KEY (Relleno_ID),
	CONSTRAINT FK_Relleno_Material FOREIGN KEY (Relleno_ID) REFERENCES DD.Material
)

CREATE TABLE DD.Medida (
	Medida_ID BIGINT IDENTITY(1,1),
	Medida_Alto DECIMAL(18,2),
	Medida_Ancho DECIMAL(18,2),
	Medida_Profundidad DECIMAL(18,2),
	Medida_Precio DECIMAL(18,2),
	CONSTRAINT PK_Medida PRIMARY KEY (Medida_ID)
)

CREATE TABLE DD.Modelo (
	Modelo_Codigo BIGINT,
	Modelo_Nombre NVARCHAR(255),
	Modelo_Descripcion NVARCHAR(255),
	Modelo_Precio DECIMAL(18,2),
	CONSTRAINT PK_Modelo PRIMARY KEY (Modelo_Codigo)
)

CREATE TABLE DD.Sillon (
	Sillon_Codigo BIGINT,
	Sillon_Modelo BIGINT,
	Sillon_Medida BIGINT,
	Sillon_Madera BIGINT,
	Sillon_Tela BIGINT,
	Sillon_Relleno BIGINT,
	CONSTRAINT PK_Sillon PRIMARY KEY (Sillon_Codigo),
	CONSTRAINT FK_Sillon_Modelo FOREIGN KEY (Sillon_Modelo) REFERENCES DD.Modelo,
	CONSTRAINT FK_Sillon_Medida FOREIGN KEY (Sillon_Medida) REFERENCES DD.Medida,
	CONSTRAINT FK_Sillon_Madera FOREIGN KEY (Sillon_Madera) REFERENCES DD.Material,
	CONSTRAINT FK_Sillon_Tela FOREIGN KEY (Sillon_Tela) REFERENCES DD.Material,
	CONSTRAINT FK_Sillon_Relleno FOREIGN KEY (Sillon_Relleno) REFERENCES DD.Material
)

CREATE TABLE DD.Cliente (
	Cliente_ID BIGINT IDENTITY(1,1),
	Cliente_DNI BIGINT,
	Cliente_Domicilio BIGINT,
	Cliente_Nombre NVARCHAR(255),
	Cliente_Apellido NVARCHAR(255),
	Cliente_Telefono NVARCHAR(255),
	Cliente_Fecha_Nacimiento DATETIME2(6),
	Cliente_Mail NVARCHAR(255),
	CONSTRAINT PK_Cliente PRIMARY KEY (Cliente_ID),
	CONSTRAINT FK_Cliente_Domicilio FOREIGN KEY (Cliente_Domicilio) REFERENCES DD.Domicilio
)

CREATE TABLE DD.Proveedor (
	Proveedor_ID BIGINT IDENTITY(1,1),
	Proveedor_CUIT NVARCHAR(255),
	Proveedor_Razon_Social NVARCHAR(255),
	Proveedor_Domicilio BIGINT,
	Proveedor_Telefono NVARCHAR(255),
	Proveedor_Mail NVARCHAR(255),
	CONSTRAINT PK_Proveedor PRIMARY KEY (Proveedor_ID),
	CONSTRAINT FK_Proveedor_Domicilio FOREIGN KEY (Proveedor_Domicilio) REFERENCES DD.Domicilio
)

CREATE TABLE DD.Sucursal (
	Sucursal_ID BIGINT IDENTITY(1,1),
	Sucursal_Numero BIGINT,
	Sucursal_Domicilio BIGINT,
	Sucursal_Telefono NVARCHAR(255),
	Sucursal_Mail NVARCHAR(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (Sucursal_ID),
	CONSTRAINT FK_Sucursal_Domicilio FOREIGN KEY (Sucursal_Domicilio) REFERENCES DD.Domicilio
)

CREATE TABLE DD.Pedido (
	Pedido_ID DECIMAL(18,0),
	Pedido_Numero DECIMAL(18,0),
	Pedido_Sucursal BIGINT,
	Pedido_Cliente BIGINT,
	Pedido_Fecha DATETIME2(6),
	Pedido_Estado NVARCHAR(255),
	Pedido_Total DECIMAL(18,2),	
	CONSTRAINT PK_Pedido PRIMARY KEY (Pedido_ID),
	CONSTRAINT FK_Pedido_Sucursal FOREIGN KEY (Pedido_Sucursal) REFERENCES DD.Sucursal,
	CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (Pedido_Cliente) REFERENCES DD.Cliente,
	CONSTRAINT CK_Pedido_Estado CHECK (Pedido_Estado IN ('PENDIENTE', 'CANCELADO', 'ENTREGADO'))
)

CREATE TABLE DD.Cancelacion (
	Cancelacion_Pedido DECIMAL(18,0),
	Cancelacion_Fecha DATETIME2(6),
	Cancelacion_Motivo VARCHAR(255),
	CONSTRAINT PK_Cancelacion PRIMARY KEY (Cancelacion_Pedido),
	CONSTRAINT FK_Cancelacion_Pedido FOREIGN KEY (Cancelacion_Pedido) REFERENCES DD.Pedido
)

CREATE TABLE DD.Detalle_Pedido (
	Detalle_Pedido_Sillon BIGINT,
	Detalle_Pedido_Pedido DECIMAL(18,0),
	Detalle_Pedido_Cantidad BIGINT,
	Detalle_Pedido_Precio DECIMAL(18,2),
	Detalle_Pedido_Subtotal DECIMAL(18,2),
	CONSTRAINT PK_Detalle_Pedido PRIMARY KEY (Detalle_Pedido_Sillon),
	CONSTRAINT FK_Detalle_Pedido_Sillon FOREIGN KEY (Detalle_Pedido_Sillon) REFERENCES DD.Sillon,
	CONSTRAINT FK_Detalle_Pedido_Pedido FOREIGN KEY (Detalle_Pedido_Pedido) REFERENCES DD.Pedido
)

CREATE TABLE DD.Compra (
	Compra_Numero BIGINT,
	Compra_Sucursal BIGINT,
	Compra_Proveedor BIGINT,
	Compra_Fecha DATETIME2(6),
	Compra_Total DECIMAL(18,2),
	CONSTRAINT PK_Compra PRIMARY KEY (Compra_Numero),
	CONSTRAINT FK_Compra_Sucursal FOREIGN KEY (Compra_Sucursal) REFERENCES DD.Sucursal,
	CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (Compra_Proveedor) REFERENCES DD.Proveedor
)

CREATE TABLE DD.Detalle_Compra (
	Detalle_Compra_Compra BIGINT,
	Detalle_Compra_Material BIGINT,
	Detalle_Compra_Cantidad DECIMAL(18,0),
	Detalle_Compra_Precio DECIMAL(18,2),
	Detalle_Compra_Subtotal DECIMAL(18,2),
	CONSTRAINT PK_Compra_Detalle PRIMARY KEY (Detalle_Compra_Compra, Detalle_Compra_Material),
	CONSTRAINT FK_Compra_Detalle_Compra FOREIGN KEY (Detalle_Compra_Compra) REFERENCES DD.Compra,
	CONSTRAINT FK_Compra_Detalle_Material FOREIGN KEY (Detalle_Compra_Material) REFERENCES DD.Material
)

CREATE TABLE DD.Factura (
	Factura_Numero BIGINT,
	Factura_Cliente BIGINT,
	Factura_Sucursal BIGINT,
	Factura_Pedido DECIMAL(18,0),
	Factura_Fecha DATETIME2(6),
	Factura_Total DECIMAL(38,2),
	CONSTRAINT PK_Factura PRIMARY KEY (Factura_Numero),
	CONSTRAINT FK_Factura_Cliente FOREIGN KEY (Factura_Cliente) REFERENCES DD.Cliente,
	CONSTRAINT FK_Factura_Sucursal FOREIGN KEY (Factura_Sucursal) REFERENCES DD.Sucursal,
	CONSTRAINT FK_Factura_Pedido FOREIGN KEY (Factura_Pedido) REFERENCES DD.Pedido
)

CREATE TABLE DD.Envio (
	Envio_Numero DECIMAL(18,0),
	Envio_Factura BIGINT,
	Envio_Fecha_Programada DATETIME2(6),
	Envio_Fecha_Entrega DATETIME2(6),
	Envio_Importe_Translado DECIMAL(18,2),
	Envio_Importe_Subida DECIMAL(18,2),
	Envio_Importe_Total DECIMAL(18,2),
	CONSTRAINT PK_Envio PRIMARY KEY (Envio_Numero),
	CONSTRAINT FK_Envio_Factura FOREIGN KEY (Envio_Factura) REFERENCES DD.Factura
)

CREATE TABLE DD.Detalle_Factura (
	Detalle_Factura_Detalle_Pedido BIGINT,
	Detalle_Factura_Factura BIGINT,
	Detalle_Factura_Cantidad DECIMAL(18,0),
	Detalle_Factura_Precio DECIMAL(18,2),
	Detalle_Factura_Subtotal DECIMAL(18,2),
	CONSTRAINT PK_Detalle_Factura PRIMARY KEY (Detalle_Factura_Detalle_Pedido, Detalle_Factura_Factura),
	CONSTRAINT FK_Detalle_Factura_Detalle_Pedido FOREIGN KEY (Detalle_Factura_Detalle_Pedido) REFERENCES DD.Detalle_Pedido,
	CONSTRAINT FK_Detalle_Factura_Factura FOREIGN KEY (Detalle_Factura_Factura) REFERENCES DD.Factura
)

GO
--Insert Nivel 1 (Tablas sin dependencias)
INSERT INTO DD.Provincia
SELECT DISTINCT Cliente_Provincia
FROM gd_esquema.Maestra
WHERE Cliente_Provincia IS NOT NULL

UNION

SELECT DISTINCT Sucursal_Provincia
FROM gd_esquema.Maestra
WHERE Sucursal_Provincia IS NOT NULL

UNION

SELECT DISTINCT Proveedor_Provincia
FROM gd_esquema.Maestra
WHERE Proveedor_Provincia IS NOT NULL

INSERT INTO DD.Material
SELECT DISTINCT 
	Material_Tipo,
	Material_Nombre,
	Material_Descripcion,
	Material_Precio
FROM gd_esquema.Maestra
WHERE Material_Nombre IS NOT NULL

INSERT INTO DD.Medida
SELECT DISTINCT
	Sillon_Medida_Alto,
	Sillon_Medida_Ancho,
	Sillon_Medida_Profundidad,
	Sillon_Medida_Precio 
FROM gd_esquema.Maestra 
WHERE Sillon_Medida_Precio IS NOT NULL

INSERT INTO DD.Modelo
SELECT DISTINCT
	Sillon_Modelo_Codigo,
	Sillon_Modelo,
	Sillon_Modelo_Descripcion,
	Sillon_Modelo_Precio
FROM gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo IS NOT NULL


--Nivel 2
INSERT INTO DD.Localidad 
SELECT DISTINCT Cliente_Localidad, Provincia_ID
FROM gd_esquema.Maestra
JOIN  DD.Provincia ON Provincia_Nombre = Cliente_Provincia

UNION

SELECT DISTINCT Proveedor_Localidad, Provincia_ID
FROM gd_esquema.Maestra
JOIN  DD.Provincia ON Provincia_Nombre = Proveedor_Provincia

UNION

SELECT DISTINCT Sucursal_Localidad, Provincia_ID
FROM gd_esquema.Maestra
JOIN  DD.Provincia ON Provincia_Nombre = Sucursal_Provincia