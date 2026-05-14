-- Inicialización de base de datos ms-envios - PymeTrack
-- Datos personalizados para pymes chilenas (ropa, electrónicos, belleza)

USE ms_envios;

-- Insertar repartidores PymeTrack de ejemplo
INSERT INTO repartidor (nombre, apellido, rut, email, telefono, patente_vehiculo, tipo_vehiculo, estado_repartidor) VALUES
('Juan Carlos', 'Pérez Soto', '12.345.678-9', 'juan.perez@pymetrack.cl', '+56912345678', 'ABC123', 'AUTOMOVIL', 'DISPONIBLE_CHILE'),
('María José', 'González López', '13.456.789-0', 'maria.gonzalez@pymetrack.cl', '+56987654321', 'DEF456', 'MOTOCICLETA', 'DISPONIBLE_CHILE'),
('Carlos Andrés', 'Rodríguez Muñoz', '14.567.890-1', 'carlos.rodriguez@pymetrack.cl', '+56911223344', 'GHI789', 'FURGONETA', 'DESCANSO_CHILE'),
('Ana María', 'Martínez Díaz', '15.678.901-2', 'ana.martinez@pymetrack.cl', '+56922334455', 'JKL012', 'AUTOMOVIL', 'DISPONIBLE_CHILE'),
('Luis Alberto', 'Silva Fuentes', '16.789.012-3', 'luis.silva@pymetrack.cl', '+56933445566', 'MNO345', 'BICICLETA_ELECTRICA', 'OCUPADO_CHILE');

INSERT INTO zona (nombre, comuna, region) VALUES
('Zona Centro Santiago', 'Santiago', 'Metropolitana'),
('Zona Providencia', 'Providencia', 'Metropolitana'),
('Zona Las Condes', 'Las Condes', 'Metropolitana'),
('Zona La Florida', 'La Florida', 'Metropolitana'),
('Zona Quilicura', 'Quilicura', 'Metropolitana');

-- Insertar envíos PymeTrack de ejemplo para pruebas
INSERT INTO envio (id_pedido, id_pyme, numero_orden, etiqueta_despacho, nombre_cliente, email_cliente, telefono_cliente, direccion_entrega, comuna_entrega, estado_despacho, id_repartidor, coordenadas_entrega) VALUES
(1, 1, 'ORD-2024-001', 'PYM-CHILE-001', 'María Fernanda López', 'mf.lopez@email.com', '+56998765432', 'Calle Los Andes 1234, Depto 45B', 'Providencia', 'PREPARACION_PYME', 1, ST_GeomFromText('POINT(-70.6693 -33.4489)')),
(2, 2, 'ORD-2024-002', 'PYM-CHILE-002', 'Pedro Andrés Silva', 'pa.silva@email.com', '+56987654321', 'Av. Las Condes 567, Oficina 201', 'Las Condes', 'DESPACHADO_CHILE', 2, ST_GeomFromText('POINT(-70.5506 -33.4088)')),
(3, 3, 'ORD-2024-003', 'PYM-CHILE-003', 'Catalina Morales Rojas', 'cmorales@email.com', '+56976543210', 'Calle Ahumada 890, Local 12', 'Santiago', 'EN_CAMINO_CHILE', 4, ST_GeomFromText('POINT(-70.6506 -33.4372)'));

-- Insertar movimientos de seguimiento de envíos
INSERT INTO envio_seguimiento (envio_id, estado, descripcion, fecha_registro, coordenadas_latitud, coordenadas_longitud) VALUES
(1, 'CREADO', 'Envío creado y asignado a repartidor', NOW(), -33.4489, -70.6693),
(2, 'CREADO', 'Envío creado y asignado a repartidor', NOW(), -33.4088, -70.5506),
(2, 'DESPACHADO', 'Envío despachado desde bodega', DATE_ADD(NOW(), INTERVAL 30 MINUTE), -33.4088, -70.5506),
(3, 'CREADO', 'Envío creado y asignado a repartidor', NOW(), -33.4372, -70.6506),
(3, 'DESPACHADO', 'Envío despachado desde bodega', DATE_ADD(NOW(), INTERVAL 45 MINUTE), -33.4372, -70.6506),
(3, 'EN_RUTA', 'Repartidor en camino a dirección de entrega', DATE_ADD(NOW(), INTERVAL 1 HOUR), -33.4372, -70.6506);
