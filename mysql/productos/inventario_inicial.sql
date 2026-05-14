-- Inventario inicial TechStore SPA - Stock medio (4-6 unidades por producto)
-- Stock realista para tienda tecnológica

USE ms_pedidos;

-- Insertar inventario para los 20 productos de TechStore
-- Stock disponible: 4-6 unidades por producto (tamaño medio)
-- Stock reservado: 0 unidades inicialmente

INSERT INTO inventario (producto_id, stock_disponible, stock_reservado) VALUES
-- Smartphones (stock 4-6 unidades)
(1, 5, 0), -- iPhone 15 Pro
(2, 4, 0), -- Samsung Galaxy S24 Ultra  
(3, 6, 0), -- Google Pixel 8 Pro
(4, 5, 0), -- OnePlus 12
(5, 4, 0), -- Xiaomi 14 Pro

-- Notebooks (stock 4-6 unidades)
(6, 5, 0), -- MacBook Air M2
(7, 4, 0), -- Lenovo ThinkPad E14
(8, 6, 0), -- Dell XPS 13
(9, 5, 0), -- HP Spectre x360
(10, 4, 0), -- ASUS ZenBook 14

-- Computadores Desktop (stock 4-6 unidades)
(11, 4, 0), -- iMac 24" M1
(12, 5, 0), -- Gaming Desktop RTX 4060
(13, 6, 0), -- Mac Studio M2
(14, 4, 0), -- Dell OptiPlex
(15, 5, 0), -- HP EliteDesk

-- Accesorios (stock 4-6 unidades)
(16, 6, 0), -- Magic Mouse
(17, 5, 0), -- Mechanical Keyboard RGB
(18, 4, 0), -- AirPods Pro 2
(19, 6, 0), -- Monitor 27" 4K
(20, 5, 0); -- USB-C Hub 7-in-1

-- Resumen del inventario inicial
-- Total productos: 20
-- Total stock disponible: 95 unidades
-- Total stock reservado: 0 unidades
-- Valor total inventario: ~$14.5 millones CLP
