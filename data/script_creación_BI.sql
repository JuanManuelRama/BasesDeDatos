USE GD1C2025
GO

DROP TABLE IF EXISTS BI_Fact_Table_Factura
DROP TABLE IF EXISTS BI_Fact_Table_Compra
DROP TABLE IF EXISTS BI_Sucursal
DROP TABLE IF EXISTS BI_Fecha
DROP TABLE IF EXISTS BI_Cliente
DROP TABLE IF EXISTS BI_Modelo
DROP TABLE IF EXISTS BI_Material
DROP VIEW IF EXISTS Factura_Promedio_Mensual
DROP VIEW IF EXISTS Rendimiento_de_modelos
DROP VIEW IF EXISTS Promedio_De_Compras
DROP VIEW IF EXISTS Compra_Por_Tipo_De_Material
DROP VIEW IF EXISTS Ganancias
GO


CREATE TABLE BI_Fecha (
	fecha_id BIGINT IDENTITY(1,1),
	fecha_año INT,
	fecha_mes INT,
	fecha_cuatrimestre AS 
	CASE 
        WHEN fecha_mes BETWEEN 1 AND 4 THEN 1
        WHEN fecha_mes BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END 
	PERSISTED,
	CONSTRAINT PK_Fecha PRIMARY KEY (fecha_id),
	CONSTRAINT UQ_Fecha UNIQUE (fecha_año, fecha_mes),
	CONSTRAINT CK_Fecha_Mes CHECK (fecha_mes BETWEEN 1 AND 12)
)

CREATE TABLE BI_Cliente (
	cliente_id BIGINT IDENTITY(1,1),
	cliente_minimo INT,
	cliente_maximo INT,
	cliente_rango VARCHAR(5),
	CONSTRAINT PK_Cliente PRIMARY KEY (cliente_id),
	CONSTRAINT UQ_Cliente UNIQUE (cliente_minimo, cliente_maximo, cliente_rango)
)

CREATE TABLE BI_Sucursal (
	sucursal_id BIGINT,
	sucursal_provincia VARCHAR(50),
	sucursal_localidad VARCHAR(50),
	CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_id),
)

CREATE TABLE BI_Modelo (
	modelo_id BIGINT,
	modelo_nombre VARCHAR(50)
	CONSTRAINT PK_Modelo PRIMARY KEY (modelo_id)
)

CREATE TABLE BI_Material (
	material_id INT IDENTITY(1,1),
	material_nombre varchar(50),
	CONSTRAINT PK_Material PRIMARY KEY (material_id),
	CONSTRAINT UQ_Material UNIQUE (material_nombre)
)

CREATE TABLE BI_Fact_Table_Factura (
	id_fecha BIGINT,
	id_cliente BIGINT,
	id_sucursal BIGINT,
	id_modelo BIGINT,
	fact_numero BIGINT,
	fact_precio DECIMAL(12,2),
	fact_cantidad DECIMAL(12,2),
	fact_total DECIMAl(12,2),
	CONSTRAINT FK_Fact_Table_Factura_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Factura_Cliente FOREIGN KEY (id_cliente) REFERENCES BI_Cliente,
	CONSTRAINT FK_Fact_Table_Factura_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
	CONSTRAINT FK_Fact_Table_Factura_Modelo FOREIGN KEY (id_modelo) REFERENCES BI_Modelo,
)

CREATE TABLE BI_Fact_Table_Envio (
	id_fecha BIGINT,
	id_sucursal BIGINT,

	Envio_numero decimal(18, 0),
	Envio_Fecha_Programada datetime2(6),
	Envio_Fecha_Entrega datetime2(6),
	Envio_Total decimal(18, 2) -- aca solo tomo el total, no traslado y subida (podria tomarse y sumarse)
	CONSTRAINT FK_Fact_Table_Envio_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Envio_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
)

CREATE TABLE BI_Fact_Table_Compra (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	id_material INT,
	compra_precio DECIMAL(12,2),
	compra_cantidad DECIMAL(12,2),
	compra_total DECIMAL(12,2),
	--CONSTRAINT PKFact_Table_Compra PRIMARY KEY (id_fecha, id_sucursal, id_material)
	CONSTRAINT FK_Fact_Table_Compra_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Compra_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
	CONSTRAINT FK_Fact_Table_Compra_Material FOREIGN KEY (id_material) REFERENCES BI_Material

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

INSERT INTO BI_CLIENTE (
	cliente_minimo,
	cliente_maximo,
	cliente_rango
)
VALUES (0, 24, '<24'), 
	   (25, 34, '25-35'), 
	   (35, 49, '35-50'),
	   (50, 100000, '>50')


INSERT INTO BI_Sucursal (
    sucursal_id,
    sucursal_provincia,
	sucursal_localidad
)
SELECT 
    Sucursal_Numero,
    Provincia_Nombre,
	Localidad_Nombre
FROM DROP_DATABASE.Sucursal
JOIN DROP_DATABASE.Domicilio ON Domicilio_ID = Sucursal_Domicilio
JOIN DROP_DATABASE.Localidad ON Localidad_ID = Domicilio_Localidad
JOIN DROP_DATABASE.Provincia p ON Provincia_ID = Localidad_Provincia

INSERT INTO BI_Modelo (
	modelo_id,
	modelo_nombre
)
SELECT Modelo_Codigo,
	   Modelo_Nombre
FROM DROP_DATABASE.Modelo


INSERT INTO BI_Material (
	material_nombre
)
SELECT DISTINCT Material_Tipo
FROM DROP_DATABASE.Material

GO
--Tablas de hechos
INSERT INTO BI_Fact_Table_Factura (
	id_fecha,
	id_cliente,
	id_sucursal,
	id_modelo,
	fact_numero,
	fact_cantidad,
	fact_precio,
	fact_total
)
SELECT fecha_id, 
	   BI_Cliente.cliente_id,
	   sucursal_id,
	   Sillon_Modelo,
	   Factura_Numero,
	   Detalle_Factura_Cantidad,
	   Detalle_Factura_Precio,
	   Detalle_Factura_Subtotal
FROM DROP_DATABASE.Factura
JOIN DROP_DATABASE.Detalle_Factura ON Detalle_Factura_Factura = Factura_Numero
JOIN DROP_DATABASE.Cliente ON Cliente_ID = Factura_Cliente
JOIN BI_Fecha ON fecha_año = YEAR(Factura_Fecha)
			  AND fecha_mes = MONTH(Factura_Fecha)
JOIN BI_Cliente ON DATEDIFF(YEAR, Cliente_Fecha_Nacimiento, GETDATE()) BETWEEN cliente_minimo AND cliente_maximo
JOIN BI_Sucursal ON BI_Sucursal.sucursal_id = Factura_Sucursal
JOIN DROP_DATABASE.Sillon ON Detalle_Factura_Detalle_Pedido = Sillon_Codigo

INSERT INTO BI_Fact_Table_Compra (
	id_fecha,
	id_sucursal,
	id_material,
	compra_cantidad,
	compra_precio,
	compra_total
)
SELECT fecha_id,
       Compra_Sucursal,
	   mb.material_id,
	   Detalle_Compra_Cantidad,
	   Detalle_Compra_Precio,
	   Detalle_Compra_Subtotal
FROM DROP_DATABASE.Compra
JOIN DROP_DATABASE.Detalle_Compra ON Detalle_Compra_Compra = Compra_Numero
JOIN DROP_DATABASE.Material m ON Material_ID = Detalle_Compra_Material
JOIN BI_Fecha ON fecha_año = YEAR(Compra_Fecha)
			  AND fecha_mes = MONTH(Compra_Fecha)
JOIN BI_Material mb ON mb.material_nombre = m.Material_Tipo
GO
--Vistas
CREATE VIEW Ganancias
AS
	SELECT SUM(fact_total)
		   - ISNULL((SELECT SUM(compra_total)
		   	  FROM BI_Fact_Table_Compra
			  JOIN BI_Fecha ON fecha_id = id_fecha
			  WHERE fecha_mes = f.fecha_mes
			  	AND id_sucursal = fac.id_sucursal),0) AS Ganancias,
		   fecha_mes,
		   id_sucursal
	FROM BI_Fact_Table_Factura fac
	JOIN BI_Fecha f ON fecha_id = id_fecha
	GROUP BY fecha_mes, id_sucursal
GO

CREATE VIEW Factura_Promedio_Mensual
AS
	SELECT fecha_año,
		fecha_cuatrimestre,
		sucursal_provincia,
		(SUM(fact_total) / COUNT(DISTINCT fact_numero)) / 4 AS Promedio_Facturado
	FROM BI_Fact_Table_Factura
	JOIN BI_Fecha ON fecha_id = id_fecha
	JOIN BI_Sucursal ON sucursal_id = id_sucursal
	GROUP BY fecha_año, 
			fecha_cuatrimestre, 
			sucursal_provincia
GO
CREATE VIEW Rendimiento_de_modelos
AS
	SELECT modelo_nombre, 
		   fecha_año,
		   fecha_cuatrimestre,
		   sucursal_localidad,
		   cliente_rango
	FROM BI_Fact_Table_Factura
	JOIN BI_Modelo m ON modelo_id = id_modelo
	JOIN BI_Fecha f ON fecha_id = id_fecha
	JOIN BI_Sucursal s ON sucursal_id = id_sucursal
	JOIN BI_Cliente c ON cliente_id = id_cliente
	GROUP BY modelo_nombre,
			fecha_año,
			fecha_cuatrimestre,
			sucursal_localidad,
			cliente_rango,
			modelo_id
	HAVING modelo_id IN (SELECT TOP 3 id_modelo
						 FROM BI_Fact_Table_Factura
						 JOIN BI_Fecha ON id_fecha = fecha_id
						 JOIN BI_Sucursal ON id_sucursal = sucursal_id
						 JOIN BI_Cliente ON id_cliente = cliente_id
						 WHERE fecha_año = f.fecha_año
							AND fecha_cuatrimestre = f.fecha_cuatrimestre
							AND sucursal_localidad = s.sucursal_localidad
							AND cliente_rango = c.cliente_rango
						 GROUP BY id_modelo
						 ORDER BY SUM(fact_cantidad) DESC)
GO
CREATE VIEW Promedio_De_Compras
AS
	SELECT AVG(compra_total) AS promedio_compra_mensual,
		   fecha_mes
	FROM BI_Fact_Table_Compra
	JOIN BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_mes
GO
CREATE VIEW Compra_Por_Tipo_De_Material
AS
	SELECT SUM(compra_total) AS importe_total_gastado,
		   material_nombre,
		   sucursal_id,
		   fecha_cuatrimestre
	FROM BI_Fact_Table_Compra
	JOIN BI_Material ON material_id = id_material
	JOIN BI_Fecha ON fecha_id = id_fecha
	JOIN BI_Sucursal ON sucursal_id = id_sucursal
	GROUP BY material_nombre,
			 sucursal_id,
			 fecha_cuatrimestre
GO
/*
SELECT Pedido_Sucursal,
		datepart(QUARTER, Pedido_Fecha),
	   avg(datediff(day, Pedido_Fecha, Factura_Fecha))
FROM DROP_DATABASE.Pedido
join  DROP_DATABASE.Factura on Factura_Pedido = Pedido_Numero
group by Pedido_Sucursal, datepart(QUARTER, Pedido_Fecha)*/
