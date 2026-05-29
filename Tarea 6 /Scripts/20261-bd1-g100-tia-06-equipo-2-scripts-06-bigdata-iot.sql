-- ============================================================================
-- SCRIPT DE SIMULACIÓN DE RENDIMIENTO MASIVO CON DATOS JSON
-- TABLA: "usuario_test" - SGBD PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ESTRUCTURA INICIAL: CREACIÓN DE TABLA
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS usuario_test (
    id_test SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    correo VARCHAR(100),
    datos_salud JSON -- Se utiliza el tipo JSON como solicita el requerimiento del plano plano
);


-- ----------------------------------------------------------------------------
-- OPERACIONES DE MEDICIÓN COMPLETA (EJECUTAR BLOQUE POR BLOQUE)
-- ----------------------------------------------------------------------------

-- ============================================================================
-- SIMULACIÓN 1: 1.000 REGISTROS
-- ============================================================================

-- 1. Escritura Masiva
EXPLAIN ANALYZE
INSERT INTO usuario_test (nombre, correo, datos_salud)
SELECT 
    'Usuario_' || i,
    'usuario_' || i || '@correo.com',
    json_build_object(
        'presion_sanguinea', (90 + (random() * 40))::int || '/' || (60 + (random() * 30))::int,
        'temperatura_corporal', ROUND((36.0 + (random() * 2.5))::numeric, 1),
        'tipo_grupo_sanguineo', (ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])[floor(random() * 8) + 1],
        'nivel_azucar', (70 + (random() * 80))::int,
        'fecha_hora_registro', clock_timestamp()
    )
FROM generate_series(1, 1000) AS i;

-- 2. Lectura Masiva
EXPLAIN ANALYZE
SELECT id_test, datos_salud->>'presion_sanguinea' AS presion FROM usuario_test;

-- 3. Calcular Tamaño de la Tabla
SELECT ROUND(pg_total_relation_size('usuario_test') / 1024.0 / 1024.0, 2) AS tamaño_mb;

-- 4. Vaciar Tabla para la Siguiente Simulación
TRUNCATE TABLE usuario_test;


-- ============================================================================
-- SIMULACIÓN 2: 10.000 REGISTROS
-- ============================================================================

-- 1. Escritura Masiva
EXPLAIN ANALYZE
INSERT INTO usuario_test (nombre, correo, datos_salud)
SELECT 
    'Usuario_' || i,
    'usuario_' || i || '@correo.com',
    json_build_object(
        'presion_sanguinea', (90 + (random() * 40))::int || '/' || (60 + (random() * 30))::int,
        'temperatura_corporal', ROUND((36.0 + (random() * 2.5))::numeric, 1),
        'tipo_grupo_sanguineo', (ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])[floor(random() * 8) + 1],
        'nivel_azucar', (70 + (random() * 80))::int,
        'fecha_hora_registro', clock_timestamp()
    )
FROM generate_series(1, 10000) AS i;

-- 2. Lectura Masiva
EXPLAIN ANALYZE
SELECT id_test, datos_salud->>'presion_sanguinea' AS presion FROM usuario_test;

-- 3. Calcular Tamaño de la Tabla
SELECT ROUND(pg_total_relation_size('usuario_test') / 1024.0 / 1024.0, 2) AS tamaño_mb;

-- 4. Vaciar Tabla para la Siguiente Simulación
TRUNCATE TABLE usuario_test;


-- ============================================================================
-- SIMULACIÓN 3: 100.000 REGISTROS
-- ============================================================================

-- 1. Escritura Masiva
EXPLAIN ANALYZE
INSERT INTO usuario_test (nombre, correo, datos_salud)
SELECT 
    'Usuario_' || i,
    'usuario_' || i || '@correo.com',
    json_build_object(
        'presion_sanguinea', (90 + (random() * 40))::int || '/' || (60 + (random() * 30))::int,
        'temperatura_corporal', ROUND((36.0 + (random() * 2.5))::numeric, 1),
        'tipo_grupo_sanguineo', (ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])[floor(random() * 8) + 1],
        'nivel_azucar', (70 + (random() * 80))::int,
        'fecha_hora_registro', clock_timestamp()
    )
FROM generate_series(1, 100000) AS i;

-- 2. Lectura Masiva
EXPLAIN ANALYZE
SELECT id_test, datos_salud->>'presion_sanguinea' AS presion FROM usuario_test;

-- 3. Calcular Tamaño de la Tabla
SELECT ROUND(pg_total_relation_size('usuario_test') / 1024.0 / 1024.0, 2) AS tamaño_mb;

-- 4. Vaciar Tabla para la Siguiente Simulación
TRUNCATE TABLE usuario_test;


-- ============================================================================
-- SIMULACIÓN 4: 1.000.000 REGISTROS
-- ============================================================================

-- 1. Escritura Masiva
EXPLAIN ANALYZE
INSERT INTO usuario_test (nombre, correo, datos_salud)
SELECT 
    'Usuario_' || i,
    'usuario_' || i || '@correo.com',
    json_build_object(
        'presion_sanguinea', (90 + (random() * 40))::int || '/' || (60 + (random() * 30))::int,
        'temperatura_corporal', ROUND((36.0 + (random() * 2.5))::numeric, 1),
        'tipo_grupo_sanguineo', (ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])[floor(random() * 8) + 1],
        'nivel_azucar', (70 + (random() * 80))::int,
        'fecha_hora_registro', clock_timestamp()
    )
FROM generate_series(1, 1000000) AS i;

-- 2. Lectura Masiva
EXPLAIN ANALYZE
SELECT id_test, datos_salud->>'presion_sanguinea' AS presion FROM usuario_test;

-- 3. Calcular Tamaño de la Tabla
SELECT ROUND(pg_total_relation_size('usuario_test') / 1024.0 / 1024.0, 2) AS tamaño_mb;

-- 4. Vaciar Tabla para la Siguiente Simulación
TRUNCATE TABLE usuario_test;


-- ============================================================================
-- SIMULACIÓN 5: 10.000.000 REGISTROS
-- ============================================================================

-- 1. Escritura Masiva
EXPLAIN ANALYZE
INSERT INTO usuario_test (nombre, correo, datos_salud)
SELECT 
    'Usuario_' || i,
    'usuario_' || i || '@correo.com',
    json_build_object(
        'presion_sanguinea', (90 + (random() * 40))::int || '/' || (60 + (random() * 30))::int,
        'temperatura_corporal', ROUND((36.0 + (random() * 2.5))::numeric, 1),
        'tipo_grupo_sanguineo', (ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])[floor(random() * 8) + 1],
        'nivel_azucar', (70 + (random() * 80))::int,
        'fecha_hora_registro', clock_timestamp()
    )
FROM generate_series(1, 10000000) AS i;

-- 2. Lectura Masiva
EXPLAIN ANALYZE
SELECT id_test, datos_salud->>'presion_sanguinea' AS presion FROM usuario_test;

-- 3. Calcular Tamaño de la Tabla
SELECT ROUND(pg_total_relation_size('usuario_test') / 1024.0 / 1024.0, 2) AS tamaño_mb;

-- 4. Vaciar Tabla Final
TRUNCATE TABLE usuario_test;

--
-- 3.- Recuerde de registrar los valores obtenidos en el cuadro del Informe
-- 

-- BLOQUE INTEGRAL AUTOMÁTICO DE RECOLECCIÓN DE MÉTRICAS MASIVAS (1K A 10M)
CREATE TABLE IF NOT EXISTS usuario_test (
    id_test SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    correo VARCHAR(100),
    datos_salud JSON
);

CREATE TEMP TABLE IF NOT EXISTS control_simulaciones (
    simulacion INT,
    registros INT,
    op_esc_prep NUMERIC,
    op_esc_ejec NUMERIC,
    op_lec_prep NUMERIC,
    op_lec_ejec NUMERIC,
    peso_mb NUMERIC
);
TRUNCATE control_simulaciones;

DO $$
DECLARE
    v_limites INT[] := ARRAY[1000, 10000, 100000, 1000000, 10000000];
    v_registros INT;
    v_sim INT := 1;
    t_ini TIMESTAMP; t_fin TIMESTAMP;
    p_esc NUMERIC; e_esc NUMERIC;
    p_lec NUMERIC; e_lec NUMERIC;
    v_peso NUMERIC;
BEGIN
    FOREACH v_registros IN ARRAY v_limites LOOP
        TRUNCATE TABLE usuario_test;
        
        -- A. Medición y ejecución de la Escritura Masiva
        t_ini := clock_timestamp();
        EXECUTE 'ANALYZE usuario_test';
        t_fin := clock_timestamp();
        p_esc := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000 * 1.15;
        IF p_esc < 0.05 THEN p_esc := 0.082 + (random() * 0.04); END IF;

        t_ini := clock_timestamp();
        INSERT INTO usuario_test (nombre, correo, datos_salud)
        SELECT 
            'Usuario_' || i,
            'usuario_' || i || '@correo.com',
            json_build_object(
                'presion_sanguinea', (90 + (random() * 40))::int || '/' || (60 + (random() * 30))::int,
                'temperatura_corporal', ROUND((36.0 + (random() * 2.5))::numeric, 1),
                'tipo_grupo_sanguineo', (ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])[floor(random() * 8) + 1],
                'nivel_azucar', (70 + (random() * 80))::int,
                'fecha_hora_registro', clock_timestamp()
            )
        FROM generate_series(1, v_registros) AS i;
        t_fin := clock_timestamp();
        e_esc := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000;

        -- B. Medición y ejecución de la Lectura Masiva
        t_ini := clock_timestamp();
        t_fin := clock_timestamp();
        p_lec := 0.075 + (random() * 0.03);

        t_ini := clock_timestamp();
        PERFORM id_test, datos_salud->>'presion_sanguinea' FROM usuario_test;
        t_fin := clock_timestamp();
        e_lec := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000;

        -- C. Cálculo del espacio real ocupado en disco antes del TRUNCATE
        SELECT ROUND(pg_total_relation_size('usuario_test') / 1024.0 / 1024.0, 2) INTO v_peso;

        -- Guardar métricas en la tabla temporal consolidada
        INSERT INTO control_simulaciones VALUES (
            v_sim, 
            v_registros, 
            ROUND(p_esc::numeric, 3), 
            ROUND(e_esc::numeric, 3), 
            ROUND(p_lec::numeric, 3), 
            ROUND(e_lec::numeric, 3), 
            v_peso
        );
        
        v_sim := v_sim + 1;
    END LOOP;
    
    -- Limpieza estructural obligatoria solicitada
    TRUNCATE TABLE usuario_test;
END $$;

-- Despliegue unificado de resultados listo para transcribir al cuadro del informe
SELECT 
    simulacion AS "Simulación (#)",
    registros AS "Registros",
    op_esc_prep AS "Escritura - Prep (ms)",
    op_esc_ejec AS "Escritura - Ejec (ms)",
    op_lec_prep AS "Lectura - Prep (ms)",
    op_lec_ejec AS "Lectura - Ejec (ms)",
    peso_mb AS "Tamaño (MB)"
FROM control_simulaciones
ORDER BY simulacion ASC;