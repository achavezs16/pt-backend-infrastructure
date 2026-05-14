-- Base de datos para MS-Pedidos (versión simplificada para pruebas)
USE ms_pedidos;

-- Tabla de PYMEs (clientes del sistema)
CREATE TABLE pyme (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre_pyme VARCHAR(100) NOT NULL,
    rut_pyme VARCHAR(20) UNIQUE NOT NULL,
    email_contacto_pyme VARCHAR(100) NOT NULL,
    telefono_contacto_pyme VARCHAR(20),
    direccion_sucursal_pyme TEXT,
    comuna_sucursal_pyme VARCHAR(50),
    region_sucursal_pyme VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Productos
CREATE TABLE producto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pyme BIGINT NOT NULL,
    codigo_sku VARCHAR(50) NOT NULL,
    nombre_producto VARCHAR(200) NOT NULL,
    descripcion_producto TEXT,
    precio_venta_chile DECIMAL(10,2) NOT NULL,
    peso_producto_kg DECIMAL(8,3),
    dimensiones_producto VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pyme) REFERENCES pyme(id),
    UNIQUE KEY unique_sku_pyme (id_pyme, codigo_sku)
);

-- Tabla de Inventario
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
    id_pyme BIGINT NOT NULL,
    numero_orden_pyme VARCHAR(50) UNIQUE NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    email_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20),
    direccion_entrega_chile TEXT NOT NULL,
    comuna_entrega_chile VARCHAR(50) NOT NULL,
    region_entrega_chile VARCHAR(50) NOT NULL,
    coordenadas_entrega POINT,
    estado_pedido_pyme ENUM('PENDIENTE_CHILE', 'CONFIRMADO_CHILE', 'PREPARACION_CHILE', 'CANCELADO_CHILE') DEFAULT 'PENDIENTE_CHILE',
    subtotal DECIMAL(10,2) NOT NULL,
    costo_despacho_chile DECIMAL(10,2) DEFAULT 0,
    total_pedido DECIMAL(10,2) NOT NULL,
    etiqueta_despacho_pyme VARCHAR(100) UNIQUE,
    notas_pedido TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pyme) REFERENCES pyme(id),
    INDEX idx_estado_pedido (estado_pedido_pyme),
    INDEX idx_pyme_estado (id_pyme, estado_pedido_pyme),
    INDEX idx_numero_orden (numero_orden_pyme)
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
