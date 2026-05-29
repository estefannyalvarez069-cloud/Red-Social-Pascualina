--
-- Script de Consulta con Parámtros a partir de una Vista (VIEW) de la Base de Datos  - SGBD PostgreSQL
--
-- 


--
-- 1.- Crea la vista (VIEW)
--      No debe tener ni WHERE ni GROUP BY ni ORDER BY (no tendría sentido para la reutilización)
--
DROP VIEW IF EXISTS v_base_auditoria_vendedores CASCADE;

CREATE VIEW v_base_auditoria_vendedores AS
SELECT 
    u.id_usuario,
    u.nombre_completo AS vendedor,
    tu.nombre_tipo AS estamento,
    p.atributos_producto->>'condicion' AS condicion_articulo,
    p.precio,
    p.stock,
    (p.precio * p.stock) AS valor_inventario_potencial
FROM t_producto p
JOIN t_usuario u ON p.id_usuario_vendedor = u.id_usuario
JOIN t_maestra_tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario;



--
-- 2.- Preparar la consulta (utilizando la vista)
--      Aquí se colocan los parámetros
--      Se aplican los parámetros a un dato en el WHERE y un dato en el HAVING
--
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_prepared_statements WHERE name = 'p_auditoria_consejo') THEN
        DEALLOCATE p_auditoria_consejo;
    END IF;
END $$;

PREPARE p_auditoria_consejo(text, numeric) AS
SELECT 
    vendedor,
    estamento,
    COUNT(*) AS total_productos_ofertados,
    SUM(valor_inventario_potencial) AS total_ventas_potenciales
FROM v_base_auditoria_vendedores
WHERE condicion_articulo = $1 
GROUP BY vendedor, estamento
HAVING SUM(valor_inventario_potencial) >= $2;



--
-- 3.- Ejecutar 3 consultas con diferentes parámetros (EXECUTE)
--
-- Consulta 1: Buscar vendedores de artículos 'Nuevo' con ingresos potenciales >= $50,000
EXECUTE p_auditoria_consejo('Nuevo', 50000);

-- Consulta 2: Buscar vendedores de artículos 'Usado' con ingresos potenciales >= $10,000
EXECUTE p_auditoria_consejo('Usado', 10000);

-- Consulta 3: Buscar vendedores de artículos 'Nuevo' con un umbral muy alto (ej. >= $200,000)
EXECUTE p_auditoria_consejo('Nuevo', 200000);


--
-- 4.-  Explicar la importancia de esta experiencia 
--
-- La realización de este ejercicio técnico nos revela la enorme importancia de dos
-- conceptos avanzados en la gestión de bases de datos: la reutilización de código y la seguridad del servidor.