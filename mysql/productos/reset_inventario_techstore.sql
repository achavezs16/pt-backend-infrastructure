-- Limpiar y cargar inventario para TechStore SPA
USE ms_pedidos;

-- Limpiar inventario existente
DELETE FROM inventario;

-- Resetear auto_increment
ALTER TABLE inventario AUTO_INCREMENT = 1;

-- Insertar inventario para los 20 productos de TechStore (IDs 2-21)
-- Stock disponible: 4-6 unidades por producto (tamaño medio)
-- Stock reservado: 0 unidades inicialmente

INSERT INTO inventario (producto_id, stock_disponible, stock_reservado) VALUES
-- Smartphones (stock 4-6 unidades)
(2, 5, 0), -- iPhone 15 Pro
(3, 4, 0), -- Samsung Galaxy S24 Ultra  
(4, 6, 0), -- Google Pixel 8 Pro
(5, 5, 0), -- OnePlus 12
(6, 4, 0), -- Xiaomi 14 Pro

-- Notebooks (stock 4-6 unidades)
(7, 5, 0), -- MacBook Air M2
(8, 4, 0), -- Lenovo ThinkPad E14
(9, 6, 0), -- Dell XPS 13
(10, 5, 0), -- HP Spectre x360
(11, 4, 0), -- ASUS ZenBook 14

-- Computadores Desktop (stock 4-6 unidades)
(12, 4, 0), -- iMac 24" M1
(13, 5, 0), -- Gaming Desktop RTX 4060
(14, 6, 0), -- Mac Studio M2
(15, 4, 0), -- Dell OptiPlex
(16, 5, 0), -- HP EliteDesk

-- Accesorios (stock 4-6 unidades)
(17, 6, 0), -- Magic Mouse
(18, 5, 0), -- Mechanical Keyboard RGB
(19, 4, 0), -- AirPods Pro 2
(20, 6, 0), -- Monitor 27" 4K
(21, 5, 0); -- USB-C Hub 7-in-1

-- Verificar resultados
SELECT COUNT(*) as total_inventario FROM inventario;
SELECT SUM(stock_disponible) as total_stock_disponible FROM inventario;
