USE GD1C2025
GO

DROP TABLE IF EXISTS BI_Fact_Table_Factura
DROP TABLE IF EXISTS BI_Sucursal
DROP TABLE IF EXISTS BI_Fecha
DROP TABLE IF EXISTS BI_Cliente
DROP TABLE IF EXISTS BI_Ubicacion
DROP TABLE IF EXISTS BI_Provincia
DROP TABLE IF EXISTS BI_Modelo
DROP TABLE IF EXISTS BI_Factura
DROP VIEW IF EXISTS Factura_Promedio_Mensual
DROP VIEW IF EXISTS Rendimiento_de_modelos
GO


CREATE TABLE BI_Fecha (
	fecha_id BIGINT IDENTITY(1,1),
	fecha_año INT,
	fecha_mes INT,
	fecha_cuatrimestre INT,
	CONSTRAINT PK_Fecha PRIMARY KEY (fecha_id),
	CONSTRAINT UQ_Fecha UNIQUE (fecha_año, fecha_mes),
	CONSTRAINT CK_Fecha_Cuatrimestre CHECK (fecha_cuatrimestre IN(1, 2, 3, 4))
)

CREATE TABLE BI_Cliente (
	cliente_id BIGINT IDENTITY(1,1),
	cliente_minimo INT,
	cliente_maximo INT,
	cliente_rango VARCHAR(5),
	CONSTRAINT PK_Cliente PRIMARY KEY (cliente_id),
	CONSTRAINT UQ_Cliente UNIQUE (cliente_minimo, cliente_maximo, cliente_rango)
)

CREATE TABLE BI_Provincia (
	provincia_id BIGINT IDENTITY(1,1),
	provincia_nombre VARCHAR(50),
	CONSTRAINT PK_Provincia PRIMARY KEY (provincia_id),
	CONSTRAINT UQ_Provincia UNIQUE (provincia_nombre)
)

CREATE TABLE BI_Ubicacion (
	ubicacion_id BIGINT IDENTITY(1,1),
	ubicacion_localidad VARCHAR(50),
	ubicacion_provincia BIGINT,
	CONSTRAINT PK_Ubicacion PRIMARY KEY (ubicacion_id),
	CONSTRAINT FK_Ubicacion_Provincia FOREIGN KEY (ubicacion_provincia) REFERENCES BI_Provincia,
	CONSTRAINT UQ_Ubicacion UNIQUE (ubicacion_provincia, ubicacion_localidad)
)

CREATE TABLE BI_Sucursal (
	sucursal_id BIGINT,
	sucursal_ubicacion BIGINT
	CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_id),
	CONSTRAINT FK_Sucursal_Ubicacion FOREIGN KEY (sucursal_ubicacion) REFERENCES BI_Ubicacion
)

CREATE TABLE BI_Modelo (
	modelo_id BIGINT,
	modelo_nombre VARCHAR(50)
	CONSTRAINT PK_Modelo PRIMARY KEY (modelo_id)
)

CREATE TABLE BI_Factura (
	factura_id BIGINT,
	CONSTRAINT PK_Factura PRIMARY KEY (factura_id)
)

CREATE TABLE BI_Fact_Table_Factura (
	id_fecha BIGINT,
	id_cliente BIGINT,
	id_sucursal BIGINT,
	--id_ubicacion BIGINT,
	id_modelo BIGINT,
	id_factura BIGINT,
	fact_total DECIMAl(12,2),
	--CONSTRAINT PK_Fact_Table_Factura PRIMARY KEY (id_fecha, fact_total),
	CONSTRAINT FK_Fact_Table_Factura_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_fecha,
	CONSTRAINT FK_Fact_Table_Factura_Modelo FOREIGN KEY (id_modelo) REFERENCES BI_Modelo,
	CONSTRAINT FK_Fact_Table_Factura_Factura FOREIGN KEY (id_factura) REFERENCES BI_Factura
)
GO

INSERT INTO BI_Fecha (
	fecha_año,
	fecha_mes
)
SELECT DISTINCT YEAR(Factura_Fecha), 
			    MONTH(Factura_Fecha)
FROM DROP_DATABASE.Factura
UNION
SELECT DISTINCT YEAR(Pedido_Fecha), 
			    MONTH(Pedido_Fecha)
FROM DROP_DATABASE.Pedido
UNION
SELECT DISTINCT YEAR(Envio_Fecha_Entrega), 
			    MONTH(Envio_Fecha_Entrega)
FROM DROP_DATABASE.Envio
UNION
SELECT DISTINCT YEAR(Envio_Fecha_Programada), 
			    MONTH(Envio_Fecha_Programada)
FROM DROP_DATABASE.Envio
UNION
SELECT DISTINCT YEAR(Compra_Fecha), 
			    MONTH(Compra_Fecha)
FROM DROP_DATABASE.Compra

UPDATE BI_Fecha
SET fecha_cuatrimestre = CASE
    WHEN fecha_mes BETWEEN 1 AND 4 THEN 1
    WHEN fecha_mes BETWEEN 5 AND 8 THEN 2
    ELSE 3
END

INSERT INTO BI_CLIENTE (
	cliente_minimo,
	cliente_maximo,
	cliente_rango
)
VALUES (0, 24, '<24'), 
	   (25, 34, '25-35'), 
	   (35, 49, '35-50'),
	   (50, 100000, '>50')


INSERT INTO BI_Provincia (
	provincia_nombre
)
SELECT Provincia_Nombre
FROM DROP_DATABASE.Provincia

INSERT INTO BI_Ubicacion (
	ubicacion_provincia,
	ubicacion_localidad
)
SELECT BI_Provincia.provincia_id, Localidad_Nombre
FROM DROP_DATABASE.Localidad
JOIN BI_Provincia ON Provincia_ID = Localidad_Provincia


INSERT INTO BI_Sucursal (
    sucursal_id,
    sucursal_ubicacion
)
SELECT 
    Sucursal_Numero,
    ubicacion_id
FROM DROP_DATABASE.Sucursal
JOIN DROP_DATABASE.Domicilio ON Domicilio_ID = Sucursal_Domicilio
JOIN DROP_DATABASE.Localidad ON Localidad_ID = Domicilio_Localidad
JOIN DROP_DATABASE.Provincia p ON Provincia_ID = Localidad_Provincia
JOIN BI_Provincia bp ON bp.provincia_nombre = p.Provincia_Nombre
JOIN BI_Ubicacion u ON ubicacion_localidad = Localidad_Nombre
					AND ubicacion_provincia = bp.provincia_id

INSERT INTO BI_Modelo (
	modelo_id,
	modelo_nombre
)
SELECT Modelo_Codigo,
	   Modelo_Nombre
FROM DROP_DATABASE.Modelo

INSERT INTO BI_Factura (
	factura_id
)
SELECT Factura_Numero
FROM DROP_DATABASE.Factura

INSERT INTO BI_Fact_Table_Factura (
	id_fecha,
	id_cliente,
	id_sucursal,
	id_modelo,
	id_factura,
	fact_total
)
SELECT fecha_id, 
	   BI_Cliente.cliente_id,
	   sucursal_id,
	   Sillon_Modelo,
	   Factura_Numero,
	   Detalle_Factura_Subtotal
FROM DROP_DATABASE.Factura
JOIN DROP_DATABASE.Detalle_Factura ON Detalle_Factura_Factura = Factura_Numero
JOIN DROP_DATABASE.Cliente ON Cliente_ID = Factura_Cliente
JOIN BI_Fecha ON fecha_año = YEAR(Factura_Fecha)
			  AND fecha_mes = MONTH(Factura_Fecha)
JOIN BI_Cliente ON DATEDIFF(YEAR, Cliente_Fecha_Nacimiento, GETDATE()) BETWEEN cliente_minimo AND cliente_maximo
JOIN BI_Sucursal ON BI_Sucursal.sucursal_id = Factura_Sucursal
JOIN DROP_DATABASE.Sillon ON Detalle_Factura_Detalle_Pedido = Sillon_Codigo
GO
--Vistas
CREATE VIEW Factura_Promedio_Mensual
AS
SELECT fecha_año,
	   fecha_cuatrimestre,
	   provincia_nombre,
	   SUM(fact_total) / COUNT(DISTINCT id_factura) AS Promedio_Facturado
FROM BI_Fact_Table_Factura
JOIN BI_Fecha ON fecha_id = id_fecha
JOIN BI_Sucursal ON sucursal_id = id_sucursal
JOIN BI_Ubicacion ON ubicacion_id = sucursal_ubicacion
JOIN BI_Provincia ON provincia_id = ubicacion_provincia
GROUP BY fecha_año, 
         fecha_cuatrimestre, 
		 provincia_nombre
GO
CREATE VIEW Rendimiento_de_modelos
AS
SELECT modelo_nombre, 
	   fecha_año,
	   fecha_cuatrimestre,
	   ubicacion_localidad,
	   cliente_rango
FROM BI_Fact_Table_Factura
JOIN BI_Modelo m ON modelo_id = id_modelo
JOIN BI_Fecha f ON fecha_id = id_fecha
JOIN BI_Sucursal s ON sucursal_id = id_sucursal
JOIN BI_Ubicacion u ON ubicacion_id = sucursal_ubicacion
JOIN BI_Cliente c ON cliente_id = id_cliente
GROUP BY modelo_nombre,
		 fecha_año,
		 fecha_cuatrimestre,
		 ubicacion_localidad,
		 cliente_rango,
		 modelo_id
HAVING modelo_id IN (SELECT TOP 3 ft2.id_modelo
					 FROM BI_Fact_Table_Factura ft2
					 JOIN BI_Fecha ON ft2.id_fecha = fecha_id
					 JOIN BI_Sucursal ON id_sucursal = sucursal_id
					 JOIN BI_Ubicacion u2 ON sucursal_ubicacion = u2.ubicacion_id
					 JOIN BI_Cliente c2       ON ft2.id_cliente = c2.cliente_id
					 WHERE fecha_año = f.fecha_año
						AND fecha_cuatrimestre = f.fecha_cuatrimestre
						AND ubicacion_localidad = u.ubicacion_localidad
						AND cliente_rango = c.cliente_rango
				    GROUP BY ft2.id_modelo
					ORDER BY SUM(ft2.fact_total) DESC)
GO
