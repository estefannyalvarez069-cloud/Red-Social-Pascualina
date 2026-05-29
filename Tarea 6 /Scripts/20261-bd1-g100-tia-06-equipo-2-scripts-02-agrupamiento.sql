--
-- Scripts de Consultas con agrupamientos y funciones de agregación de la Base de Datos  - SGBD PostgreSQL
-- 


--
-- Consulta #1: Grupos
-- 
SELECT 
    g.id_grupo AS identificacion_del_grupo,
    g.nombre_grupo,
    g.fecha_creacion AS fecha_de_creacion_del_grupo,
    u_crea.nombre_completo AS usuario_creador_del_grupo,
    COUNT(ug.id_usuario) AS cantidad_de_usuarios_pertenecientes_al_grupo
FROM t_grupo g
JOIN t_usuario u_crea ON g.id_usuario_creador = u_crea.id_usuario
LEFT JOIN t_usuario_grupo ug ON g.id_grupo = ug.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.fecha_creacion, u_crea.nombre_completo
ORDER BY g.nombre_grupo ASC;

--
-- Consulta #2: Eventos
-- 
SELECT 
    te.id_tipo_evento AS identificacion_del_tipo_evento,
    te.nombre_tipo_evento AS nombre_tipo_evento,
    u_prom.nombre_completo AS usuario_promotor_del_evento,
    e.descripcion AS descripcion_del_evento,
    e.fecha_registro AS fecha_evento,
    COUNT(ue.id_usuario) AS cantidad_de_usuarios_adscritos_al_evento
FROM t_evento e
JOIN t_maestra_tipo_evento te ON e.id_tipo_evento = te.id_tipo_evento
JOIN t_usuario u_prom ON e.id_usuario_organizador = u_prom.id_usuario
LEFT JOIN t_usuario_evento ue ON e.id_evento = ue.id_evento
GROUP BY te.id_tipo_evento, te.nombre_tipo_evento, u_prom.nombre_completo, e.descripcion, e.fecha_registro
ORDER BY e.fecha_registro DESC;

--
-- Consulta #3: Tipos de Servicio
-- 
SELECT 
    mts.id_tipo_servicio AS identificacion_del_tipo_servicio,
    mts.nombre_tipo_servicio,
    COUNT(DISTINCT us.id_adquiriente) AS cantidad_de_usuarios_que_consumieron_el_tipo_servicio
FROM t_maestra_tipo_servicio mts
JOIN t_servicio s ON mts.id_tipo_servicio = s.id_tipo_servicio
JOIN t_usuario_servicio us ON s.id_servicio = us.id_servicio
WHERE us.fecha_solicitud >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY mts.id_tipo_servicio, mts.nombre_tipo_servicio
ORDER BY cantidad_de_usuarios_que_consumieron_el_tipo_servicio DESC;

--
-- Consulta #4: Productos
-- 
SELECT 
    tp.nombre_tipo_producto AS nombre_tipo_producto,
    p.nombre_producto,
    u_vend.nombre_completo AS vendedor_del_producto,
    SUM(p.precio * p.stock) AS suma_del_total_vendido
FROM t_producto p
JOIN t_maestra_tipo_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
JOIN t_usuario u_vend ON p.id_usuario_vendedor = u_vend.id_usuario
WHERE p.fecha_registro >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY tp.nombre_tipo_producto, p.nombre_producto, u_vend.nombre_completo
ORDER BY suma_del_total_vendido DESC
LIMIT 20;

--
-- Consulta #5: Tipos de Producto
-- 
SELECT 
    tp.nombre_tipo_producto AS nombre_tipo_producto,
    COUNT(DISTINCT p.id_usuario_vendedor) AS total_usuarios_vendedores,
    COUNT(DISTINCT p.id_usuario_vendedor) AS total_usuarios_compradores,
    SUM(p.precio * p.stock) AS monto_total_de_ventas,
    AVG(p.precio) AS promedio_del_monto_de_venta,
    MAX(p.precio) AS monto_venta_maxima,
    MIN(p.precio) AS monto_venta_minima
FROM t_maestra_tipo_producto tp
JOIN t_producto p ON tp.id_tipo_producto = p.id_tipo_producto
GROUP BY tp.id_tipo_producto, tp.nombre_tipo_producto
ORDER BY monto_total_de_ventas DESC;

--
-- Consulta #6: LIBRE DE PLANTEAMIENTO
-- 
SELECT 
    u.id_usuario,
    u.nombre_completo AS usuario,
    tu.nombre_tipo AS estamento,
    COUNT(p.id_publicacion) AS total_publicaciones_realizadas
FROM t_usuario u
JOIN t_maestra_tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
JOIN t_maestra_rol r ON u.id_rol = r.id_rol
JOIN t_publicacion p ON u.id_usuario = p.id_usuario
WHERE u.estado_registro = TRUE
GROUP BY u.id_usuario, u.nombre_completo, tu.nombre_tipo, r.nombre_rol
HAVING COUNT(p.id_publicacion) >= 5
ORDER BY total_publicaciones_realizadas DESC;