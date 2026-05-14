-- Base de datos para ms-user (unificado ms-auth + ms-admin)
-- Gestión de usuarios, PYMEs, roles y autenticación JWT

CREATE DATABASE IF NOT EXISTS ms_user CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ms_user;

-- Tabla de Roles
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Permisos
CREATE TABLE IF NOT EXISTS permisos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Rol-Permiso (muchos a muchos)
CREATE TABLE IF NOT EXISTS rol_permiso (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rol_id BIGINT NOT NULL,
    permiso_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_rol_permiso (rol_id, permiso_id)
);

-- Tabla de Usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    rol_id BIGINT NOT NULL,
    pyme_id BIGINT,
    activo BOOLEAN DEFAULT TRUE,
    ultimo_login TIMESTAMP NULL,
    intentos_fallidos INT DEFAULT 0,
    bloqueado_hasta TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id),
    INDEX idx_usuario_email (email),
    INDEX idx_usuario_activo (activo),
    INDEX idx_usuario_pyme (pyme_id)
);

-- Tabla de PYMEs
CREATE TABLE IF NOT EXISTS pymes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rut VARCHAR(20) UNIQUE NOT NULL,
    email_contacto VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    comuna VARCHAR(50),
    region VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_pyme_rut (rut),
    INDEX idx_pyme_activo (activo)
);

-- Insertar roles por defecto
INSERT INTO roles (nombre, descripcion) VALUES
('ADMIN', 'Administrador del sistema con acceso completo'),
('PYME', 'Usuario PYME con acceso a gestión de productos y pedidos'),
('REPARTIDOR', 'Repartidor con acceso a actualización de estados');

-- Insertar permisos por defecto
INSERT INTO permisos (nombre, descripcion) VALUES
('USUARIOS_VER', 'Ver lista de usuarios'),
('USUARIOS_CREAR', 'Crear nuevos usuarios'),
('USUARIOS_EDITAR', 'Editar usuarios existentes'),
('USUARIOS_ELIMINAR', 'Eliminar usuarios'),
('USUARIOS_CAMBIAR_ROL', 'Cambiar rol de usuarios'),
('PRODUCTOS_VER', 'Ver productos'),
('PRODUCTOS_CREAR', 'Crear productos'),
('PRODUCTOS_EDITAR', 'Editar productos'),
('PRODUCTOS_ELIMINAR', 'Eliminar productos'),
('PRODUCTOS_INVENTARIO', 'Gestionar inventario'),
('PEDIDOS_VER', 'Ver pedidos'),
('PEDIDOS_CREAR', 'Crear pedidos'),
('PEDIDOS_EDITAR', 'Editar pedidos'),
('PEDIDOS_ESTADOS', 'Actualizar estados de pedidos'),
('PYMES_VER', 'Ver lista de PYMEs'),
('PYMES_CREAR', 'Crear nuevas PYMEs'),
('PYMES_EDITAR', 'Editar PYMEs'),
('PYMES_ELIMINAR', 'Eliminar PYMEs'),
('SISTEMA_STATS', 'Ver estadísticas del sistema');

-- Asignar permisos a roles
-- ADMIN: todos los permisos
INSERT INTO rol_permiso (rol_id, permiso_id) 
SELECT r.id, p.id FROM roles r, permisos p WHERE r.nombre = 'ADMIN';

-- PYME: permisos de productos y pedidos
INSERT INTO rol_permiso (rol_id, permiso_id) 
SELECT r.id, p.id FROM roles r, permisos p 
WHERE r.nombre = 'PYME' AND p.nombre IN (
    'PRODUCTOS_VER', 'PRODUCTOS_CREAR', 'PRODUCTOS_EDITAR', 'PRODUCTOS_ELIMINAR', 'PRODUCTOS_INVENTARIO',
    'PEDIDOS_VER', 'PEDIDOS_CREAR', 'PEDIDOS_EDITAR'
);

-- REPARTIDOR: permisos de pedidos (solo estados)
INSERT INTO rol_permiso (rol_id, permiso_id) 
SELECT r.id, p.id FROM roles r, permisos p 
WHERE r.nombre = 'REPARTIDOR' AND p.nombre IN (
    'PEDIDOS_VER', 'PEDIDOS_ESTADOS'
);

-- Insertar usuarios de ejemplo
INSERT INTO usuarios (email, password, nombre, apellido, rol_id, pyme_id) VALUES
('admin@pymetrack.cl', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Admin', 'System', 1, NULL),
('pyme1@pymetrack.cl', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Juan', 'Pérez', 2, 1),
('pyme2@pymetrack.cl', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'María', 'González', 2, 2),
('repartidor1@pymetrack.cl', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Carlos', 'López', 3, NULL);

-- Insertar PYMEs de ejemplo
INSERT INTO pymes (nombre, rut, email_contacto, telefono, direccion, comuna, region) VALUES
('TechStore Chile', '76.123.456-7', 'contacto@techstore.cl', '+56 2 2345 6789', 'Av. Providencia 1234', 'Providencia', 'Región Metropolitana'),
('Café del Sur', '77.987.654-3', 'hola@cafedelsur.cl', '+56 2 2345 6789', 'Calle Los Héroes 567', 'Santiago', 'Región Metropolitana');

-- Crear vista de usuarios con roles y permisos
CREATE VIEW usuarios_detalle AS
SELECT 
    u.id,
    u.email,
    u.nombre,
    u.apellido,
    u.activo,
    u.ultimo_login,
    r.nombre as rol,
    p.nombre as pyme_nombre,
    p.rut as pyme_rut,
    GROUP_CONCAT(per.nombre ORDER BY per.nombre SEPARATOR ', ') as permisos
FROM usuarios u
LEFT JOIN roles r ON u.rol_id = r.id
LEFT JOIN pymes p ON u.pyme_id = p.id
LEFT JOIN rol_permiso rp ON r.id = rp.rol_id
LEFT JOIN permisos per ON rp.permiso_id = per.id
GROUP BY u.id, u.email, u.nombre, u.apellido, u.activo, u.ultimo_login, r.nombre, p.nombre, p.rut;
