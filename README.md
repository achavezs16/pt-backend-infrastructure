# Infraestructura PymeTrack MVP

## Docker Compose - Desarrollo Local

Este archivo `docker-compose.yml` configura toda la infraestructura necesaria para ejecutar el MVP localmente.

### Servicios Configurados

#### Bases de Datos MySQL
- **mysql-pedidos**: Puerto 3306 - Base de datos para gestión de pedidos e inventario
- **mysql-envios**: Puerto 3307 - Base de datos para logística y rutas
- **mysql-notificaciones**: Puerto 3308 - Base de datos para sistema de notificaciones

#### Mensajería
- **rabbitmq**: Puerto 5672 (AMQP) y 15672 (Management UI) - Colas para comunicación asíncrona

#### Herramientas de Administración
- **phpmyadmin**: Puerto 8080 - Interfaz web para administrar las 3 bases de datos
- **redis**: Puerto 6379 - Caché y sesiones (opcional para MVP)

### Iniciar la Infraestructura

```bash
# Desde el directorio infrastructure/
docker-compose up -d
```

### Acceso a los Servicios

- **MySQL Pedidos**: localhost:3306 (root/password)
- **MySQL Envíos**: localhost:3307 (root/password)  
- **MySQL Notificaciones**: localhost:3308 (root/password)
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **PhpMyAdmin**: http://localhost:8080

### Datos de Ejemplo

Las bases de datos se inicializan automáticamente con datos de prueba:

#### PYMEs (ms-pedidos)
- TechStore SPA
- ModaExpress Ltda  
- ElectroWorld SA

#### Productos
- 8 productos diferentes con stock disponible
- Precios desde $19.990 hasta $899.990

#### Repartidores (ms-envíos)
- 5 repartidores con diferentes tipos de vehículos
- Estados: DISPONIBLE, OCUPADO, DESCANSO

#### Plantillas de Notificaciones (ms-notificaciones)
- 5 plantillas de email para diferentes eventos
- Configuración SMTP simulada
- Reglas de anti-saturación

### Detener la Infraestructura

```bash
docker-compose down
```

### Limpiar Datos (eliminar volúmenes)

```bash
docker-compose down -v
```

## Configuración de Aplicaciones

Las aplicaciones Spring Boot están configuradas para conectarse a estos servicios:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ms_pedidos
    username: root
    password: password
    
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
```

## Flujo Completo de Prueba

1. **Iniciar infraestructura**: `docker-compose up -d`
2. **Iniciar microservicios**: Ejecutar los 3 servicios Spring Boot
3. **Crear pedido**: POST a ms-pedidos:8081/api/v1/pedidos/crearPedido
4. **Verificar cola**: RabbitMQ Management UI
5. **Actualizar estado**: PATCH a ms-envios:8082/api/v1/envios/{id}/estado
6. **Ver notificaciones**: Logs de ms-notificaciones en consola

## Troubleshooting

### Problemas Comunes

1. **Puertos en uso**: Cambiar los puertos en docker-compose.yml
2. **Permisos de MySQL**: Verificar que los usuarios tengan los permisos correctos
3. **Conexión RabbitMQ**: Esperar 30 segundos después de iniciar los contenedores

### Logs

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f mysql-pedidos
docker-compose logs -f rabbitmq
```

### Reiniciar Servicios

```bash
# Reiniciar un servicio específico
docker-compose restart mysql-pedidos

# Reiniciar todos los servicios
docker-compose restart
```
