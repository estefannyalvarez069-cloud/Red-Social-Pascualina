--
-- Scripts de DELETE de la Base de Datos  - SGBD PostgreSQL
--
-- 1. PRODUCTO: Inserción y eliminación
-- Inserción
INSERT INTO t_producto (id_usuario_vendedor, id_tipo_producto, nombre_producto, descripcion, precio, stock) 
VALUES ((SELECT id_usuario FROM t_usuario LIMIT 1), 1, 'Equipo de sonido', 'Dispositivo de audio de prueba ', 15000, 10);

-- Verificación de creación
SELECT * FROM t_producto WHERE nombre_producto = 'Equipo de sonido';

-- Eliminación. Ese producto no se comercializará todavía
DELETE FROM t_producto WHERE nombre_producto = 'Equipo de sonido';

-- Verificación de eliminación
SELECT * FROM t_producto WHERE nombre_producto = 'Equipo de sonido';


-- 2. EVENTO: Inserción y eliminación
-- Inserción
INSERT INTO t_evento (id_usuario_organizador, id_tipo_evento, titulo, descripcion, detalles_logistica) 
VALUES ((SELECT id_usuario FROM t_usuario LIMIT 1), 1, 'Conferencia compra de vivienda', 'Evento cancelado por error administrativo', '{}');

-- Verificación de creación
SELECT * FROM t_evento WHERE titulo = 'Conferencia compra de vivienda';

-- Eliminación  Ese evemto ya no se publicará en la Red.
DELETE FROM t_evento WHERE titulo = 'Conferencia compra de vivienda';

-- Verificación de eliminación
SELECT * FROM t_evento WHERE titulo = 'Conferencia compra de vivienda';


-- 3. SERVICIO: Inserción y eliminación
-- Inserción
INSERT INTO t_servicio (id_usuario_ofertante, id_tipo_servicio, descripcion, precio) 
VALUES ((SELECT id_usuario FROM t_usuario LIMIT 1), 1, 'Mantenimiento de computador', 500);

-- Verificación de creación
SELECT * FROM t_servicio WHERE descripcion = 'Mantenimiento de computador';

-- Eliminación Ese servicio ya no se ofrecerá en la Red.

DELETE FROM t_servicio WHERE descripcion = 'Mantenimiento de computador';

-- Verificación de eliminación
SELECT * FROM t_servicio WHERE descripcion = 'Mantenimiento de computador';