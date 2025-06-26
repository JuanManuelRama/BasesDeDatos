--------------------------------- SETUP ------------------------------------------------

USE GD1C2025
GO

DROP TABLE IF EXISTS BI_Fact_Table_Envio
DROP TABLE IF EXISTS BI_Fact_Table_Pedido
DROP TABLE IF EXISTS BI_Fact_Table_Factura
DROP TABLE IF EXISTS BI_Fact_Table_Compra
DROP TABLE IF EXISTS BI_Fact_Table_Fabricacion
DROP TABLE IF EXISTS BI_Sucursal
DROP TABLE IF EXISTS BI_Fecha
DROP TABLE IF EXISTS BI_Cliente
DROP TABLE IF EXISTS BI_Modelo
DROP TABLE IF EXISTS BI_Material
DROP TABLE IF EXISTS BI_Turno
DROP TABLE IF EXISTS BI_Localidad
DROP TABLE IF EXISTS BI_Estado
DROP VIEW IF EXISTS Factura_Promedio_Mensual
DROP VIEW IF EXISTS Rendimiento_de_modelos
DROP VIEW IF EXISTS Promedio_De_Compras
DROP VIEW IF EXISTS Compra_Por_Tipo_De_Material
DROP VIEW IF EXISTS Ganancias
DROP VIEW IF EXISTS Volumen_de_Pedidos
DROP VIEW IF EXISTS Volumen_de_Pedidos
DROP VIEW IF EXISTS Conversion_De_Pedidos
DROP VIEW IF EXISTS PORCENTAJE_CUMPLIMIENTO_ENVIOS
DROP VIEW IF EXISTS LOCALIDADES_CON_MAYOR_COSTO_ENVIO
DROP VIEW IF EXISTS Tiempo_Promedio_De_Fabricacion
GO

--------------------------------- CREACION TABLAS  ------------------------------------------------

CREATE TABLE BI_Fecha (
	fecha_id BIGINT IDENTITY(1,1),
	fecha_año INT,
	fecha_mes INT,
	fecha_cuatrimestre AS ((fecha_mes - 1) / 4) + 1 PERSISTED,
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
	sucursal_provincia NVARCHAR(255),
	sucursal_localidad NVARCHAR(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_id),
)

CREATE TABLE BI_Modelo (
	modelo_id BIGINT,
	modelo_nombre VARCHAR(50)
	CONSTRAINT PK_Modelo PRIMARY KEY (modelo_id)
)

CREATE TABLE BI_Material (
	material_id INT IDENTITY(1,1),
	material_nombre NVARCHAR(255),
	CONSTRAINT PK_Material PRIMARY KEY (material_id),
	CONSTRAINT UQ_Material UNIQUE (material_nombre)
)

CREATE TABLE BI_Turno (
	turno_id BIGINT IDENTITY(1,1),
	turno_maximo_horas INT,
	turno_maximo_minutos INT,
	turno_minimo_horas INT,
	turno_minimo_minutos INT,
	turno_rango VARCHAR(13),
	CONSTRAINT PK_Turno PRIMARY KEY (turno_id),
	CONSTRAINT UQ_Turno UNIQUE (turno_maximo_horas, turno_maximo_minutos, turno_minimo_horas, turno_minimo_minutos, turno_rango)
)

CREATE TABLE BI_Localidad (
	localidad_id BIGINT IDENTITY(1,1),
	localidad_nombre nvarchar(255),
	localidad_provincia nvarchar(255)
	CONSTRAINT PK_Localidad PRIMARY KEY (localidad_id)
)

CREATE TABLE BI_Estado (
	estado_id INT IDENTITY(1,1),
	estado_nombre NVARCHAR(255),
	CONSTRAINT PK_Estado PRIMARY KEY (estado_id),
	CONSTRAINT UQ_Estado UNIQUE (estado_nombre),
)

CREATE TABLE BI_Fact_Table_Factura (
	id_fecha BIGINT,
	id_cliente BIGINT,
	id_sucursal BIGINT,
	id_modelo BIGINT,
	fact_numero BIGINT,
	fact_precio DECIMAL(18,2),
	fact_cantidad DECIMAL(18,0),
	fact_total DECIMAl(18,2),
	CONSTRAINT FK_Fact_Table_Factura_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Factura_Cliente FOREIGN KEY (id_cliente) REFERENCES BI_Cliente,
	CONSTRAINT FK_Fact_Table_Factura_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
	CONSTRAINT FK_Fact_Table_Factura_Modelo FOREIGN KEY (id_modelo) REFERENCES BI_Modelo,
)

CREATE TABLE BI_Fact_Table_Envio (
	id_fecha BIGINT,
	id_localidad BIGINT,
	envio_numero decimal(18, 0),
	envio_fecha_programada datetime2(6),
	envio_fecha_entrega datetime2(6),
	envio_total decimal(18, 2) -- aca solo tomo el total, no traslado y subida (podria tomarse y sumarse)
	CONSTRAINT FK_Fact_Table_Envio_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Envio_Sucursal FOREIGN KEY (id_localidad) REFERENCES BI_Localidad
)

CREATE TABLE BI_Fact_Table_Compra (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	id_material INT,
	compra_numero DECIMAL(18,0),
	compra_precio DECIMAL(18,2),
	compra_cantidad DECIMAL(18,0),
	compra_total DECIMAL(18,2),
	--CONSTRAINT PKFact_Table_Compra PRIMARY KEY (id_fecha, id_sucursal, id_material)
	CONSTRAINT FK_Fact_Table_Compra_Fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Compra_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
	CONSTRAINT FK_Fact_Table_Compra_Material FOREIGN KEY (id_material) REFERENCES BI_Material

)

CREATE TABLE BI_Fact_Table_Pedido (
	id_fecha BIGINT,
	id_turno BIGINT,
	id_cliente BIGINT,
	id_sucursal BIGINT,
	id_estado INT,
	pedido_cantidad BIGINT,
	CONSTRAINT FK_Fact_Table_Pedido_fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Pedido_turno FOREIGN KEY (id_turno) REFERENCES BI_Turno,
	CONSTRAINT FK_Fact_Table_Pedido_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
	CONSTRAINT FK_Fact_Table_Pedido_Estado FOREIGN KEY (id_estado) REFERENCES BI_Estado
)

CREATE TABLE BI_Fact_Table_Fabricacion (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	fabricacion_tiempo_promedio INT,
	CONSTRAINT FK_Fact_Table_Fabricacion_fecha FOREIGN KEY (id_fecha) REFERENCES BI_Fecha,
	CONSTRAINT FK_Fact_Table_Fabricacion_Sucursal FOREIGN KEY (id_sucursal) REFERENCES BI_Sucursal,
)
GO

--------------------------------- CARGA DIMENSIONES ------------------------------------------------

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

INSERT INTO BI_Turno (
	turno_minimo_horas,
	turno_minimo_minutos,
	turno_maximo_horas,
	turno_maximo_minutos,
	turno_rango
)
VALUES (8, 0, 14, 0, '08:00 - 14:00'),
	   (14, 0, 20, 0, '14:00 - 20:00')
	   
INSERT INTO BI_Localidad (
	localidad_nombre,
	localidad_provincia
)
SELECT l.Localidad_Nombre,
	   p.Provincia_Nombre
FROM DROP_DATABASE.Localidad l
JOIN DROP_DATABASE.Provincia p on l.Localidad_Provincia = p.Provincia_ID

INSERT INTO BI_Estado (
	estado_nombre
)
SELECT DISTINCT Pedido_Estado
FROM DROP_DATABASE.Pedido

GO

--------------------------------- CARGA HECHOS ------------------------------------------------
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
	compra_numero,
	compra_cantidad,
	compra_precio,
	compra_total
)
SELECT fecha_id,
       Compra_Sucursal,
	   mb.material_id,
	   Compra_Numero,
	   Detalle_Compra_Cantidad,
	   Detalle_Compra_Precio,
	   Detalle_Compra_Subtotal
FROM DROP_DATABASE.Compra
JOIN DROP_DATABASE.Detalle_Compra ON Detalle_Compra_Compra = Compra_Numero
JOIN DROP_DATABASE.Material m ON Material_ID = Detalle_Compra_Material
JOIN BI_Fecha ON fecha_año = YEAR(Compra_Fecha)
			  AND fecha_mes = MONTH(Compra_Fecha)
JOIN BI_Material mb ON mb.material_nombre = m.Material_Tipo

INSERT INTO BI_Fact_Table_Pedido (
	id_fecha,
    id_turno,
    id_sucursal,
    id_estado,
    pedido_cantidad
)
SELECT fecha_id,
	   turno_id,
	   sucursal_id,
	   estado_id,
	   COUNT(*)
FROM DROP_DATABASE.Pedido
JOIN DROP_DATABASE.Cliente ON Cliente_ID = Pedido_Cliente
JOIN BI_Fecha ON fecha_año = YEAR(Pedido_Fecha)
			  AND fecha_mes = MONTH(Pedido_Fecha)
JOIN BI_Turno ON DATEPART(HOUR, Pedido_fecha) BETWEEN turno_minimo_horas AND turno_maximo_horas
			  AND DATEPART (MINUTE, Pedido_fecha) BETWEEN turno_minimo_minutos AND turno_maximo_minutos
JOIN BI_Sucursal ON BI_Sucursal.sucursal_id = Pedido_Sucursal
JOIN BI_Estado ON estado_nombre = Pedido_Estado
GROUP BY fecha_id,
	     turno_id,
	     sucursal_id,
	     estado_id

INSERT INTO BI_Fact_Table_Envio (
	id_fecha,
	id_localidad,

	envio_numero,
	envio_fecha_entrega,
	envio_fecha_programada,
	envio_total
)
SELECT fecha_BI.fecha_id,
	   localidad_BI.localidad_id, --esto es del cliente
	   e.Envio_Numero,
	   e.Envio_Fecha_Entrega,
	   e.Envio_Fecha_Programada,
	   e.Envio_Importe_Total
FROM DROP_DATABASE.Envio e
JOIN DROP_DATABASE.Factura f on e.Envio_Factura = f.Factura_Numero
JOIN DROP_DATABASE.Cliente c on f.Factura_Cliente = c.Cliente_ID
JOIN DROP_DATABASE.Domicilio d on c.Cliente_Domicilio = d.Domicilio_ID
JOIN DROP_DATABASE.Localidad l on d.Domicilio_Localidad = l.Localidad_ID
JOIN DROP_DATABASE.Provincia p on l.Localidad_Provincia = p.Provincia_ID
JOIN BI_Fecha fecha_BI ON fecha_BI.fecha_año = YEAR(f.Factura_Fecha)
			           AND fecha_BI.fecha_mes = MONTH(f.Factura_Fecha)
JOIN BI_Localidad localidad_BI ON localidad_BI.localidad_nombre = l.Localidad_Nombre
							   AND localidad_BI.localidad_provincia = p.Provincia_Nombre
go

INSERT INTO BI_Fact_Table_Fabricacion (
	id_fecha,
	id_sucursal,
	fabricacion_tiempo_promedio
)
SELECT fecha_id,
	   Pedido_Sucursal,
	   AVG(datediff(day, Pedido_Fecha, Factura_Fecha))
FROM DROP_DATABASE.Pedido
JOIN  DROP_DATABASE.Factura on Factura_Pedido = Pedido_Numero
JOIN BI_Fecha ON YEAR(Pedido_Fecha) = fecha_año
			  AND MONTH(Pedido_Fecha) = fecha_mes
GROUP BY Pedido_Sucursal, fecha_id
GO
--------------------------------- CREACION VISTAS ------------------------------------------------
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

CREATE VIEW Volumen_De_Pedidos
AS
	SELECT 
		fecha_año AS Año,
		fecha_mes AS Mes,		
		sucursal_id AS Sucursal,
		turno_rango AS Turno,
		SUM(pedido_cantidad) AS Volumen_Pedidos
	FROM BI_Fact_Table_Pedido
	JOIN BI_Turno ON turno_id = id_turno
	JOIN BI_Sucursal ON sucursal_id = id_sucursal
	JOIN BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_año, fecha_mes, sucursal_id, turno_rango
GO

CREATE VIEW Conversion_De_Pedidos
AS
	SELECT 
		sucursal_id AS Sucursal,
		fecha_cuatrimestre AS Cuatrimestre,
		(100.0 * SUM(CASE WHEN estado_nombre = 'ENTREGADO' THEN pedido_cantidad ELSE 0 END) / SUM(pedido_cantidad)) AS Porcentaje_Entregados,
		(100.0 * SUM(CASE WHEN estado_nombre = 'CANCELADO' THEN pedido_cantidad ELSE 0 END) / SUM(pedido_cantidad)) AS Porcentaje_Cancelados
	FROM BI_Fact_Table_Pedido
	JOIN BI_Fecha ON fecha_id = id_fecha
	JOIN BI_Sucursal ON sucursal_id = id_sucursal
	JOIN BI_Estado ON estado_id = id_estado
	GROUP BY sucursal_id, fecha_cuatrimestre
	
GO
CREATE VIEW Tiempo_Promedio_De_Fabricacion
AS
	SELECT AVG(fabricacion_tiempo_promedio) AS tiempo_promedio_en_dias,
		   fecha_cuatrimestre AS Cuatrimestre,
		   id_sucursal AS Sucursal
	FROM BI_Fact_Table_Fabricacion
	JOIN BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_cuatrimestre,
			 id_sucursal
GO
CREATE VIEW Promedio_De_Compras
AS
	SELECT SUM(compra_total)/COUNT(DISTINCT compra_numero) AS promedio_compra_mensual,
		   fecha_mes AS mes
	FROM BI_Fact_Table_Compra
	JOIN BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_mes
GO
CREATE VIEW Compra_Por_Tipo_De_Material
AS
	SELECT SUM(compra_total) AS importe_total_gastado,
		   material_nombre AS Material,
		   sucursal_id AS Sucursal,
		   fecha_cuatrimestre AS Cuatrimestre
	FROM BI_Fact_Table_Compra
	JOIN BI_Material ON material_id = id_material
	JOIN BI_Fecha ON fecha_id = id_fecha
	JOIN BI_Sucursal ON sucursal_id = id_sucursal
	GROUP BY material_nombre,
			 sucursal_id,
			 fecha_cuatrimestre
GO

CREATE VIEW PORCENTAJE_CUMPLIMIENTO_ENVIOS
AS
	SELECT 100.0 * (sum(case when envio_fecha_entrega = envio_fecha_programada then 1.0 else 0.0 end) / count(*)) porcentaje, fecha_mes
	FROM BI_Fact_Table_Envio
	JOIN BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_mes
GO

CREATE VIEW LOCALIDADES_CON_MAYOR_COSTO_ENVIO
AS
	SELECT TOP 3 localidad_nombre, localidad_provincia
	FROM BI_Fact_Table_Envio
	JOIN BI_Localidad ON localidad_id = id_localidad
	GROUP BY localidad_id, localidad_nombre, localidad_provincia
	ORDER BY AVG(envio_total) DESC
GO