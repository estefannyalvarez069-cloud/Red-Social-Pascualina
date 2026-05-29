--
-- Scripts de Manipulación de una dato (campo) JSONB
-- Tabla: "perfil" de la Base de Datos  - SGBD PostgreSQL
--

-- Agregue un NUEVO campo tipo JSONB a la tabla “perfil” (otro JSONB DIFERENTE al original que creo en la tarea anterior).
-- Utilice la misma estructura del campo tipo JSON del ítem anterior. Nota: solo cambie el nombre del campo para diferenciarlo
-- Realice cada una de las operaciones con el dato campo creado

--
-- Instrucción "ALTER TABLE" para agregar campo JSONB en tabla "perfil"
--
ALTER TABLE t_usuario ADD COLUMN preferencias_sistema_jsonb JSONB;


--
-- 1.- Inserción del dato semi estructurado en nuevo campo 
--
UPDATE t_usuario 
SET preferencias_sistema_jsonb = '{    
    "tema": "oscuro",    
    "notificaciones": {        
        "correo": true,        
        "push": false    
    },    
    "idioma": "es",    
    "accesibilidad": {        
        "fuente_grande": false    
    }
}'::jsonb;


--
-- 2.- Consulta de los datos del campo 
-- 
SELECT 
    id_usuario,
    preferencias_sistema_jsonb->>'tema' AS tema_actual,
    preferencias_sistema_jsonb->'notificaciones'->>'correo' AS notificaciones_correo,
    preferencias_sistema_jsonb->'accesibilidad' AS configuracion_accesibilidad
FROM t_usuario;


--
-- 3.- Modificación de uno de los datos dentro la semi estructura
-- 
UPDATE t_usuario
SET preferencias_sistema_jsonb = jsonb_set(preferencias_sistema_jsonb, '{tema}', '"claro"'::jsonb);


--
-- 4.- Eliminación de uno de los datos dentro la semi estructura
-- 
UPDATE t_usuario
SET preferencias_sistema_jsonb = preferencias_sistema_jsonb #- '{accesibilidad,fuente_grande}';