SELECT Pedido_Numero, Detalle_Pedido_SubTotal, Sillon_Codigo, Factura_Numero, Detalle_Factura_SubTotal
FROM gd_esquema.Maestra
WHERE Pedido_Numero IS NOT NULL
ORDER BY Pedido_Numero, Detalle_Pedido_SubTotal