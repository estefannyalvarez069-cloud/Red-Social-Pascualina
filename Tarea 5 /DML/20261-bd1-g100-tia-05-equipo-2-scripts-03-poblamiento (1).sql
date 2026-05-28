-- ===========================================================================
-- SCRIPT DE POBLAMIENTO PARAMÉTRICO Y PROCEDURAL AUTOMÁTICO (DML RIGUROSO)
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- PASO 1: INSERCIÓN DE DATOS EN TABLAS MAESTRAS PARAMÉTRICAS (CATÁLOGOS)
-- ---------------------------------------------------------------------------
INSERT INTO t_maestra_rol (id_rol, nombre_rol) VALUES
(1, 'Administrador'), (2, 'Auxiliar'), (3, 'Miembro'), (4, 'Visitante')
ON CONFLICT (id_rol) DO NOTHING;

INSERT INTO t_maestra_tipo_usuario (id_tipo_usuario, nombre_tipo) VALUES
(1, 'Estudiante'), (2, 'Docente'), (3, 'Egresado'), (4, 'Empleado'),
(5, 'Empresario'), (6, 'Ex-Empleado'), (7, 'Ex-Estudiante'), (8, 'Ex-Docente'), (9, 'Invitado')
ON CONFLICT (id_tipo_usuario) DO NOTHING;

INSERT INTO t_maestra_tipo_servicio (id_tipo_servicio, nombre_tipo_servicio) VALUES
(1, 'Asesoría académica'), (2, 'Asesoría Laboral'), (3, 'Curso Tecnológico'), (4, 'Mantenimiento Moto'),
(5, 'Reparación artículo electrónico'), (6, 'Corte de Cabello'), (7, 'Manicure y Pedicure'), (8, 'Reparación PC'),
(9, 'Masaje terapéutico'), (10, 'Declaración de impuestos'), (11, 'Asesoría Trabajo de Grado'), (12, 'Viaje turístico'),
(13, 'Transporte'), (14, 'Elaboración de Dulces'), (15, 'Reparación de Calzado'), (16, 'Confección vestimenta'),
(17, 'Organización evento'), (18, 'Programación'), (19, 'Marketing'), (20, 'Fotografía')
ON CONFLICT (id_tipo_servicio) DO NOTHING;

INSERT INTO t_maestra_tipo_producto (id_tipo_producto, nombre_tipo_producto) VALUES
(1, 'Libro'), (2, 'Motocicleta'), (3, 'Vehículo'), (4, 'Almuerzo'), (5, 'Desayuno'),
(6, 'Ropa'), (7, 'Cosméticos'), (8, 'Ticket de Concierto'), (9, 'Bolso'), (10, 'Zapato'),
(11, 'Postres'), (12, 'Dulces'), (13, 'Patineta Eléctrica'), (14, 'Teléfono móvil'), (15, 'Computador'),
(16, 'Artículo Deportivo'), (17, 'Alimentos'), (18, 'Papelería'), (19, 'Accesorios Tecnológicos'), (20, 'Bicicleta')
ON CONFLICT (id_tipo_producto) DO NOTHING;

INSERT INTO t_maestra_tipo_evento (id_tipo_evento, nombre_tipo_evento) VALUES
(1, 'Congreso'), (2, 'Conferencia'), (3, 'Taller'), (4, 'Baile'), (5, 'Fiesta'),
(6, 'Conformación de Grupo'), (7, 'Viaje Turístico'), (8, 'Concierto musical'), (9, 'Reunión Semillero'), (10, 'Feria de comida'),
(11, 'Feria de ropa'), (12, 'Paseo en moto'), (13, 'Feria Tecnológica'), (14, 'Cine - Película'), (15, 'Reunión grupo interés'),
(16, 'Entrevista laboral'), (17, 'Matrimonio'), (18, 'Festival'), (19, 'Campaña'), (20, 'Salida de campo')
ON CONFLICT (id_tipo_evento) DO NOTHING;

-- Sincronizar contadores de las secuencias seriales de catálogos
SELECT setval('t_maestra_rol_id_rol_seq', (SELECT MAX(id_rol) FROM t_maestra_rol));
SELECT setval('t_maestra_tipo_usuario_id_tipo_usuario_seq', (SELECT MAX(id_tipo_usuario) FROM t_maestra_tipo_usuario));
SELECT setval('t_maestra_tipo_evento_id_tipo_evento_seq', (SELECT MAX(id_tipo_evento) FROM t_maestra_tipo_evento));
SELECT setval('t_maestra_tipo_servicio_id_tipo_servicio_seq', (SELECT MAX(id_tipo_servicio) FROM t_maestra_tipo_servicio));
SELECT setval('t_maestra_tipo_producto_id_tipo_producto_seq', (SELECT MAX(id_tipo_producto) FROM t_maestra_tipo_producto));


-- ---------------------------------------------------------------------------
-- PASO 2: BLOQUE PROCEDURAL PARA USUARIOS Y PERFILES (CON DATA_INSTITUCIONAL JSONB)
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    v_nombres text[] := ARRAY['Mateo', 'Santiago', 'Juan', 'Andres', 'Carlos', 'Luis', 'Diego', 'Alejandro', 'Daniel', 'Camilo', 'Maria', 'Valentina', 'Camila', 'Isabella', 'Sofia', 'Diana', 'Laura', 'Paula', 'Gabriela', 'Natalia'];
    v_apellidos text[] := ARRAY['Perez', 'Gomez', 'Rodriguez', 'Martinez', 'Lopez', 'Hernandez', 'Gonzalez', 'Zapata', 'Alvarez', 'Restrepo', 'Montoya', 'Cardona', 'Mejia', 'Giraldo', 'Tobon', 'Ospina', 'Velasquez', 'Bermudez', 'Cano', 'Hoyos'];
    
    c_estudiante INT := 0; c_docente INT := 0; c_egresado INT := 0; c_empleado INT := 0;
    c_empresario INT := 0; c_ex_emp INT := 0; c_ex_est INT := 0; c_ex_doc INT := 0; c_invitado INT := 0;
    c_admin INT := 0; c_auxiliar INT := 0; c_miembro INT := 0; c_visitante INT := 0;

    i INT;
    v_nombre_completo VARCHAR(200);
    v_tag VARCHAR(50);
    v_email VARCHAR(320);
    v_id_rol INT;
    v_id_tipo INT;
    v_id_usuario UUID;
    v_data_institucional JSONB; -- Estructura JSONB requerida para cumplir la restricción física de la tabla
BEGIN
    RAISE NOTICE 'Iniciando poblamiento controlado de 500 usuarios e inyección de JSONB institucional...';

    FOR i IN 1..500 LOOP
        v_nombre_completo := v_nombres[1 + (i % 20)] || ' ' || v_apellidos[1 + ((i + 7) % 20)];
        v_tag := lower(v_nombres[1 + (i % 20)]) || '.' || lower(v_apellidos[1 + ((i + 7) % 20)]) || i;
        v_email := v_tag || '@pascualbravo.edu.co';

        -- Asignación estricta de Cuotas de Negocio
        IF c_admin < 10 THEN
            v_id_rol := 1; c_admin := c_admin + 1;
            IF c_empleado < 5 THEN v_id_tipo := 4; c_empleado := c_empleado + 1;
            ELSE v_id_tipo := 2; c_docente := c_docente + 1; END IF;
        ELSIF c_auxiliar < 20 THEN
            v_id_rol := 2; c_auxiliar := c_auxiliar + 1;
            IF c_empleado < 20 THEN v_id_tipo := 4; c_empleado := c_empleado + 1;
            ELSE v_id_tipo := 1; c_estudiante := c_estudiante + 1; END IF;
        ELSIF c_miembro < 420 THEN
            v_id_rol := 3; c_miembro := c_miembro + 1;
            IF c_estudiante < 300 THEN v_id_tipo := 1; c_estudiante := c_estudiante + 1; 
            ELSIF c_docente < 70 THEN v_id_tipo := 2; c_docente := c_docente + 1;       
            ELSIF c_egresado < 30 THEN v_id_tipo := 3; c_egresado := c_egresado + 1;
            ELSIF c_empresario < 15 THEN v_id_tipo := 5; c_empresario := c_empresario + 1;
            ELSIF c_ex_emp < 5 THEN v_id_tipo := 6; c_ex_emp := c_ex_emp + 1;
            ELSIF c_ex_est < 5 THEN v_id_tipo := 7; c_ex_est := c_ex_est + 1;
            ELSE v_id_tipo := 8; c_ex_doc := c_ex_doc + 1; END IF;
        ELSE
            v_id_rol := 4; v_id_tipo := 9; c_visitante := c_visitante + 1; c_invitado := c_invitado + 1;
        END IF;

        -- Construcción dinámica del objeto JSONB obligatorio indexado por GIN
        -- Se inyecta explícitamente fecha_nacimiento e ingreso_red para responder a la Consulta analítica #1 requerida
        v_data_institucional := jsonb_build_object(
            'correo_institucional', v_email,
            'fecha_nacimiento', (DATE '1985-01-01' + (i * 11 % 4500))::text,
            'ingreso_red', (TIMESTAMP '2024-01-01 08:00:00' + (i * INTERVAL '4 hours 15 minutes'))::text,
            'metadata_seguridad', jsonb_build_object('estado_cuenta', 'ACTIVA', 'mfa_habilitado', true)
        );

        -- Generación de UUID explícito para evitar fallas estructurales por DEFAULT nulo
        v_id_usuario := gen_random_uuid();

        -- Inserción con correspondencia de firmas al 100% con tu base de datos física
        INSERT INTO t_usuario (id_usuario, nombre_completo, usuario_tag, data_institucional, id_rol, id_tipo_usuario, estado_registro)
        VALUES (v_id_usuario, v_nombre_completo, v_tag, v_data_institucional, v_id_rol, v_id_tipo, TRUE);

        -- Inserción correspondiente en la tabla t_perfil_usuario
        INSERT INTO t_perfil_usuario (id_usuario, area_estudio_trabajo, intereses_habilidades)
        VALUES (
            v_id_usuario,
            CASE 
                WHEN v_id_tipo = 1 THEN 'Facultad de Ingenierías'
                WHEN v_id_tipo = 2 THEN 'Cuerpo Docente Pascualino'
                WHEN v_id_tipo = 4 THEN 'Área Administrativa y Apoyo'
                ELSE 'Ecosistema Externo / Graduados' END,
            jsonb_build_object(
                'presentacion', 'Hola, soy parte de la comunidad Pascualina.',
                'clave_encriptada', '$2b$12$RstUeWzY7X6vBa4qN7mK9pL2oI1uYtReWqMaK39vX8hBz91mLo9Pq',
                'intereses', jsonb_build_array('Tecnología', 'Bases de Datos', 'Emprendimiento', 'Comunidades')
            )
        );
    END LOOP;
    
    RAISE NOTICE '-> Poblado con éxito: 500 registros en t_usuario y t_perfil_usuario sin violar restricciones.';
END $$;


-- ---------------------------------------------------------------------------
-- PASO 3: BLOQUE PROCEDURAL AUTOMÁTICO PARA INTERACCIONES Y TRANSACCIONES
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    v_pool_usuarios UUID[];
    v_id_usuario UUID;
    v_comprador_id UUID;
    
    v_id_publicacion INT;
    v_id_evento INT;
    v_id_servicio INT;
    v_id_producto INT;
    
    v_total_usuarios INT;
    i INT;
BEGIN
    RAISE NOTICE 'Iniciando generación cruzada de interacciones sociales y de mercado...';

    -- Extracción segura del pool real de usuarios guardados
    SELECT array_agg(id_usuario) INTO v_pool_usuarios FROM t_usuario;
    v_total_usuarios := array_length(v_pool_usuarios, 1);

    -- Creación de Comunidades Autónomas (t_grupo) asignando creadores UUID válidos
    INSERT INTO t_grupo (id_usuario_creador, nombre_grupo, perfil_grupo) VALUES
    (v_pool_usuarios[1], 'Semillero de Base de Datos e Innovación', '{"enfoque": ["PostgreSQL", "Analítica"], "categoria": "Académico"}'::jsonb),
    (v_pool_usuarios[6], 'Red de Emprendedores Pascualinos', '{"enfoque": ["Negocios", "Networking"], "categoria": "Feria Marketplace"}'::jsonb),
    (v_pool_usuarios[11], 'Club de Ciclismo y Rutas PB', '{"enfoque": ["Deporte", "Salidas"], "categoria": "Bienestar"}'::jsonb),
    (v_pool_usuarios[26], 'Red de Apoyo y Monitorías Académicas', '{"enfoque": ["Matemáticas", "Programación"], "categoria": "Apoyo"}'::jsonb),
    (v_pool_usuarios[31], 'Colectivo de Cine y Cultura Institucional', '{"enfoque": ["Artes", "Audiovisual"], "categoria": "Cultural"}'::jsonb);

    -- Recorrido para generar volumen operacional
    FOR i IN 1..v_total_usuarios LOOP
        v_id_usuario := v_pool_usuarios[i];

        -- A. Módulo de Publicaciones y Comentarios (Nombres de atributos exactos del DDL)
        IF i % 2 = 0 THEN
            INSERT INTO t_publicacion (id_usuario, contenido_texto, recursos_multimedia)
            VALUES (v_id_usuario, 'Saludos comunidad. Recuerden revisar las actividades programadas y los productos del marketplace. #Pascualinos', '{"adjuntos": false, "tipo": "general"}'::jsonb)
            RETURNING id_publicacion INTO v_id_publicacion;

            INSERT INTO t_comentario (id_publicacion, id_usuario, contenido)
            VALUES (v_id_publicacion, v_pool_usuarios[CASE WHEN i < v_total_usuarios THEN i + 1 ELSE 1 END], 'Muchas gracias por la información compartida, estaré muy atento.');
        END IF;

        -- B. Registro de Integrantes en Comunidades (t_usuario_grupo)
        IF i % 3 = 0 THEN
            INSERT INTO t_usuario_grupo (id_usuario, id_grupo, rol_miembro)
            VALUES (v_id_usuario, 1 + (i % 5), 'MIEMBRO')
            ON CONFLICT DO NOTHING;
        END IF;

        -- C. Gestión de Logística y Suscripciones (t_evento y t_usuario_evento)
        IF i % 10 = 0 THEN
            INSERT INTO t_evento (id_usuario_organizador, id_tipo_evento, titulo, descripcion, detalles_logistica)
            VALUES (v_id_usuario, 1 + (i % 20), 'Encuentro e Integración Nro ' || i, 'Espacio abierto enfocado en el desarrollo académico y networking dentro de las instalaciones.', '{"ubicacion": "Auditorio Bloque 3", "asistencia_estimada": 40}'::jsonb)
            RETURNING id_evento INTO v_id_evento;

            INSERT INTO t_usuario_evento (id_usuario, id_evento, estado_confirmacion, calificacion_like, comentario_post_evento)
            VALUES (v_pool_usuarios[CASE WHEN i > 5 THEN i - 4 ELSE 2 END], v_id_evento, 'CONFIRMADO', 5, 'Excelente planeación.');
        END IF;

        -- D. Módulo Marketplace: Servicios (t_servicio y t_usuario_servicio)
        IF i % 15 = 0 THEN
            INSERT INTO t_servicio (id_usuario_ofertante, id_tipo_servicio, descripcion, precio, metadatos_servicio)
            VALUES (v_id_usuario, 1 + (i % 20), 'Prestación de asesoría y acompañamiento especializado técnico.', 40000.00 + (i * 100), '{"modalidad": "Híbrido", "duración_horas": 3}'::jsonb)
            RETURNING id_servicio INTO v_id_servicio;

            INSERT INTO t_usuario_servicio (id_adquiriente, id_servicio, estado_servicio, detalles_pacto)
            VALUES (v_pool_usuarios[CASE WHEN i < 480 THEN i + 3 ELSE 1 END], v_id_servicio, 'COMPLETADO', '{"entregables": ["Informe de avance"]}'::jsonb);
        END IF;

        -- E. Módulo Marketplace: Productos y Ventas (t_producto y t_usuario_producto)
        IF i % 12 = 0 THEN
            INSERT INTO t_producto (id_usuario_vendedor, id_tipo_producto, nombre_producto, descripcion, precio, stock, atributos_producto)
            VALUES (v_id_usuario, 1 + (i % 20), 'Artículo Universitario Tipo ' || i, 'Elemento disponible para entrega o distribución inmediata en campus.', 12000.00 + (i * 150), 15, '{"condicion": "Nuevo", "disponibilidad": "Inmediata"}'::jsonb)
            RETURNING id_producto INTO v_id_producto;

            v_comprador_id := v_pool_usuarios[CASE WHEN i > 25 THEN i - 20 ELSE 4 END];

            IF v_comprador_id <> v_id_usuario THEN
                INSERT INTO t_usuario_producto (id_comprador, id_producto, cantidad_comprada, monto_total_pagado)
                VALUES (v_comprador_id, v_id_producto, 1, 12000.00 + (i * 150));
            END IF;
        END IF;

    END LOOP;

    RAISE NOTICE '====================================================================';
    RAISE NOTICE '  PROCESAMIENTO OPERACIONAL Y TRANSACCIONAL POBLADO CORRECTAMENTE';
    RAISE NOTICE '====================================================================';
END $$;