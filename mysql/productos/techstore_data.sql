-- Datos TechStore SPA - MVP Catálogo Tecnológico
-- Empresa: TechStore SPA - Retail tecnológico

USE ms_pedidos;

-- Insertar TechStore SPA
INSERT INTO pyme (
    nombre_pyme, 
    rut_pyme, 
    email_contacto_pyme, 
    telefono_contacto_pyme, 
    direccion_sucursal_pyme, 
    comuna_sucursal_pyme, 
    region_sucursal_pyme,
    activo
) VALUES (
    'TechStore SPA',
    '76.543.210-9',
    'contacto@techstore.cl',
    '+56923456789',
    'Av. Apoquindo 6900, Local 215, Costanera Center',
    'Las Condes',
    'Metropolitana',
    TRUE
);

-- Obtener ID de TechStore para usar en productos (será 1 si es la primera PYME)
