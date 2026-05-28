--
-- Scripts de Update de la Base de Datos  - SGBD PostgreSQL
--
-- Update de las tablas
-- 
-- 1. Actualización de dirección de un usuario
-- Como no hay columna 'direccion', la insertaremos/actualizaremos dentro del JSONB 'data_institucional'

UPDATE t_usuario 
SET data_institucional = data_institucional || '{"direccion": "Calle 10 # 5-20"}'::jsonb
WHERE usuario_tag = 'maria.bermudez10';

SELECT data_institucional FROM t_usuario WHERE usuario_tag = 'maria.bermudez10';

-- 2. Actualización de ubicación (dirección) de un evento
-- Usamos el campo JSONB 'detalles_logistica' que sí tienes en la tabla t_evento
UPDATE t_evento 
SET detalles_logistica = detalles_logistica || '{"ubicacion": "Auditorio Bloque 1"}'::jsonb
WHERE titulo = 'Artículo Universitario Tipo 12';


--3 Actualización de precios
-- Identificar los nombre de producto
SELECT nombre_producto, precio 
FROM t_producto 
LIMIT 10;


-- Actualización Producto A
SELECT nombre_producto, precio FROM t_producto WHERE nombre_producto = 'Artículo Universitario Tipo 12';
UPDATE t_producto SET precio = 15000.00 WHERE nombre_producto = 'Artículo Universitario Tipo 12';
SELECT nombre_producto, precio FROM t_producto WHERE nombre_producto = 'Artículo Universitario Tipo 12';

-- Actualización Producto B
SELECT nombre_producto, precio FROM t_producto WHERE nombre_producto = 'Artículo Universitario Tipo 24';
UPDATE t_producto SET precio = 25000.00 WHERE nombre_producto = 'Artículo Universitario Tipo 24';
SELECT nombre_producto, precio FROM t_producto WHERE nombre_producto = 'Artículo Universitario Tipo 24';

-- Actualización Producto C
SELECT nombre_producto, precio FROM t_producto WHERE nombre_producto = 'Artículo Universitario Tipo 36';
UPDATE t_producto SET precio = 35000.00 WHERE nombre_producto = 'Artículo Universitario Tipo 36';
SELECT nombre_producto, precio FROM t_producto WHERE nombre_producto = 'Artículo Universitario Tipo 36';

-- 4 Actualización de fechas de evento

-- Actualización de fecha para el primer evento
SELECT titulo, fecha_registro FROM t_evento WHERE titulo = 'Encuentro e Integración Nro 10';
UPDATE t_evento SET fecha_registro = '2026-06-15 10:00:00' WHERE titulo = 'Encuentro e Integración Nro 10';
SELECT titulo, fecha_registro FROM t_evento WHERE titulo = 'Encuentro e Integración Nro 10';

-- Actualización de fecha para el segundo evento
SELECT titulo, fecha_registro FROM t_evento WHERE titulo = 'Encuentro e Integración Nro 20';
UPDATE t_evento SET fecha_registro = '2026-07-20 14:30:00' WHERE titulo = 'Encuentro e Integración Nro 20';
SELECT titulo, fecha_registro FROM t_evento WHERE titulo = 'Encuentro e Integración Nro 20';
