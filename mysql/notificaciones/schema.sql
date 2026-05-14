-- Base de datos para MS-Notificaciones
-- Sistema de comunicaciones por email (simulado)

CREATE DATABASE IF NOT EXISTS ms_notificaciones CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ms_notificaciones;

-- Tabla de Plantillas de Notificación
CREATE TABLE plantilla_notificacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    tipo_notificacion ENUM('PEDIDO_CREADO', 'ENVIO_DESPACHADO', 'ENVIO_EN_RUTA', 'ENVIO_ENTREGADO', 'ENVIO_FALLIDO', 'VENTANA_ENTREGA') NOT NULL,
    canal ENUM('EMAIL', 'WHATSAPP', 'SMS') NOT NULL,
    asunto VARCHAR(200),
    contenido_html TEXT,
    contenido_texto TEXT,
    variables_reemplazo JSON, -- Ej: ["{{nombre_cliente}}", "{{estado_envio}}"]
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tipo_canal (tipo_notificacion, canal),
    INDEX idx_activa (activa)
);

-- Tabla de Notificaciones
CREATE TABLE notificacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    envio_id BIGINT NOT NULL,
    pedido_id BIGINT NOT NULL,
    cliente_email VARCHAR(100) NOT NULL,
    cliente_telefono VARCHAR(20),
    tipo_notificacion ENUM('PEDIDO_CREADO', 'ENVIO_DESPACHADO', 'ENVIO_EN_RUTA', 'ENVIO_ENTREGADO', 'ENVIO_FALLIDO', 'VENTANA_ENTREGA') NOT NULL,
    canal_envio ENUM('EMAIL', 'WHATSAPP', 'SMS') NOT NULL DEFAULT 'EMAIL',
    estado_notificacion ENUM('PENDIENTE', 'ENVIANDO', 'ENVIADO', 'FALLIDO', 'REINTENTAR') DEFAULT 'PENDIENTE',
    intentos_envio INT DEFAULT 0,
    max_intentos INT DEFAULT 3,
    proximo_intento TIMESTAMP NULL,
    fecha_envio TIMESTAMP NULL,
    respuesta_servidor TEXT,
    error_detalle TEXT,
    datos_personalizacion JSON, -- Datos para reemplazar en plantilla
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_envio_estado (envio_id, estado_notificacion),
    INDEX idx_tipo_estado (tipo_notificacion, estado_notificacion),
    INDEX idx_pendientes_reintentar (estado_notificacion, proximo_intento),
    INDEX idx_fecha_envio (fecha_envio)
);

-- Tabla de Configuración de Canales
CREATE TABLE configuracion_canal (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    canal ENUM('EMAIL', 'WHATSAPP', 'SMS') NOT NULL,
    proveedor VARCHAR(50) NOT NULL, -- 'SMTP', 'TWILIO', 'WHATSAPP_API'
    configuracion JSON NOT NULL, -- Ej: {"host": "smtp.gmail.com", "port": 587, "username": "..."}
    activo BOOLEAN DEFAULT TRUE,
    prioridad INT DEFAULT 1, -- 1 = más alta prioridad
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_canal_activo (canal, activo)
);

-- Tabla de Reglas de Anti-Saturación
CREATE TABLE regla_anti_saturacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_notificacion ENUM('ENVIO_EN_RUTA', 'VENTANA_ENTREGA') NOT NULL,
    condicion_geografica ENUM('DENTRO_RADIO_KM', 'ENTREGAS_PREVIAS', 'TIEMPO_ULTIMA_NOTIFICACION') NOT NULL,
    valor_condicion DECIMAL(10,2) NOT NULL, -- Ej: 2.0 km, 3 entregas, 60 minutos
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tipo_activa (tipo_notificacion, activa)
);

-- Tabla de Historial de Envíos (para control de anti-saturación)
CREATE TABLE historial_envio_cliente (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_email VARCHAR(100) NOT NULL,
    envio_id BIGINT NOT NULL,
    tipo_notificacion ENUM('ENVIO_EN_RUTA', 'VENTANA_ENTREGA') NOT NULL,
    coordenadas_envio POINT,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    canal_envio ENUM('EMAIL', 'WHATSAPP', 'SMS') NOT NULL,
    INDEX idx_cliente_fecha (cliente_email, fecha_notificacion),
    INDEX idx_tipo_fecha (tipo_notificacion, fecha_notificacion)
);

-- Tabla de Estadísticas de Notificaciones
CREATE TABLE estadistica_notificacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo_notificacion ENUM('PEDIDO_CREADO', 'ENVIO_DESPACHADO', 'ENVIO_EN_RUTA', 'ENVIO_ENTREGADO', 'ENVIO_FALLIDO', 'VENTANA_ENTREGA') NOT NULL,
    canal_envio ENUM('EMAIL', 'WHATSAPP', 'SMS') NOT NULL,
    total_enviados INT DEFAULT 0,
    total_exitosos INT DEFAULT 0,
    total_fallidos INT DEFAULT 0,
    tasa_exito DECIMAL(5,2) GENERATED ALWAYS AS (CASE WHEN total_enviados > 0 THEN (total_exitosos * 100.0 / total_enviados) ELSE 0 END) STORED,
    tiempo_promedio_envio INT, -- segundos
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_fecha_tipo_canal (fecha, tipo_notificacion, canal_envio),
    INDEX idx_fecha (fecha),
    INDEX idx_tipo_fecha (tipo_notificacion, fecha)
);

-- Trigger para actualizar timestamps
DELIMITER //
CREATE TRIGGER before_notificacion_update 
BEFORE UPDATE ON notificacion
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
    
    -- Actualizar fecha de envío cuando se envía exitosamente
    IF OLD.estado_notificacion != 'ENVIADO' AND NEW.estado_notificacion = 'ENVIADO' THEN
        NEW.fecha_envio = CURRENT_TIMESTAMP;
    END IF;
    
    -- Incrementar intentos
    IF OLD.estado_notificacion != NEW.estado_notificacion AND NEW.estado_notificacion IN ('FALLIDO', 'REINTENTAR') THEN
        NEW.intentos_envio = NEW.intentos_envio + 1;
        
        -- Programar próximo reintento
        IF NEW.intentos_envio < NEW.max_intentos THEN
            SET NEW.proximo_intento = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 
                CASE NEW.intentos_envio
                    WHEN 1 THEN 5 -- 5 minutos
                    WHEN 2 THEN 15 -- 15 minutos
                    ELSE 60 -- 1 hora
                END MINUTE);
            SET NEW.estado_notificacion = 'REINTENTAR';
        ELSE
            SET NEW.estado_notificacion = 'FALLIDO';
        END IF;
    END IF;
END//

CREATE TRIGGER before_plantilla_update 
BEFORE UPDATE ON plantilla_notificacion
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
END//

CREATE TRIGGER before_configuracion_update 
BEFORE UPDATE ON configuracion_canal
FOR EACH ROW
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- Trigger para actualizar estadísticas
DELIMITER //
CREATE TRIGGER after_notificacion_update
AFTER UPDATE ON notificacion
FOR EACH ROW
BEGIN
    IF OLD.estado_notificacion != 'ENVIADO' AND NEW.estado_notificacion = 'ENVIADO' THEN
        INSERT INTO estadistica_notificacion (
            fecha, 
            tipo_notificacion, 
            canal_envio, 
            total_enviados, 
            total_exitosos
        ) VALUES (
            CURRENT_DATE,
            NEW.tipo_notificacion,
            NEW.canal_envio,
            1,
            1
        ) ON DUPLICATE KEY UPDATE 
            total_enviados = total_enviados + 1,
            total_exitosos = total_exitosos + 1,
            actualizado_en = CURRENT_TIMESTAMP;
            
    ELSEIF OLD.estado_notificacion NOT IN ('FALLIDO', 'ENVIADO') AND NEW.estado_notificacion = 'FALLIDO' THEN
        INSERT INTO estadistica_notificacion (
            fecha, 
            tipo_notificacion, 
            canal_envio, 
            total_enviados, 
            total_fallidos
        ) VALUES (
            CURRENT_DATE,
            NEW.tipo_notificacion,
            NEW.canal_envio,
            1,
            1
        ) ON DUPLICATE KEY UPDATE 
            total_enviados = total_enviados + 1,
            total_fallidos = total_fallidos + 1,
            actualizado_en = CURRENT_TIMESTAMP;
    END IF;
END//
DELIMITER ;

-- Datos de ejemplo (plantillas y configuración)
INSERT INTO plantilla_notificacion (nombre, tipo_notificacion, canal, asunto, contenido_texto, variables_reemplazo) VALUES
('Email Pedido Creado', 'PEDIDO_CREADO', 'EMAIL', 'Tu pedido {{numero_orden}} ha sido recibido', 
 'Hola {{nombre_cliente}},\n\nTu pedido {{numero_orden}} ha sido recibido y está siendo procesado.\n\nEstado: {{estado_pedido}}\n\nGracias por tu compra.', 
 '["{{nombre_cliente}}", "{{numero_orden}}", "{{estado_pedido}}"]'),

('Email Envío Despachado', 'ENVIO_DESPACHADO', 'EMAIL', 'Tu envío {{etiqueta_despacho}} ha sido despachado', 
 'Hola {{nombre_cliente}},\n\nTu envío con etiqueta {{etiqueta_despacho}} ha sido despachado.\n\nRepartidor: {{nombre_repartidor}}\n\nPuedes seguir tu pedido en nuestro portal.', 
 '["{{nombre_cliente}}", "{{etiqueta_despacho}}", "{{nombre_repartidor}}"]'),

('Email Envío Entregado', 'ENVIO_ENTREGADO', 'EMAIL', 'Tu envío {{etiqueta_despacho}} ha sido entregado', 
 'Hola {{nombre_cliente}},\n\n¡Buenas noticias! Tu envío con etiqueta {{etiqueta_despacho}} ha sido entregado exitosamente.\n\nGracias por confiar en nosotros.', 
 '["{{nombre_cliente}}", "{{etiqueta_despacho}}"]');

INSERT INTO configuracion_canal (canal, proveedor, configuracion, activo, prioridad) VALUES
('EMAIL', 'SMTP', '{"host": "smtp.gmail.com", "port": 587, "username": "noreply@pymetrack.cl", "password": "password", "from": "PymeTrack <noreply@pymetrack.cl>"}', TRUE, 1),
('SMS', 'TWILIO', '{"account_sid": "ACxxxxxxxx", "auth_token": "xxxxxxxx", "from_number": "+1234567890"}', FALSE, 2),
('WHATSAPP', 'WHATSAPP_API', '{"phone_number_id": "xxxxxxxx", "access_token": "xxxxxxxx", "version": "v16.0"}', FALSE, 3);

INSERT INTO regla_anti_saturacion (nombre, tipo_notificacion, condicion_geografica, valor_condicion, activa) VALUES
('Radio 2km para En Ruta', 'ENVIO_EN_RUTA', 'DENTRO_RADIO_KM', 2.0, TRUE),
('Máximo 3 notificaciones por hora', 'VENTANA_ENTREGA', 'TIEMPO_ULTIMA_NOTIFICACION', 60.0, TRUE),
('Máximo 2 entregas previas', 'ENVIO_EN_RUTA', 'ENTREGAS_PREVIAS', 2.0, TRUE);
