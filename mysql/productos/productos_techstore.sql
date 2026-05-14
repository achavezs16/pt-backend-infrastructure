-- Catálogo de Productos TechStore SPA - 20 productos tecnológicos
-- Categorías: SMARTPHONE, NOTEBOOK, COMPUTADOR, ACCESORIOS

USE ms_pedidos;

-- Smartphones (5 productos)
INSERT INTO producto (
    id_pyme, codigo_sku, nombre_producto, descripcion_producto, 
    precio_venta_chile, peso_producto_kg, dimensiones_producto, 
    categoria_producto, imagen_url, activo
) VALUES 
-- Smartphones gama alta
(1, 'TECH-SM001', 'iPhone 15 Pro', 'Apple iPhone 15 Pro 256GB - Titanio natural con chip A17 Pro', 899990, 0.187, '15.0 x 7.5 x 0.8 cm', 'SMARTPHONE', 'https://images.apple.com/iphone-15-pro/images/overview/hero/hero_iphone_15_pro__i8902x.png', TRUE),
(1, 'TECH-SM002', 'Samsung Galaxy S24 Ultra', 'Samsung Galaxy S24 Ultra 256GB - Negro con S Pen', 799990, 0.234, '16.3 x 7.8 x 0.8 cm', 'SMARTPHONE', 'https://images.samsung.com/is/image/samsung/p6pim/cl/2402/gallery/cl-galaxy-s24-ultra-s928-sm-s928bzkdcl-537240656?$720_576_PNG$', TRUE),
(1, 'TECH-SM003', 'Google Pixel 8 Pro', 'Google Pixel 8 Pro 128GB - Bay Blue con Tensor G3', 699990, 0.213, '16.2 x 7.6 x 0.8 cm', 'SMARTPHONE', 'https://store.google.com/static/images/pixel-8-pro/pro/kv2.jpg', TRUE),
(1, 'TECH-SM004', 'OnePlus 12', 'OnePlus 12 256GB - Flowy Emerald con Snapdragon 8 Gen 3', 599990, 0.193, '16.3 x 7.5 x 0.8 cm', 'SMARTPHONE', 'https://www.oneplus.com/content/dam/oneplus/oneplus-12/product/oneplus-12-flowy-emerald.png', TRUE),
(1, 'TECH-SM005', 'Xiaomi 14 Pro', 'Xiaomi 14 Pro 256GB - Negro con Snapdragon 8 Gen 3', 499990, 0.219, '16.2 x 7.6 x 0.8 cm', 'SMARTPHONE', 'https://i01.appmifile.com/v1/MI_18455B3E4DA706226CF7535A58E875F0.png', TRUE),

-- Notebooks (5 productos)
(1, 'TECH-NB001', 'MacBook Air M2', 'Apple MacBook Air 13" M2 256GB - Medianoche', 999990, 1.240, '30.4 x 21.2 x 1.1 cm', 'NOTEBOOK', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-select-20230606?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1684340933094', TRUE),
(1, 'TECH-NB002', 'Lenovo ThinkPad E14', 'Lenovo ThinkPad E14 Intel Core i5 8GB 512GB SSD', 499990, 1.680, '32.9 x 22.8 x 1.8 cm', 'NOTEBOOK', 'https://www.lenovo.com/medias/lenovo-pc-products/thinkpad-laptops/thinkpad-e14-gen-4/gallery/thinkpad-e14-gen-4-hero.png', TRUE),
(1, 'TECH-NB003', 'Dell XPS 13', 'Dell XPS 13 Intel Core i7 16GB 512GB SSD - Platinum Silver', 899990, 1.170, '29.6 x 19.9 x 1.5 cm', 'NOTEBOOK', 'https://i.dell.com/is/image/DellContent/content/dam/ss2/product-images/dell-client-products/performance-laptops/xps-13-9330/media-gallery/x13-9330-gy-pdp-gallery-1.psd?fmt=pjpg&pscan=auto&scl=1&hei=402&wid=573&qlt=100', TRUE),
(1, 'TECH-NB004', 'HP Spectre x360', 'HP Spectre x360 14 Intel Core i7 16GB 512GB - Nightfall Black', 799990, 1.400, '31.6 x 22.4 x 1.7 cm', 'NOTEBOOK', 'https://www.hp.com/us-en/shop/app/assets/images/uploads/prod/x360-14-eu0097nr-1.png', TRUE),
(1, 'TECH-NB005', 'ASUS ZenBook 14', 'ASUS ZenBook 14 AMD Ryzen 7 16GB 1TB SSD - Celestial Blue', 699990, 1.300, '31.2 x 22.0 x 1.6 cm', 'NOTEBOOK', 'https://dlcdnweb.asus.com/gfx/2019/vivo/zenbook-2024/Zenbook-14-UX3405/KV-UX3405-1.png', TRUE),

-- Computadores Desktop (5 productos)
(1, 'TECH-PC001', 'iMac 24" M1', 'Apple iMac 24" M1 256GB 8GB RAM - Azul', 899990, 4.480, '56.9 x 47.3 x 18.1 cm', 'COMPUTADOR', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/imac-24-blue-select-202311?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1698726357809', TRUE),
(1, 'TECH-PC002', 'Gaming Desktop RTX 4060', 'PC Gaming Intel Core i5 RTX 4060 16GB 1TB SSD - RGB', 699990, 8.500, '45.0 x 20.0 x 42.0 cm', 'COMPUTADOR', 'https://www.nzxt.com/assets/uploads/products/cases/h210i-rgb/h210i-rgb-black-1.jpg', TRUE),
(1, 'TECH-PC003', 'Mac Studio M2', 'Apple Mac Studio M2 512GB 32GB RAM - Space Gray', 1299990, 2.900, '19.7 x 19.7 x 9.5 cm', 'COMPUTADOR', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-select-20230606?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1684340933094', TRUE),
(1, 'TECH-PC004', 'Dell OptiPlex', 'Dell OptiPlex Intel Core i7 16GB 512GB SSD - Negro', 399990, 5.200, '29.0 x 29.0 x 9.3 cm', 'COMPUTADOR', 'https://i.dell.com/is/image/DellContent/content/dam/ss2/product-images/dell-client-products/computers/optiplex-desktops/optiplex-5000/media-gallery/optiplex-5000-tower-gallery-1.psd?fmt=pjpg&pscan=auto&scl=1&hei=402&wid=573&qlt=100', TRUE),
(1, 'TECH-PC005', 'HP EliteDesk', 'HP EliteDesk Intel Core i5 8GB 256GB SSD - Microtower', 299990, 4.800, '33.5 x 16.5 x 38.0 cm', 'COMPUTADOR', 'https://www.hp.com/us-en/shop/app/assets/images/uploads/prod/eliteone-800-g9-4z8x4ea-1.png', TRUE),

-- Accesorios (5 productos)
(1, 'TECH-AC001', 'Magic Mouse', 'Apple Magic Mouse - Multi-Touch Surface', 79990, 0.099, '11.4 x 5.7 x 2.1 cm', 'ACCESORIOS', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MMMQ3?wid=2000&hei=2000&fmt=jpeg&qlt=95&.v=1632863672000', TRUE),
(1, 'TECH-AC002', 'Mechanical Keyboard RGB', 'Teclado mecánico RGB switches azules - Español Latino', 49990, 0.850, '44.0 x 13.0 x 3.5 cm', 'ACCESORIOS', 'https://www.razer.com/merchant/1933/products/668/images/7b6c0e3c5c3e4a5b9c6d7e8f9a0b1c2d.png', TRUE),
(1, 'TECH-AC003', 'AirPods Pro 2', 'Apple AirPods Pro 2ª generación con MagSafe', 249990, 0.053, '4.6 x 2.1 x 5.4 cm', 'ACCESORIOS', 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/airpods-pro-2-hero-select-202209?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1663090989298', TRUE),
(1, 'TECH-AC004', 'Monitor 27" 4K', 'LG UltraFine 27" 4K IPS - USB-C', 299990, 6.100, '62.0 x 38.0 x 5.0 cm', 'ACCESORIOS', 'https://www.lg.com/us/images/monitors/MD04925212/gallery/MD04925212-G1.jpg', TRUE),
(1, 'TECH-AC005', 'USB-C Hub 7-in-1', 'Hub USB-C 7 puertos HDMI 4K SD Card Reader', 19990, 0.050, '12.0 x 4.0 x 1.5 cm', 'ACCESORIOS', 'https://www.anker.com/media/wysiwyg/7-in-1-usb-c-hub-a8342.png', TRUE);
