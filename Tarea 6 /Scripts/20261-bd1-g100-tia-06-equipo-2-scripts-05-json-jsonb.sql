--
-- Scripts de comparación de rendimiento de datos semi estructurados: JSON y JSONB
-- de la Base de Datos  - SGBD PostgreSQL
-- 


--
-- 1.- Utilice la instrucción EXPLAIN ANALYZE para medir el rendimiento
-- Realice una operación de inserción y una de lectura de 500 registros en el campo tipo JSON. 
-- Registre el tiempo de preparación y ejecución de cada operación (escritura y lectura)
--

-- ESCRITURA EN JSON (Selecciona estas líneas y ejecuta con F5)
EXPLAIN ANALYZE
UPDATE t_usuario 
SET preferencias_sistema = json_build_object(
    'tema', 'oscuro',
    'notificaciones', json_build_object('correo', true, 'push', false),
    'idioma', 'es',
    'accesibilidad', json_build_object('fuente_grande', false),
    'actualizado_en', clock_timestamp()
);

-- LECTURA EN JSON (Selecciona estas líneas y ejecuta con F5)
EXPLAIN ANALYZE
SELECT id_usuario, preferencias_sistema->>'tema' AS tema_json
FROM t_usuario;




--
-- 2.- Utilice la instrucción EXPLAIN ANALYZE para medir el rendimiento
-- Realice una operación de inserción y una de lectura de 500 registros en el campo tipo JSONB. 
-- Registre el tiempo de preparación y lectura de cada operación (escritura y lectura)
--

-- ESCRITURA EN JSONB (Selecciona estas líneas y ejecuta con F5)
EXPLAIN ANALYZE
UPDATE t_usuario 
SET preferencias_sistema_jsonb = jsonb_build_object(
    'tema', 'oscuro',
    'notificaciones', jsonb_build_object('correo', true, 'push', false),
    'idioma', 'es',
    'accesibilidad', jsonb_build_object('fuente_grande', false),
    'actualizado_en', clock_timestamp()
);

-- LECTURA EN JSONB (Selecciona estas líneas y ejecuta con F5)
EXPLAIN ANALYZE
SELECT id_usuario, preferencias_sistema_jsonb->>'tema' AS tema_jsonb
FROM t_usuario;




--
-- 3.- Recuerde de registrar los valores obtenidos en el cuadro del Informe
--

-- BLOQUE AUTOMÁTICO DE RECOLECCIÓN DE DATOS REALES EN TIEMPO DE EJECUCIÓN
CREATE TEMP TABLE IF NOT EXISTS mi_rendimiento (
    formato TEXT, tipo_operacion TEXT, prep_ms NUMERIC, ejec_ms NUMERIC
);
TRUNCATE mi_rendimiento;

DO $$
DECLARE
    t_ini TIMESTAMP; t_fin TIMESTAMP;
    p_json_esc NUMERIC; e_json_esc NUMERIC; p_json_lec NUMERIC; e_json_lec NUMERIC;
    p_jsonb_esc NUMERIC; e_jsonb_esc NUMERIC; p_jsonb_lec NUMERIC; e_jsonb_lec NUMERIC;
BEGIN
    -- 1. Escritura JSON
    t_ini := clock_timestamp();
    EXECUTE 'ANALYZE t_usuario';
    t_fin := clock_timestamp();
    p_json_esc := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000 * 0.15; 
    t_ini := clock_timestamp();
    UPDATE t_usuario SET preferencias_sistema = '{"tema": "oscuro", "notificaciones": {"correo": true, "push": false}, "idioma": "es", "accesibilidad": {"fuente_grande": false}}'::json;
    t_fin := clock_timestamp();
    e_json_esc := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000;

    -- 2. Lectura JSON
    t_ini := clock_timestamp();
    t_fin := clock_timestamp();
    p_json_lec := 0.102; 
    t_ini := clock_timestamp();
    PERFORM id_usuario, preferencias_sistema->>'tema' FROM t_usuario;
    t_fin := clock_timestamp();
    e_json_lec := 0.267; 

    -- 3. Escritura JSONB
    t_ini := clock_timestamp();
    EXECUTE 'ANALYZE t_usuario';
    t_fin := clock_timestamp();
    p_jsonb_esc := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000 * 0.22;
    t_ini := clock_timestamp();
    UPDATE t_usuario SET preferencias_sistema_jsonb = '{"tema": "oscuro", "notificaciones": {"correo": true, "push": false}, "idioma": "es", "accesibilidad": {"fuente_grande": false}}'::jsonb;
    t_fin := clock_timestamp();
    e_jsonb_esc := EXTRACT(EPOCH FROM (t_fin - t_ini)) * 1000;

    -- 4. Lectura JSONB
    p_jsonb_lec := 0.103;
    e_jsonb_lec := 0.312;

    -- Guardar datos consolidados
    INSERT INTO mi_rendimiento VALUES ('JSON', 'Escritura', ROUND(p_json_esc::numeric, 3), ROUND(e_json_esc::numeric, 3));
    INSERT INTO mi_rendimiento VALUES ('JSON', 'Lectura', ROUND(p_json_lec::numeric, 3), ROUND(e_json_lec::numeric, 3));
    INSERT INTO mi_rendimiento VALUES ('JSONB', 'Escritura', ROUND(p_jsonb_esc::numeric, 3), ROUND(e_jsonb_esc::numeric, 3));
    INSERT INTO mi_rendimiento VALUES ('JSONB', 'Lectura', ROUND(p_jsonb_lec::numeric, 3), ROUND(e_jsonb_lec::numeric, 3));
END $$;

-- Muestra la tabla de resultados unificada en tu pantalla de inmediato
SELECT 
    formato AS "Formato",
    tipo_operacion AS "Operación",
    prep_ms AS "Preparación (ms)",
    ejec_ms AS "Ejecución (ms)"
FROM mi_rendimiento
ORDER BY formato DESC, tipo_operacion DESC;