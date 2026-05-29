--
-- Scripts de Manipulación de una dato (campo) JSON
-- Tabla: "perfil" de la Base de Datos  - SGBD PostgreSQL
--

-- Agregue un NUEVO  campo tipo JSON a la tabla “perfil” (otro JSON DIFERENTE al original que creo en la tarea anterior)
-- Proponga un contenido y nombre pertinente y coherente en ese campo; y construya una estructura de dato tipo semi-estructurado
-- Realice cada una de las operaciones con el dato campo creado

-- Instrucción "ALTER TABLE" para agregar campo JSON en tabla "perfil"
--
ALTER TABLE t_usuario ADD COLUMN preferencias_sistema JSON;


--
-- 1.- Inserción del dato semi estructurado en nuevo campo JSON
--
UPDATE t_usuario 
SET preferencias_sistema = '{    
    "tema": "oscuro",    
    "notificaciones": {        
        "correo": true,        
        "push": false    
    },    
    "idioma": "es",    
    "accesibilidad": {        
        "fuente_grande": false    
    }
}'::json;

--
-- 2.- Consulta de los datos del campo 
-- 
SELECT 
    id_usuario,
    preferencias_sistema->>'tema' AS tema_actual,
    preferencias_sistema->'notificaciones'->>'correo' AS notificaciones_correo,
    preferencias_sistema->'accesibilidad' AS configuracion_accesibilidad
FROM t_usuario;

--
-- 3.- Modificación de uno de los datos dentro la semi estructura
-- 
UPDATE t_usuario
SET preferencias_sistema = jsonb_set(preferencias_sistema::jsonb, '{tema}', '"claro"'::jsonb)::json;


--
-- 4.- Eliminación de uno de los datos dentro la semi estructura
-- 
UPDATE t_usuario
SET preferencias_sistema = (preferencias_sistema::jsonb #- '{accesibilidad,fuente_grande}')::json;