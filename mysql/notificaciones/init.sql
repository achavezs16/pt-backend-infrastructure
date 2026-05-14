-- Inicialización completa de base de datos ms-notificaciones - PymeTrack
-- Este archivo ejecuta el esquema y los datos iniciales personalizados para pymes chilenas

-- Ejecutar el esquema completo primero
SOURCE /docker-entrypoint-initdb.d/schema.sql;

-- Insertar datos de ejemplo personalizados para pymes chilenas (ropa, electrónicos, belleza)
INSERT INTO plantilla_notificacion (nombre, tipo_evento, canal_notificacion, asunto, contenido_formato_texto, variables_personalizacion) VALUES
('Correo Pedido Confirmado', 'PEDIDO_CONFIRMADO', 'CORREO_ELECTRONICO', '¡Tu pedido {{numero_pedido}} está confirmado!', 
 '¡Hola {{nombre_cliente}}! 🎉\n\n¡Buenas noticias! Tu pedido {{numero_pedido}} ya está confirmado y nuestro equipo está preparándolo con mucho cariño.\n\n📦 Productos: {{detalle_productos}}\n💰 Total: ${{total_pedido}}\n📍 Dirección de entrega: {{direccion_entrega}}\n\nTe mantendremos informado de cada paso. ¡Gracias por confiar en PymeTrack!\n\nSaludos cordiales,\nEl equipo de {{nombre_pyme}}', 
 '["{{nombre_cliente}}", "{{numero_pedido}}", "{{detalle_productos}}", "{{total_pedido}}", "{{direccion_entrega}}", "{{nombre_pyme}}"]'),

('WhatsApp Despacho Iniciado', 'DESPACHO_INICIADO', 'WHATSAPP', '🚚 ¡Tu pedido va en camino!', 
 '¡Hola {{nombre_cliente}}! 🛵\n\n¡Excelente noticia! Tu pedido {{numero_pedido}} ya está en camino.\n\n📦 Etiqueta de seguimiento: {{etiqueta_despacho}}\n👤 Repartidor: {{nombre_repartidor}}\n📱 Teléfono del repartidor: {{telefono_repartidor}}\n\n¡Prepárate para recibirlo! 🎯\n\nPuedes seguir tu pedido aquí: {{link_seguimiento}}', 
 '["{{nombre_cliente}}", "{{numero_pedido}}", "{{etiqueta_despacho}}", "{{nombre_repartidor}}", "{{telefono_repartidor}}", "{{link_seguimiento}}"]'),

('Correo Entrega en Camino', 'ENTREGA_EN_CAMINO', 'CORREO_ELECTRONICO', '🏠 Tu repartidor está cerca', 
 '¡Hola {{nombre_cliente}}! 🏠\n\n¡Buenas noticias! Tu repartidor {{nombre_repartidor}} está muy cerca de tu dirección.\n\n📍 Dirección: {{direccion_entrega}}\n⏰ Tiempo estimado: {{tiempo_entrega}} minutos\n📱 Teléfono del repartidor: {{telefono_repartidor}}\n\n¡Prepárate para recibir tu pedido! 📦✨\n\nSi no estarás, avísanos lo antes posible.\n\n¡Gracias por tu paciencia!\nEl equipo de PymeTrack', 
 '["{{nombre_cliente}}", "{{nombre_repartidor}}", "{{direccion_entrega}}", "{{tiempo_entrega}}", "{{telefono_repartidor}}"]'),

('SMS Entrega Realizada', 'ENTREGA_REALIZADA', 'MENSAJE_TEXTO', '✅ ¡Pedido entregado!', 
 '¡Hola {{nombre_cliente}}! ✅ Tu pedido {{numero_pedido}} fue entregado exitosamente. ¡Que lo disfrutes! 🎉 Gracias por comprar en {{nombre_pyme}}', 
 '["{{nombre_cliente}}", "{{numero_pedido}}", "{{nombre_pyme}}"]'),

('Correo Problema Entrega', 'ENTREGA_FALLIDA', 'CORREO_ELECTRONICO', '📍 Necesitamos coordinar tu entrega', 
 '¡Hola {{nombre_cliente}}! 📍\n\nLamentamos informarte que no pudimos realizar la entrega de tu pedido {{numero_pedido}}.\n\n🔍 Motivo: {{motivo_falla}}\n📦 Tu pedido está seguro y lo intentaremos nuevamente.\n\n📞 ¿Podrías contactarnos al {{telefono_pyme}} para coordinar?\n\nAgradecemos tu comprensión y paciencia.\n\nSaludos cordiales,\nEl equipo de {{nombre_pyme}}', 
 '["{{nombre_cliente}}", "{{numero_pedido}}", "{{motivo_falla}}", "{{telefono_pyme}}", "{{nombre_pyme}}"]'),

('WhatsApp Aviso Entrega Próxima', 'AVISO_ENTREGA_PROXIMA', 'WHATSAPP', '⏰ ¡Tu pedido llega hoy!', 
 '¡Hola {{nombre_cliente}}! ⏰\n\n¡Atención! Tu pedido {{numero_pedido}} será entregado hoy.\n\n🕐 Horario estimado: {{horario_entrega}}\n📍 Dirección: {{direccion_entrega}}\n\n¡Asegúrate de estar disponible! 🏠\n\nSi necesitas cambiar algo, avísanos rápido.\n\n¡Gracias! 🎉', 
 '["{{nombre_cliente}}", "{{numero_pedido}}", "{{horario_entrega}}", "{{direccion_entrega}}"]');

INSERT INTO configuracion_canal (canal_notificacion, proveedor, configuracion, activo) VALUES
('CORREO_ELECTRONICO', 'SMTP', '{"host": "smtp.gmail.com", "port": 587, "username": "contacto@pymetrack.cl", "password": "app_password_here", "from": "PymeTrack Chile <contacto@pymetrack.cl>", "use_tls": true, "use_ssl": false}', TRUE),
('MENSAJE_TEXTO', 'TWILIO', '{"account_sid": "ACxxxxxxxx", "auth_token": "xxxxxxxx", "from_number": "+569XXXXXXXX"}', FALSE),
('WHATSAPP', 'WHATSAPP_API', '{"phone_number_id": "xxxxxxxx", "access_token": "xxxxxxxx", "version": "v16.0"}', FALSE);

INSERT INTO regla_anti_saturacion (nombre, tipo_evento, condicion_geografica, valor_condicion, activa) VALUES
('Radio 2km para entrega en camino', 'ENTREGA_EN_CAMINO', 'DENTRO_RADIO_KM', 2.0, TRUE),
('Máximo 3 notificaciones por hora', 'AVISO_ENTREGA_PROXIMA', 'TIEMPO_ULTIMA_NOTIFICACION', 60.0, TRUE),
('Máximo 2 entregas previas', 'ENTREGA_EN_CAMINO', 'ENTREGAS_PREVIAS', 2.0, TRUE);
