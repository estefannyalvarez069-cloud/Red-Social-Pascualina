--
-- Scripst de Creación de la Base de Datos  - SGBD PostgreSQL
--
-- Todas las instrucciones se DEBEN EJECUTAR EN SECUENCIA SIN ERRORES
-- NOTA: Ojo con las tablas relacionadas. Primero las independientes y después las dependientes
--

-- ---------------------------------------------------------------------------
-- PASO 1: ELIMINACIÓN DE TABLAS TRANSICIONALES OBSOLETAS (Por dependencias FK)
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS t_usuario_usuario;
DROP TABLE IF EXISTS t_conexiones;
DROP TABLE IF EXISTS t_credencial;
DROP TABLE IF EXISTS t_usuario_grupo;
DROP TABLE IF EXISTS t_usuario_evento;
DROP TABLE IF EXISTS t_publicacion_actividad;
DROP TABLE IF EXISTS t_biografia;
DROP TABLE IF EXISTS t_maestra_categoria;

-- ---------------------------------------------------------------------------
-- PASO 2: ADAPTACIÓN Y REESTRUCTURACIÓN DE LA TABLA CORE 't_usuario'
-- ---------------------------------------------------------------------------
-- Añadir campos obligatorios del nuevo inventario analítico
ALTER TABLE t_usuario ADD COLUMN IF NOT EXISTS id_rol INT;
ALTER TABLE t_usuario ADD COLUMN IF NOT EXISTS id_tipo_usuario INT;
ALTER TABLE t_usuario ADD COLUMN IF NOT EXISTS estado_registro BOOLEAN DEFAULT TRUE;
-- ---------------------------------------------------------------------------
-- PASO 3: CREACIÓN DE NUEVAS TABLAS MAESTRAS PARAMÉTRICAS (CATÁLOGOS)
-- ---------------------------------------------------------------------------

-- Asegurar que la maestra de roles exista con la estructura correcta
-- Si ya existía de la TIA-04, el SGBD continuará sin errores
CREATE TABLE IF NOT EXISTS t_maestra_rol (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS t_maestra_tipo_usuario (
    id_tipo_usuario SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS t_maestra_tipo_evento (
    id_tipo_evento SERIAL PRIMARY KEY,
    nombre_tipo_evento VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS t_maestra_tipo_servicio (
    id_tipo_servicio SERIAL PRIMARY KEY,
    nombre_tipo_servicio VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS t_maestra_tipo_producto (
    id_tipo_producto SERIAL PRIMARY KEY,
    nombre_tipo_producto VARCHAR(50) UNIQUE NOT NULL
);

-- ---------------------------------------------------------------------------
-- PASO 4: ENLACE DE LLAVES FORÁNEAS EN LA TABLA 't_usuario'
-- ---------------------------------------------------------------------------
ALTER TABLE t_usuario 
    ADD CONSTRAINT fk_usu_rol FOREIGN KEY (id_rol) REFERENCES t_maestra_rol(id_rol) ON DELETE RESTRICT;

ALTER TABLE t_usuario 
    ADD CONSTRAINT fk_usu_tipo FOREIGN KEY (id_tipo_usuario) REFERENCES t_maestra_tipo_usuario(id_tipo_usuario) ON DELETE RESTRICT;

-- ---------------------------------------------------------------------------
-- PASO 5: IMPLEMENTACIÓN DE LAS NUEVAS ENTIDADES CORE Y RELACIONALES (TIA-05)
-- ---------------------------------------------------------------------------

-- Perfil de Usuario (Evolución de t_biografia)
CREATE TABLE t_perfil_usuario (
    id_perfil SERIAL PRIMARY KEY,
    id_usuario UUID UNIQUE NOT NULL,
    area_estudio_trabajo VARCHAR(150),
    intereses_habilidades JSONB NOT NULL,
    fecha_actualizacion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE
);

-- Publicaciones y Comentarios Separados
CREATE TABLE t_publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    id_usuario UUID NOT NULL,
    contenido_texto TEXT NOT NULL,
    recursos_multimedia JSONB,
    fecha_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (id_usuario) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE t_comentario (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_usuario UUID NOT NULL,
    contenido TEXT NOT NULL,
    fecha_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES t_publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE
);

-- Módulo de Grupos Integrado
CREATE TABLE t_grupo (
    id_grupo SERIAL PRIMARY KEY,
    id_usuario_creador UUID NOT NULL,
    nombre_grupo VARCHAR(100) NOT NULL,
    perfil_grupo JSONB NOT NULL,
    fecha_creacion DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_grupo_creador FOREIGN KEY (id_usuario_creador) REFERENCES t_usuario(id_usuario) ON DELETE RESTRICT
);

CREATE TABLE t_usuario_grupo (
    id_usuario UUID NOT NULL,
    id_grupo INT NOT NULL,
    fecha_union DATE DEFAULT CURRENT_DATE,
    rol_miembro VARCHAR(30) NOT NULL DEFAULT 'MIEMBRO',
    PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_usu_grupo_u FOREIGN KEY (id_usuario) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_usu_grupo_g FOREIGN KEY (id_grupo) REFERENCES t_grupo(id_grupo) ON DELETE CASCADE
);

-- Módulo de Eventos y Suscripción con Feedback
CREATE TABLE t_evento (
    id_evento SERIAL PRIMARY KEY,
    id_usuario_organizador UUID NOT NULL,
    id_tipo_evento INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT NOT NULL,
    detalles_logistica JSONB NOT NULL,
    fecha_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evento_organizador FOREIGN KEY (id_usuario_organizador) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_evento_tipo FOREIGN KEY (id_tipo_evento) REFERENCES t_maestra_tipo_evento(id_tipo_evento) ON DELETE RESTRICT
);

CREATE TABLE t_usuario_evento (
    id_usuario UUID NOT NULL,
    id_evento INT NOT NULL,
    fecha_inscripcion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    estado_confirmacion VARCHAR(30) DEFAULT 'PENDIENTE',
    calificacion_like INT CHECK (calificacion_like BETWEEN 1 AND 5),
    comentario_post_evento TEXT,
    PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_rel_evento_usuario FOREIGN KEY (id_usuario) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_rel_evento_base FOREIGN KEY (id_evento) REFERENCES t_evento(id_evento) ON DELETE CASCADE
);

-- Módulo Marketplace: Servicios
CREATE TABLE t_servicio (
    id_servicio SERIAL PRIMARY KEY,
    id_usuario_ofertante UUID NOT NULL,
    id_tipo_servicio INT NOT NULL,
    descripcion TEXT NOT NULL,
    precio NUMERIC(12,2) NOT NULL CHECK (precio >= 0),
    metadatos_servicio JSONB,
    fecha_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_servicio_usuario FOREIGN KEY (id_usuario_ofertante) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_servicio_tipo FOREIGN KEY (id_tipo_servicio) REFERENCES t_maestra_tipo_servicio(id_tipo_servicio) ON DELETE RESTRICT
);

CREATE TABLE t_usuario_servicio (
    id_adquiriente UUID NOT NULL,
    id_servicio INT NOT NULL,
    fecha_solicitud TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    estado_servicio VARCHAR(30) DEFAULT 'SOLICITADO',
    detalles_pacto JSONB,
    PRIMARY KEY (id_adquiriente, id_servicio),
    CONSTRAINT fk_rel_servicio_usuario FOREIGN KEY (id_adquiriente) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_rel_servicio_base FOREIGN KEY (id_servicio) REFERENCES t_servicio(id_servicio) ON DELETE CASCADE
);

-- Módulo Marketplace: Productos y Ventas
CREATE TABLE t_producto (
    id_producto SERIAL PRIMARY KEY,
    id_usuario_vendedor UUID NOT NULL,
    id_tipo_producto INT NOT NULL,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio NUMERIC(12,2) NOT NULL CHECK (precio >= 0),
    stock INT NOT NULL DEFAULT 1 CHECK (stock >= 0),
    atributos_producto JSONB,
    fecha_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_producto_usuario FOREIGN KEY (id_usuario_vendedor) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_producto_tipo FOREIGN KEY (id_tipo_producto) REFERENCES t_maestra_tipo_producto(id_tipo_producto) ON DELETE RESTRICT
);

CREATE TABLE t_usuario_producto (
    id_compra_transaccion SERIAL PRIMARY KEY,
    id_comprador UUID NOT NULL,
    id_producto INT NOT NULL,
    cantidad_comprada INT NOT NULL CHECK (cantidad_comprada > 0),
    fecha_transaccion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    monto_total_pagado NUMERIC(12,2) NOT NULL CHECK (monto_total_pagado >= 0),
    CONSTRAINT fk_rel_producto_comprador FOREIGN KEY (id_comprador) REFERENCES t_usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_rel_producto_base FOREIGN KEY (id_producto) REFERENCES t_producto(id_producto) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- PASO 6: CREACIÓN DE ÍNDICES INVERTIDOS OPTIMIZADOS (BIG DATA)
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_usuario_data_inst ON t_usuario USING GIN (data_institucional);
CREATE INDEX IF NOT EXISTS idx_perfil_intereses ON t_perfil_usuario USING GIN (intereses_habilidades);