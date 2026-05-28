--
-- Script de Verificar cada una de las 4 propiedades ACID en la Base de Datos  - SGBD PostgreSQL


-- 1. ATOMICIDAD se hace todo con éxito, o no se hace nada

-- Inspección rápida inicial para ver el estado de un producto con stock real
SELECT id_producto, nombre_producto, stock, precio 
FROM t_producto 
WHERE stock > 0 
LIMIT 1;

-- --- CASO A: Transacción exitosa 
BEGIN; 

    -- Operación A.1: Insertamos el registro transaccional de compra en el Marketplace
    INSERT INTO t_usuario_producto (id_comprador, id_producto, cantidad_comprada, monto_total_pagado)
    VALUES (
        (SELECT id_usuario FROM t_usuario LIMIT 1), 
        (SELECT id_producto FROM t_producto WHERE stock > 2 LIMIT 1), 
        2, 
        ((SELECT precio FROM t_producto WHERE stock > 2 LIMIT 1) * 2)
    );

    -- Operación A.2: Modificamos el stock restando las unidades que acabamos de comprar
    UPDATE t_producto 
    SET stock = stock - 2
    WHERE id_producto = (SELECT id_producto FROM t_producto WHERE stock > 2 LIMIT 1);

COMMIT; -- Todo marchó sin problemas, los cambios se consolidan físicamente en el disco.


-- --- CASO B: Transacción fallida controlada (Simulación de "Todo o Nada") ---
-- Nota: Envolvemos en DO $$ para capturar el error de la regla del stock por software,
-- aplicando un ROLLBACK controlado que impide que la terminal de pgAdmin se detenga bruscamente.
DO $$
DECLARE
    v_usuario_id UUID;
    v_producto_id INT;
    v_precio_prod NUMERIC(12,2);
BEGIN
    -- Buscamos datos reales existentes para que la simulación de la compra sea válida
    SELECT id_usuario INTO v_usuario_id FROM t_usuario LIMIT 1;
    SELECT id_producto, precio INTO v_producto_id, v_precio_prod FROM t_producto WHERE stock > 0 LIMIT 1;

    -- Operación B.1: Intentamos registrar una compra masiva de 500 unidades
    INSERT INTO t_usuario_producto (id_comprador, id_producto, cantidad_comprada, monto_total_pagado)
    VALUES (v_usuario_id, v_producto_id, 500, (v_precio_prod * 500));

    -- Operación B.2: Forzamos el error restando las 500 unidades (El stock quedaría en -485)
    UPDATE t_producto 
    SET stock = stock - 500
    WHERE id_producto = v_producto_id;

    -- Nota: Si no existieran restricciones, esta línea guardaría los datos, pero el CHECK lo impedirá
    COMMIT;

EXCEPTION 
    WHEN check_violation THEN
        -- Al saltar la regla 't_producto_stock_check', PostgreSQL aborta y cae directo aquí:
        RAISE NOTICE '------------------------------------------------------------';
        RAISE NOTICE '¡ALERTA ACID: ATOMICIDAD! Se detectó un intento de stock negativo.';
        RAISE NOTICE 'PostgreSQL aplicó ROLLBACK automático de toda la transacción.';
        RAISE NOTICE 'El registro de la compra (Operación B.1) fue destruido para evitar inconsistencias.';
        RAISE NOTICE '------------------------------------------------------------';
END $$;

-- Verificación de la Atomicidad: Busquemos si se guardó la compra fantasma de 500 unidades
-- (Debe retornar 0 filas / estar vacío, demostrando que la Operación B.1 jamás se guardó)
SELECT * FROM t_usuario_producto WHERE cantidad_comprada = 500;


	
-- 2. CONSISTENCIA Cumplimiento estricto de las reglas del modelo


-- --- Prueba de consistencia 1: Violación de Integridad Referencial (FK) ---
-- Explicación: El SGBD no puede permitir ingresar un producto cuyo vendedor no exista en el sistema.
DO $$
BEGIN
    INSERT INTO t_producto (id_usuario_vendedor, id_tipo_producto, nombre_producto, descripcion, precio, stock)
    VALUES (
        '00000000-0000-0000-0000-000000000000', -- UUID inexistente en 't_usuario'
        1, 
        'Camiseta de la u', 
        'Tratando de saltarme la FK', 
        25000.00, 
        5
    );
    
    COMMIT;
EXCEPTION 
    WHEN foreign_key_violation THEN
        -- El SGBD atrapa la violación de la llave foránea fk_producto_usuario y limpia el canal
        RAISE NOTICE '------------------------------------------------------------';
        RAISE NOTICE '¡ALERTA ACID: CONSISTENCIA! Intento de violar Integridad Referencial (FK).';
        RAISE NOTICE 'PostgreSQL bloqueó el producto porque el vendedor fantasma no existe.';
        RAISE NOTICE 'La base de datos rechaza el registro y se mantiene CONSISTENTE.';
        RAISE NOTICE '------------------------------------------------------------';
END $$;


-- --- Prueba de consistencia 2: Violación de Restricción del Modelo (CHECK) ---
-- Explicación: No se permite alterar las reglas del negocio lógico, como insertar precios negativos.
DO $$
DECLARE
    v_usuario_id UUID;
BEGIN
    -- Buscamos un usuario real para aislar el error únicamente en el campo de precio
    SELECT id_usuario INTO v_usuario_id FROM t_usuario LIMIT 1;

    INSERT INTO t_producto (id_usuario_vendedor, id_tipo_producto, nombre_producto, descripcion, precio, stock)
    VALUES (
        v_usuario_id, 
        1, 
        'Libro Cálculo Antiguo', 
        'Intento de vulnerar el modelo con precio negativo', 
        -1500.00, -- Infracción directa a la regla: CHECK (precio >= 0)
        2
    );
    
    COMMIT;
EXCEPTION 
    WHEN check_violation THEN
        -- Captura el error de precio no válido definido en la creación de t_producto
        RAISE NOTICE '------------------------------------------------------------';
        RAISE NOTICE '¡ALERTA ACID: CONSISTENCIA! Intento de ingresar un precio de venta negativo.';
        RAISE NOTICE 'PostgreSQL rechazó el registro gracias a la restricción CHECK de la tabla.';
        RAISE NOTICE 'La base de datos sigue siendo estructuralmente CONSISTENTE.';
        RAISE NOTICE '------------------------------------------------------------';
END $$;


-- 3. AISLAMIENTO Lo que ocurre en paralelo no ensucia a los demás

-- Explicación para sustentación: Si modificamos un dato dentro de un bloque activo,
-- otras terminales concurrentes seguirán leyendo el dato previo hasta que hagamos COMMIT.

BEGIN;
    -- El Usuario A decide cambiarle el precio drásticamente a un servicio, pero aún no guarda
    UPDATE t_servicio 
    SET precio = 850000.00 
    WHERE id_servicio = (SELECT id_servicio FROM t_servicio LIMIT 1);

-- [ESCENARIO DE CONCURRENCIA SIMULTÁNEA]
-- Si en este preciso instante otro estudiante (Usuario B) consulta el precio desde otra pestaña,
-- el SGBD le devolverá el precio ORIGINAL viejo. El aislamiento previene lecturas sucias (Dirty Reads).
SELECT precio FROM t_servicio WHERE id_servicio = (SELECT id_servicio FROM t_servicio LIMIT 1);

COMMIT; -- El Usuario A termina de transaccionar y libera el cambio al sistema público.

-- [VERIFICACIÓN POST-COMMIT]
-- Una vez ejecutado el COMMIT, el cambio se vuelve visible para todas las consultas concurrentes.
SELECT precio FROM t_servicio WHERE id_servicio = (SELECT id_servicio FROM t_servicio LIMIT 1);


-- 4. DURABILIDAD Datos permanentes resguardados en hardware

-- Explicación: Cuando el motor devuelve el éxito del COMMIT, el dato se escribe 
-- de inmediato en los registros WAL (Write-Ahead Logging) garantizando que la 
-- publicación persistirá de forma definitiva ante pérdidas intempestivas de energía.

BEGIN;
    INSERT INTO t_publicacion (id_usuario, contenido_texto, recursos_multimedia)
    VALUES (
        (SELECT id_usuario FROM t_usuario LIMIT 1),
        'Mensaje crítico de prueba para verificar durabilidad en el disco rígido de Postgres 18.',
        '{"estado_seguridad": "verificado_wal"}'::jsonb
    );
COMMIT; -- Fin del bloque transaccional. Datos blindados físicamente.

-- Verificación de Durabilidad: Comprobación de persistencia del registro en el almacenamiento secundario.
-- (Incluso si apagas el servidor de bases de datos y lo vuelves a prender, la fila seguirá intacta)
SELECT id_publicacion, contenido_texto, fecha_registro 
FROM t_publicacion 
WHERE contenido_texto LIKE '%durabilidad en el disco%';