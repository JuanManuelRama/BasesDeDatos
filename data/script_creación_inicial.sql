--Setup
USE GD1C2025
GO
CREATE SCHEMA DD
GO

--Creación de tablas

CREATE TABLE DD.Provincia (
	Provincia_ID BIGINT IDENTITY(1,1),
	Provincia_Nombre NVARCHAR(255),
	CONSTRAINT PK_Provincia PRIMARY KEY (Provincia_ID)
)

CREATE TABLE DD.Localidad (
	Domicilio_ID BIGINT IDENTITY(1,1),
	Localidad_Nombre NVARCHAR(255),
	Localidad_Provincia BIGINT,
	CONSTRAINT PK_Localidad PRIMARY KEY (Domicilio_ID),
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
	CONSTRAINT PK_Material PRIMARY KEY (Material_ID)
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
	Tela_Textura NVARCHAR(255)
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
	Medida_Precio DECIMAL(18,2)
	CONSTRAINT PK_Medida PRIMARY KEY (Medida_ID)
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