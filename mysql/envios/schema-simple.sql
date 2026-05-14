-- Esquema simplificado para ms-envios (sin triggers complejos)

USE ms_envios;

-- Tabla de Repartidores
CREATE TABLE repartidor (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    patente_vehiculo VARCHAR(20),
    tipo_vehiculo ENUM('AUTO', 'MOTO', 'FURGON', 'BICICLETA') NOT NULL,
    estado ENUM('DISPONIBLE', 'OCUPADO', 'DESCANSO') DEFAULT 'DISPONIBLE',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Envíos
CREATE TABLE envio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT NOT NULL,
    repartidor_id BIGINT,
    etiqueta_despacho VARCHAR(50) UNIQUE NOT NULL,
    estado_envio ENUM('PREPARACION', 'DESPACHADO', 'EN_RUTA', 'ENTREGADO', 'FALLIDO') DEFAULT 'PREPARACION',
    direccion_entrega TEXT NOT NULL,
    comuna_entrega VARCHAR(50),
    coordenadas_latitud DECIMAL(10,8),
    coordenadas_longitud DECIMAL(11,8),
    notas TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (repartidor_id) REFERENCES repartidor(id)
);

-- Tabla de Zonas
CREATE TABLE zona (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comuna VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    prioridad_entrega INT DEFAULT 1,
    tiempo_estimado_promedio INT DEFAULT 30,
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_repartidor_estado ON repartidor(estado);
CREATE INDEX idx_envio_estado ON envio(estado_envio);
CREATE INDEX idx_envio_pedido ON envio(pedido_id);
CREATE INDEX idx_zona_comuna ON zona(comuna, activa);
