-- Esquema simplificado para ms-notificaciones (sin triggers complejos)

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
    variables_reemplazo JSON,
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Notificaciones
CREATE TABLE notificacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    envio_id BIGINT NOT NULL,
    pedido_id BIGINT NOT NULL,
    cliente_email VARCHAR(100) NOT NULL,
    cliente_telefono VARCHAR(20),
    tipo_notificacion ENUM('PEDIDO_CREADO', 'ENVIO_DESPACHADO', 'ENVIO_EN_RUTA', 'ENVIO_ENTREGADO', 'ENVIO_FALLIDO', 'VENTANA_ENTREGA') NOT NULL,
    canal_envio ENUM('EMAIL', 'WHATSAPP', 'SMS') DEFAULT 'EMAIL',
    estado_notificacion ENUM('PENDIENTE', 'ENVIANDO', 'ENVIADO', 'FALLIDO', 'REINTENTAR') DEFAULT 'PENDIENTE',
    intentos_envio INT DEFAULT 0,
    max_intentos INT DEFAULT 3,
    proximo_intento TIMESTAMP,
    fecha_envio TIMESTAMP,
    respuesta_servidor TEXT,
    error_detalle TEXT,
    datos_personalizacion JSON,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Configuración de Canales
CREATE TABLE configuracion_canal (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    canal ENUM('EMAIL', 'WHATSAPP', 'SMS') NOT NULL,
    proveedor VARCHAR(50) NOT NULL,
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Reglas Anti-Saturación
CREATE TABLE regla_anti_saturacion (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_notificacion ENUM('PEDIDO_CREADO', 'ENVIO_DESPACHADO', 'ENVIO_EN_RUTA', 'ENVIO_ENTREGADO', 'ENVIO_FALLIDO', 'VENTANA_ENTREGA') NOT NULL,
    condicion_geografica ENUM('DENTRO_RADIO_KM', 'FUERA_RADIO_KM', 'TIEMPO_ULTIMA_NOTIFICACION', 'ENTREGAS_PREVIAS') NOT NULL,
    valor_condicion DECIMAL(10,2) NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_notificacion_envio ON notificacion(envio_id);
CREATE INDEX idx_notificacion_pedido ON notificacion(pedido_id);
CREATE INDEX idx_notificacion_estado ON notificacion(estado_notificacion);
CREATE INDEX idx_notificacion_tipo ON notificacion(tipo_notificacion);
CREATE INDEX idx_plantilla_tipo ON plantilla_notificacion(tipo_notificacion, canal);
CREATE INDEX idx_configuracion_canal ON configuracion_canal(canal);
