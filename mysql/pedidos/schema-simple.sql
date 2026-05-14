-- Base de datos simplificada para MS-Pedidos (sin triggers para evitar errores)

CREATE DATABASE IF NOT EXISTS ms_pedidos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ms_pedidos;

-- Tabla de PYMEs (clientes del sistema)
CREATE TABLE pyme (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rut VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    comuna VARCHAR(50),
    region VARCHAR(50),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_pyme_rut (rut),
    INDEX idx_pyme_email (email)
);

-- Tabla de productos
CREATE TABLE producto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pyme_id BIGINT NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    peso_kg DECIMAL(8,3) CHECK (peso_kg >= 0),
    dimensiones VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pyme_id) REFERENCES pyme(id) ON DELETE CASCADE,
    INDEX idx_producto_pyme (pyme_id),
    INDEX idx_producto_sku (sku),
    INDEX idx_producto_activo (activo)
);

-- Tabla de inventario
CREATE TABLE inventario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL UNIQUE,
    stock_disponible INT NOT NULL DEFAULT 0 CHECK (stock_disponible >= 0),
    stock_reservado INT NOT NULL DEFAULT 0 CHECK (stock_reservado >= 0),
    stock_minimo INT NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0),
    ultimo_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES producto(id) ON DELETE CASCADE,
    INDEX idx_inventario_producto (producto_id),
    CHECK (stock_disponible >= stock_reservado)
);

-- Tabla de pedidos
CREATE TABLE pedido (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pyme_id BIGINT NOT NULL,
    numero_orden VARCHAR(50) NOT NULL UNIQUE,
    cliente_nombre VARCHAR(100) NOT NULL,
    cliente_email VARCHAR(100) NOT NULL,
    cliente_telefono VARCHAR(20),
    direccion_entrega TEXT NOT NULL,
    comuna_entrega VARCHAR(50) NOT NULL,
    region_entrega VARCHAR(50) NOT NULL,
    estado_pedido ENUM('PENDIENTE', 'PREPARACION', 'DESPACHADO', 'EN_RUTA', 'ENTREGADO', 'CANCELADO') DEFAULT 'PENDIENTE',
    costo_envio DECIMAL(10,2) DEFAULT 0 CHECK (costo_envio >= 0),
    total DECIMAL(10,2) NOT NULL CHECK (total > 0),
    etiqueta_despacho VARCHAR(50),
    notas TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pyme_id) REFERENCES pyme(id),
    INDEX idx_pedido_pyme (pyme_id),
    INDEX idx_pedido_numero (numero_orden),
    INDEX idx_pedido_estado (estado_pedido),
    INDEX idx_pedido_etiqueta (etiqueta_despacho),
    INDEX idx_pedido_fecha (creado_en)
);

-- Tabla de detalles de pedido
CREATE TABLE pedido_detalle (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedido(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    INDEX idx_detalle_pedido (pedido_id),
    INDEX idx_detalle_producto (producto_id)
);

-- Tabla de movimientos de inventario
CREATE TABLE inventario_movimiento (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'RESERVA', 'LIBERACION') NOT NULL,
    cantidad INT NOT NULL,
    stock_antes INT NOT NULL,
    stock_despues INT NOT NULL,
    motivo VARCHAR(200),
    referencia_id BIGINT,
    referencia_tipo VARCHAR(50),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    INDEX idx_movimiento_producto (producto_id),
    INDEX idx_movimiento_fecha (creado_en),
    INDEX idx_movimiento_tipo (tipo_movimiento)
);
