-- Base de datos para MS-Pedidos
-- Gestión transaccional de pedidos e inventario (ACID)

CREATE DATABASE IF NOT EXISTS ms_pedidos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ms_pedidos;

-- Tabla de PYMEs (clientes del sistema)
CREATE TABLE pyme (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rut VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    comuna VARCHAR(50),
    region VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Productos
CREATE TABLE producto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pyme_id BIGINT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    peso_kg DECIMAL(8,3),
    dimensiones VARCHAR(50), -- Formato: "largo x ancho x alto cm"
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pyme_id) REFERENCES pyme(id),
    UNIQUE KEY unique_sku_pyme (pyme_id, sku)
);

-- Tabla de Inventario (stock por producto)
CREATE TABLE inventario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    stock_disponible INT NOT NULL DEFAULT 0,
    stock_reservado INT NOT NULL DEFAULT 0,
    stock_total INT GENERATED ALWAYS AS (stock_disponible + stock_reservado) STORED,
    ultimo_actualizado TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    UNIQUE KEY unique_producto (producto_id),
    CHECK (stock_disponible >= 0),
    CHECK (stock_reservado >= 0)
);

-- Tabla de Pedidos
CREATE TABLE pedido (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pyme_id BIGINT NOT NULL,
    numero_orden VARCHAR(50) UNIQUE NOT NULL,
    cliente_nombre VARCHAR(100) NOT NULL,
    cliente_email VARCHAR(100) NOT NULL,
    cliente_telefono VARCHAR(20),
    direccion_entrega TEXT NOT NULL,
    comuna_entrega VARCHAR(50) NOT NULL,
    region_entrega VARCHAR(50) NOT NULL,
    coordenadas_entrega POINT, -- Para geolocalización
    estado_pedido ENUM('PENDIENTE', 'CONFIRMADO', 'PREPARACION', 'CANCELADO') DEFAULT 'PENDIENTE',
    subtotal DECIMAL(10,2) NOT NULL,
    costo_envio DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    etiqueta_despacho VARCHAR(100) UNIQUE, -- Código QR o alfanumérico
    notas TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pyme_id) REFERENCES pyme(id),
    INDEX idx_estado_pedido (estado_pedido),
    INDEX idx_pyme_estado (pyme_id, estado_pedido),
    INDEX idx_numero_orden (numero_orden)
);

-- Tabla de Detalles de Pedido
CREATE TABLE pedido_detalle (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedido(id),
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    INDEX idx_pedido (pedido_id),
    INDEX idx_producto (producto_id)
);

-- Tabla de Movimientos de Inventario (para auditoría)
CREATE TABLE movimiento_inventario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'RESERVA', 'LIBERACION') NOT NULL,
    cantidad INT NOT NULL,
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    referencia_id BIGINT, -- ID del pedido o movimiento relacionado
    referencia_tipo VARCHAR(50), -- 'PEDIDO', 'AJUSTE_MANUAL', etc.
    motivo VARCHAR(200),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    INDEX idx_producto_fecha (producto_id, creado_en),
    INDEX idx_referencia (referencia_tipo, referencia_id)
);

-- Trigger para actualizar timestamp de pedidos
DELIMITER //
CREATE TRIGGER before_pedido_update 
BEFORE UPDATE ON pedido
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- Trigger para auditoría de inventario
DELIMITER //
CREATE TRIGGER after_inventario_update
AFTER UPDATE ON inventario
FOR EACH ROW
BEGIN
    IF OLD.stock_disponible != NEW.stock_disponible OR OLD.stock_reservado != NEW.stock_reservado THEN
        INSERT INTO movimiento_inventario (
            producto_id, 
            tipo_movimiento, 
            cantidad, 
            stock_anterior, 
            stock_nuevo,
            referencia_id,
            referencia_tipo,
            motivo
        ) VALUES (
            NEW.producto_id,
            CASE 
                WHEN NEW.stock_disponible < OLD.stock_disponible THEN 'SALIDA'
                WHEN NEW.stock_disponible > OLD.stock_disponible THEN 'ENTRADA'
                WHEN NEW.stock_reservado > OLD.stock_reservado THEN 'RESERVA'
                WHEN NEW.stock_reservado < OLD.stock_reservado THEN 'LIBERACION'
            END,
            ABS(NEW.stock_disponible - OLD.stock_disponible) + ABS(NEW.stock_reservado - OLD.stock_reservado),
            OLD.stock_disponible + OLD.stock_reservado,
            NEW.stock_disponible + NEW.stock_reservado,
            NULL,
            'AJUSTE_AUTOMATICO',
            'Actualización automática de inventario'
        );
    END IF;
END//
DELIMITER ;

-- Datos de ejemplo (opcional - para desarrollo)
INSERT INTO pyme (nombre, rut, email, telefono, direccion, comuna, region) VALUES
('TechStore SPA', '76.123.456-7', 'contacto@techstore.cl', '+56912345678', 'Av. Providencia 1234', 'Providencia', 'Metropolitana'),
('ModaExpress Ltda', '77.876.543-2', 'ventas@modaexpress.cl', '+56987654321', 'Calle Ahumada 567', 'Santiago', 'Metropolitana');

INSERT INTO producto (pyme_id, sku, nombre, descripcion, precio, peso_kg, dimensiones) VALUES
(1, 'TECH001', 'Laptop Gaming Pro', 'Laptop de alto rendimiento para gaming', 899990, 2.5, '35 x 25 x 3 cm'),
(1, 'TECH002', 'Mouse Inalámbrico', 'Mouse ergonómico recargable', 49990, 0.15, '12 x 7 x 4 cm'),
(2, 'MODA001', 'Jeans Classic', 'Jeans de corte clásico', 39990, 0.8, 'talla 32'),
(2, 'MODA002', 'Polera Algodón', 'Polera de algodón orgánico', 19990, 0.3, 'talla L');

INSERT INTO inventario (producto_id, stock_disponible, stock_reservado) VALUES
(1, 10, 0),
(2, 25, 0),
(3, 15, 0),
(4, 30, 0);
