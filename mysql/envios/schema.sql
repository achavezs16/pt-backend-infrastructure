-- Base de datos para MS-Envíos
-- Orquestación logística y gestión de rutas

CREATE DATABASE IF NOT EXISTS ms_envios CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ms_envios;

-- Tabla de Repartidores
CREATE TABLE repartidor (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    patente_vehiculo VARCHAR(10),
    tipo_vehiculo ENUM('MOTO', 'AUTO', 'FURGON', 'BICICLETA') DEFAULT 'AUTO',
    estado ENUM('DISPONIBLE', 'OCUPADO', 'DESCANSO', 'OFFLINE') DEFAULT 'DISPONIBLE',
    coordenadas_actuales POINT,
    ultima_actualizacion_gps TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_estado (estado),
    INDEX idx_activo_estado (activo, estado)
);

-- Tabla de Envíos
CREATE TABLE envio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT UNIQUE NOT NULL, -- Referencia al pedido del ms-pedidos
    pyme_id BIGINT NOT NULL,
    numero_orden VARCHAR(50) NOT NULL,
    etiqueta_despacho VARCHAR(100) UNIQUE NOT NULL,
    cliente_nombre VARCHAR(100) NOT NULL,
    cliente_email VARCHAR(100) NOT NULL,
    cliente_telefono VARCHAR(20),
    direccion_entrega TEXT NOT NULL,
    comuna_entrega VARCHAR(50) NOT NULL,
    region_entrega VARCHAR(50) NOT NULL,
    coordenadas_entrega POINT NOT NULL,
    estado_envio ENUM('PENDIENTE', 'PREPARACION', 'DESPACHADO', 'EN_RUTA', 'ENTREGADO', 'FALLIDO') DEFAULT 'PENDIENTE',
    repartidor_id BIGINT,
    fecha_asignacion TIMESTAMP NULL,
    fecha_despacho TIMESTAMP NULL,
    fecha_entrega TIMESTAMP NULL,
    intentos_entrega INT DEFAULT 0,
    motivo_falla VARCHAR(200),
    notas_repartidor TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (repartidor_id) REFERENCES repartidor(id),
    INDEX idx_estado (estado_envio),
    INDEX idx_pyme_estado (pyme_id, estado_envio),
    INDEX idx_repartidor_estado (repartidor_id, estado_envio),
    INDEX idx_etiqueta (etiqueta_despacho),
    INDEX idx_fecha_despacho (fecha_despacho)
);

-- Tabla de Rutas (agrupación de envíos por repartidor)
CREATE TABLE ruta (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    repartidor_id BIGINT NOT NULL,
    nombre_ruta VARCHAR(100) NOT NULL,
    fecha_ruta DATE NOT NULL,
    estado_ruta ENUM('PLANIFICADA', 'EN_CURSO', 'COMPLETADA', 'CANCELADA') DEFAULT 'PLANIFICADA',
    hora_inicio TIMESTAMP NULL,
    hora_fin TIMESTAMP NULL,
    total_envios INT DEFAULT 0,
    envios_entregados INT DEFAULT 0,
    envios_fallidos INT DEFAULT 0,
    kilometros_estimados DECIMAL(8,2),
    kilometros_reales DECIMAL(8,2),
    observaciones TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (repartidor_id) REFERENCES repartidor(id),
    INDEX idx_repartidor_fecha (repartidor_id, fecha_ruta),
    INDEX idx_estado_fecha (estado_ruta, fecha_ruta)
);

-- Tabla de Detalles de Ruta (envíos asignados a cada ruta)
CREATE TABLE ruta_detalle (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ruta_id BIGINT NOT NULL,
    envio_id BIGINT NOT NULL,
    secuencia_entrega INT NOT NULL, -- Orden en la ruta
    hora_estimada_entrega TIME,
    hora_real_entrega TIMESTAMP NULL,
    estado_detalle ENUM('PENDIENTE', 'ENTREGADO', 'FALLIDO', 'REPROGRAMADO') DEFAULT 'PENDIENTE',
    notas TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ruta_id) REFERENCES ruta(id),
    FOREIGN KEY (envio_id) REFERENCES envio(id),
    UNIQUE KEY unique_envio_ruta (envio_id),
    UNIQUE KEY unique_secuencia (ruta_id, secuencia_entrega),
    INDEX idx_ruta_secuencia (ruta_id, secuencia_entrega)
);

-- Tabla de Historial de Estados (para auditoría completa)
CREATE TABLE historial_estado_envio (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    envio_id BIGINT NOT NULL,
    estado_anterior ENUM('PENDIENTE', 'PREPARACION', 'DESPACHADO', 'EN_RUTA', 'ENTREGADO', 'FALLIDO') NULL,
    estado_nuevo ENUM('PENDIENTE', 'PREPARACION', 'DESPACHADO', 'EN_RUTA', 'ENTREGADO', 'FALLIDO') NOT NULL,
    repartidor_id BIGINT,
    coordenadas_cambio POINT,
    ip_origen VARCHAR(45),
    user_agent VARCHAR(500),
    motivo_cambio VARCHAR(200),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (envio_id) REFERENCES envio(id),
    FOREIGN KEY (repartidor_id) REFERENCES repartidor(id),
    INDEX idx_envio_fecha (envio_id, creado_en),
    INDEX idx_estado_fecha (estado_nuevo, creado_en)
);

-- Tabla de Zonas Geográficas (para optimización de rutas)
CREATE TABLE zona (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comuna VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    poligono GEOMETRY, -- Polígono que define la zona
    prioridad_entrega INT DEFAULT 1, -- 1 = más alta
    tiempo_estimado_promedio INT, -- minutos por entrega
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_comuna_activa (comuna, activa)
);

-- Trigger para actualizar timestamps
DELIMITER //
CREATE TRIGGER before_envio_update 
BEFORE UPDATE ON envio
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
    
    -- Actualizar contadores de ruta si cambia el estado
    IF OLD.estado_envio != NEW.estado_envio THEN
        IF NEW.estado_envio = 'ENTREGADO' THEN
            UPDATE ruta_detalle SET estado_detalle = 'ENTREGADO', hora_real_entrega = CURRENT_TIMESTAMP
            WHERE envio_id = NEW.id;
        ELSEIF NEW.estado_envio = 'FALLIDO' THEN
            UPDATE ruta_detalle SET estado_detalle = 'FALLIDO'
            WHERE envio_id = NEW.id;
        END IF;
    END IF;
END//

CREATE TRIGGER before_ruta_update 
BEFORE UPDATE ON ruta
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
END//

CREATE TRIGGER before_ruta_detalle_update 
BEFORE UPDATE ON ruta_detalle
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- Trigger para historial de estados
DELIMITER //
CREATE TRIGGER after_envio_update
AFTER UPDATE ON envio
FOR EACH ROW
BEGIN
    IF OLD.estado_envio != NEW.estado_envio THEN
        INSERT INTO historial_estado_envio (
            envio_id, 
            estado_anterior, 
            estado_nuevo, 
            repartidor_id,
            coordenadas_cambio,
            motivo_cambio
        ) VALUES (
            NEW.id,
            OLD.estado_envio,
            NEW.estado_envio,
            NEW.repartidor_id,
            NEW.coordenadas_entrega,
            CONCAT('Cambio de estado de ', OLD.estado_envio, ' a ', NEW.estado_envio)
        );
        
        -- Actualizar fecha de entrega si es entregado
        IF NEW.estado_envio = 'ENTREGADO' AND OLD.estado_envio != 'ENTREGADO' THEN
            UPDATE envio SET fecha_entrega = CURRENT_TIMESTAMP WHERE id = NEW.id;
        END IF;
        
        -- Incrementar intentos si falla entrega
        IF NEW.estado_envio = 'FALLIDO' AND OLD.estado_envio != 'FALLIDO' THEN
            UPDATE envio SET intentos_entrega = intentos_entrega + 1 WHERE id = NEW.id;
        END IF;
    END IF;
END//
DELIMITER ;

-- Datos de ejemplo (para desarrollo)
INSERT INTO repartidor (nombre, apellido, rut, email, telefono, patente_vehiculo, tipo_vehiculo, estado) VALUES
('Juan', 'Pérez', '12.345.678-9', 'juan.perez@pymetrack.cl', '+56912345678', 'ABC123', 'AUTO', 'DISPONIBLE'),
('María', 'González', '13.456.789-0', 'maria.gonzalez@pymetrack.cl', '+56987654321', 'DEF456', 'MOTO', 'DISPONIBLE'),
('Carlos', 'Rodríguez', '14.567.890-1', 'carlos.rodriguez@pymetrack.cl', '+56911223344', 'GHI789', 'FURGON', 'DESCANSO');

INSERT INTO zona (nombre, comuna, region, prioridad_entrega, tiempo_estimado_promedio) VALUES
('Zona Centro', 'Santiago', 'Metropolitana', 1, 20),
('Zona Este', 'Providencia', 'Metropolitana', 2, 25),
('Zona Sur', 'La Florida', 'Metropolitana', 3, 30);
