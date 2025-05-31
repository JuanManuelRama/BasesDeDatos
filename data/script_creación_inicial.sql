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
	Sucursal_Numero BIGINT,
	Sucursal_Domicilio BIGINT,
	Sucursal_Telefono NVARCHAR(255),
	Sucursal_Mail NVARCHAR(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (Sucursal_Numero),
	CONSTRAINT FK_Sucursal_Domicilio FOREIGN KEY (Sucursal_Domicilio) REFERENCES DD.Domicilio
)

CREATE TABLE DD.Pedido (
	Pedido_Numero DECIMAL(18,0),
	Pedido_Sucursal BIGINT,
	Pedido_Cliente BIGINT,
	Pedido_Fecha DATETIME2(6) DEFAULT GETDATE(),
	Pedido_Estado NVARCHAR(255) DEFAULT 'PENDIENTE',
	Pedido_Total DECIMAL(18,2),	
	CONSTRAINT PK_Pedido PRIMARY KEY (Pedido_Numero),
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
	Compra_Numero DECIMAL(18,0),
	Compra_Sucursal BIGINT,
	Compra_Proveedor BIGINT,
	Compra_Fecha DATETIME2(6),
	Compra_Total DECIMAL(18,2),
	CONSTRAINT PK_Compra PRIMARY KEY (Compra_Numero),
	CONSTRAINT FK_Compra_Sucursal FOREIGN KEY (Compra_Sucursal) REFERENCES DD.Sucursal,
	CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (Compra_Proveedor) REFERENCES DD.Proveedor
)

CREATE TABLE DD.Detalle_Compra (
	Detalle_Compra_Compra DECIMAL(18,0),
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
-- Tabla provincia
INSERT INTO DD.Provincia (
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

INSERT INTO DD.Material (
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

-- Tabla medida
INSERT INTO DD.Medida (
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
WHERE Sillon_Medida_Precio IS NOT NULL

INSERT INTO DD.Modelo (
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
INSERT INTO DD.Localidad (
	Localidad_Nombre,
	Localidad_Provincia
)
SELECT DISTINCT 
	Cliente_Localidad, 
	Provincia_ID
FROM gd_esquema.Maestra mas
JOIN  DD.Provincia p ON p.Provincia_Nombre = mas.Cliente_Provincia

UNION

SELECT DISTINCT 
	Proveedor_Localidad, 
	Provincia_ID
FROM gd_esquema.Maestra mas
JOIN  DD.Provincia p ON p.Provincia_Nombre = mas.Proveedor_Provincia

UNION

SELECT DISTINCT 
	Sucursal_Localidad, 
	Provincia_ID
FROM gd_esquema.Maestra mas
JOIN  DD.Provincia p ON p.Provincia_Nombre = mas.Sucursal_Provincia

INSERT INTO DD.Tela (
	Tela_ID,
	Tela_Color,
	Tela_Textura
)
SELECT DISTINCT 
	Material_ID, 
	Tela_Color, 
	Tela_Textura
FROM gd_esquema.Maestra mas
JOIN DD.Material mat ON mat.Material_Nombre = mas.Material_Nombre
WHERE mat.Material_Tipo = 'TELA'

INSERT INTO DD.Madera (
	Madera_ID,
	Madera_Color,
	Madera_Dureza
)
SELECT DISTINCT 
	Material_ID, 
	Madera_Color, 
	Madera_Dureza
FROM gd_esquema.Maestra mas
JOIN DD.Material mat ON mat.Material_Nombre = mas.Material_Nombre
WHERE mat.Material_Tipo = 'MADERA'

INSERT INTO DD.Relleno (
	Relleno_ID,
	Relleno_Densidad
)
SELECT DISTINCT 
	Material_ID, 
	Relleno_Densidad
FROM gd_esquema.Maestra mas
JOIN DD.Material mat ON mat.Material_Nombre = mas.Material_Nombre
WHERE mat.Material_Tipo = 'RELLENO'

--Nivel 3

INSERT INTO DD.Domicilio (
	Domicilio_Direccion,
	Domicilio_Localidad
)
SELECT DISTINCT 
	Sucursal_Direccion, 
	Localidad_ID  
FROM gd_esquema.Maestra mas
JOIN DD.Localidad l ON l.Localidad_Nombre = mas.Sucursal_Localidad
JOIN DD.Provincia p ON p.Provincia_ID = l.Localidad_Provincia 
WHERE Provincia_Nombre = Sucursal_Provincia 

UNION

SELECT DISTINCT 
	Cliente_Direccion, 
	Localidad_ID
FROM gd_esquema.Maestra mas
JOIN DD.Localidad l ON l.Localidad_Nombre = mas.Cliente_Localidad
JOIN DD.Provincia p ON p.Provincia_ID = l.Localidad_Provincia 
WHERE Provincia_Nombre = Cliente_Provincia 

UNION

SELECT DISTINCT 
	Proveedor_Direccion, 
	Localidad_ID
FROM gd_esquema.Maestra mas
JOIN DD.Localidad l ON l.Localidad_Nombre = mas.Proveedor_Localidad
JOIN DD.Provincia p ON p.Provincia_ID = l.Localidad_Provincia 
WHERE Provincia_Nombre = Proveedor_Provincia 

-- No se pueden insertar los 3 materiales a la vez
INSERT INTO DD.Sillon (
	Sillon_Codigo, 
	Sillon_Medida, 
	Sillon_Modelo, 
	Sillon_Tela
)
SELECT DISTINCT 
    sillon_codigo, 
    Medida_ID, 
    Sillon_Modelo_Codigo, 
    Material_ID
FROM gd_esquema.Maestra mas
JOIN DD.Medida ON Sillon_Medida_Alto = Medida_Alto AND Sillon_Medida_Ancho = Medida_Ancho AND Sillon_Medida_Profundidad = Medida_Profundidad
JOIN DD.Material mat ON mat.Material_Nombre = mas.Material_Nombre AND mat.Material_Tipo = 'TELA';

UPDATE DD.Sillon
SET Sillon_Madera = m.Material_ID
FROM DD.Sillon
JOIN gd_esquema.Maestra mas ON DD.Sillon.Sillon_Codigo  = mas.Sillon_Codigo
JOIN DD.Material m ON m.Material_Nombre = mas.Material_Nombre AND m.Material_Tipo = 'MADERA';

UPDATE DD.Sillon
SET Sillon_Relleno = r.Material_ID
FROM DD.Sillon
JOIN gd_esquema.Maestra mas ON DD.Sillon.Sillon_Codigo = mas.Sillon_Codigo
JOIN DD.Material r ON r.Material_Nombre = mas.Material_Nombre AND r.Material_Tipo = 'RELLENO';

-- Nivel 4

INSERT INTO DD.Cliente (
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
JOIN DD.Domicilio d ON d.Domicilio_Direccion  = mas.Cliente_Direccion 
JOIN DD.Localidad l ON l.Localidad_ID = d.Domicilio_Localidad 
JOIN DD.Provincia p ON p.Provincia_ID  = l.Localidad_Provincia 
WHERE Cliente_Localidad = Localidad_Nombre 
AND Cliente_Provincia = Provincia_Nombre 

INSERT INTO DD.Sucursal (
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
FROM gd_esquema.Maestra mas
JOIN DD.Domicilio d ON d.Domicilio_Direccion = mas.Sucursal_Direccion
JOIN DD.Localidad l ON l.Localidad_ID = d.Domicilio_Localidad 
JOIN DD.Provincia p ON p.Provincia_ID  = l.Localidad_Provincia 
WHERE Sucursal_Localidad  = Localidad_Nombre 
AND Sucursal_Provincia  = Provincia_Nombre 

INSERT INTO DD.Proveedor (
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
FROM gd_esquema.Maestra mas
JOIN DD.Domicilio d ON d.Domicilio_Direccion  = mas.Proveedor_Direccion  
JOIN DD.Localidad l ON l. Localidad_ID = d.Domicilio_Localidad 
JOIN DD.Provincia p ON p.Provincia_ID  = l.Localidad_Provincia 
WHERE Proveedor_Localidad  = Localidad_Nombre 
AND Proveedor_Provincia  = Provincia_Nombre 

-- Nivel 5

INSERT INTO DD.Pedido (
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
JOIN DD.Sucursal s ON s.Sucursal_Numero = mas.Sucursal_NroSucursal
JOIN DD.Cliente c ON c.Cliente_DNI = mas.Cliente_Dni
where Pedido_Numero IS NOT NULL

INSERT INTO DD.Compra (
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
JOIN DD.Sucursal s ON s.Sucursal_Numero = mas.Sucursal_NroSucursal
JOIN DD.Proveedor p ON p.Proveedor_CUIT = mas.Proveedor_Cuit
WHERE Compra_Numero IS NOT NULL

INSERT INTO DD.Cancelacion (
	Cancelacion_Pedido,
	Cancelacion_Fecha,
	Cancelacion_Motivo
)
SELECT DISTINCT
	Pedido_Numero,
	Pedido_Cancelacion_Fecha,
	Pedido_Cancelacion_Motivo
FROM gd_esquema.Maestra mas