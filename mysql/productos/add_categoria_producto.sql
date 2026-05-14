-- Agregar columnas faltantes a la tabla producto existente
USE ms_pedidos;

-- Agregar la columna imagen_url
ALTER TABLE producto 
ADD COLUMN imagen_url VARCHAR(500) AFTER dimensiones_producto;

-- Agregar la columna categoria_producto
ALTER TABLE producto 
ADD COLUMN categoria_producto ENUM('SMARTPHONE', 'NOTEBOOK', 'COMPUTADOR', 'ACCESORIOS') NOT NULL AFTER imagen_url;

-- Verificar la estructura de la tabla
DESCRIBE producto;
