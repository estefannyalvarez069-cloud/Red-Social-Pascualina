--
-- Scripts de LISTADOS de la Base de Datos  - SGBD PostgreSQL
--
-- -- 1. CONSULTA SIMPLE SIN JOIN
-- Listar todos los usuarios con su información, fecha de nacimiento e ingreso.
-- Nota: Se asume que fecha_nacimiento está dentro del JSONB 'data_institucional' o fue agregada previamente.
SELECT 
    id_usuario, 
    nombre_completo, 
    usuario_tag, 
    (data_institucional->>'fecha_nacimiento') AS fecha_nacimiento, 
    estado_registro,
    id_rol,
    id_tipo_usuario
FROM t_usuario;

---

-- 2. CONSULTA CON 1 JOIN
-- Listar eventos (orden descendiente) con el nombre del organizador y datos del evento.
SELECT 
    u.nombre_completo AS nombre_organizador,
    e.id_evento,
    e.titulo,
    e.descripcion,
    e.detalles_logistica,
    e.fecha_registro
FROM t_evento e
JOIN t_usuario u ON e.id_usuario_organizador = u.id_usuario
ORDER BY e.fecha_registro DESC;

---

-- 3. CONSULTA CON 2 JOINS
-- Consulta #3 con 2 JOIN: Listar eventos de un usuario promotor con sus usuarios suscritos.
SELECT 
    u_prom.id_usuario AS codigo_promotor,
    u_prom.nombre_completo AS nombre_promotor,
    e.titulo AS nombre_evento,
    e.id_tipo_evento,
    ue.id_usuario AS codigo_usuario_suscrito,
    ue.fecha_inscripcion
FROM t_evento e
JOIN t_usuario u_prom ON e.id_usuario_organizador = u_prom.id_usuario
JOIN t_usuario_evento ue ON e.id_evento = ue.id_evento
WHERE u_prom.nombre_completo = 'Nombre de un usuario real en tu tabla';

-- 4. CONSULTA CON 3 JOINS
-- Productos vendidos el último mes con fecha, transacción, nombre, precio y vendedor.
SELECT 
    up.fecha_transaccion AS fecha_venta,
    up.id_compra_transaccion AS numero_transaccion_venta,
    p.nombre_producto,
    p.precio,
    u.nombre_completo AS nombre_usuario_vendedor
FROM t_usuario_producto up
JOIN t_producto p ON up.id_producto = p.id_producto
JOIN t_usuario u ON p.id_usuario_vendedor = u.id_usuario
JOIN t_maestra_tipo_producto tp ON p.id_tipo_producto = tp.id_tipo_producto
WHERE up.fecha_transaccion BETWEEN '2024-04-01' AND '2024-04-30'; 

---

-- 5. CONSULTA CON 4 JOINS
-- Servicios consumidos de un tipo específico en los últimos 3 meses.
SELECT 
    us.fecha_solicitud AS fecha_consumo_servicio,
    s.id_servicio AS codigo_servicio,
    mts.nombre_tipo_servicio AS nombre_servicio,
    s.precio,
    u_ven.id_usuario AS codigo_usuario_vendedor,
    u_ven.nombre_completo AS nombre_usuario_vendedor,
    u_con.id_usuario AS codigo_usuario_consumidor,
    u_con.nombre_completo AS nombre_usuario_consumio
FROM t_usuario_servicio us
JOIN t_servicio s ON us.id_servicio = s.id_servicio
JOIN t_maestra_tipo_servicio mts ON s.id_tipo_servicio = mts.id_tipo_servicio
JOIN t_usuario u_ven ON s.id_usuario_ofertante = u_ven.id_usuario
JOIN t_usuario u_con ON us.id_adquiriente = u_con.id_usuario
WHERE mts.nombre_tipo_servicio = 'Suscripción' -- Tipo de servicio de su escogencia
  AND us.fecha_solicitud >= CURRENT_DATE - INTERVAL '3 months'
ORDER BY us.fecha_solicitud DESC, u_ven.nombre_completo ASC;
---

-- 6. CONSULTA CON 4 JOINS (INSIGHT)
-- Listar comentarios realizados en publicaciones, incluyendo el rol del usuario que comenta 
-- y el tipo de usuario del autor de la publicación.
SELECT 
    p.id_publicacion,
    p.contenido_texto AS contenido_publicacion,
    u_autor.nombre_completo AS autor_publicacion,
    mtu.nombre_tipo AS tipo_usuario_autor,
    c.contenido AS comentario_realizado,
    u_coment.nombre_completo AS usuario_que_comento,
    mr.nombre_rol AS rol_del_comentarista
FROM t_comentario c
JOIN t_publicacion p ON c.id_publicacion = p.id_publicacion
JOIN t_usuario u_autor ON p.id_usuario = u_autor.id_usuario
JOIN t_maestra_tipo_usuario mtu ON u_autor.id_tipo_usuario = mtu.id_tipo_usuario
JOIN t_usuario u_coment ON c.id_usuario = u_coment.id_usuario
JOIN t_maestra_rol mr ON u_coment.id_rol = mr.id_rol;

