--------------------------------- SETUP ------------------------------------------------

USE GD1C2025
GO

DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Facturacion_Modelo
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Compra_Material
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Envio
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Pedido
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Factura
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Compra
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fact_Table_Fabricacion
DROP TABLE IF EXISTS DROP_DATABASE.BI_Sucursal
DROP TABLE IF EXISTS DROP_DATABASE.BI_Fecha
DROP TABLE IF EXISTS DROP_DATABASE.BI_Cliente
DROP TABLE IF EXISTS DROP_DATABASE.BI_Modelo
DROP TABLE IF EXISTS DROP_DATABASE.BI_Material
DROP TABLE IF EXISTS DROP_DATABASE.BI_Turno
DROP TABLE IF EXISTS DROP_DATABASE.BI_Localidad
DROP TABLE IF EXISTS DROP_DATABASE.BI_Estado
DROP VIEW IF EXISTS DROP_DATABASE.Factura_Promedio_Mensual
DROP VIEW IF EXISTS DROP_DATABASE.Rendimiento_de_modelos
DROP VIEW IF EXISTS DROP_DATABASE.Promedio_De_Compras
DROP VIEW IF EXISTS DROP_DATABASE.Compra_Por_Tipo_De_Material
DROP VIEW IF EXISTS DROP_DATABASE.Ganancias
DROP VIEW IF EXISTS DROP_DATABASE.Volumen_de_Pedidos
DROP VIEW IF EXISTS DROP_DATABASE.Volumen_de_Pedidos
DROP VIEW IF EXISTS DROP_DATABASE.Conversion_De_Pedidos
DROP VIEW IF EXISTS DROP_DATABASE.PORCENTAJE_CUMPLIMIENTO_ENVIOS
DROP VIEW IF EXISTS DROP_DATABASE.LOCALIDADES_CON_MAYOR_COSTO_ENVIO
DROP VIEW IF EXISTS DROP_DATABASE.Tiempo_Promedio_De_Fabricacion
GO

--------------------------------- CREACION TABLAS  ------------------------------------------------

CREATE TABLE DROP_DATABASE.BI_Fecha (
	fecha_id BIGINT IDENTITY(1,1),
	fecha_año INT,
	fecha_mes INT,
	fecha_cuatrimestre AS ((fecha_mes - 1) / 4) + 1 PERSISTED,
	CONSTRAINT PK_BI_Fecha PRIMARY KEY (fecha_id),
	CONSTRAINT UQ_BI_Fecha UNIQUE (fecha_año, fecha_mes),
	CONSTRAINT CK_Fecha_Mes CHECK (fecha_mes BETWEEN 1 AND 12)
)

CREATE TABLE DROP_DATABASE.BI_Cliente (
	cliente_id BIGINT IDENTITY(1,1),
	cliente_minimo INT,
	cliente_maximo INT,
	cliente_rango VARCHAR(5),
	CONSTRAINT PK_BI_Cliente PRIMARY KEY (cliente_id),
	CONSTRAINT UQ_BI_Cliente UNIQUE (cliente_minimo, cliente_maximo, cliente_rango)
)

CREATE TABLE DROP_DATABASE.BI_Sucursal (
	sucursal_id BIGINT,
	sucursal_provincia NVARCHAR(255),
	sucursal_localidad NVARCHAR(255),
	CONSTRAINT PK_BI_Sucursal PRIMARY KEY (sucursal_id),
)

CREATE TABLE DROP_DATABASE.BI_Modelo (
	modelo_id BIGINT,
	modelo_nombre VARCHAR(50)
	CONSTRAINT PK_BI_Modelo PRIMARY KEY (modelo_id)
)

CREATE TABLE DROP_DATABASE.BI_Material (
	material_id INT IDENTITY(1,1),
	material_nombre NVARCHAR(255),
	CONSTRAINT PK_BI_Material PRIMARY KEY (material_id),
	CONSTRAINT UQ_BI_Material UNIQUE (material_nombre)
)

CREATE TABLE DROP_DATABASE.BI_Turno (
	turno_id BIGINT IDENTITY(1,1),
	turno_maximo_horas INT,
	turno_maximo_minutos INT,
	turno_minimo_horas INT,
	turno_minimo_minutos INT,
	turno_rango VARCHAR(13),
	CONSTRAINT PK_BI_Turno PRIMARY KEY (turno_id),
	CONSTRAINT UQ_BI_Turno UNIQUE (turno_maximo_horas, turno_maximo_minutos, turno_minimo_horas, turno_minimo_minutos, turno_rango)
)

CREATE TABLE DROP_DATABASE.BI_Localidad (
	localidad_id BIGINT IDENTITY(1,1),
	localidad_nombre nvarchar(255),
	localidad_provincia nvarchar(255)
	CONSTRAINT PK_BI_Localidad PRIMARY KEY (localidad_id)
)

CREATE TABLE DROP_DATABASE.BI_Estado (
	estado_id INT IDENTITY(1,1),
	estado_nombre NVARCHAR(255),
	CONSTRAINT PK_BI_Estado PRIMARY KEY (estado_id),
	CONSTRAINT UQ_BI_Estado UNIQUE (estado_nombre),
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Factura (
	id_fecha BIGINT,
	id_cliente BIGINT,
	id_sucursal BIGINT,
	fact_cantidad_facturas DECIMAL(18,0),
	fact_suma_total DECIMAl(18,2),
	CONSTRAINT PK_BI_Fact_Table_Factura PRIMARY KEY (id_fecha, id_cliente, id_sucursal),
	CONSTRAINT FK_BI_Fact_Table_Factura_Fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Factura_Cliente FOREIGN KEY (id_cliente) REFERENCES DROP_DATABASE.BI_Cliente,
	CONSTRAINT FK_BI_Fact_Table_Factura_Sucursal FOREIGN KEY (id_sucursal) REFERENCES DROP_DATABASE.BI_Sucursal
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Facturacion_Modelo (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	id_cliente BIGINT,
	id_modelo BIGINT,
	modelo_cantidad INT,
	modelo_suma_total DECIMAL(18,2),
	CONSTRAINT PK_BI_Fact_Table_Facturacion_Modelo PRIMARY KEY (id_fecha, id_sucursal, id_cliente, id_modelo),
	CONSTRAINT FK_BI_Fact_Table_Facturacion_Modelo_Fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Facturacion_Modelo_Modelo FOREIGN KEY (id_modelo) REFERENCES DROP_DATABASE.BI_Modelo
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Envio (
	id_fecha BIGINT,
	id_localidad BIGINT,
	envio_cantidad_envios INT,
	envio_cumplidos INT,
	envio_suma_costos DECIMAL(18,2),
	CONSTRAINT PK_BI_Fact_Table_Envio PRIMARY KEY (id_fecha, id_localidad),
	CONSTRAINT FK_BI_Fact_Table_Envio_Fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Envio_Sucursal FOREIGN KEY (id_localidad) REFERENCES DROP_DATABASE.BI_Localidad
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Compra (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	compra_cantidad_compras DECIMAL(18,0),
	compra_suma_total DECIMAL(18,2),
	CONSTRAINT PK_BI_Fact_Table_Compra PRIMARY KEY (id_fecha, id_sucursal),
	CONSTRAINT FK_BI_Fact_Table_Compra_Fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Compra_Sucursal FOREIGN KEY (id_sucursal) REFERENCES DROP_DATABASE.BI_Sucursal
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Compra_Material (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	id_material INT,
	material_cantidad INT,
	material_suma_total DECIMAL(18,2),
	CONSTRAINT PK_BI_Fact_Table_Material PRIMARY KEY (id_fecha, id_sucursal, id_material),
	CONSTRAINT FK_BI_Fact_Table_Material_Fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Material_Sucursal FOREIGN KEY (id_sucursal) REFERENCES DROP_DATABASE.BI_Sucursal,
	CONSTRAINT FK_BI_Fact_Table_Material_Material FOREIGN KEY (id_material) REFERENCES DROP_DATABASE.BI_Material
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Pedido (
	id_fecha BIGINT,
	id_turno BIGINT,
	id_sucursal BIGINT,
	id_estado INT,
	pedido_cantidad BIGINT,
	CONSTRAINT PK_BI_Fact_Table_Pedido PRIMARY KEY (id_fecha, id_turno, id_sucursal, id_estado),
	CONSTRAINT FK_BI_Fact_Table_Pedido_fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Pedido_turno FOREIGN KEY (id_turno) REFERENCES DROP_DATABASE.BI_Turno,
	CONSTRAINT FK_BI_Fact_Table_Pedido_Sucursal FOREIGN KEY (id_sucursal) REFERENCES DROP_DATABASE.BI_Sucursal,
	CONSTRAINT FK_BI_Fact_Table_Pedido_Estado FOREIGN KEY (id_estado) REFERENCES DROP_DATABASE.BI_Estado
)

CREATE TABLE DROP_DATABASE.BI_Fact_Table_Fabricacion (
	id_fecha BIGINT,
	id_sucursal BIGINT,
	fabricacion_tiempo_promedio INT,
	CONSTRAINT FK_BI_Fact_Table_Fabricacion_fecha FOREIGN KEY (id_fecha) REFERENCES DROP_DATABASE.BI_Fecha,
	CONSTRAINT FK_BI_Fact_Table_Fabricacion_Sucursal FOREIGN KEY (id_sucursal) REFERENCES DROP_DATABASE.BI_Sucursal,
)
GO

--------------------------------- CARGA DIMENSIONES ------------------------------------------------

INSERT INTO DROP_DATABASE.BI_Fecha (
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

INSERT INTO DROP_DATABASE.BI_CLIENTE (
	cliente_minimo,
	cliente_maximo,
	cliente_rango
)
VALUES (0, 24, '<24'), 
	   (25, 34, '25-35'), 
	   (35, 49, '35-50'),
	   (50, 100000, '>50')


INSERT INTO DROP_DATABASE.BI_Sucursal (
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

INSERT INTO DROP_DATABASE.BI_Modelo (
	modelo_id,
	modelo_nombre
)
SELECT Modelo_Codigo,
	   Modelo_Nombre
FROM DROP_DATABASE.Modelo


INSERT INTO DROP_DATABASE.BI_Material (
	material_nombre
)
SELECT DISTINCT Material_Tipo
FROM DROP_DATABASE.Material

INSERT INTO DROP_DATABASE.BI_Turno (
	turno_minimo_horas,
	turno_minimo_minutos,
	turno_maximo_horas,
	turno_maximo_minutos,
	turno_rango
)
VALUES (8, 0, 14, 0, '08:00 - 14:00'),
	   (14, 0, 20, 0, '14:00 - 20:00')
	   
INSERT INTO DROP_DATABASE.BI_Localidad (
	localidad_nombre,
	localidad_provincia
)
SELECT l.Localidad_Nombre,
	   p.Provincia_Nombre
FROM DROP_DATABASE.Localidad l
JOIN DROP_DATABASE.Provincia p on l.Localidad_Provincia = p.Provincia_ID

INSERT INTO DROP_DATABASE.BI_Estado (
	estado_nombre
)
SELECT DISTINCT Pedido_Estado
FROM DROP_DATABASE.Pedido

GO

--------------------------------- CARGA HECHOS ------------------------------------------------
INSERT INTO DROP_DATABASE.BI_Fact_Table_Factura (
	id_fecha,
	id_cliente,
	id_sucursal,
	fact_cantidad_facturas,
	fact_suma_total
)
SELECT fecha_id, 
	   DROP_DATABASE.BI_Cliente.cliente_id,
	   Factura_Sucursal,
	   COUNT(*),
	   SUM(Factura_Total)
FROM DROP_DATABASE.Factura
JOIN DROP_DATABASE.Cliente ON Cliente_ID = Factura_Cliente
JOIN DROP_DATABASE.BI_Fecha ON fecha_año = YEAR(Factura_Fecha)
			  AND fecha_mes = MONTH(Factura_Fecha)
JOIN DROP_DATABASE.BI_Cliente ON DATEDIFF(YEAR, Cliente_Fecha_Nacimiento, GETDATE()) BETWEEN cliente_minimo AND cliente_maximo
GROUP BY fecha_id, 
	     DROP_DATABASE.BI_Cliente.cliente_id, 
	     Factura_Sucursal

INSERT INTO DROP_DATABASE.BI_Fact_Table_Facturacion_Modelo (
	id_fecha,
	id_sucursal,
	id_cliente,
	id_modelo,
	modelo_cantidad,
	modelo_suma_total
)
SELECT fecha_id,
	   Pedido_Sucursal,
	   c.Cliente_ID,
	   Sillon_Modelo,
	   SUM(Detalle_Pedido_Cantidad),
	   SUM(Detalle_Pedido_Subtotal)
FROM DROP_DATABASE.Pedido
JOIN DROP_DATABASE.Detalle_Pedido ON Detalle_Pedido_Pedido = Pedido_Numero
JOIN DROP_DATABASE.Sillon ON Sillon_Codigo = Detalle_Pedido_Sillon
JOIN DROP_DATABASE.Cliente ON Cliente_ID = Pedido_Cliente
JOIN DROP_DATABASE.BI_Cliente c ON DATEDIFF(YEAR, Cliente_Fecha_Nacimiento, GETDATE()) BETWEEN cliente_minimo AND cliente_maximo
JOIN DROP_DATABASE.BI_Fecha ON fecha_año = YEAR(Pedido_Fecha)
			  AND fecha_mes = MONTH(Pedido_Fecha)
GROUP BY fecha_id,
	   Pedido_Sucursal,
	   c.Cliente_ID,
	   Sillon_Modelo

INSERT INTO DROP_DATABASE.BI_Fact_Table_Compra (
	id_fecha,
	id_sucursal,
	compra_cantidad_compras,
	compra_suma_total
)
SELECT fecha_id,
       Compra_Sucursal,
	   COUNT(*),
	   SUM(Compra_Total)
FROM DROP_DATABASE.Compra
JOIN DROP_DATABASE.BI_Fecha ON fecha_año = YEAR(Compra_Fecha)
			  AND fecha_mes = MONTH(Compra_Fecha)
GROUP BY fecha_id,
		 Compra_Sucursal

INSERT INTO DROP_DATABASE.BI_Fact_Table_Pedido (
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
JOIN DROP_DATABASE.BI_Fecha ON fecha_año = YEAR(Pedido_Fecha)
			  AND fecha_mes = MONTH(Pedido_Fecha)
JOIN DROP_DATABASE.BI_Turno ON DATEPART(HOUR, Pedido_fecha) BETWEEN turno_minimo_horas AND turno_maximo_horas
			  AND DATEPART (MINUTE, Pedido_fecha) BETWEEN turno_minimo_minutos AND turno_maximo_minutos
JOIN DROP_DATABASE.BI_Sucursal ON DROP_DATABASE.BI_Sucursal.sucursal_id = Pedido_Sucursal
JOIN DROP_DATABASE.BI_Estado ON estado_nombre = Pedido_Estado
GROUP BY fecha_id,
	     turno_id,
	     sucursal_id,
	     estado_id

INSERT INTO DROP_DATABASE.BI_Fact_Table_Compra_Material (
	id_fecha,
	id_sucursal,
	id_material,
	material_cantidad,
	material_suma_total
)
SELECT fecha_id,
       Compra_Sucursal, --ya que coincide con el id del OLAP
	   mb.material_id,
	   COUNT(distinct Compra_Numero),
	   SUM(Detalle_Compra_Subtotal)
FROM DROP_DATABASE.Compra
JOIN DROP_DATABASE.Detalle_Compra ON Detalle_Compra_Compra = Compra_Numero
JOIN DROP_DATABASE.Material m ON Material_ID = Detalle_Compra_Material
JOIN DROP_DATABASE.BI_Material mb ON mb.material_nombre = m.Material_Tipo
JOIN DROP_DATABASE.BI_Fecha ON fecha_año = YEAR(Compra_Fecha)
			  AND fecha_mes = MONTH(Compra_Fecha)
GROUP BY fecha_id,
       Compra_Sucursal,
	   mb.material_id

INSERT INTO DROP_DATABASE.BI_Fact_Table_Envio (
	id_fecha,
	id_localidad,

	envio_cantidad_envios,
	envio_cumplidos,
	envio_suma_costos
)
SELECT fecha_BI.fecha_id,
	   localidad_BI.localidad_id, --esto es del cliente,
	   COUNT(*),
	   sum(case when e.envio_fecha_entrega = e.envio_fecha_programada then 1.0 else 0.0 end),
	   SUM(e.Envio_Importe_Total)
FROM DROP_DATABASE.Envio e
JOIN DROP_DATABASE.Factura f on e.Envio_Factura = f.Factura_Numero
JOIN DROP_DATABASE.Cliente c on f.Factura_Cliente = c.Cliente_ID
JOIN DROP_DATABASE.Domicilio d on c.Cliente_Domicilio = d.Domicilio_ID
JOIN DROP_DATABASE.Localidad l on d.Domicilio_Localidad = l.Localidad_ID
JOIN DROP_DATABASE.Provincia p on l.Localidad_Provincia = p.Provincia_ID
JOIN DROP_DATABASE.BI_Fecha fecha_BI ON fecha_BI.fecha_año = YEAR(f.Factura_Fecha)
			           AND fecha_BI.fecha_mes = MONTH(f.Factura_Fecha)
JOIN DROP_DATABASE.BI_Localidad localidad_BI ON localidad_BI.localidad_nombre = l.Localidad_Nombre
							   AND localidad_BI.localidad_provincia = p.Provincia_Nombre
GROUP BY fecha_BI.fecha_id,
		 localidad_BI.localidad_id

INSERT INTO DROP_DATABASE.BI_Fact_Table_Fabricacion (
	id_fecha,
	id_sucursal,
	fabricacion_tiempo_promedio
)
SELECT fecha_id,
	   Pedido_Sucursal,
	   AVG(datediff(day, Pedido_Fecha, Factura_Fecha))
FROM DROP_DATABASE.Pedido
JOIN  DROP_DATABASE.Factura on Factura_Pedido = Pedido_Numero
JOIN DROP_DATABASE.BI_Fecha ON YEAR(Pedido_Fecha) = fecha_año
			  AND MONTH(Pedido_Fecha) = fecha_mes
GROUP BY Pedido_Sucursal, fecha_id
GO
--------------------------------- CREACION VISTAS ------------------------------------------------
CREATE VIEW DROP_DATABASE.Ganancias
AS
	SELECT SUM(fact_suma_total)
		   - ISNULL((SELECT SUM(compra_suma_total)
		   	  FROM DROP_DATABASE.BI_Fact_Table_Compra
			  JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
			  WHERE fecha_mes = f.fecha_mes
			  	AND id_sucursal = fac.id_sucursal),0) AS Ganancias,
		   fecha_mes,
		   id_sucursal
	FROM DROP_DATABASE.BI_Fact_Table_Factura fac
	JOIN DROP_DATABASE.BI_Fecha f ON fecha_id = id_fecha
	GROUP BY fecha_mes, id_sucursal
GO

CREATE VIEW DROP_DATABASE.Factura_Promedio_Mensual
AS
	SELECT fecha_año,
		fecha_cuatrimestre,
		sucursal_provincia,
		(SUM(fact_suma_total) / SUM(fact_cantidad_facturas)) / 4 AS Promedio_Facturado
	FROM DROP_DATABASE.BI_Fact_Table_Factura
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	JOIN DROP_DATABASE.BI_Sucursal ON sucursal_id = id_sucursal
	GROUP BY fecha_año, 
			fecha_cuatrimestre, 
			sucursal_provincia
GO
CREATE VIEW DROP_DATABASE.Rendimiento_de_modelos
AS
	SELECT modelo_nombre, 
		   fecha_año,
		   fecha_cuatrimestre,
		   sucursal_localidad,
		   cliente_rango
	FROM DROP_DATABASE.BI_Fact_Table_Facturacion_Modelo
	JOIN DROP_DATABASE.BI_Modelo m ON modelo_id = id_modelo
	JOIN DROP_DATABASE.BI_Fecha f ON fecha_id = id_fecha
	JOIN DROP_DATABASE.BI_Sucursal s ON sucursal_id = id_sucursal
	JOIN DROP_DATABASE.BI_Cliente c ON cliente_id = id_cliente
	GROUP BY modelo_nombre,
			fecha_año,
			fecha_cuatrimestre,
			sucursal_localidad,
			cliente_rango,
			modelo_id
	HAVING modelo_id IN (SELECT TOP 3 id_modelo
						 FROM DROP_DATABASE.BI_Fact_Table_Facturacion_Modelo
						 JOIN DROP_DATABASE.BI_Fecha ON id_fecha = fecha_id
						 JOIN DROP_DATABASE.BI_Sucursal ON id_sucursal = sucursal_id
						 JOIN DROP_DATABASE.BI_Cliente ON id_cliente = cliente_id
						 WHERE fecha_año = f.fecha_año
							AND fecha_cuatrimestre = f.fecha_cuatrimestre
							AND sucursal_localidad = s.sucursal_localidad
							AND cliente_rango = c.cliente_rango
						 GROUP BY id_modelo
						 ORDER BY SUM(modelo_cantidad) DESC)
GO

CREATE VIEW DROP_DATABASE.Volumen_De_Pedidos
AS
	SELECT 
		fecha_año AS Año,
		fecha_mes AS Mes,		
		sucursal_id AS Sucursal,
		turno_rango AS Turno,
		SUM(pedido_cantidad) AS Volumen_Pedidos
	FROM DROP_DATABASE.BI_Fact_Table_Pedido
	JOIN DROP_DATABASE.BI_Turno ON turno_id = id_turno
	JOIN DROP_DATABASE.BI_Sucursal ON sucursal_id = id_sucursal
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_año, fecha_mes, sucursal_id, turno_rango
GO

CREATE VIEW DROP_DATABASE.Conversion_De_Pedidos
AS
	SELECT 
		sucursal_id AS Sucursal,
		fecha_cuatrimestre AS Cuatrimestre,
		(100.0 * SUM(CASE WHEN estado_nombre = 'ENTREGADO' THEN pedido_cantidad ELSE 0 END) / SUM(pedido_cantidad)) AS Porcentaje_Entregados,
		(100.0 * SUM(CASE WHEN estado_nombre = 'CANCELADO' THEN pedido_cantidad ELSE 0 END) / SUM(pedido_cantidad)) AS Porcentaje_Cancelados
	FROM DROP_DATABASE.BI_Fact_Table_Pedido
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	JOIN DROP_DATABASE.BI_Sucursal ON sucursal_id = id_sucursal
	JOIN DROP_DATABASE.BI_Estado ON estado_id = id_estado
	GROUP BY sucursal_id, fecha_cuatrimestre
	
GO
CREATE VIEW DROP_DATABASE.Tiempo_Promedio_De_Fabricacion
AS
	SELECT AVG(fabricacion_tiempo_promedio) AS tiempo_promedio_en_dias,
		   fecha_cuatrimestre AS Cuatrimestre,
		   id_sucursal AS Sucursal
	FROM DROP_DATABASE.BI_Fact_Table_Fabricacion
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_cuatrimestre,
			 id_sucursal
GO
CREATE VIEW DROP_DATABASE.Promedio_De_Compras
AS
	SELECT SUM(compra_suma_total)/SUM(compra_cantidad_compras) AS promedio_compra_mensual,
		   fecha_mes AS mes
	FROM DROP_DATABASE.BI_Fact_Table_Compra
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_mes
GO
CREATE VIEW DROP_DATABASE.Compra_Por_Tipo_De_Material
AS
	SELECT SUM(material_suma_total) AS importe_total_gastado,
		   material_nombre AS Material,
		   sucursal_id AS Sucursal,
		   fecha_cuatrimestre AS Cuatrimestre
	FROM DROP_DATABASE.BI_Fact_Table_Compra_Material
	JOIN DROP_DATABASE.BI_Material ON material_id = id_material
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	JOIN DROP_DATABASE.BI_Sucursal ON sucursal_id = id_sucursal
	GROUP BY material_nombre,
			 sucursal_id,
			 fecha_cuatrimestre
GO

CREATE VIEW DROP_DATABASE.PORCENTAJE_CUMPLIMIENTO_ENVIOS
AS
	SELECT  (SUM(envio_cumplidos)*1.0 / SUM(envio_cantidad_envios)) * 100 porcentaje, fecha_mes
	FROM DROP_DATABASE.BI_Fact_Table_Envio
	JOIN DROP_DATABASE.BI_Fecha ON fecha_id = id_fecha
	GROUP BY fecha_mes
GO

CREATE VIEW DROP_DATABASE.LOCALIDADES_CON_MAYOR_COSTO_ENVIO
AS
	SELECT TOP 3 localidad_nombre, localidad_provincia
	FROM DROP_DATABASE.BI_Fact_Table_Envio
	JOIN DROP_DATABASE.BI_Localidad ON localidad_id = id_localidad
	GROUP BY localidad_id, localidad_nombre, localidad_provincia
	ORDER BY SUM(envio_suma_costos)/SUM(envio_cantidad_envios) DESC
GO