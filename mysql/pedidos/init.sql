-- Inicialización de base de datos ms-pedidos
-- Este archivo se ejecuta automáticamente cuando el contenedor MySQL se inicia por primera vez

USE ms_pedidos;

-- Ejecutar el esquema principal
-- El esquema completo está en backend/ms-pedidos/database/schema.sql

-- Insertar datos de ejemplo para desarrollo
INSERT INTO pyme (nombre, rut, email, telefono, direccion, comuna, region) VALUES
('TechStore SPA', '76.123.456-7', 'contacto@techstore.cl', '+56912345678', 'Av. Providencia 1234', 'Providencia', 'Metropolitana'),
('ModaExpress Ltda', '77.876.543-2', 'ventas@modaexpress.cl', '+56987654321', 'Calle Ahumada 567', 'Santiago', 'Metropolitana'),
('ElectroWorld SA', '78.234.567-8', 'contacto@electroworld.cl', '+56998765432', 'Av. Kennedy 890', 'Las Condes', 'Metropolitana');

INSERT INTO producto (pyme_id, sku, nombre, descripcion, precio, peso_kg, dimensiones) VALUES
(1, 'TECH001', 'Laptop Gaming Pro', 'Laptop de alto rendimiento para gaming', 899990, 2.5, '35 x 25 x 3 cm'),
(1, 'TECH002', 'Mouse Inalámbrico', 'Mouse ergonómico recargable', 49990, 0.15, '12 x 7 x 4 cm'),
(1, 'TECH003', 'Teclado Mecánico', 'Teclado RGB mecánico', 79990, 1.2, '45 x 15 x 4 cm'),
(2, 'MODA001', 'Jeans Classic', 'Jeans de corte clásico', 39990, 0.8, 'talla 32'),
(2, 'MODA002', 'Polera Algodón', 'Polera de algodón orgánico', 19990, 0.3, 'talla L'),
(2, 'MODA003', 'Chaqueta Cuero', 'Chaqueta de cuero genuino', 129990, 1.5, 'talla M'),
(3, 'ELEC001', 'Smartphone Pro', 'Teléfono de última generación', 699990, 0.2, '15 x 7 x 0.8 cm'),
(3, 'ELEC002', 'Auriculares Bluetooth', 'Auriculares con cancelación de ruido', 89990, 0.3, '18 x 15 x 8 cm');

INSERT INTO inventario (producto_id, stock_disponible, stock_reservado) VALUES
(1, 10, 0),
(2, 25, 0),
(3, 15, 0),
(4, 20, 0),
(5, 30, 0),
(6, 12, 0),
(7, 8, 0),
(8, 18, 0);

-- Insertar algunos pedidos de ejemplo para pruebas
INSERT INTO pedido (pyme_id, numero_orden, cliente_nombre, cliente_email, cliente_telefono, direccion_entrega, comuna_entrega, region_entrega, estado_pedido, total, etiqueta_despacho) VALUES
(1, 'ORD20240101001', 'Ana María Silva', 'ana.silva@email.com', '+56912345678', 'Calle Los Andes 1234', 'Providencia', 'Metropolitana', 'PENDIENTE', 979970, 'PYM-001-001'),
(2, 'ORD20240101002', 'Carlos González', 'carlos.gonzalez@email.com', '+56987654321', 'Av. Las Condes 567', 'Las Condes', 'Metropolitana', 'PREPARACION', 159980, 'PYM-002-002'),
(3, 'ORD20240101003', 'María Rodríguez', 'maria.rodriguez@email.com', '+56911223344', 'Calle Ahumada 890', 'Santiago', 'Metropolitana', 'DESPACHADO', 789970, 'PYM-003-003');

-- Insertar detalles de los pedidos
INSERT INTO pedido_detalle (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 899990),
(1, 2, 1, 49990),
(1, 3, 1, 79990),
(2, 4, 2, 39990),
(2, 5, 4, 19990),
(3, 7, 1, 699990),
(3, 8, 1, 89990);
