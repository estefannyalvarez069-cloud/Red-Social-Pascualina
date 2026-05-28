--
-- Script de VIEW de la Base de Datos  - SGBD PostgreSQL
-- 

-- VISTA 1: v_resumen_marketplace 

CREATE VIEW v_resumen_marketplace AS
SELECT 
    p.id_producto AS codigo_producto,
    p.nombre_producto AS producto,
    p.precio AS precio_unitario,
    p.stock AS unidades_disponibles,
    p.id_tipo_producto AS codigo_categoria_producto, 
    u.nombre_completo AS nombre_vendedor,
    u.usuario_tag AS contacto_vendedor,
    p.atributos_producto->>'condicion' AS estado_articulo
FROM t_producto p
JOIN t_usuario u ON p.id_usuario_vendedor = u.id_usuario
WHERE u.estado_registro = TRUE
ORDER BY p.precio DESC;

-- >>> VERIFICACIÓN VISTA 1 <<<
SELECT * FROM v_resumen_marketplace;


--  VISTA 2: v_actividad_publicaciones 

CREATE VIEW v_actividad_publicaciones AS
SELECT 
    p.id_publicacion AS codigo_post,
    u.nombre_completo AS autor_publicacion,
    tu.nombre_tipo AS estamento_usuario, 
    r.nombre_rol AS rol_plataforma,      
    p.contenido_texto AS extracto_contenido,
    p.fecha_registro AS publicado_el
FROM t_publicacion p
JOIN t_usuario u ON p.id_usuario = u.id_usuario
JOIN t_maestra_tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
JOIN t_maestra_rol r ON u.id_rol = r.id_rol
ORDER BY p.fecha_registro DESC;

-- >>> VERIFICACIÓN VISTA 2 <<<
SELECT * FROM v_actividad_publicaciones;


-- VISTA 3: v_servicios_adquiridos 

CREATE VIEW v_servicios_adquiridos AS
SELECT 
    s.id_servicio AS codigo_servicio,             
    mts.nombre_tipo_servicio AS categoria_servicio, 
    s.precio AS valor_pactado,
    u_ofer.nombre_completo AS prestador_servicio,  
    u_adqu.nombre_completo AS cliente_estudiante,  
    us.estado_servicio AS situacion_actual,
    us.fecha_solicitud AS registrado_el
FROM t_usuario_servicio us
JOIN t_servicio s ON us.id_servicio = s.id_servicio
JOIN t_maestra_tipo_servicio mts ON s.id_tipo_servicio = mts.id_tipo_servicio
JOIN t_usuario u_ofer ON s.id_usuario_ofertante = u_ofer.id_usuario
JOIN t_usuario u_adqu ON us.id_adquiriente = u_adqu.id_usuario 
ORDER BY us.fecha_solicitud DESC;

-- >>> VERIFICACIÓN VISTA 3 <<<
SELECT * FROM v_servicios_adquiridos;