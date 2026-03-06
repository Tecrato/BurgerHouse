-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 06-03-2026 a las 11:43:00
-- Versión del servidor: 8.0.41
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `burgerhouse`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Caja` (IN `idCaja` INT)   BEGIN
    SELECT 
        mp.id AS id_metodo_pago,
        mp.nombre AS metodo_pago,
        CONCAT(c.nombre, ' ', c.apellido) AS cliente,
        pc.monto,
        pc.tasa,
        pc.fecha,
        pc.nro_orden,
        pc.tipo_pago
    FROM metodo_pago mp
    LEFT JOIN (
        -- Pagos de ventas
        SELECT 
            p.id_metodo_pago,
            p.monto,
            p.tasa,
            p.fecha,
            o.id_cliente,
            o.nro_orden,
            'venta' AS tipo_pago
        FROM pagos p
        INNER JOIN pago_venta pv ON pv.id_pago = p.id
        INNER JOIN ventas v ON v.id = pv.id_venta
        INNER JOIN orden o ON o.id = v.id_orden
        WHERE v.id_caja = idCaja

        UNION ALL

        -- Pagos de reservaciones
        SELECT 
            p.id_metodo_pago,
            p.monto,
            p.tasa,
            p.fecha,
            o.id_cliente,
            o.nro_orden,
            'reserva' AS tipo_pago
        FROM pagos p
        INNER JOIN pago_reserva pr ON pr.id_pago = p.id
        INNER JOIN reservaciones r ON r.id = pr.id_reserva
        LEFT JOIN orden o ON o.id = r.id_orden
        WHERE r.id_caja = idCaja
    ) AS pc ON pc.id_metodo_pago = mp.id
    LEFT JOIN clientes c ON pc.id_cliente = c.id
    WHERE mp.active = 1
    ORDER BY mp.id, cliente;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CerrarCaja` (IN `cajaId` INT)   BEGIN
    DECLARE inicial_bs FLOAT DEFAULT 0;
    DECLARE inicial_dolar FLOAT DEFAULT 0;
    DECLARE total_bs FLOAT DEFAULT 0;
    DECLARE total_dolar FLOAT DEFAULT 0;
    DECLARE tasa_promedio_dolar FLOAT DEFAULT 0;

    -- Montos iniciales
    SELECT monto_inicial_bs, monto_inicial_dolar
    INTO inicial_bs, inicial_dolar
    FROM caja
    WHERE id = cajaId;

    -- Total pagos en Bs (de ventas y reservaciones)
    SELECT IFNULL(SUM(p.monto), 0)
    INTO total_bs
    FROM pagos p
    JOIN metodo_pago m ON m.id = p.id_metodo_pago
    WHERE m.nombre NOT IN ('Zelle', 'Binance', 'Divisa')
      AND p.id IN (
        -- pagos asociados a ventas
        SELECT pv.id_pago
        FROM pago_venta pv
        JOIN ventas v ON v.id = pv.id_venta
        WHERE v.id_caja = cajaId

        UNION ALL

        -- pagos asociados a reservaciones
        SELECT pr.id_pago
        FROM pago_reserva pr
        JOIN reservaciones r ON r.id = pr.id_reserva
        WHERE r.id_caja = cajaId
    );

    -- Total pagos en dólares (ventas y reservaciones)
    SELECT IFNULL(SUM(p.monto), 0)
    INTO total_dolar
    FROM pagos p
    JOIN metodo_pago m ON m.id = p.id_metodo_pago
    WHERE m.nombre IN ('Zelle', 'Binance', 'Divisa')
      AND p.id IN (
        SELECT pv.id_pago
        FROM pago_venta pv
        JOIN ventas v ON v.id = pv.id_venta
        WHERE v.id_caja = cajaId

        UNION ALL

        SELECT pr.id_pago
        FROM pago_reserva pr
        JOIN reservaciones r ON r.id = pr.id_reserva
        WHERE r.id_caja = cajaId
    );

    -- Tasa promedio dólar para pagos en Bs
    SELECT IFNULL(AVG(p.tasa), 0)
    INTO tasa_promedio_dolar
    FROM pagos p
    JOIN metodo_pago m ON m.id = p.id_metodo_pago
    WHERE m.nombre NOT IN ('Zelle', 'Binance', 'Divisa')
      AND p.id IN (
        SELECT pv.id_pago
        FROM pago_venta pv
        JOIN ventas v ON v.id = pv.id_venta
        WHERE v.id_caja = cajaId

        UNION ALL

        SELECT pr.id_pago
        FROM pago_reserva pr
        JOIN reservaciones r ON r.id = pr.id_reserva
        WHERE r.id_caja = cajaId
    );

    -- Actualizar caja con totales
    UPDATE caja
    SET 
        monto_final_bs = inicial_bs + total_bs,
        monto_final_dolar = inicial_dolar + total_dolar,
        fecha_cierre = NOW(),
        estado = 0
    WHERE id = cajaId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gastoClienteAnual` (IN `p_anio` INT)   BEGIN
    
    WITH meses AS (
        SELECT 1 AS mes_numero, 'Enero' AS nombre UNION
        SELECT 2, 'Febrero' UNION
        SELECT 3, 'Marzo' UNION
        SELECT 4, 'Abril' UNION
        SELECT 5, 'Mayo' UNION
        SELECT 6, 'Junio' UNION
        SELECT 7, 'Julio' UNION
        SELECT 8, 'Agosto' UNION
        SELECT 9, 'Septiembre' UNION
        SELECT 10, 'Octubre' UNION
        SELECT 11, 'Noviembre' UNION
        SELECT 12, 'Diciembre'
    ),

    
    ventas_por_mes AS (
        SELECT 
            MONTH(fecha) AS mes_numero,
            SUM(monto_final) AS total_mes,
            COUNT(DISTINCT DATE(fecha)) AS dias_con_ventas,
            SUM(monto_final) / COUNT(DISTINCT DATE(fecha)) AS promedio_diario
        FROM ventas
        WHERE YEAR(fecha) = p_anio
        GROUP BY MONTH(fecha)
    )

    SELECT
        m.nombre AS mes,
        m.mes_numero,
        ROUND(COALESCE(v.total_mes, 0), 2) AS total_mes,
        ROUND(COALESCE(v.promedio_diario, 0), 2) AS promedio_diario
    FROM meses m
    LEFT JOIN ventas_por_mes v ON m.mes_numero = v.mes_numero
    ORDER BY m.mes_numero;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gastoClienteMes` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
 DECLARE fecha_inicio DATE;
    DECLARE fecha_fin DATE;

    
    SET lc_time_names = 'es_ES';

    
    SET fecha_inicio = DATE(CONCAT(p_anio, '-', LPAD(p_mes, 2, '0'), '-01'));
    SET fecha_fin = LAST_DAY(fecha_inicio);

    
    DROP TEMPORARY TABLE IF EXISTS fechas_mes;
    CREATE TEMPORARY TABLE fechas_mes (
        fecha DATE,
        semana_iso INT
    );

    
    WHILE fecha_inicio <= fecha_fin DO
        INSERT INTO fechas_mes (fecha, semana_iso)
        VALUES (fecha_inicio, WEEK(fecha_inicio, 3));
        SET fecha_inicio = DATE_ADD(fecha_inicio, INTERVAL 1 DAY);
    END WHILE;

    
    SELECT 
        semana_iso AS semana,
        MIN(f.fecha) AS inicio_semana,
        MAX(f.fecha) AS fin_semana,
        ROUND(SUM(IFNULL(v.monto_final, 0)), 2) AS total_semana
    FROM fechas_mes f
    LEFT JOIN ventas v ON DATE(v.fecha) = f.fecha
    GROUP BY semana_iso
    ORDER BY semana_iso;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GastoClienteSemana` (IN `p_anio` INT, IN `p_semana` INT)   BEGIN
    DECLARE target_yearweek INT;

    
    SET target_yearweek = p_anio * 100 + p_semana;

    WITH 
    RECURSIVE calendario AS (
        SELECT DATE(CONCAT(p_anio,'-01-01')) AS fecha
        UNION ALL
        SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
        FROM calendario
        WHERE fecha < DATE(CONCAT(p_anio,'-12-31'))
    ),
    semana_iso AS (
        SELECT fecha
        FROM calendario
        WHERE YEARWEEK(fecha,1) = target_yearweek
    ),
    dias_nombres AS (
        SELECT 1 AS dia_orden, 'Lunes'    AS dia_nombre UNION ALL
        SELECT 2, 'Martes'    UNION ALL
        SELECT 3, 'Miércoles' UNION ALL
        SELECT 4, 'Jueves'    UNION ALL
        SELECT 5, 'Viernes'   UNION ALL
        SELECT 6, 'Sábado'    UNION ALL
        SELECT 7, 'Domingo'
    ),
    dias_semana AS (
        SELECT
          si.fecha,
          WEEKDAY(si.fecha) + 1      AS dia_orden,
          dn.dia_nombre
        FROM semana_iso si
        JOIN dias_nombres dn ON dn.dia_orden = WEEKDAY(si.fecha) + 1
    )

    SELECT
        ds.dia_nombre               AS dia,
        DATE_FORMAT(ds.fecha, '%Y-%m-%d') AS fecha,
        ROUND(SUM(IFNULL(v.monto_final, 0)), 2)   AS total_dia
    FROM dias_semana ds
    LEFT JOIN ventas v
      ON DATE(v.fecha) = ds.fecha
    GROUP BY
        ds.dia_orden,
        ds.dia_nombre,
        ds.fecha
    ORDER BY
        ds.dia_orden;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `porcentaje_reservaciones_anio` (IN `p_anio` INT)   BEGIN
    DECLARE total_reservaciones INT;

    -- Calcular el total de reservaciones para el año especificado
    SELECT COUNT(*) INTO total_reservaciones
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio;

    -- Calcular reservaciones por cada hora
    SELECT 
        '5 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 17

    UNION ALL

    SELECT 
        '6 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 18

    UNION ALL

    SELECT 
        '7 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 19

    UNION ALL

    SELECT 
        '8 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 20

    UNION ALL

    SELECT 
        '9 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 21

    UNION ALL

    SELECT 
        '10 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 22

    UNION ALL

    SELECT 
        '11 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 23;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `porcentaje_reservaciones_mes` (IN `p_mes` INT, IN `p_anio` INT)   BEGIN
    DECLARE total_reservaciones INT;

    -- Calcular el total de reservaciones para el mes y año especificados
    SELECT COUNT(*) INTO total_reservaciones
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio;

    -- Calcular reservaciones por cada hora
    SELECT 
        '5 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 17

    UNION ALL

    SELECT 
        '6 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 18

    UNION ALL

    SELECT 
        '7 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 19

    UNION ALL

    SELECT 
        '8 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 20

    UNION ALL

    SELECT 
        '9 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 21

    UNION ALL

    SELECT 
        '10 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 22

    UNION ALL

    SELECT 
        '11 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    WHERE MONTH(r.fecha_inicio) = p_mes
    AND YEAR(r.fecha_inicio) = p_anio
    AND HOUR(r.fecha_inicio) = 23;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `porcentaje_reservaciones_semana` (IN `p_semana` INT, IN `p_anio` INT)   BEGIN
    DECLARE total_reservaciones INT;

    -- Calcular el total de reservaciones para la semana y año especificados
    SELECT COUNT(*) INTO total_reservaciones
    FROM (
        WITH 
        RECURSIVE calendario AS (
            SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
            UNION ALL
            SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
            FROM calendario
            WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
        )
        SELECT fecha
        FROM calendario
        WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
    ) AS semana_iso
    JOIN reservaciones r ON DATE(r.fecha_inicio) = semana_iso.fecha;

    -- Calcular reservaciones por cada hora
    SELECT 
        '5 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 17

    UNION ALL

    SELECT 
        '6 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 18

    UNION ALL

    SELECT 
        '7 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 19

    UNION ALL

    SELECT 
        '8 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 20

    UNION ALL

    SELECT 
        '9 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 21

    UNION ALL

    SELECT 
        '10 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 22

    UNION ALL

    SELECT 
        '11 PM' AS hora,
        COUNT(*) AS cantidad,
        CASE 
            WHEN total_reservaciones = 0 THEN 0 
            ELSE ROUND((COUNT(*) / total_reservaciones) * 100, 2) 
        END AS porcentaje
    FROM reservaciones r
    JOIN (
        SELECT fecha
        FROM (
            WITH 
            RECURSIVE calendario AS (
                SELECT DATE(CONCAT(p_anio, '-01-01')) AS fecha
                UNION ALL
                SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
                FROM calendario
                WHERE fecha < DATE(CONCAT(p_anio, '-12-31'))
            )
            SELECT fecha
            FROM calendario
            WHERE YEARWEEK(fecha, 1) = (p_anio * 100 + p_semana)
        ) AS semana_iso
    ) AS si ON DATE(r.fecha_inicio) = si.fecha
    WHERE HOUR(r.fecha_inicio) = 23;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productosMasVendidoAnio` (IN `p_anio` INT)   BEGIN

    WITH meses AS (
        SELECT 1 AS mes_num, 'Enero' AS mes_nombre UNION ALL
        SELECT 2, 'Febrero' UNION ALL
        SELECT 3, 'Marzo' UNION ALL
        SELECT 4, 'Abril' UNION ALL
        SELECT 5, 'Mayo' UNION ALL
        SELECT 6, 'Junio' UNION ALL
        SELECT 7, 'Julio' UNION ALL
        SELECT 8, 'Agosto' UNION ALL
        SELECT 9, 'Septiembre' UNION ALL
        SELECT 10, 'Octubre' UNION ALL
        SELECT 11, 'Noviembre' UNION ALL
        SELECT 12, 'Diciembre'
    ),

    
    ventas_mensuales AS (
        SELECT
            MONTH(o.fecha)                     AS mes,
            p.id                               AS producto_id,
            p.nombre                           AS producto_nombre,
            SUM(od.cantidad)                   AS total_cantidad,
            SUM(od.cantidad * p.precio)        AS total_monto
        FROM producto_preparado_detalle_orden od
        JOIN productos_preparados p ON p.id = od.id_producto
        JOIN `orden` o              ON o.id = od.id_orden
        WHERE YEAR(o.fecha) = p_anio
          AND p.tipo = 'producto'
        GROUP BY mes, p.id, p.nombre
    ),

    
    ranking AS (
        SELECT
            vm.*,
            ROW_NUMBER() OVER (
                PARTITION BY vm.mes
                ORDER BY vm.total_cantidad DESC
            ) AS rn
        FROM ventas_mensuales vm
    ),

    top_ventas AS (
        SELECT
            mes,
            producto_nombre,
            total_cantidad,
            ROUND(total_monto, 2) AS total_monto
        FROM ranking
        WHERE rn <= 3
    )

    
    SELECT
        m.mes_num                        AS numero_mes,
        m.mes_nombre                    AS nombre_mes,
        COALESCE(tv.producto_nombre, 'Sin ventas') AS producto,
        COALESCE(tv.total_cantidad, 0) AS unidades_vendidas,
        COALESCE(tv.total_monto, 0.00) AS monto_generado
    FROM meses m
    LEFT JOIN top_ventas tv ON tv.mes = m.mes_num
    ORDER BY m.mes_num, unidades_vendidas DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productosMasVendidoMes` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
SET lc_time_names = 'es_ES';

    
    WITH RECURSIVE fechas AS (
        SELECT DATE(CONCAT(p_anio, '-', p_mes, '-01')) AS fecha
        UNION ALL
        SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
        FROM fechas
        WHERE MONTH(fecha) = p_mes AND YEAR(fecha) = p_anio
    ),
    semanas_mes AS (
        SELECT DISTINCT WEEK(fecha, 1) AS semana
        FROM fechas
    ),

    
    ventas_semanales AS (
        SELECT
            WEEK(o.fecha, 1)                  AS semana,
            p.id                              AS producto_id,
            p.nombre                          AS producto_nombre,
            SUM(od.cantidad)                  AS total_cantidad,
            SUM(od.cantidad * p.precio)       AS total_monto
        FROM producto_preparado_detalle_orden od
        JOIN productos_preparados p ON p.id = od.id_producto
        JOIN `orden` o              ON o.id = od.id_orden
        WHERE YEAR(o.fecha) = p_anio
          AND MONTH(o.fecha) = p_mes
          AND p.tipo = 'producto'
        GROUP BY semana, p.id, p.nombre
    ),

    
    ranking AS (
        SELECT
            vs.*,
            ROW_NUMBER() OVER (
                PARTITION BY vs.semana
                ORDER BY vs.total_cantidad DESC
            ) AS rn
        FROM ventas_semanales vs
    ),

    
    top_ventas AS (
        SELECT
            semana,
            producto_nombre,
            total_cantidad,
            ROUND(total_monto, 2) AS total_monto
        FROM ranking
        WHERE rn <= 3
    )

    
    SELECT
        sm.semana                      AS semana_del_anio,
        COALESCE(tv.producto_nombre, 'Sin ventas')  AS producto,
        COALESCE(tv.total_cantidad, 0)              AS unidades_vendidas,
        COALESCE(tv.total_monto, 0.00)              AS monto_generado
    FROM semanas_mes sm
    LEFT JOIN top_ventas tv ON tv.semana = sm.semana
    ORDER BY sm.semana, unidades_vendidas DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productosMasVendidoSemana` (IN `p_anio` INT, IN `p_semana` INT)   BEGIN
    
    SET lc_time_names = 'es_ES';

    
    WITH dias_semana AS (
        SELECT 0 AS dia_orden, 'Lunes' AS dia UNION ALL
        SELECT 1, 'Martes' UNION ALL
        SELECT 2, 'Miércoles' UNION ALL
        SELECT 3, 'Jueves' UNION ALL
        SELECT 4, 'Viernes' UNION ALL
        SELECT 5, 'Sábado' UNION ALL
        SELECT 6, 'Domingo'
    ),

    
    ventas_semanales AS (
        SELECT
            p.id                            AS producto_id,
            p.nombre                        AS producto_nombre,
            WEEKDAY(o.fecha)               AS dia_orden,
            DAYNAME(o.fecha)               AS dia_nombre,
            SUM(od.cantidad)               AS total_cantidad,
            SUM(od.cantidad * p.precio)    AS total_monto
        FROM producto_preparado_detalle_orden od
        JOIN productos_preparados p ON p.id = od.id_producto
        JOIN `orden` o              ON o.id = od.id_orden
        WHERE YEAR(o.fecha) = p_anio
          AND WEEK(o.fecha, 1) = p_semana
          AND p.tipo = 'producto'
        GROUP BY p.id, p.nombre, WEEKDAY(o.fecha), DAYNAME(o.fecha)
    ),

    
    ranking AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY dia_orden
                ORDER BY total_cantidad DESC
            ) AS rn
        FROM ventas_semanales
    ),

    
    dias_con_ventas AS (
        SELECT
            d.dia_orden,
            d.dia,
            COALESCE(r.producto_nombre, 'SIN VENTA') AS producto,
            IFNULL(r.total_cantidad, 0) AS unidades_vendidas,
            ROUND(IFNULL(r.total_monto, 0), 2) AS monto_generado
        FROM dias_semana d
        LEFT JOIN ranking r ON d.dia_orden = r.dia_orden AND r.rn <= 3
    )

    SELECT *
    FROM dias_con_ventas
    ORDER BY dia_orden, unidades_vendidas DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productosMenosVendidoAnio` (IN `p_anio` INT)   BEGIN

    WITH meses AS (
        SELECT 1 AS mes_num, 'Enero' AS mes_nombre UNION ALL
        SELECT 2, 'Febrero' UNION ALL
        SELECT 3, 'Marzo' UNION ALL
        SELECT 4, 'Abril' UNION ALL
        SELECT 5, 'Mayo' UNION ALL
        SELECT 6, 'Junio' UNION ALL
        SELECT 7, 'Julio' UNION ALL
        SELECT 8, 'Agosto' UNION ALL
        SELECT 9, 'Septiembre' UNION ALL
        SELECT 10, 'Octubre' UNION ALL
        SELECT 11, 'Noviembre' UNION ALL
        SELECT 12, 'Diciembre'
    ),

    
    ventas_mensuales AS (
        SELECT
            MONTH(o.fecha)                     AS mes,
            p.id                               AS producto_id,
            p.nombre                           AS producto_nombre,
            SUM(od.cantidad)                   AS total_cantidad,
            SUM(od.cantidad * p.precio)        AS total_monto
        FROM producto_preparado_detalle_orden od
        JOIN productos_preparados p ON p.id = od.id_producto
        JOIN `orden` o              ON o.id = od.id_orden
        WHERE YEAR(o.fecha) = p_anio
          AND p.tipo = 'producto'
        GROUP BY mes, p.id, p.nombre
    ),

    
    ranking AS (
        SELECT
            vm.*,
            ROW_NUMBER() OVER (
                PARTITION BY vm.mes
                ORDER BY vm.total_cantidad ASC
            ) AS rn
        FROM ventas_mensuales vm
    ),

    top_ventas AS (
        SELECT
            mes,
            producto_nombre,
            total_cantidad,
            ROUND(total_monto, 2) AS total_monto
        FROM ranking
        WHERE rn <= 3
    )

    
    SELECT
        m.mes_num                        AS numero_mes,
        m.mes_nombre                    AS nombre_mes,
        COALESCE(tv.producto_nombre, 'Sin ventas') AS producto,
        COALESCE(tv.total_cantidad, 0) AS unidades_vendidas,
        COALESCE(tv.total_monto, 0.00) AS monto_generado
    FROM meses m
    LEFT JOIN top_ventas tv ON tv.mes = m.mes_num
    ORDER BY m.mes_num, unidades_vendidas ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productosMenosVendidoMes` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
SET lc_time_names = 'es_ES';

    
    WITH RECURSIVE fechas AS (
        SELECT DATE(CONCAT(p_anio, '-', p_mes, '-01')) AS fecha
        UNION ALL
        SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
        FROM fechas
        WHERE MONTH(fecha) = p_mes AND YEAR(fecha) = p_anio
    ),
    semanas_mes AS (
        SELECT DISTINCT WEEK(fecha, 1) AS semana
        FROM fechas
    ),

    
    ventas_semanales AS (
        SELECT
            WEEK(o.fecha, 1)                  AS semana,
            p.id                              AS producto_id,
            p.nombre                          AS producto_nombre,
            SUM(od.cantidad)                  AS total_cantidad,
            SUM(od.cantidad * p.precio)       AS total_monto
        FROM producto_preparado_detalle_orden od
        JOIN productos_preparados p ON p.id = od.id_producto
        JOIN `orden` o              ON o.id = od.id_orden
        WHERE YEAR(o.fecha) = p_anio
          AND MONTH(o.fecha) = p_mes
          AND p.tipo = 'producto'
        GROUP BY semana, p.id, p.nombre
    ),

    
    ranking AS (
        SELECT
            vs.*,
            ROW_NUMBER() OVER (
                PARTITION BY vs.semana
                ORDER BY vs.total_cantidad ASC
            ) AS rn
        FROM ventas_semanales vs
    ),

    
    top_ventas AS (
        SELECT
            semana,
            producto_nombre,
            total_cantidad,
            ROUND(total_monto, 2) AS total_monto
        FROM ranking
        WHERE rn <= 3
    )

    
    SELECT
        sm.semana                      AS semana_del_anio,
        COALESCE(tv.producto_nombre, 'Sin ventas')  AS producto,
        COALESCE(tv.total_cantidad, 0)              AS unidades_vendidas,
        COALESCE(tv.total_monto, 0.00)              AS monto_generado
    FROM semanas_mes sm
    LEFT JOIN top_ventas tv ON tv.semana = sm.semana
    ORDER BY sm.semana, unidades_vendidas ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `productosMenosVendidoSemana` (IN `p_anio` INT, IN `p_semana` INT)   BEGIN
    
    SET lc_time_names = 'es_ES';

    
    WITH dias_semana AS (
        SELECT 0 AS dia_orden, 'Lunes' AS dia UNION ALL
        SELECT 1, 'Martes' UNION ALL
        SELECT 2, 'Miércoles' UNION ALL
        SELECT 3, 'Jueves' UNION ALL
        SELECT 4, 'Viernes' UNION ALL
        SELECT 5, 'Sábado' UNION ALL
        SELECT 6, 'Domingo'
    ),

    
    ventas_semanales AS (
        SELECT
            p.id                            AS producto_id,
            p.nombre                        AS producto_nombre,
            WEEKDAY(o.fecha)               AS dia_orden,
            DAYNAME(o.fecha)               AS dia_nombre,
            SUM(od.cantidad)               AS total_cantidad,
            SUM(od.cantidad * p.precio)    AS total_monto
        FROM producto_preparado_detalle_orden od
        JOIN productos_preparados p ON p.id = od.id_producto
        JOIN `orden` o              ON o.id = od.id_orden
        WHERE YEAR(o.fecha) = p_anio
          AND WEEK(o.fecha, 1) = p_semana
          AND p.tipo = 'producto'
        GROUP BY p.id, p.nombre, WEEKDAY(o.fecha), DAYNAME(o.fecha)
    ),

    
    ranking AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY dia_orden
                ORDER BY total_cantidad DESC
            ) AS rn
        FROM ventas_semanales
    ),

    
    dias_con_ventas AS (
        SELECT
            d.dia_orden,
            d.dia,
            COALESCE(r.producto_nombre, 'SIN VENTA') AS producto,
            IFNULL(r.total_cantidad, 0) AS unidades_vendidas,
            ROUND(IFNULL(r.total_monto, 0), 2) AS monto_generado
        FROM dias_semana d
        LEFT JOIN ranking r ON d.dia_orden = r.dia_orden AND r.rn <= 3
    )

    SELECT *
    FROM dias_con_ventas
    ORDER BY dia_orden, unidades_vendidas ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReservasPorMetodoAnual` (IN `p_anio` INT)   BEGIN
    
    SELECT
        metodo_pedido,
        COALESCE(COUNT(*),0) AS cantidad_reservas
    FROM reservaciones
    WHERE YEAR(fecha_inicio) = p_anio
    GROUP BY metodo_pedido;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReservasPorMetodoMes` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
    
    SELECT
        metodo_pedido,
        COUNT(*) AS cantidad_reservas
    FROM reservaciones
    WHERE YEAR(fecha_inicio) = p_anio AND MONTH(fecha_inicio) =p_mes
    GROUP BY metodo_pedido;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReservasPorMetodoSemana` (IN `p_anio` INT, IN `p_semana` INT)   BEGIN
    -- Versión adaptada para trabajar por semana y año
    SELECT
        metodo_pedido,
        COUNT(*) AS cantidad_reservas
    FROM reservaciones
    WHERE YEARWEEK(fecha_inicio, 1) = (p_anio * 100 + p_semana)
    GROUP BY metodo_pedido;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalVentasAnio` (IN `p_anio` INT)   BEGIN
    SELECT
        o.tipo AS tipo_orden,
        COUNT(DISTINCT o.id) AS total_ordenes,
        ROUND(SUM(v.monto_final), 2) AS total_recaudado
    FROM `orden` o
    JOIN ventas v ON v.id_orden = o.id
    WHERE YEAR(o.fecha) = p_anio
    GROUP BY o.tipo
    ORDER BY total_recaudado DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalVentasMes` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
    SELECT
        o.tipo AS tipo_orden,
        COUNT(DISTINCT o.id) AS total_ordenes,
        ROUND(SUM(v.monto_final), 2) AS total_recaudado
    FROM `orden` o
    JOIN ventas v ON v.id_orden = o.id
    WHERE YEAR(o.fecha) = p_anio
      AND MONTH(o.fecha) = p_mes
    GROUP BY o.tipo
    ORDER BY total_recaudado DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TotalVentasSemana` (IN `p_anio` INT, IN `p_semana` INT)   BEGIN
    SELECT
        o.tipo AS tipo_orden,
        COUNT(DISTINCT o.id) AS total_ordenes,
        ROUND(SUM(v.monto_final), 2) AS total_recaudado
    FROM `orden` o
    JOIN ventas v ON v.id_orden = o.id
    WHERE YEAR(o.fecha) = p_anio
      AND WEEK(o.fecha, 1) = p_semana
    GROUP BY o.tipo
    ORDER BY total_recaudado DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UtilidadNetaAnual` (IN `p_anio` INT)   BEGIN
    
    WITH meses AS (
        SELECT 1 AS mes_numero, 'Enero' AS nombre UNION
        SELECT 2, 'Febrero' UNION
        SELECT 3, 'Marzo' UNION
        SELECT 4, 'Abril' UNION
        SELECT 5, 'Mayo' UNION
        SELECT 6, 'Junio' UNION
        SELECT 7, 'Julio' UNION
        SELECT 8, 'Agosto' UNION
        SELECT 9, 'Septiembre' UNION
        SELECT 10, 'Octubre' UNION
        SELECT 11, 'Noviembre' UNION
        SELECT 12, 'Diciembre'
    ),
    
    utilidad_por_mes AS (
        SELECT 
            MONTH(mc.fecha) AS mes_numero,
            ROUND(SUM(CASE WHEN mc.monto / mc.tasa > 0 THEN mc.monto / mc.tasa ELSE 0 END), 2) AS ingresos,
            ROUND(SUM(CASE WHEN mc.monto / mc.tasa > 0 AND mc.descripcion LIKE '%Ingreso por venta%' 
                           THEN mc.monto / mc.tasa ELSE 0 END), 2) AS ventas,
            ROUND(SUM(CASE WHEN mc.monto / mc.tasa < 0 THEN mc.monto / mc.tasa ELSE 0 END), 2) AS gastos,
            ROUND(
                SUM(CASE WHEN mc.monto / mc.tasa > 0 THEN mc.monto / mc.tasa ELSE 0 END) +
                SUM(CASE WHEN mc.monto / mc.tasa < 0 THEN mc.monto / mc.tasa ELSE 0 END), 2
            ) AS utilidad_neta
        FROM movimientos_capital mc
        WHERE YEAR(mc.fecha) = p_anio
        GROUP BY MONTH(mc.fecha)
    )

    SELECT
        m.nombre AS mes,
        m.mes_numero,
        COALESCE(u.ingresos, 0) AS ingresos,
        COALESCE(u.ventas, 0) AS ventas,
        COALESCE(u.gastos, 0) AS gastos,
        COALESCE(u.utilidad_neta, 0) AS utilidad_neta
    FROM meses m
    LEFT JOIN utilidad_por_mes u ON m.mes_numero = u.mes_numero
    ORDER BY m.mes_numero;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UtilidadNetaMes` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
    
    WITH RECURSIVE calendario AS (
        SELECT DATE(CONCAT(p_anio, '-', LPAD(p_mes, 2, '0'), '-01')) AS fecha
        UNION ALL
        SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
        FROM calendario
        WHERE MONTH(fecha) = p_mes
          AND fecha < LAST_DAY(CONCAT(p_anio, '-', LPAD(p_mes, 2, '0'), '-01'))
    ),

    semanas_del_mes AS (
        SELECT 
            YEARWEEK(fecha, 1) AS anio_semana,
            WEEK(fecha, 1)     AS semana,
            MIN(fecha) OVER (PARTITION BY WEEK(fecha, 1)) AS inicio_semana,
            MAX(fecha) OVER (PARTITION BY WEEK(fecha, 1)) AS fin_semana,
            fecha
        FROM calendario
    ),

    semanas_agrupadas AS (
        SELECT DISTINCT 
            semana,
            DATE_FORMAT(MIN(fecha), '%Y-%m-%d') AS fecha_inicio,
            DATE_FORMAT(MAX(fecha), '%Y-%m-%d') AS fecha_fin
        FROM semanas_del_mes
        GROUP BY semana
    )

    SELECT 
        sa.semana                               AS semana,
        sa.fecha_inicio                         AS fecha_inicio,
        sa.fecha_fin                            AS fecha_fin,
        
        ROUND(SUM(CASE 
            WHEN mc.monto / NULLIF(mc.tasa,0) > 0 THEN mc.monto / NULLIF(mc.tasa,0)
        END), 2) AS ingresos,
        
        ROUND(SUM(CASE 
            WHEN mc.monto / NULLIF(mc.tasa,0) > 0 
                 AND mc.descripcion LIKE '%Ingreso por venta%' 
            THEN mc.monto / NULLIF(mc.tasa,0)
        END), 2) AS ventas,
        
        ROUND(SUM(CASE 
            WHEN mc.monto / NULLIF(mc.tasa,0) < 0 THEN mc.monto / NULLIF(mc.tasa,0)
        END), 2) AS gastos,
        
        ROUND(
            SUM(CASE WHEN mc.monto / NULLIF(mc.tasa,0) > 0 THEN mc.monto / NULLIF(mc.tasa,0) ELSE 0 END) +
            SUM(CASE WHEN mc.monto / NULLIF(mc.tasa,0) < 0 THEN mc.monto / NULLIF(mc.tasa,0) ELSE 0 END)
        , 2) AS utilidad_neta

    FROM semanas_agrupadas sa
    LEFT JOIN movimientos_capital mc 
      ON WEEK(mc.fecha, 1) = sa.semana AND YEAR(mc.fecha) = p_anio
    GROUP BY sa.semana, sa.fecha_inicio, sa.fecha_fin
    ORDER BY sa.semana;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UtilidadNetaSemana` (IN `p_anio` INT, IN `p_semana` INT)   BEGIN
    DECLARE target_yearweek INT;

    -- Construir el formato de YEARWEEK
    SET target_yearweek = p_anio * 100 + p_semana;

    WITH 
    RECURSIVE calendario AS (
        SELECT DATE(CONCAT(p_anio,'-01-01')) AS fecha
        UNION ALL
        SELECT DATE_ADD(fecha, INTERVAL 1 DAY)
        FROM calendario
        WHERE fecha < DATE(CONCAT(p_anio,'-12-31'))
    ),

    semana_iso AS (
        SELECT fecha
        FROM calendario
        WHERE YEARWEEK(fecha,1) = target_yearweek
    ),

    dias_nombres AS (
        SELECT 1 AS dia_orden, 'Lunes'    AS dia_nombre UNION ALL
        SELECT 2, 'Martes'    UNION ALL
        SELECT 3, 'Miércoles' UNION ALL
        SELECT 4, 'Jueves'    UNION ALL
        SELECT 5, 'Viernes'   UNION ALL
        SELECT 6, 'Sábado'    UNION ALL
        SELECT 7, 'Domingo'
    ),

    dias_semana AS (
        SELECT
            si.fecha,
            WEEKDAY(si.fecha) + 1  AS dia_orden,
            dn.dia_nombre
        FROM semana_iso si
        JOIN dias_nombres dn ON dn.dia_orden = WEEKDAY(si.fecha) + 1
    )

    SELECT
        ds.dia_nombre                                AS dia,
        DATE_FORMAT(ds.fecha, '%Y-%m-%d')            AS fecha,
        
        ROUND(SUM(CASE 
            WHEN mc.monto / NULLIF(mc.tasa,0) > 0 THEN mc.monto / NULLIF(mc.tasa,0)
        END), 2) AS ingresos,
        
        ROUND(SUM(CASE 
            WHEN mc.monto / NULLIF(mc.tasa,0) > 0 
                 AND mc.descripcion LIKE '%Ingreso por venta%' 
            THEN mc.monto / NULLIF(mc.tasa,0)
        END), 2) AS ventas,
        
        ROUND(SUM(CASE 
            WHEN mc.monto / NULLIF(mc.tasa,0) < 0 THEN mc.monto / NULLIF(mc.tasa,0)
        END), 2) AS gastos,
        
        ROUND(
            SUM(CASE WHEN mc.monto / NULLIF(mc.tasa,0) > 0 THEN mc.monto / NULLIF(mc.tasa,0) ELSE 0 END) +
            SUM(CASE WHEN mc.monto / NULLIF(mc.tasa,0) < 0 THEN mc.monto / NULLIF(mc.tasa,0) ELSE 0 END)
        , 2) AS utilidad_neta

    FROM dias_semana ds
    LEFT JOIN movimientos_capital mc 
           ON DATE(mc.fecha) = ds.fecha
    GROUP BY ds.dia_orden, ds.dia_nombre, ds.fecha
    ORDER BY ds.dia_orden;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `id` int NOT NULL,
  `id_usuario` int NOT NULL,
  `monto_inicial_dolar` float NOT NULL,
  `monto_inicial_bs` float NOT NULL,
  `monto_final_bs` float DEFAULT NULL,
  `monto_final_dolar` float DEFAULT NULL,
  `fecha_apertura` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_cierre` datetime DEFAULT NULL,
  `estado` int NOT NULL DEFAULT '1',
  `total_ventas` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `caja`
--

INSERT INTO `caja` (`id`, `id_usuario`, `monto_inicial_dolar`, `monto_inicial_bs`, `monto_final_bs`, `monto_final_dolar`, `fecha_apertura`, `fecha_cierre`, `estado`, `total_ventas`) VALUES
(27, 11, 150, 3000, 3796.16, 158.88, '2025-07-07 14:07:09', '2025-07-09 12:57:17', 0, NULL),
(28, 11, 150, 25, 2237.26, 150, '2025-07-09 12:57:28', '2025-07-10 14:45:38', 0, NULL),
(29, 11, 300, 2500, 4988.16, 300, '2025-07-16 14:45:52', '2025-07-25 12:23:49', 0, NULL),
(30, 11, 58.55, 250, 11657.2, 58.55, '2025-08-06 12:24:01', '2025-08-09 12:13:04', 0, NULL),
(31, 11, 150, 25, NULL, NULL, '2025-08-28 08:13:13', NULL, 1, NULL),
(32, 11, 1000, 1000, 0, 0, '2025-10-13 19:10:54', NULL, 1, NULL),
(33, 11, 1000, 1000, 0, 0, '2025-10-13 19:10:58', NULL, 1, NULL),
(34, 11, 1000, 1000, 0, 0, '2025-10-13 19:18:38', NULL, 1, NULL),
(35, 11, 1000, 1000, 0, 0, '2025-10-13 19:24:55', NULL, 1, NULL),
(36, 11, 1000, 1000, 0, 0, '2025-10-13 19:24:58', NULL, 1, NULL),
(37, 11, 1000, 1000, 0, 0, '2025-10-13 19:32:29', NULL, 1, NULL),
(38, 11, 1000, 1000, 0, 0, '2025-10-13 19:35:26', NULL, 1, NULL),
(39, 11, 1000, 1000, 0, 0, '2025-10-13 19:36:53', NULL, 1, NULL),
(40, 11, 1000, 1000, 0, 0, '2025-10-13 19:38:06', NULL, 1, NULL),
(41, 11, 1000, 1000, 0, 0, '2025-10-13 19:41:51', NULL, 1, NULL),
(42, 11, 1000, 1000, 0, 0, '2025-10-13 19:43:41', NULL, 1, NULL),
(43, 11, 1000, 1000, 0, 0, '2025-10-13 19:45:30', NULL, 1, NULL),
(44, 11, 1000, 1000, 0, 0, '2025-10-13 19:45:43', NULL, 1, NULL),
(45, 11, 1000, 1000, 0, 0, '2025-10-13 19:46:46', NULL, 1, NULL),
(46, 11, 1000, 1000, 0, 0, '2025-10-13 19:56:53', NULL, 1, NULL),
(47, 11, 1000, 1000, 0, 0, '2025-10-13 19:57:59', NULL, 1, NULL),
(48, 11, 1000, 1000, 0, 0, '2025-10-13 19:58:09', NULL, 1, NULL),
(49, 11, 1000, 1000, 0, 0, '2025-10-13 20:02:24', NULL, 1, NULL),
(50, 11, 1000, 1000, 0, 0, '2025-10-13 20:18:33', NULL, 1, NULL),
(51, 11, 1000, 1000, 0, 0, '2025-10-13 20:30:09', NULL, 1, NULL),
(52, 11, 1000, 1000, 0, 0, '2025-10-13 20:31:37', NULL, 1, NULL),
(53, 11, 1000, 1000, 0, 0, '2025-10-13 20:31:51', NULL, 1, NULL),
(54, 11, 1000, 1000, 0, 0, '2025-10-13 20:34:35', NULL, 1, NULL),
(55, 11, 1000, 1000, 0, 0, '2025-10-13 20:35:05', NULL, 1, NULL),
(56, 11, 1000, 1000, 0, 0, '2025-10-13 20:35:51', NULL, 1, NULL),
(57, 11, 1000, 1000, 0, 0, '2025-10-13 20:37:25', NULL, 1, NULL),
(58, 11, 1000, 1000, 0, 0, '2025-10-13 20:38:29', NULL, 1, NULL),
(59, 11, 1000, 1000, 0, 0, '2025-10-13 20:38:45', NULL, 1, NULL),
(60, 11, 1000, 1000, 0, 0, '2025-10-13 20:39:19', NULL, 1, NULL),
(61, 11, 1000, 1000, 0, 0, '2025-10-13 20:40:45', NULL, 1, NULL),
(62, 11, 1000, 1000, 0, 0, '2025-10-13 20:42:47', NULL, 1, NULL),
(63, 11, 1000, 1000, 0, 0, '2025-10-13 20:43:27', NULL, 1, NULL),
(64, 11, 1000, 1000, 0, 0, '2025-10-13 20:43:49', NULL, 1, NULL),
(65, 11, 1000, 1000, 0, 0, '2025-10-13 20:44:11', NULL, 1, NULL),
(66, 11, 1000, 1000, 0, 0, '2025-10-13 20:44:46', NULL, 1, NULL),
(67, 11, 1000, 1000, 0, 0, '2025-10-13 20:45:10', NULL, 1, NULL),
(68, 11, 1000, 1000, 0, 0, '2025-10-13 20:45:20', NULL, 1, NULL),
(69, 11, 1000, 1000, 0, 0, '2025-10-13 20:46:04', NULL, 1, NULL),
(70, 11, 1000, 1000, 0, 0, '2025-10-13 21:06:10', NULL, 1, NULL),
(71, 11, 1000, 1000, 0, 0, '2025-10-14 20:02:57', NULL, 1, NULL),
(72, 11, 1000, 1000, 0, 0, '2025-10-24 13:46:19', NULL, 1, NULL),
(73, 11, 1000, 1000, 0, 0, '2025-10-24 13:47:33', NULL, 1, NULL),
(74, 11, 1000, 1000, 0, 0, '2025-10-24 13:49:43', NULL, 1, NULL),
(75, 11, 1000, 1000, 0, 0, '2025-10-24 13:49:55', NULL, 1, NULL),
(76, 11, 1000, 1000, 0, 0, '2025-10-24 13:50:27', NULL, 1, NULL),
(77, 11, 1000, 1000, 0, 0, '2025-10-24 13:50:51', NULL, 1, NULL),
(78, 11, 1000, 1000, 0, 0, '2025-10-24 13:53:31', NULL, 1, NULL),
(79, 11, 1000, 1000, 0, 0, '2025-10-24 13:53:54', NULL, 1, NULL),
(80, 11, 1000, 1000, 0, 0, '2025-10-24 13:55:13', NULL, 1, NULL),
(81, 11, 1000, 1000, 0, 0, '2025-10-24 13:56:24', NULL, 1, NULL),
(82, 11, 1000, 1000, 0, 0, '2025-10-24 13:57:57', NULL, 1, NULL),
(83, 11, 1000, 1000, 0, 0, '2025-10-26 13:01:15', NULL, 1, NULL),
(84, 11, 1000, 1000, 1000, 1000, '2025-10-26 13:02:16', '2025-10-30 10:15:30', 0, NULL),
(85, 11, 1000, 1000, 1000, 1000, '2025-10-26 13:07:04', '2025-10-30 10:15:27', 0, NULL),
(86, 11, 1000, 1000, 1000, 1000, '2025-10-26 13:09:30', '2025-10-30 10:15:25', 0, NULL),
(87, 14, 0.1, 0.1, 0.1, 0.1, '2025-10-30 09:57:02', '2025-10-30 10:15:23', 0, NULL),
(88, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:27:13', NULL, 1, NULL),
(89, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:29:44', NULL, 1, NULL),
(90, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:30:45', NULL, 1, NULL),
(91, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:32:56', NULL, 1, NULL),
(92, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:33:18', NULL, 1, NULL),
(93, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:34:10', NULL, 1, NULL),
(94, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:34:30', NULL, 1, NULL),
(95, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:35:43', NULL, 1, NULL),
(96, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:49:16', NULL, 1, NULL),
(97, 11, 1000, 1000, NULL, NULL, '2025-11-05 22:50:46', NULL, 1, NULL),
(98, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:10:18', NULL, 1, NULL),
(99, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:10:43', NULL, 1, NULL),
(100, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:12:32', NULL, 1, NULL),
(101, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:13:35', NULL, 1, NULL),
(102, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:15:18', NULL, 1, NULL),
(103, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:17:44', NULL, 1, NULL),
(104, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:18:04', NULL, 1, NULL),
(105, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:19:25', NULL, 1, NULL),
(106, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:21:21', NULL, 1, NULL),
(107, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:22:44', NULL, 1, NULL),
(108, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:24:52', NULL, 1, NULL),
(109, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:25:14', NULL, 1, NULL),
(110, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:26:08', NULL, 1, NULL),
(111, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:26:51', NULL, 1, NULL),
(112, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:46:36', NULL, 1, NULL),
(113, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:47:18', NULL, 1, NULL),
(114, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:49:51', NULL, 1, NULL),
(115, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:50:15', NULL, 1, NULL),
(116, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:50:37', NULL, 1, NULL),
(117, 11, 1000, 1000, NULL, NULL, '2025-11-05 23:51:01', NULL, 1, NULL),
(118, 11, 1000, 1000, NULL, NULL, '2025-11-06 01:01:42', NULL, 1, NULL),
(119, 11, 1000, 1000, NULL, NULL, '2025-11-06 01:31:50', NULL, 1, NULL),
(120, 11, 1000, 1000, NULL, NULL, '2025-11-06 01:33:44', NULL, 1, NULL),
(121, 11, 1000, 1000, NULL, NULL, '2025-11-06 01:33:46', NULL, 1, NULL),
(122, 11, 1000, 1000, NULL, NULL, '2025-11-06 06:45:15', NULL, 1, NULL),
(123, 11, 1000, 1000, 1000, 1000, '2025-11-11 14:21:06', '2026-03-01 13:09:18', 0, NULL),
(124, 11, 1000, 1000, NULL, NULL, '2025-11-11 14:21:29', NULL, 1, NULL),
(125, 11, 1000, 1000, 1000, 1000, '2025-11-11 17:42:29', '2026-03-01 13:09:14', 0, NULL),
(126, 25, 20, 100, 100, 20, '2026-02-28 16:10:04', '2026-02-28 16:10:09', 0, NULL),
(127, 25, 1.11, 1231.23, 1231.23, 1.11, '2026-03-01 13:08:49', '2026-03-01 13:09:09', 0, NULL),
(128, 25, 20, 100, NULL, NULL, '2026-03-01 21:27:15', NULL, 1, NULL),
(129, 11, 1000, 1000, NULL, NULL, '2026-03-03 17:33:52', NULL, 1, NULL),
(130, 11, 1000, 1000, NULL, NULL, '2026-03-03 17:34:32', NULL, 1, NULL),
(131, 11, 1000, 1000, NULL, NULL, '2026-03-03 17:38:05', NULL, 1, NULL),
(132, 11, 1000, 1000, NULL, NULL, '2026-03-03 17:38:15', NULL, 1, NULL),
(133, 11, 1000, 1000, NULL, NULL, '2026-03-03 17:38:33', NULL, 1, NULL),
(134, 11, 1000, 1000, NULL, NULL, '2026-03-03 17:52:02', NULL, 1, NULL),
(135, 11, 1000, 1000, NULL, NULL, '2026-03-03 18:00:19', NULL, 1, NULL),
(136, 11, 1000, 1000, NULL, NULL, '2026-03-03 18:41:27', NULL, 1, NULL),
(137, 11, 1000, 1000, NULL, NULL, '2026-03-03 18:47:21', NULL, 1, NULL),
(138, 11, 1000, 1000, NULL, NULL, '2026-03-03 18:55:23', NULL, 1, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `capital`
--

CREATE TABLE `capital` (
  `id` int NOT NULL,
  `monto` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `capital`
--

INSERT INTO `capital` (`id`, `monto`, `fecha`) VALUES
(1, -47190.1, '2025-06-12 16:08:49');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias_productos`
--

CREATE TABLE `categorias_productos` (
  `id` int NOT NULL,
  `nombre` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `categorias_productos`
--

INSERT INTO `categorias_productos` (`id`, `nombre`, `active`) VALUES
(1, 'Bebidas', 1),
(2, 'Pepitos', 1),
(3, 'Griegos', 1),
(4, 'Perros Calientes', 1),
(5, 'Papas', 1),
(6, 'Club House', 1),
(7, 'Burgers', 1),
(8, 'Kids', 1),
(9, 'Jira', 0),
(10, 'Adicionales', 0),
(11, 'Otra mas', 0),
(12, 'UN a', 0),
(13, 'Nueva categoria', 0),
(14, 'Hola', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_materia_prima`
--

CREATE TABLE `categoria_materia_prima` (
  `id` int NOT NULL,
  `nombre` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `categoria_materia_prima`
--

INSERT INTO `categoria_materia_prima` (`id`, `nombre`, `active`) VALUES
(1, 'Carnes', 1),
(2, 'Panadería', 1),
(3, 'Verduras y hortaliza', 1),
(4, 'Salsas y condimentos', 1),
(5, 'Aceites y grasas', 1),
(6, 'Postres y acompañamientos', 1),
(7, 'Lacteos', 1),
(8, 'Prueba', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id` int NOT NULL,
  `nombre` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `apellido` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `documento` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `apellido`, `telefono`, `active`, `documento`) VALUES
(1, 'Jose', 'Escalona', '+584126742231', 1, 'V-30087582'),
(36, 'AMELIA', 'GARNICAR', '+584266092231', 1, 'V-5435543'),
(44, 'ALI', 'PERNALETE', '+584125695231', 1, 'V-30087583'),
(114, 'EDOUARD', 'SANDOVAL', '+584122943118', 1, 'V-29972530');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuraciones`
--

CREATE TABLE `configuraciones` (
  `id` int NOT NULL,
  `llave` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `valor` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `delivery`
--

CREATE TABLE `delivery` (
  `id` int NOT NULL,
  `id_usuario_delivery` int NOT NULL,
  `id_venta` int NOT NULL,
  `active` tinyint DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `delivery`
--

INSERT INTO `delivery` (`id`, `id_usuario_delivery`, `id_venta`, `active`) VALUES
(4, 11, 61, 1),
(40, 11, 145, 1),
(42, 11, 148, 1),
(44, 11, 151, 1),
(46, 11, 154, 1),
(67, 11, 189, 1),
(68, 11, 192, 1),
(69, 11, 194, 1),
(71, 11, 196, 1),
(73, 11, 199, 1),
(75, 11, 202, 1),
(77, 11, 205, 1),
(79, 11, 208, 1),
(81, 11, 211, 1),
(83, 11, 214, 1),
(85, 11, 217, 1),
(87, 11, 220, 1),
(89, 11, 223, 1),
(91, 11, 226, 1),
(94, 11, 229, 1),
(96, 11, 233, 1),
(98, 11, 236, 1),
(100, 11, 239, 1),
(102, 11, 242, 1),
(104, 11, 245, 1),
(106, 11, 248, 1),
(108, 11, 251, 1),
(110, 11, 254, 1),
(112, 11, 257, 1),
(114, 11, 260, 1),
(116, 11, 263, 1),
(118, 11, 266, 1),
(120, 11, 269, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_entradas_materia_prima`
--

CREATE TABLE `detalles_entradas_materia_prima` (
  `id` int NOT NULL,
  `codigo` varchar(45) NOT NULL,
  `id_materia_prima` int NOT NULL,
  `id_entrada` int NOT NULL,
  `fecha_vencimiento` datetime NOT NULL,
  `existencia` float NOT NULL,
  `cantidad` float DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `broken` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `detalles_entradas_materia_prima`
--

INSERT INTO `detalles_entradas_materia_prima` (`id`, `codigo`, `id_materia_prima`, `id_entrada`, `fecha_vencimiento`, `existencia`, `cantidad`, `active`, `broken`) VALUES
(23, '545454', 8, 85, '2025-10-10 00:00:00', 55, 55, 1, 0),
(24, '5565', 10, 86, '6666-05-04 00:00:00', 0.5, 0.5, 1, 0),
(25, 'COD-00001', 1, 90, '2026-10-24 00:00:00', 5, 5, 1, 0),
(26, 'COD-00002', 2, 90, '2026-10-24 00:00:00', 10, 10, 1, 0),
(27, 'COD-00003', 3, 90, '2026-10-24 00:00:00', 15, 15, 1, 0),
(28, 'COD-00001', 1, 91, '2026-10-24 00:00:00', 5, 5, 1, 0),
(29, 'COD-00002', 2, 91, '2026-10-24 00:00:00', 10, 10, 1, 0),
(30, 'COD-00003', 3, 91, '2026-10-24 00:00:00', 15, 15, 1, 0),
(31, 'COD-00001', 1, 92, '2026-10-24 00:00:00', 5, 5, 1, 0),
(32, 'COD-00002', 2, 92, '2026-10-24 00:00:00', 10, 10, 1, 0),
(33, 'COD-00003', 3, 92, '2026-10-24 00:00:00', 15, 15, 1, 0),
(34, 'COD-00001', 1, 93, '2026-10-24 00:00:00', 5, 5, 1, 0),
(35, 'COD-00002', 2, 93, '2026-10-24 00:00:00', 10, 10, 1, 0),
(36, 'COD-00003', 3, 93, '2026-10-24 00:00:00', 15, 15, 1, 0),
(37, 'COD-00001', 1, 94, '2026-10-24 00:00:00', 5, 5, 1, 0),
(38, 'COD-00002', 2, 94, '2026-10-24 00:00:00', 10, 10, 1, 0),
(39, 'COD-00003', 3, 94, '2026-10-24 00:00:00', 15, 15, 1, 0),
(40, 'COD-00001', 1, 95, '2026-10-24 00:00:00', 5, 5, 1, 0),
(41, 'COD-00002', 2, 95, '2026-10-24 00:00:00', 10, 10, 1, 0),
(42, 'COD-00003', 3, 95, '2026-10-24 00:00:00', 15, 15, 1, 0),
(48, 'COD-00001', 1, 101, '2026-10-24 00:00:00', 5, 5, 1, 0),
(49, 'COD-00002', 2, 101, '2026-10-24 00:00:00', 10, 10, 1, 0),
(50, 'COD-00003', 3, 101, '2026-10-24 00:00:00', 15, 15, 1, 0),
(51, 'COD-00001', 1, 102, '2026-10-24 00:00:00', 5, 5, 1, 0),
(52, 'COD-00002', 2, 102, '2026-10-24 00:00:00', 10, 10, 1, 0),
(53, 'COD-00003', 3, 102, '2026-10-24 00:00:00', 15, 15, 1, 0),
(54, 'COD-00001', 1, 103, '2026-10-26 00:00:00', 10, 10, 1, 0),
(55, 'COD-00002', 2, 103, '2026-10-26 00:00:00', 20, 20, 1, 0),
(56, 'COD-00001', 1, 104, '2026-10-26 00:00:00', 5, 5, 1, 0),
(57, 'COD-00002', 2, 104, '2026-10-26 00:00:00', 10, 10, 1, 0),
(58, 'COD-00003', 3, 104, '2026-10-26 00:00:00', 15, 15, 1, 0),
(59, 'COD-00001', 1, 105, '2026-10-26 00:00:00', 5, 5, 1, 0),
(60, 'COD-00002', 2, 105, '2026-10-26 00:00:00', 10, 10, 1, 0),
(61, 'COD-00003', 3, 105, '2026-10-26 00:00:00', 15, 15, 1, 0),
(62, 'COD-00001', 1, 106, '2026-10-26 00:00:00', 5, 5, 1, 0),
(63, 'COD-00002', 2, 106, '2026-10-26 00:00:00', 10, 10, 1, 0),
(64, 'COD-00003', 3, 106, '2026-10-26 00:00:00', 15, 15, 1, 0),
(65, 'COD-00001', 1, 107, '2026-10-26 00:00:00', 5, 5, 1, 0),
(66, 'COD-00002', 2, 107, '2026-10-26 00:00:00', 10, 10, 1, 0),
(67, 'COD-00003', 3, 107, '2026-10-26 00:00:00', 15, 15, 1, 0),
(68, 'COD-00001', 1, 124, '2026-11-06 00:00:00', 5, 5, 1, 0),
(69, 'COD-00002', 2, 124, '2026-11-06 00:00:00', 10, 10, 1, 0),
(70, 'COD-00003', 3, 124, '2026-11-06 00:00:00', 15, 15, 1, 0),
(71, 'COD00001', 1, 128, '2026-11-06 00:00:00', 5, 5, 1, 0),
(72, 'COD00002', 2, 128, '2026-11-06 00:00:00', 10, 10, 1, 0),
(73, 'COD00003', 3, 128, '2026-11-06 00:00:00', 15, 15, 1, 0),
(74, 'COD00001', 1, 129, '2026-11-06 00:00:00', 5, 5, 1, 0),
(75, 'COD00002', 2, 129, '2026-11-06 00:00:00', 10, 10, 1, 0),
(76, 'COD00003', 3, 129, '2026-11-06 00:00:00', 15, 15, 1, 0),
(77, 'COD00001', 1, 130, '2026-11-06 00:00:00', 5, 5, 1, 0),
(78, 'COD00002', 2, 130, '2026-11-06 00:00:00', 10, 10, 1, 0),
(79, 'COD00003', 3, 130, '2026-11-06 00:00:00', 15, 15, 1, 0),
(80, 'COD00001', 1, 131, '2026-11-06 00:00:00', 5, 5, 1, 0),
(81, 'COD00002', 2, 131, '2026-11-06 00:00:00', 10, 10, 1, 0),
(82, 'COD00003', 3, 131, '2026-11-06 00:00:00', 15, 15, 1, 0),
(83, 'COD00001', 1, 132, '2026-11-06 00:00:00', 5, 5, 1, 0),
(84, 'COD00002', 2, 132, '2026-11-06 00:00:00', 10, 10, 1, 0),
(85, 'COD00003', 3, 132, '2026-11-06 00:00:00', 15, 15, 1, 0),
(86, 'COD00001', 1, 133, '2026-11-06 00:00:00', 5, 5, 1, 0),
(87, 'COD00002', 2, 133, '2026-11-06 00:00:00', 10, 10, 1, 0),
(88, 'COD00003', 3, 133, '2026-11-06 00:00:00', 15, 15, 1, 0),
(89, 'COD00001', 1, 134, '2026-11-06 00:00:00', 5, 5, 1, 0),
(90, 'COD00002', 2, 134, '2026-11-06 00:00:00', 10, 10, 1, 0),
(91, 'COD00003', 3, 134, '2026-11-06 00:00:00', 15, 15, 1, 0),
(92, 'COD00001', 1, 135, '2026-11-06 00:00:00', 5, 5, 1, 0),
(93, 'COD00002', 2, 135, '2026-11-06 00:00:00', 10, 10, 1, 0),
(94, 'COD00003', 3, 135, '2026-11-06 00:00:00', 15, 15, 1, 0),
(95, 'COD00001', 1, 136, '2026-11-06 00:00:00', 5, 5, 1, 0),
(96, 'COD00002', 2, 136, '2026-11-06 00:00:00', 10, 10, 1, 0),
(97, 'COD00003', 3, 136, '2026-11-06 00:00:00', 15, 15, 1, 0),
(98, 'COD00001', 1, 137, '2026-11-06 00:00:00', 5, 5, 1, 0),
(99, 'COD00002', 2, 137, '2026-11-06 00:00:00', 10, 10, 1, 0),
(100, 'COD00003', 3, 137, '2026-11-06 00:00:00', 15, 15, 1, 0),
(101, 'COD00001', 1, 138, '2026-11-06 00:00:00', 5, 5, 1, 0),
(102, 'COD00002', 2, 138, '2026-11-06 00:00:00', 10, 10, 1, 0),
(103, 'COD00003', 3, 138, '2026-11-06 00:00:00', 15, 15, 1, 0),
(104, 'COD00001', 1, 139, '2026-11-06 00:00:00', 5, 5, 1, 0),
(105, 'COD00002', 2, 139, '2026-11-06 00:00:00', 10, 10, 1, 0),
(106, 'COD00003', 3, 139, '2026-11-06 00:00:00', 15, 15, 1, 0),
(107, 'COD00001', 1, 140, '2026-11-06 00:00:00', 5, 5, 1, 0),
(108, 'COD00002', 2, 140, '2026-11-06 00:00:00', 10, 10, 1, 0),
(109, 'COD00003', 3, 140, '2026-11-06 00:00:00', 15, 15, 1, 0),
(110, 'COD00001', 1, 141, '2026-11-11 00:00:00', 5, 5, 1, 0),
(111, 'COD00002', 2, 141, '2026-11-11 00:00:00', 10, 10, 1, 0),
(112, 'COD00003', 3, 141, '2026-11-11 00:00:00', 15, 15, 1, 0),
(113, 'COD00001', 1, 142, '2026-11-11 00:00:00', 5, 5, 1, 0),
(114, 'COD00002', 2, 142, '2026-11-11 00:00:00', 10, 10, 1, 0),
(115, 'COD00003', 3, 142, '2026-11-11 00:00:00', 15, 15, 1, 0),
(116, 'COD00001', 1, 143, '2026-11-11 00:00:00', 5, 5, 1, 0),
(117, 'COD00002', 2, 143, '2026-11-11 00:00:00', 10, 10, 1, 0),
(118, 'COD00003', 3, 143, '2026-11-11 00:00:00', 15, 15, 1, 0),
(119, 'COD00001', 1, 144, '2027-03-03 00:00:00', 5, 5, 1, 0),
(120, 'COD00002', 2, 144, '2027-03-03 00:00:00', 10, 10, 1, 0),
(121, 'COD00003', 3, 144, '2027-03-03 00:00:00', 15, 15, 1, 0),
(122, 'COD00001', 1, 145, '2027-03-03 00:00:00', 5, 5, 1, 0),
(123, 'COD00002', 2, 145, '2027-03-03 00:00:00', 10, 10, 1, 0),
(124, 'COD00003', 3, 145, '2027-03-03 00:00:00', 15, 15, 1, 0),
(125, 'COD00001', 1, 146, '2027-03-03 00:00:00', 5, 5, 1, 0),
(126, 'COD00002', 2, 146, '2027-03-03 00:00:00', 10, 10, 1, 0),
(127, 'COD00003', 3, 146, '2027-03-03 00:00:00', 15, 15, 1, 0),
(128, 'COD00001', 1, 147, '2027-03-03 00:00:00', 5, 5, 1, 0),
(129, 'COD00002', 2, 147, '2027-03-03 00:00:00', 10, 10, 1, 0),
(130, 'COD00003', 3, 147, '2027-03-03 00:00:00', 15, 15, 1, 0),
(131, 'COD00001', 1, 148, '2027-03-03 00:00:00', 5, 5, 1, 0),
(132, 'COD00002', 2, 148, '2027-03-03 00:00:00', 10, 10, 1, 0),
(133, 'COD00003', 3, 148, '2027-03-03 00:00:00', 15, 15, 1, 0),
(134, 'COD00001', 1, 149, '2027-03-03 00:00:00', 5, 5, 1, 0),
(135, 'COD00002', 2, 149, '2027-03-03 00:00:00', 10, 10, 1, 0),
(136, 'COD00003', 3, 149, '2027-03-03 00:00:00', 15, 15, 1, 0),
(137, 'COD00001', 1, 150, '2027-03-03 00:00:00', 5, 5, 1, 0),
(138, 'COD00002', 2, 150, '2027-03-03 00:00:00', 10, 10, 1, 0),
(139, 'COD00003', 3, 150, '2027-03-03 00:00:00', 15, 15, 1, 0),
(140, 'COD00001', 1, 151, '2027-03-03 00:00:00', 5, 5, 1, 0),
(141, 'COD00002', 2, 151, '2027-03-03 00:00:00', 10, 10, 1, 0),
(142, 'COD00003', 3, 151, '2027-03-03 00:00:00', 15, 15, 1, 0),
(143, 'COD00001', 1, 152, '2027-03-03 00:00:00', 5, 5, 1, 0),
(144, 'COD00002', 2, 152, '2027-03-03 00:00:00', 10, 10, 1, 0),
(145, 'COD00003', 3, 152, '2027-03-03 00:00:00', 15, 15, 1, 0),
(146, 'COD00001', 1, 153, '2027-03-03 00:00:00', 5, 5, 1, 0),
(147, 'COD00002', 2, 153, '2027-03-03 00:00:00', 10, 10, 1, 0),
(148, 'COD00003', 3, 153, '2027-03-03 00:00:00', 15, 15, 1, 0),
(149, '5565', 8, 154, '2029-06-05 00:00:00', 10000, 10000, 1, 0),
(150, '5565', 9, 155, '2030-05-08 00:00:00', 10000, 10000, 1, 0);

--
-- Disparadores `detalles_entradas_materia_prima`
--
DELIMITER $$
CREATE TRIGGER `detalles_entradas_materia_prima_AFTER_INSERT` AFTER INSERT ON `detalles_entradas_materia_prima` FOR EACH ROW BEGIN
 -- Actualizar la existencia sumando la cantidad de la nueva entrada
    UPDATE materia_prima 
    SET existencia = CAST(existencia AS DECIMAL(10,2)) + NEW.cantidad
    WHERE id = NEW.id_materia_prima;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_entradas_materia_prima_AFTER_UPDATE` AFTER UPDATE ON `detalles_entradas_materia_prima` FOR EACH ROW BEGIN
 DECLARE done INT DEFAULT FALSE;
    DECLARE metodo_nombre VARCHAR(25);
    DECLARE tasa_movimiento FLOAT;
    DECLARE precio_compra_entrada FLOAT;
    
    -- Cursor para múltiples pagos
    DECLARE pago_cursor CURSOR FOR 
        SELECT mp.nombre, pemp.tasa, pemp.precio_compra
        FROM pagos_entrada_materia_prima pemp
        INNER JOIN metodo_pago mp ON mp.id = pemp.id_metodo_pago
        WHERE pemp.id_entrada = NEW.id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Si se desactiva la entrada (active cambia de 1 a 0)
    IF OLD.active = 1 AND NEW.active = 0 THEN
        -- Restar la cantidad de la existencia total en materia_prima
        UPDATE materia_prima 
        SET existencia = existencia - OLD.cantidad 
        WHERE id = NEW.id_materia_prima;
        
        -- Procesar todos los pagos asociados
        OPEN pago_cursor;
        read_loop: LOOP
            FETCH pago_cursor INTO metodo_nombre, tasa_movimiento, precio_compra_entrada;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            -- Determinar la tasa según el método de pago
            IF metodo_nombre IN ('Pago Movil', 'Transferencia', 'Efectivo') THEN
                SET tasa_movimiento = tasa_movimiento; -- usar la tasa real
            ELSE
                SET tasa_movimiento = 1; -- otros métodos
            END IF;
            
            -- Insertar movimiento positivo para compensar el egreso anterior
            INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
            VALUES (
                precio_compra_entrada, 
                CONCAT('Ingreso por eliminacion de entrada de materia prima nro ', NEW.id),
                NOW(),
                tasa_movimiento
            );
        END LOOP;
        CLOSE pago_cursor;
        
        -- Reset del flag para el siguiente bloque
        SET done = FALSE;
    END IF;
    
    -- Si se reactiva la entrada (active cambia de 0 a 1)
    IF OLD.active = 0 AND NEW.active = 1 THEN
        -- Sumar la cantidad a la existencia total en materia_prima
        UPDATE materia_prima 
        SET existencia = existencia + NEW.cantidad 
        WHERE id = NEW.id_materia_prima;
        
        -- Procesar todos los pagos asociados para revertir compensación
        OPEN pago_cursor;
        read_loop2: LOOP
            FETCH pago_cursor INTO metodo_nombre, tasa_movimiento, precio_compra_entrada;
            IF done THEN
                LEAVE read_loop2;
            END IF;
            
            -- Determinar la tasa según el método de pago
            IF metodo_nombre IN ('Pago Movil', 'Transferencia', 'Efectivo') THEN
                SET tasa_movimiento = tasa_movimiento; -- usar la tasa real
            ELSE
                SET tasa_movimiento = 1; -- otros métodos
            END IF;
            
            -- Insertar movimiento negativo para revertir la compensación
            INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
            VALUES (
                -precio_compra_entrada, 
                CONCAT('Egreso por reactivacion de entrada de materia prima nro ', NEW.id),
                NOW(),
                tasa_movimiento
            );
        END LOOP;
        CLOSE pago_cursor;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `detalles_entradas_materia_prima_BEFORE_UPDATE` BEFORE UPDATE ON `detalles_entradas_materia_prima` FOR EACH ROW BEGIN
-- Declarar la variable al principio del bloque, como exige MySQL
    DECLARE diferencia FLOAT DEFAULT 0;

    -- Lógica Condicional:
    -- Caso 1: Si se modifica la CANTIDAD de la compra
    IF NEW.cantidad <> OLD.cantidad THEN
        SET diferencia = NEW.cantidad - OLD.cantidad;
        
        -- Forzar el cálculo de la existencia del lote
        SET NEW.existencia = OLD.existencia + diferencia;
        
    -- Caso 2: Si solo se modifica la EXISTENCIA (y no la cantidad)
    ELSEIF NEW.existencia <> OLD.existencia THEN
        SET diferencia = NEW.existencia - OLD.existencia;
        -- Aquí se respeta el valor de NEW.existencia que puso el usuario.
    END IF;

    -- Si hubo algún cambio (diferencia no es 0), se actualiza el inventario maestro
    IF diferencia <> 0 THEN
        UPDATE materia_prima
        SET existencia = existencia + diferencia
        WHERE id = NEW.id_materia_prima;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_receta`
--

CREATE TABLE `detalles_receta` (
  `id` int NOT NULL,
  `id_receta` int NOT NULL,
  `id_materia_prima` int NOT NULL,
  `cantidad` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `detalles_receta`
--

INSERT INTO `detalles_receta` (`id`, `id_receta`, `id_materia_prima`, `cantidad`) VALUES
(60, 13, 8, 0.68),
(68, 16, 1, 0.15),
(69, 17, 9, 1),
(70, 17, 8, 0.15),
(71, 17, 6, 0.35),
(72, 18, 6, 0.6),
(73, 19, 5, 0.15),
(74, 13, 9, 1),
(75, 55, 1, 10),
(76, 55, 2, 20),
(77, 55, 3, 30),
(78, 57, 1, 10),
(79, 57, 2, 20),
(80, 57, 3, 30),
(81, 59, 1, 10),
(82, 59, 2, 20),
(83, 59, 3, 30),
(84, 61, 1, 10),
(85, 61, 2, 20),
(86, 61, 3, 30),
(87, 62, 1, 10),
(88, 62, 2, 20),
(89, 62, 3, 30),
(90, 63, 1, 10),
(91, 63, 2, 20),
(92, 63, 3, 30),
(93, 65, 1, 10),
(94, 65, 2, 20),
(95, 65, 3, 30),
(96, 67, 1, 10),
(97, 67, 2, 20),
(98, 67, 3, 30),
(99, 69, 1, 10),
(100, 69, 2, 20),
(101, 69, 3, 30),
(102, 71, 1, 10),
(103, 71, 2, 20),
(104, 71, 3, 30),
(105, 73, 1, 10),
(106, 73, 2, 20),
(107, 73, 3, 30),
(108, 74, 1, 10),
(109, 74, 2, 20),
(110, 74, 3, 30),
(111, 76, 1, 10),
(112, 76, 2, 20),
(113, 76, 3, 30),
(114, 78, 1, 10),
(115, 78, 2, 20),
(116, 78, 3, 30),
(117, 80, 1, 10),
(118, 80, 2, 20),
(119, 80, 3, 30),
(120, 82, 1, 10),
(121, 82, 2, 20),
(122, 82, 3, 30),
(123, 84, 1, 10),
(124, 84, 2, 20),
(125, 84, 3, 30),
(126, 86, 1, 10),
(127, 86, 2, 20),
(128, 86, 3, 30),
(129, 88, 1, 10),
(130, 88, 2, 20),
(131, 88, 3, 30),
(132, 90, 1, 10),
(133, 90, 2, 20),
(134, 90, 3, 30),
(135, 92, 1, 10),
(136, 92, 2, 20),
(137, 92, 3, 30),
(138, 94, 1, 10),
(139, 94, 2, 20),
(140, 94, 3, 30),
(141, 96, 1, 10),
(142, 96, 2, 20),
(143, 96, 3, 30),
(144, 98, 1, 10),
(145, 98, 2, 20),
(146, 98, 3, 30),
(147, 100, 1, 10),
(148, 100, 2, 20),
(149, 100, 3, 30),
(150, 102, 1, 10),
(151, 102, 2, 20),
(152, 102, 3, 30),
(153, 104, 1, 10),
(154, 104, 2, 20),
(155, 104, 3, 30),
(156, 106, 1, 10),
(157, 106, 2, 20),
(158, 106, 3, 30),
(159, 108, 1, 10),
(160, 108, 2, 20),
(161, 108, 3, 30),
(162, 110, 1, 10),
(163, 110, 2, 20),
(164, 110, 3, 30),
(165, 112, 1, 10),
(166, 112, 2, 20),
(167, 112, 3, 30),
(168, 114, 1, 10),
(169, 114, 2, 20),
(170, 114, 3, 30),
(171, 116, 1, 10),
(172, 116, 2, 20),
(173, 116, 3, 30),
(174, 118, 1, 10),
(175, 118, 2, 20),
(176, 118, 3, 30),
(177, 120, 1, 10),
(178, 120, 2, 20),
(179, 120, 3, 30),
(180, 122, 1, 10),
(181, 122, 2, 20),
(182, 122, 3, 30),
(183, 123, 1, 10),
(184, 123, 2, 20),
(185, 123, 3, 30),
(186, 124, 1, 10),
(187, 124, 2, 20),
(188, 124, 3, 30),
(189, 126, 1, 10),
(190, 126, 2, 20),
(191, 126, 3, 30),
(192, 128, 1, 10),
(193, 128, 2, 20),
(194, 128, 3, 30),
(195, 130, 1, 10),
(196, 130, 2, 20),
(197, 130, 3, 30),
(198, 132, 1, 10),
(199, 132, 2, 20),
(200, 132, 3, 30),
(201, 134, 1, 10),
(202, 134, 2, 20),
(203, 134, 3, 30),
(204, 136, 1, 10),
(205, 136, 2, 20),
(206, 136, 3, 30),
(207, 138, 1, 10),
(208, 138, 2, 20),
(209, 138, 3, 30),
(210, 140, 1, 10),
(211, 140, 2, 20),
(212, 140, 3, 30),
(213, 142, 1, 10),
(214, 142, 2, 20),
(215, 142, 3, 30),
(216, 144, 1, 10),
(217, 144, 2, 20),
(218, 144, 3, 30),
(219, 146, 1, 10),
(220, 146, 2, 20),
(221, 146, 3, 30),
(222, 149, 1, 10),
(223, 149, 2, 20),
(224, 149, 3, 30),
(225, 151, 1, 10),
(226, 151, 2, 20),
(227, 151, 3, 30),
(228, 153, 1, 10),
(229, 153, 2, 20),
(230, 153, 3, 30),
(231, 155, 1, 10),
(232, 155, 2, 20),
(233, 155, 3, 30),
(234, 157, 1, 10),
(235, 157, 2, 20),
(236, 157, 3, 30),
(237, 159, 1, 10),
(238, 159, 2, 20),
(239, 159, 3, 30),
(240, 161, 1, 10),
(241, 161, 2, 20),
(242, 161, 3, 30),
(243, 163, 1, 10),
(244, 163, 2, 20),
(245, 163, 3, 30),
(246, 165, 1, 10),
(247, 165, 2, 20),
(248, 165, 3, 30),
(249, 167, 1, 10),
(250, 167, 2, 20),
(251, 167, 3, 30),
(252, 169, 1, 10),
(253, 169, 2, 20),
(254, 169, 3, 30),
(255, 171, 1, 10),
(256, 171, 2, 20),
(257, 171, 3, 30),
(258, 173, 1, 10),
(259, 173, 2, 20),
(260, 173, 3, 30);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas_materia_prima`
--

CREATE TABLE `entradas_materia_prima` (
  `id` int NOT NULL,
  `id_proveedor` int NOT NULL,
  `fecha_compra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `entradas_materia_prima`
--

INSERT INTO `entradas_materia_prima` (`id`, `id_proveedor`, `fecha_compra`) VALUES
(85, 2, '2025-09-25 20:16:15'),
(86, 2, '2025-10-14 10:55:45'),
(87, 1, '2025-10-24 19:45:39'),
(88, 1, '2025-10-24 19:46:20'),
(89, 1, '2025-10-24 19:47:34'),
(90, 1, '2025-10-24 19:48:36'),
(91, 1, '2025-10-24 19:49:20'),
(92, 1, '2025-10-24 19:49:44'),
(93, 1, '2025-10-24 19:49:56'),
(94, 1, '2025-10-24 19:50:27'),
(95, 1, '2025-10-24 19:50:52'),
(101, 1, '2025-10-24 19:57:57'),
(102, 1, '2025-10-24 19:58:08'),
(103, 1, '2025-10-26 18:01:15'),
(104, 1, '2025-10-26 18:01:16'),
(105, 1, '2025-10-26 18:02:16'),
(106, 1, '2025-10-26 18:07:04'),
(107, 1, '2025-10-26 18:09:30'),
(108, 1, '2025-11-06 00:00:00'),
(109, 1, '2025-11-06 00:00:00'),
(110, 1, '2025-11-06 00:00:00'),
(111, 1, '2025-11-06 00:00:00'),
(112, 1, '2025-11-06 00:00:00'),
(113, 1, '2025-11-06 00:00:00'),
(114, 1, '2025-11-06 00:00:00'),
(115, 1, '2025-11-06 00:00:00'),
(116, 1, '2025-11-06 00:00:00'),
(117, 1, '2025-11-06 00:00:00'),
(118, 1, '2025-11-06 00:00:00'),
(119, 1, '2025-11-06 00:00:00'),
(120, 1, '2025-11-06 00:00:00'),
(121, 1, '2025-11-06 00:00:00'),
(122, 1, '2025-11-06 00:00:00'),
(123, 1, '2025-11-06 00:00:00'),
(124, 1, '2025-11-06 00:00:00'),
(125, 1, '2025-11-06 00:00:00'),
(126, 1, '2025-11-06 00:00:00'),
(127, 1, '2025-11-06 00:00:00'),
(128, 1, '2025-11-06 00:00:00'),
(129, 1, '2025-11-06 00:00:00'),
(130, 1, '2025-11-06 00:00:00'),
(131, 1, '2025-11-06 00:00:00'),
(132, 1, '2025-11-06 00:00:00'),
(133, 1, '2025-11-06 00:00:00'),
(134, 1, '2025-11-06 00:00:00'),
(135, 1, '2025-11-06 00:00:00'),
(136, 1, '2025-11-06 00:00:00'),
(137, 1, '2025-11-06 00:00:00'),
(138, 1, '2025-11-06 00:00:00'),
(139, 1, '2025-11-06 00:00:00'),
(140, 1, '2025-11-06 00:00:00'),
(141, 1, '2025-11-11 00:00:00'),
(142, 1, '2025-11-11 00:00:00'),
(143, 1, '2025-11-11 00:00:00'),
(144, 1, '2026-03-03 00:00:00'),
(145, 1, '2026-03-03 00:00:00'),
(146, 1, '2026-03-03 00:00:00'),
(147, 1, '2026-03-03 00:00:00'),
(148, 1, '2026-03-03 00:00:00'),
(149, 1, '2026-03-03 00:00:00'),
(150, 1, '2026-03-03 00:00:00'),
(151, 1, '2026-03-03 00:00:00'),
(152, 1, '2026-03-03 00:00:00'),
(153, 1, '2026-03-03 00:00:00'),
(154, 2, '2026-03-05 17:27:45'),
(155, 2, '2026-03-05 17:51:14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas_producto_procesado`
--

CREATE TABLE `entradas_producto_procesado` (
  `id` int NOT NULL,
  `codigo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_producto` int NOT NULL,
  `id_proveedor` int NOT NULL,
  `id_unidad` int NOT NULL,
  `fecha_compra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_vencimiento` datetime DEFAULT NULL,
  `existencia` float NOT NULL,
  `cantidad` float NOT NULL,
  `active` int NOT NULL DEFAULT '1',
  `broken` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entradas_producto_procesado`
--

INSERT INTO `entradas_producto_procesado` (`id`, `codigo`, `id_producto`, `id_proveedor`, `id_unidad`, `fecha_compra`, `fecha_vencimiento`, `existencia`, `cantidad`, `active`, `broken`) VALUES
(26, '202020', 42, 1, 1, '2025-09-03 14:02:05', '2025-12-24 00:00:00', 40, 40, 1, 0),
(27, '202020', 41, 2, 1, '2025-09-04 10:37:22', '2025-12-24 00:00:00', 38, 40, 1, 0),
(82, 'COD-PROC-1761498136', 41, 1, 1, '2025-10-26 18:02:16', '2026-04-26 00:00:00', 50, 50, 1, 0),
(83, 'COD-PROC-1761498413', 41, 1, 1, '2025-10-26 18:06:53', '2026-04-26 00:00:00', 50, 50, 1, 0),
(85, 'COD-PROC-1761498425', 41, 1, 1, '2025-10-26 18:07:05', '2026-04-26 00:00:00', 50, 50, 1, 0),
(87, 'COD-PROC-1761498570', 41, 1, 1, '2025-10-26 18:09:30', '2026-04-26 00:00:00', 50, 50, 1, 0),
(106, 'COD-PROC-1762399166', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(109, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(110, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(112, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(114, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(116, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(118, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(120, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(122, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(124, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(126, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(128, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(130, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(132, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(134, 'asdkaskdaksj', 41, 1, 1, '2025-11-06 00:00:00', '2026-05-06 00:00:00', 50, 50, 1, 0),
(136, 'asdkaskdaksj', 41, 1, 1, '2025-11-11 00:00:00', '2026-05-11 00:00:00', 50, 50, 1, 0),
(138, 'asdkaskdaksj', 41, 1, 1, '2025-11-11 00:00:00', '2026-05-11 00:00:00', 50, 50, 1, 0),
(140, 'asdkaskdaksj', 41, 1, 1, '2025-11-11 00:00:00', '2026-05-11 00:00:00', 50, 50, 1, 0),
(142, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(144, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(146, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(148, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(150, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(152, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(154, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(156, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(158, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0),
(160, 'asdkaskdaksj', 41, 1, 1, '2026-03-03 00:00:00', '2026-09-03 00:00:00', 50, 50, 1, 0);

--
-- Disparadores `entradas_producto_procesado`
--
DELIMITER $$
CREATE TRIGGER `entradas_producto_procesado_AFTER_INSERT` AFTER INSERT ON `entradas_producto_procesado` FOR EACH ROW BEGIN
 -- Actualizar la existencia sumando la cantidad de la nueva entrada
    UPDATE productos_procesados
    SET existencia = CAST(existencia AS DECIMAL(10,2)) + NEW.cantidad
    WHERE id = NEW.id_producto;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entradas_producto_procesado_AFTER_UPDATE` AFTER UPDATE ON `entradas_producto_procesado` FOR EACH ROW BEGIN
 DECLARE done INT DEFAULT FALSE;
    DECLARE metodo_nombre VARCHAR(25);
    DECLARE tasa_movimiento FLOAT;
    DECLARE precio_compra_entrada FLOAT;
    
    -- Cursor para múltiples pagos
    DECLARE pago_cursor CURSOR FOR 
        SELECT mp.nombre, pemp.tasa, pemp.precio_compra
        FROM pagos_entrada_materia_prima pemp
        INNER JOIN metodo_pago mp ON mp.id = pemp.id_metodo_pago
        WHERE pemp.id_entrada = NEW.id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Si se desactiva la entrada (active cambia de 1 a 0)
    IF OLD.active = 1 AND NEW.active = 0 THEN
        -- Restar la cantidad de la existencia total en materia_prima
        UPDATE productos_procesados 
        SET existencia = existencia - OLD.cantidad 
        WHERE id = NEW.id_producto;
        
        -- Procesar todos los pagos asociados
        OPEN pago_cursor;
        read_loop: LOOP
            FETCH pago_cursor INTO metodo_nombre, tasa_movimiento, precio_compra_entrada;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            -- Determinar la tasa según el método de pago
            IF metodo_nombre IN ('Pago Movil', 'Transferencia', 'Efectivo') THEN
                SET tasa_movimiento = tasa_movimiento; -- usar la tasa real
            ELSE
                SET tasa_movimiento = 1; -- otros métodos
            END IF;
            
            -- Insertar movimiento positivo para compensar el egreso anterior
            INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
            VALUES (
                precio_compra_entrada, 
                CONCAT('Ingreso por eliminacion de entrada de materia prima nro ', NEW.id),
                NOW(),
                tasa_movimiento
            );
        END LOOP;
        CLOSE pago_cursor;
        
        -- Reset del flag para el siguiente bloque
        SET done = FALSE;
    END IF;
    
    -- Si se reactiva la entrada (active cambia de 0 a 1)
    IF OLD.active = 0 AND NEW.active = 1 THEN
        -- Sumar la cantidad a la existencia total en materia_prima
        UPDATE productos_procesados 
        SET existencia = existencia + NEW.cantidad 
        WHERE id = NEW.id_producto;
        
        -- Procesar todos los pagos asociados para revertir compensación
        OPEN pago_cursor;
        read_loop2: LOOP
            FETCH pago_cursor INTO metodo_nombre, tasa_movimiento, precio_compra_entrada;
            IF done THEN
                LEAVE read_loop2;
            END IF;
            
            -- Determinar la tasa según el método de pago
            IF metodo_nombre IN ('Pago Movil', 'Transferencia', 'Efectivo') THEN
                SET tasa_movimiento = tasa_movimiento; -- usar la tasa real
            ELSE
                SET tasa_movimiento = 1; -- otros métodos
            END IF;
            
            -- Insertar movimiento negativo para revertir la compensación
            INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
            VALUES (
                -precio_compra_entrada, 
                CONCAT('Egreso por reactivacion de entrada de materia prima nro ', NEW.id),
                NOW(),
                tasa_movimiento
            );
        END LOOP;
        CLOSE pago_cursor;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `entradas_producto_procesado_BEFORE_UPDATE` BEFORE UPDATE ON `entradas_producto_procesado` FOR EACH ROW BEGIN
    -- Declarar la variable al principio del bloque, como exige MySQL
    DECLARE diferencia FLOAT DEFAULT 0;

    -- Lógica Condicional:
    -- Caso 1: Si se modifica la CANTIDAD de la compra
    IF NEW.cantidad <> OLD.cantidad THEN
        SET diferencia = NEW.cantidad - OLD.cantidad;
        
        -- Forzar el cálculo de la existencia del lote
        SET NEW.existencia = OLD.existencia + diferencia;
        
    -- Caso 2: Si solo se modifica la EXISTENCIA (y no la cantidad)
    ELSEIF NEW.existencia <> OLD.existencia THEN
        SET diferencia = NEW.existencia - OLD.existencia;
        -- Aquí se respeta el valor de NEW.existencia que puso el usuario.
    END IF;

    -- Si hubo algún cambio (diferencia no es 0), se actualiza el inventario maestro
    IF diferencia <> 0 THEN
        UPDATE productos_procesados
        SET existencia = existencia + diferencia
        WHERE id = NEW.id_producto;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materia_prima`
--

CREATE TABLE `materia_prima` (
  `id` int NOT NULL,
  `id_categoria` int NOT NULL,
  `id_unidad` int NOT NULL,
  `nombre` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `stock_min` int NOT NULL,
  `stock_max` int NOT NULL,
  `existencia` float NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `materia_prima`
--

INSERT INTO `materia_prima` (`id`, `id_categoria`, `id_unidad`, `nombre`, `stock_min`, `stock_max`, `existencia`, `active`) VALUES
(1, 1, 3, 'Pollo', 10, 20, 205, 1),
(2, 1, 3, 'Carne de res', 10, 50, 410, 1),
(3, 3, 3, 'Cebolla', 10, 20, 585, 1),
(4, 3, 3, 'Maíz', 10, 20, 0, 1),
(5, 7, 4, 'Queso cheddar', 10, 20, 0, 1),
(6, 4, 3, 'Salsa especial', 10, 20, 0, 1),
(7, 1, 3, 'Tocineta', 10, 20, 0, 1),
(8, 3, 3, 'Papas', 10, 20, 13000, 1),
(9, 2, 4, 'Pan de la casa', 10, 20, 40000, 1),
(10, 3, 3, 'Prueba', 1, 5, 0.5, 1),
(11, 7, 5, 'CONSOLA', 2, 10, 0, 0),
(12, 6, 4, 'CONN', 2, 3, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mesas`
--

CREATE TABLE `mesas` (
  `id` int NOT NULL,
  `nombre` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sillas` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `estado` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'LIBRE',
  `vip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `active` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `mesas`
--

INSERT INTO `mesas` (`id`, `nombre`, `sillas`, `estado`, `vip`, `imagen`, `active`) VALUES
(1, 'Mesa 2', '5', 'LIBRE', '0', '5ce0e0f8-46df-4654-b37b-7d7f40d9bc6a.jpeg', '1'),
(2, 'Mesa 45', '10', 'OCUPADA', '1', '7b37d828-2d86-40c5-b54a-9424c5dcc288.jpeg', '1'),
(3, 'Mesa 9', '4', 'LIBRE', '0', '5f395e0a-584d-4540-bc2b-3dba66a98c31.jpeg', '1'),
(4, 'Mesa 10', '7', 'LIBRE', '1', 'championship-leblanc-league-of-legends_3840x2161_xtrafondos.com.jpg', '1'),
(5, 'Mesa inf', '58', 'LIBRE', '0', '2551fe44-3bc1-476e-b084-e7ff84eb8600.jpeg', '0'),
(6, 'Mesa 99', '10', 'LIBRE', '1', '7112d1a7-cfb2-4f35-8848-0394ac5c335d.jpeg', '0'),
(7, 'Mesa 5', '8', 'LIBRE', '1', '5ce0e0f8-46df-4654-b37b-7d7f40d9bc6a.jpeg', '1'),
(8, 'Mesa 6', '5', 'LIBRE', '0', '2c51307c-9d9f-41fb-9419-1e61a44891f0.jpeg', '1'),
(9, 'Mesa 2000', '10', 'LIBRE', '0', '19085819.jpg', '0'),
(10, 'Mesa 85', '15', 'LIBRE', '1', '9503026.png', '1'),
(11, 'Otra mesa', '10', 'LIBRE', '0', 'camisa_neww.png', '0'),
(12, 'Mesa prueba', '12', 'LIBRE', '0', '53571.jpg', '0'),
(13, 'Mesa prueba', '12', 'LIBRE', '0', '53571.jpg', '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodo_pago`
--

CREATE TABLE `metodo_pago` (
  `id` int NOT NULL,
  `nombre` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `metodo_pago`
--

INSERT INTO `metodo_pago` (`id`, `nombre`, `active`, `imagen`, `descripcion`) VALUES
(1, 'Zelle', 0, NULL, NULL),
(2, 'Binance', 0, NULL, NULL),
(3, 'Pago Movil', 1, NULL, NULL),
(4, 'Efectivo', 1, NULL, NULL),
(9, 'Prueba infinity', 0, NULL, NULL),
(10, 'Prueba 2', 0, NULL, NULL),
(11, 'Transferencia', 1, NULL, NULL),
(12, 'Divisa', 1, NULL, NULL),
(13, 'Zinli', 0, NULL, NULL),
(14, 'Cashea', 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos_capital`
--

CREATE TABLE `movimientos_capital` (
  `id` int NOT NULL,
  `monto` float NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tasa` float NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `movimientos_capital`
--

INSERT INTO `movimientos_capital` (`id`, `monto`, `descripcion`, `fecha`, `tasa`) VALUES
(1, 50.58, 'Ingreso por venta', '2025-06-12 15:38:52', 1),
(2, -2117.4, 'Egreso por nuevas entradas', '2025-06-12 15:44:58', 1),
(4, -2117.4, 'Ingreso por entrada de materia prima nro 8', '2025-06-12 16:00:05', 1),
(6, 609, 'Ingreso por eliminacion de entrada de producto procesado nro 20', '2025-06-12 16:29:51', 1),
(7, -609, 'Egreso por entrada de producto procesado nro 20', '2025-06-12 16:29:51', 1),
(8, -1015, 'Egreso por nueva entradas', '2025-06-12 16:03:46', 1),
(9, 10000, 'Ingreso por aporte de alidado', '2025-06-12 16:14:45', 1),
(12, 10, 'aporte de aliado', '2025-06-13 15:06:38', 1),
(13, -10, 'me gaste en un toston', '2025-06-13 15:07:46', 1),
(14, 4796.41, 'Ingreso por venta', '2025-06-16 14:51:05', 1),
(15, 66.36, 'Ingreso por venta', '2025-06-16 15:56:19', 1),
(16, 24.7, 'Ingreso por venta', '2025-06-18 09:42:46', 1),
(17, 760.34, 'Ingreso por venta', '2025-06-18 09:46:31', 1),
(18, 2385.19, 'Ingreso por venta', '2025-06-18 09:59:39', 1),
(19, 940.26, 'Ingreso por venta', '2025-06-18 10:02:22', 1),
(20, 4770.38, 'Ingreso por venta', '2025-06-18 10:03:42', 1),
(21, 888.85, 'Ingreso por venta', '2025-06-18 10:05:11', 1),
(22, 1584.34, 'Ingreso por venta', '2025-06-18 10:08:35', 1),
(23, 734.64, 'Ingreso por venta', '2025-06-18 10:10:25', 1),
(24, 2385.19, 'Ingreso por venta', '2025-06-18 10:11:50', 1),
(25, 2385.19, 'Ingreso por venta', '2025-06-18 10:12:55', 1),
(26, 1144.85, 'Ingreso por venta', '2025-06-18 14:10:10', 1),
(27, 2463.82, 'Ingreso por venta', '2025-06-19 10:53:54', 1),
(28, 2463.82, 'Ingreso por venta', '2025-06-19 10:53:54', 1),
(29, 741.28, 'Ingreso por venta', '2025-06-19 17:18:44', 1),
(30, 2463.82, 'Ingreso por venta', '2025-06-19 17:19:52', 1),
(31, 2463.82, 'Ingreso por venta', '2025-06-19 17:19:52', 1),
(32, 799.38, 'Ingreso por venta', '2025-06-19 17:21:58', 1),
(33, 274.87, 'Ingreso por venta', '2025-06-19 17:23:21', 1),
(34, 2432.7, 'Ingreso por venta', '2025-06-19 17:24:07', 1),
(35, 482.35, 'Ingreso por venta', '2025-06-19 17:27:33', 1),
(36, 2463.82, 'Ingreso por venta', '2025-06-19 17:28:35', 1),
(37, 896.89, 'Ingreso por venta', '2025-06-19 17:30:49', 1),
(38, 67.39, 'Ingreso por venta', '2025-06-19 17:31:38', 1),
(39, -2000, 'no se mucho', '2025-06-20 10:16:04', 1),
(40, 348.69, 'Ingreso por venta', '2025-07-02 10:58:52', 1),
(41, 755.23, 'Ingreso por venta', '2025-07-02 11:07:10', 1),
(42, 695.29, 'Ingreso por venta', '2025-07-02 11:10:10', 1),
(43, 695.29, 'Ingreso por venta', '2025-07-02 11:14:02', 1),
(44, 695.29, 'Ingreso por venta', '2025-07-02 13:01:28', 1),
(45, 778.73, 'Ingreso por venta', '2025-07-02 13:19:14', 1),
(46, 72.38, 'Ingreso por venta', '2025-07-05 15:27:16', 1),
(47, 796.16, 'Ingreso por venta', '2025-07-07 14:08:50', 1),
(48, 8.88, 'Ingreso por venta', '2025-07-07 14:11:23', 1),
(49, 719.86, 'Ingreso por venta', '2025-07-09 13:49:23', 1),
(50, 758.71, 'Ingreso por venta', '2025-07-09 19:21:51', 1),
(51, 535.76, 'Ingreso por venta', '2025-07-09 19:28:52', 1),
(52, 197.93, 'Ingreso por venta', '2025-07-09 20:49:13', 1),
(53, 147.88, 'Ingreso por venta', '2025-07-10 14:46:48', 1),
(54, 2340.28, 'Ingreso por venta', '2025-07-16 14:29:07', 1),
(55, 2340.28, 'Ingreso por venta', '2025-07-16 14:31:33', 1),
(56, 2340.28, 'Ingreso por venta', '2025-07-16 14:36:18', 1),
(57, 2340.28, 'Ingreso por venta', '2025-07-16 14:38:59', 1),
(58, 2340.28, 'Ingreso por venta', '2025-07-16 14:45:17', 1),
(59, 2340.28, 'Ingreso por venta', '2025-07-16 14:47:29', 1),
(60, 2340.28, 'Ingreso por venta', '2025-07-16 15:20:47', 1),
(61, 2340.28, 'Ingreso por venta', '2025-07-16 15:23:56', 1),
(62, 424.72, 'Ingreso por venta', '2025-07-25 13:17:13', 1),
(63, 424.72, 'Ingreso por venta', '2025-07-25 13:23:27', 1),
(64, 673.49, 'Ingreso por venta', '2025-07-25 14:07:52', 1),
(65, 424.72, 'Ingreso por venta', '2025-07-25 14:09:34', 1),
(66, 673.49, 'Ingreso por venta', '2025-07-25 14:12:14', 1),
(67, 673.49, 'Ingreso por venta', '2025-07-25 14:21:42', 1),
(68, 916.92, 'Ingreso por venta', '2025-08-06 12:51:57', 1),
(69, 818.17, 'Ingreso por venta', '2025-08-06 12:57:59', 1),
(70, 1636.34, 'Ingreso por venta', '2025-08-06 13:10:04', 1),
(71, 83.36, 'Ingreso por venta', '2025-08-06 13:24:44', 1),
(72, 166.71, 'Ingreso por venta', '2025-08-06 13:26:44', 1),
(73, 1295.22, 'Ingreso por venta', '2025-08-06 13:28:11', 1),
(74, 916.92, 'Ingreso por venta', '2025-08-06 13:35:00', 1),
(75, 734.79, 'Ingreso por venta', '2025-08-06 13:48:31', 1),
(76, 855.36, 'Ingreso por venta', '2025-08-06 14:04:46', 1),
(77, 743.79, 'Ingreso por venta', '2025-08-06 14:06:41', 1),
(78, 223.14, 'Ingreso por venta', '2025-08-06 14:19:23', 1),
(79, 954.11, 'Ingreso por venta', '2025-08-06 14:21:35', 1),
(80, 83.36, 'Ingreso por venta', '2025-08-06 14:35:31', 1),
(81, 165.43, 'Ingreso por venta', '2025-08-06 14:37:43', 1),
(82, 1140.05, 'Ingreso por venta', '2025-08-06 14:38:35', 1),
(83, 7.79788, 'Ingreso por Transferencia', '2025-08-06 15:51:08', 1),
(84, 9.4656, 'Ingreso por Pago Movil', '2025-08-09 12:16:53', 1),
(85, 7.14559, 'Ingreso por Pago Movil', '2025-08-09 12:27:27', 1),
(86, 6.38003, 'Ingreso por Pago Movil', '2025-08-09 13:16:22', 1),
(87, 1.2876, 'Ingreso por Pago Movil', '2025-08-09 13:20:45', 1),
(88, 5, 'Ingreso por Pago Movil', '2025-08-09 13:24:45', 1),
(89, 7.55858, 'Ingreso por Pago Movil', '2025-08-12 13:03:42', 1),
(90, 7.4452, 'Ingreso por Transferencia', '2025-08-12 13:03:43', 1),
(91, 10.4105, 'Ingreso por Pago Movil', '2025-08-14 13:52:14', 1),
(92, 10.4105, 'Ingreso por Pago Movil', '2025-08-14 13:55:25', 1),
(93, 0.594884, 'Ingreso por Pago Movil', '2025-08-14 14:11:31', 1),
(94, 0.148721, 'Ingreso por Pago Movil', '2025-08-14 14:20:36', 1),
(95, 0.743605, 'Ingreso por Pago Movil', '2025-08-14 14:25:12', 1),
(96, 0.148721, 'Ingreso por Pago Movil', '2025-08-14 14:28:29', 1),
(97, 0.148721, 'Ingreso por Pago Movil', '2025-08-14 14:32:27', 1),
(98, 0.148721, 'Ingreso por Pago Movil', '2025-08-14 14:34:04', 1),
(99, 5.79165, 'Ingreso por Pago Movil', '2025-08-20 12:36:23', 1),
(100, 7.23956, 'Ingreso por Pago Movil', '2025-08-20 12:50:58', 1),
(101, 7.23956, 'Ingreso por Pago Movil', '2025-08-20 12:58:14', 1),
(102, 7.23956, 'Ingreso por Pago Movil', '2025-08-20 13:03:17', 1),
(103, 5.79165, 'Ingreso por Pago Movil', '2025-08-20 13:04:12', 1),
(104, -1250, 'Egreso por nueva entradas', '2025-08-25 11:20:23', 1),
(105, -2500, 'Egreso por nueva entradas', '2025-08-25 11:21:23', 1),
(106, -600, 'Egreso por nueva entradas', '2025-08-25 11:22:04', 1),
(107, -1800, 'Egreso por nueva entradas', '2025-08-25 11:23:52', 1),
(108, -750, 'Egreso por nueva entradas', '2025-08-26 10:57:08', 1),
(109, -36750, 'Egreso por nueva entradas', '2025-08-26 13:49:47', 1),
(113, -2000, 'Egreso por entrada de materia prima nro 39', '2025-09-01 14:11:54', 148.44),
(114, -1500, 'Egreso por entrada de materia prima nro 39', '2025-09-01 14:11:54', 148.44),
(115, -1500, 'Egreso por entrada de materia prima nro 40', '2025-09-01 14:46:24', 148.44),
(116, -3500, 'Egreso por entrada de materia prima nro 27', '2025-09-04 10:37:23', 151.76),
(117, -42.34, 'Egreso por entrada de materia prima nro 71', '2025-09-25 14:08:19', 171.85),
(118, -49848.9, 'Egreso por entrada de materia prima nro 72', '2025-09-25 14:08:19', 171.85),
(119, -42.34, 'Egreso por entrada de materia prima nro 73', '2025-09-25 14:09:24', 171.85),
(120, -49848.9, 'Egreso por entrada de materia prima nro 74', '2025-09-25 14:09:24', 171.85),
(121, -350, 'Egreso por entrada de materia prima nro 75', '2025-09-25 14:16:40', 171.85),
(122, -489.48, 'Egreso por entrada de materia prima nro 76', '2025-09-25 14:19:37', 171.85),
(123, -150, 'Egreso por entrada de materia prima nro 78', '2025-09-25 15:06:06', 171.85),
(124, -150, 'Egreso por entrada de materia prima nro 79', '2025-09-25 15:06:34', 171.85),
(125, -48.48, 'Egreso por entrada de materia prima nro 80', '2025-09-25 15:09:32', 171.85),
(126, -848.48, 'Egreso por entrada de materia prima nro 81', '2025-09-25 15:12:37', 171.85),
(127, -94.94, 'Egreso por entrada de materia prima nro 82', '2025-09-25 15:15:07', 171.85),
(128, -484.84, 'Egreso por entrada de materia prima nro 83', '2025-09-25 15:16:13', 171.85),
(129, -155, 'Egreso por entrada de materia prima nro 84', '2025-09-25 15:23:05', 171.85),
(130, -1500, 'Egreso por entrada de materia prima nro 85', '2025-09-25 20:16:15', 171.85),
(186, -342.34, 'Egreso por entrada de materia prima nro 86', '2025-10-14 10:55:45', 197.25),
(195, 200, 'Ingreso por Zelle', '2025-10-24 13:48:36', 1),
(196, 116, 'Ingreso por Zelle', '2025-10-24 13:48:36', 1),
(197, 200, 'Ingreso por Zelle', '2025-10-24 13:49:21', 1),
(198, 116, 'Ingreso por Zelle', '2025-10-24 13:49:21', 1),
(199, 200, 'Ingreso por Zelle', '2025-10-24 13:49:44', 1),
(200, 116, 'Ingreso por Zelle', '2025-10-24 13:49:44', 1),
(203, 200, 'Ingreso por Zelle', '2025-10-24 13:49:56', 1),
(204, 116, 'Ingreso por Zelle', '2025-10-24 13:49:56', 1),
(207, 200, 'Ingreso por Zelle', '2025-10-24 13:50:27', 1),
(208, 116, 'Ingreso por Zelle', '2025-10-24 13:50:27', 1),
(211, 200, 'Ingreso por Zelle', '2025-10-24 13:50:52', 1),
(212, 116, 'Ingreso por Zelle', '2025-10-24 13:50:52', 1),
(215, 200, 'Ingreso por Zelle', '2025-10-24 13:57:57', 1),
(216, 116, 'Ingreso por Zelle', '2025-10-24 13:57:57', 1),
(219, 200, 'Ingreso por Zelle', '2025-10-24 13:58:09', 1),
(220, 116, 'Ingreso por Zelle', '2025-10-24 13:58:09', 1),
(221, 200, 'Ingreso por Zelle', '2025-10-26 13:01:16', 1),
(222, 116, 'Ingreso por Zelle', '2025-10-26 13:01:16', 1),
(225, 200, 'Ingreso por Zelle', '2025-10-26 13:02:17', 1),
(226, 116, 'Ingreso por Zelle', '2025-10-26 13:02:17', 1),
(229, -250, 'Egreso por entrada de materia prima nro 83', '2025-10-26 18:06:53', 1),
(230, -250, 'Egreso por entrada de materia prima nro 85', '2025-10-26 18:07:05', 1),
(231, 200, 'Ingreso por Zelle', '2025-10-26 13:07:05', 1),
(232, 116, 'Ingreso por Zelle', '2025-10-26 13:07:05', 1),
(235, -250, 'Egreso por entrada de materia prima nro 87', '2025-10-26 18:09:30', 1),
(236, 200, 'Ingreso por Zelle', '2025-10-26 13:09:31', 1),
(237, 116, 'Ingreso por Zelle', '2025-10-26 13:09:31', 1),
(240, 116, 'Ingreso por Zelle', '2025-11-05 22:30:46', 1),
(241, 116, 'Ingreso por Zelle', '2025-11-05 22:32:57', 1),
(242, 200, 'Ingreso por Zelle', '2025-11-05 22:33:19', 1),
(243, 116, 'Ingreso por Zelle', '2025-11-05 22:33:19', 1),
(246, 200, 'Ingreso por Zelle', '2025-11-05 22:34:11', 1),
(247, 116, 'Ingreso por Zelle', '2025-11-05 22:34:11', 1),
(250, 200, 'Ingreso por Zelle', '2025-11-05 22:34:31', 1),
(251, 116, 'Ingreso por Zelle', '2025-11-05 22:34:31', 1),
(254, 200, 'Ingreso por Zelle', '2025-11-05 22:35:44', 1),
(255, 116, 'Ingreso por Zelle', '2025-11-05 22:35:44', 1),
(258, 200, 'Ingreso por Zelle', '2025-11-05 22:49:17', 1),
(259, 116, 'Ingreso por Zelle', '2025-11-05 22:49:17', 1),
(262, 200, 'Ingreso por Zelle', '2025-11-05 22:50:47', 1),
(263, 116, 'Ingreso por Zelle', '2025-11-05 22:50:47', 1),
(266, 200, 'Ingreso por Zelle', '2025-11-05 23:10:19', 1),
(267, 116, 'Ingreso por Zelle', '2025-11-05 23:10:19', 1),
(270, 200, 'Ingreso por Zelle', '2025-11-05 23:10:44', 1),
(271, 116, 'Ingreso por Zelle', '2025-11-05 23:10:44', 1),
(274, 200, 'Ingreso por Zelle', '2025-11-05 23:12:33', 1),
(275, 116, 'Ingreso por Zelle', '2025-11-05 23:12:33', 1),
(278, 200, 'Ingreso por Zelle', '2025-11-05 23:13:35', 1),
(279, 116, 'Ingreso por Zelle', '2025-11-05 23:13:35', 1),
(282, 200, 'Ingreso por Zelle', '2025-11-05 23:15:19', 1),
(283, 116, 'Ingreso por Zelle', '2025-11-05 23:15:19', 1),
(286, 200, 'Ingreso por Zelle', '2025-11-05 23:17:45', 1),
(287, 116, 'Ingreso por Zelle', '2025-11-05 23:17:45', 1),
(290, 200, 'Ingreso por Zelle', '2025-11-05 23:18:04', 1),
(291, 116, 'Ingreso por Zelle', '2025-11-05 23:18:04', 1),
(294, 200, 'Ingreso por Zelle', '2025-11-05 23:19:26', 1),
(295, 116, 'Ingreso por Zelle', '2025-11-05 23:19:26', 1),
(298, 200, 'Ingreso por Zelle', '2025-11-05 23:21:22', 1),
(299, 116, 'Ingreso por Zelle', '2025-11-05 23:21:22', 1),
(302, 200, 'Ingreso por Zelle', '2025-11-05 23:22:45', 1),
(303, 116, 'Ingreso por Zelle', '2025-11-05 23:22:45', 1),
(306, 200, 'Ingreso por Zelle', '2025-11-05 23:23:52', 1),
(307, 116, 'Ingreso por Zelle', '2025-11-05 23:23:52', 1),
(308, -250, 'Egreso por entrada de materia prima nro 110', '2025-11-06 04:24:45', 1),
(309, 200, 'Ingreso por Zelle', '2025-11-05 23:24:46', 1),
(310, 116, 'Ingreso por Zelle', '2025-11-05 23:24:46', 1),
(311, -250, 'Egreso por entrada de materia prima nro 112', '2025-11-06 04:24:52', 1),
(312, 200, 'Ingreso por Zelle', '2025-11-05 23:24:53', 1),
(313, 116, 'Ingreso por Zelle', '2025-11-05 23:24:53', 1),
(316, -250, 'Egreso por entrada de materia prima nro 114', '2025-11-06 04:25:14', 1),
(317, 200, 'Ingreso por Zelle', '2025-11-05 23:25:15', 1),
(318, 116, 'Ingreso por Zelle', '2025-11-05 23:25:15', 1),
(321, -250, 'Egreso por entrada de materia prima nro 116', '2025-11-06 04:26:09', 1),
(322, 200, 'Ingreso por Zelle', '2025-11-05 23:26:09', 1),
(323, 116, 'Ingreso por Zelle', '2025-11-05 23:26:09', 1),
(326, -250, 'Egreso por entrada de materia prima nro 118', '2025-11-06 04:26:52', 1),
(327, 200, 'Ingreso por Zelle', '2025-11-05 23:26:52', 1),
(328, 116, 'Ingreso por Zelle', '2025-11-05 23:26:52', 1),
(331, -250, 'Egreso por entrada de materia prima nro 120', '2025-11-06 04:46:37', 1),
(332, 200, 'Ingreso por Zelle', '2025-11-05 23:46:37', 1),
(333, 116, 'Ingreso por Zelle', '2025-11-05 23:46:37', 1),
(336, -250, 'Egreso por entrada de materia prima nro 122', '2025-11-06 04:47:19', 1),
(337, 200, 'Ingreso por Zelle', '2025-11-05 23:47:20', 1),
(338, 116, 'Ingreso por Zelle', '2025-11-05 23:47:20', 1),
(341, -250, 'Egreso por entrada de materia prima nro 124', '2025-11-06 04:49:52', 1),
(342, 200, 'Ingreso por Zelle', '2025-11-05 23:49:52', 1),
(343, 116, 'Ingreso por Zelle', '2025-11-05 23:49:52', 1),
(346, -250, 'Egreso por entrada de materia prima nro 126', '2025-11-06 04:50:16', 1),
(347, 200, 'Ingreso por Zelle', '2025-11-05 23:50:16', 1),
(348, 116, 'Ingreso por Zelle', '2025-11-05 23:50:16', 1),
(351, -250, 'Egreso por entrada de materia prima nro 128', '2025-11-06 04:50:37', 1),
(352, 200, 'Ingreso por Zelle', '2025-11-05 23:50:38', 1),
(353, 116, 'Ingreso por Zelle', '2025-11-05 23:50:38', 1),
(356, -250, 'Egreso por entrada de materia prima nro 130', '2025-11-06 04:51:02', 1),
(357, 200, 'Ingreso por Zelle', '2025-11-05 23:51:02', 1),
(358, 116, 'Ingreso por Zelle', '2025-11-05 23:51:02', 1),
(361, -250, 'Egreso por entrada de materia prima nro 132', '2025-11-06 06:01:43', 1),
(362, 200, 'Ingreso por Zelle', '2025-11-06 01:01:44', 1),
(363, 116, 'Ingreso por Zelle', '2025-11-06 01:01:44', 1),
(366, -250, 'Egreso por entrada de materia prima nro 134', '2025-11-06 11:45:16', 1),
(367, 200, 'Ingreso por Zelle', '2025-11-06 06:45:16', 1),
(368, 116, 'Ingreso por Zelle', '2025-11-06 06:45:16', 1),
(372, 200, 'Ingreso por Zelle', '2025-11-11 14:21:07', 1),
(373, 116, 'Ingreso por Zelle', '2025-11-11 14:21:07', 1),
(376, -250, 'Egreso por entrada de materia prima nro 138', '2025-11-11 19:21:29', 1),
(377, 200, 'Ingreso por Zelle', '2025-11-11 14:21:29', 1),
(378, 116, 'Ingreso por Zelle', '2025-11-11 14:21:29', 1),
(381, -250, 'Egreso por entrada de materia prima nro 140', '2025-11-11 22:42:31', 1),
(382, 200, 'Ingreso por Zelle', '2025-11-11 17:42:31', 1),
(383, 116, 'Ingreso por Zelle', '2025-11-11 17:42:31', 1),
(386, -250, 'Egreso por entrada de materia prima nro 142', '2026-03-03 22:33:53', 1),
(387, 200, 'Ingreso por Zelle', '2026-03-03 17:33:53', 1),
(388, 116, 'Ingreso por Zelle', '2026-03-03 17:33:53', 1),
(391, -250, 'Egreso por entrada de materia prima nro 144', '2026-03-03 22:34:33', 1),
(392, 200, 'Ingreso por Zelle', '2026-03-03 17:34:33', 1),
(393, 116, 'Ingreso por Zelle', '2026-03-03 17:34:33', 1),
(396, -250, 'Egreso por entrada de materia prima nro 146', '2026-03-03 22:38:06', 1),
(397, 200, 'Ingreso por Zelle', '2026-03-03 17:38:06', 1),
(398, 116, 'Ingreso por Zelle', '2026-03-03 17:38:06', 1),
(401, -250, 'Egreso por entrada de materia prima nro 148', '2026-03-03 22:38:15', 1),
(402, 200, 'Ingreso por Zelle', '2026-03-03 17:38:16', 1),
(403, 116, 'Ingreso por Zelle', '2026-03-03 17:38:16', 1),
(406, -250, 'Egreso por entrada de materia prima nro 150', '2026-03-03 22:38:33', 1),
(407, 200, 'Ingreso por Zelle', '2026-03-03 17:38:33', 1),
(408, 116, 'Ingreso por Zelle', '2026-03-03 17:38:33', 1),
(411, -250, 'Egreso por entrada de materia prima nro 152', '2026-03-03 22:52:02', 1),
(412, 200, 'Ingreso por Zelle', '2026-03-03 17:52:02', 1),
(413, 116, 'Ingreso por Zelle', '2026-03-03 17:52:03', 1),
(416, -250, 'Egreso por entrada de materia prima nro 154', '2026-03-03 23:00:20', 1),
(417, 200, 'Ingreso por Zelle', '2026-03-03 18:00:20', 1),
(418, 116, 'Ingreso por Zelle', '2026-03-03 18:00:20', 1),
(421, -250, 'Egreso por entrada de materia prima nro 156', '2026-03-03 23:41:28', 1),
(422, 200, 'Ingreso por Zelle', '2026-03-03 18:41:28', 1),
(423, 116, 'Ingreso por Zelle', '2026-03-03 18:41:28', 1),
(426, -250, 'Egreso por entrada de materia prima nro 158', '2026-03-03 23:47:22', 1),
(427, 200, 'Ingreso por Zelle', '2026-03-03 18:47:22', 1),
(428, 116, 'Ingreso por Zelle', '2026-03-03 18:47:22', 1),
(431, -250, 'Egreso por entrada de materia prima nro 160', '2026-03-03 23:55:23', 1),
(432, 200, 'Ingreso por Zelle', '2026-03-03 18:55:23', 1),
(433, 116, 'Ingreso por Zelle', '2026-03-03 18:55:23', 1),
(436, -1, 'Egreso por entrada de materia prima nro 154', '2026-03-05 17:27:45', 427.93),
(437, -1.11, 'Egreso por entrada de materia prima nro 155', '2026-03-05 17:51:14', 427.93);

--
-- Disparadores `movimientos_capital`
--
DELIMITER $$
CREATE TRIGGER `movimientos_capital_AFTER_INSERT` AFTER INSERT ON `movimientos_capital` FOR EACH ROW BEGIN
UPDATE capital SET monto = monto + NEW.monto WHERE id = 1;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden`
--

CREATE TABLE `orden` (
  `id` int NOT NULL,
  `id_cliente` int DEFAULT NULL,
  `nro_orden` float NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `tipo` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `orden`
--

INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(80, NULL, 91485100, '2025-07-03 15:46:14', 'en cocina', 'local'),
(81, 1, 63411000, '2025-07-03 19:52:49', 'pagado', 'local'),
(83, 1, 57834000, '2025-07-07 18:08:46', 'anulada', 'llevar'),
(84, 1, 45966800, '2025-07-07 18:11:22', 'en cocina', 'llevar'),
(85, 1, 66983700, '2025-07-09 17:49:12', 'entregada', 'delivery'),
(86, 1, 48539300, '2025-07-09 23:21:49', 'anulada', 'delivery'),
(87, 1, 53998900, '2025-07-09 23:28:50', 'en camino', 'delivery'),
(88, 1, 46259600, '2025-07-10 00:49:12', 'para despachar', 'delivery'),
(89, 1, 87626000, '2025-07-10 18:46:47', 'en cocina', 'llevar'),
(90, NULL, 40394500, '2025-07-16 17:47:21', 'en cocina', 'local'),
(91, NULL, 61900800, '2025-07-16 17:50:57', 'en mesa', 'local'),
(101, 44, 10431500, '2025-07-25 18:21:42', 'pagado', 'reserva'),
(102, 1, 44910200, '2025-08-06 16:51:53', 'en cocina', 'delivery'),
(103, 36, 81645900, '2025-08-06 16:57:55', 'en cocina', 'delivery'),
(104, 1, 94405200, '2025-08-06 17:10:03', 'en cocina', 'llevar'),
(105, 1, 60740500, '2025-08-06 17:24:43', 'en cocina', 'delivery'),
(106, 1, 74482600, '2025-08-06 17:26:43', 'en cocina', 'delivery'),
(107, 36, 91673300, '2025-08-06 17:28:10', 'en cocina', 'llevar'),
(108, 1, 54932400, '2025-08-06 17:34:59', 'en cocina', 'delivery'),
(109, 1, 87668500, '2025-08-06 17:48:29', 'en cocina', 'llevar'),
(110, 36, 26105400, '2025-08-06 18:04:45', 'en cocina', 'delivery'),
(111, 1, 44316100, '2025-08-06 18:06:39', 'en cocina', 'llevar'),
(112, 1, 63058700, '2025-08-06 18:19:20', 'en cocina', 'delivery'),
(113, 1, 39248300, '2025-08-06 18:21:33', 'en cocina', 'llevar'),
(114, 36, 62197100, '2025-08-06 18:35:24', 'para despachar', 'delivery'),
(115, 1, 43673800, '2025-08-06 18:37:42', 'en cocina', 'llevar'),
(116, 1, 22618600, '2025-08-06 18:38:34', 'en preparacion', 'delivery'),
(117, 36, 72337000, '2025-08-09 16:13:49', 'pagado', 'local'),
(118, 36, 52566000, '2025-08-09 16:25:56', 'pagado', 'local'),
(119, NULL, 63436300, '2025-08-09 16:29:01', 'en mesa', 'local'),
(126, NULL, 93394400, '2025-08-09 16:57:23', 'en cocina', 'local'),
(127, NULL, 35454300, '2025-08-09 16:59:59', 'para despachar', 'local'),
(128, 36, 12591700, '2025-08-09 17:01:15', 'pagado', 'local'),
(129, 36, 44447700, '2025-08-09 17:01:37', 'pagado', 'local'),
(130, 36, 95047700, '2025-08-09 17:18:34', 'pagado', 'local'),
(131, 36, 29741700, '2025-08-09 17:24:44', 'en mesa', 'reserva'),
(132, 1, 31299400, '2025-08-12 17:03:42', 'pagado', 'reserva'),
(224, NULL, 2123, '2025-10-24 23:49:21', 'preparacion', 'local'),
(225, NULL, 4287, '2025-10-24 23:49:44', 'preparacion', 'local'),
(227, NULL, 1384, '2025-10-24 23:49:56', 'preparacion', 'local'),
(229, NULL, 1849, '2025-10-24 23:50:27', 'preparacion', 'local'),
(231, NULL, 1687, '2025-10-24 23:50:52', 'preparacion', 'local'),
(233, NULL, 3142, '2025-10-24 23:57:57', 'preparacion', 'local'),
(235, NULL, 8180, '2025-10-24 23:58:08', 'preparacion', 'local'),
(236, NULL, 3119, '2025-10-26 22:01:16', 'preparacion', 'local'),
(238, NULL, 4019, '2025-10-26 22:02:17', 'preparacion', 'local'),
(240, NULL, 6084, '2025-10-26 22:07:05', 'preparacion', 'local'),
(242, NULL, 2667, '2025-10-26 22:09:31', 'preparacion', 'local'),
(244, 1, 0, '2025-10-30 14:25:45', '0', 'local'),
(245, 1, 0, '2025-10-30 14:26:10', '1', 'local'),
(246, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(247, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(248, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(249, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(250, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(251, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(252, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(253, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(254, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(255, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(256, 1, 0, '2025-10-30 14:31:53', '1', 'local'),
(257, 1, 0, '2025-10-30 14:31:54', '1', 'local'),
(258, 1, 0, '2025-10-30 14:31:54', '1', 'local'),
(259, 1, 0, '2025-10-30 14:31:54', '1', 'local'),
(260, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(261, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(262, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(263, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(264, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(265, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(266, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(267, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(268, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(269, 1, 0, '2025-10-30 14:31:55', '1', 'local'),
(270, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(271, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(272, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(273, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(274, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(275, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(276, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(277, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(278, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(279, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(280, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(281, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(282, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(283, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(284, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(285, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(286, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(287, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(288, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(289, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(290, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(291, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(292, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(293, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(294, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(295, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(296, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(297, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(298, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(299, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(300, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(301, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(302, 1, 0, '2025-10-30 14:31:56', '1', 'local'),
(303, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(304, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(305, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(306, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(307, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(308, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(309, 1, 0, '2025-10-30 14:31:57', '1', 'local'),
(310, 1, 0, '2025-10-30 14:31:58', '1', 'local'),
(311, 1, 0, '2025-10-30 14:31:58', '1', 'local'),
(312, 1, 0, '2025-10-30 14:31:58', '1', 'local'),
(313, 1, 0, '2025-10-30 14:31:59', '1', 'local'),
(314, 1, 0, '2025-10-30 14:31:59', '1', 'local'),
(315, 1, 0, '2025-10-30 14:31:59', '1', 'local'),
(316, 1, 0, '2025-10-30 14:31:59', '1', 'local'),
(317, 1, 0, '2025-10-30 14:31:59', '1', 'local'),
(318, 1, 0, '2025-10-30 14:31:59', '1', 'local'),
(319, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(320, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(321, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(322, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(323, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(324, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(325, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(326, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(327, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(328, 1, 0, '2025-10-30 14:32:00', '1', 'local'),
(329, 1, 0, '2025-10-30 14:32:01', '1', 'local'),
(330, 1, 0, '2025-10-30 14:32:01', '1', 'local'),
(331, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(332, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(333, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(334, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(335, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(336, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(337, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(338, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(339, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(340, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(341, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(342, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(343, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(344, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(345, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(346, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(347, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(348, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(349, 1, 0, '2025-10-30 14:32:02', '1', 'local'),
(350, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(351, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(352, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(353, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(354, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(355, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(356, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(357, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(358, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(359, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(360, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(361, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(362, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(363, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(364, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(365, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(366, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(367, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(368, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(369, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(370, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(371, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(372, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(373, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(374, 1, 0, '2025-10-30 14:32:03', '1', 'local'),
(375, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(376, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(377, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(378, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(379, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(380, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(381, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(382, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(383, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(384, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(385, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(386, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(387, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(388, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(389, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(390, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(391, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(392, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(393, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(394, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(395, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(396, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(397, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(398, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(399, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(400, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(401, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(402, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(403, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(404, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(405, 1, 0, '2025-10-30 14:32:04', '1', 'local'),
(406, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(407, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(408, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(409, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(410, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(411, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(412, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(413, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(414, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(415, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(416, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(417, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(418, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(419, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(420, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(421, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(422, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(423, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(424, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(425, 1, 0, '2025-10-30 14:32:05', '1', 'local'),
(426, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(427, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(428, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(429, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(430, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(431, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(432, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(433, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(434, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(435, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(436, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(437, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(438, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(439, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(440, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(441, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(442, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(443, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(444, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(445, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(446, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(447, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(448, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(449, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(450, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(451, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(452, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(453, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(454, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(455, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(456, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(457, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(458, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(459, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(460, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(461, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(462, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(463, 1, 0, '2025-10-30 14:32:06', '1', 'local'),
(464, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(465, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(466, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(467, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(468, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(469, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(470, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(471, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(472, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(473, 1, 0, '2025-10-30 14:32:07', '1', 'local'),
(474, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(475, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(476, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(477, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(478, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(479, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(480, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(481, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(482, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(483, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(484, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(485, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(486, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(487, 1, 0, '2025-10-30 14:32:08', '1', 'local'),
(488, 1, 0, '2025-10-30 14:32:09', '1', 'local'),
(489, 1, 0, '2025-10-30 14:32:09', '1', 'local'),
(490, 1, 0, '2025-10-30 14:32:09', '1', 'local'),
(491, 1, 0, '2025-10-30 14:32:09', '1', 'local'),
(492, 1, 0, '2025-10-30 14:32:09', '1', 'local'),
(493, 1, 0, '2025-10-30 14:32:09', '1', 'local'),
(494, 1, 0, '2025-10-30 14:32:10', '1', 'local'),
(495, 1, 0, '2025-10-30 14:32:10', '1', 'local'),
(496, 1, 0, '2025-10-30 14:32:10', '1', 'local'),
(497, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(498, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(499, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(500, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(501, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(502, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(503, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(504, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(505, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(506, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(507, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(508, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(509, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(510, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(511, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(512, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(513, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(514, 1, 0, '2025-10-30 14:32:11', '1', 'local'),
(515, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(516, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(517, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(518, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(519, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(520, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(521, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(522, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(523, 1, 0, '2025-10-30 14:32:12', '1', 'local'),
(524, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(525, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(526, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(527, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(528, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(529, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(530, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(531, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(532, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(533, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(534, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(535, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(536, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(537, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(538, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(539, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(540, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(541, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(542, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(543, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(544, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(545, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(546, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(547, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(548, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(549, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(550, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(551, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(552, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(553, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(554, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(555, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(556, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(557, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(558, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(559, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(560, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(561, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(562, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(563, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(564, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(565, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(566, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(567, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(568, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(569, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(570, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(571, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(572, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(573, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(574, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(575, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(576, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(577, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(578, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(579, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(580, 1, 0, '2025-10-30 14:32:13', '1', 'local'),
(581, 1, 0, '2025-10-30 14:32:25', '1', 'local'),
(582, 1, 0, '2025-10-30 14:32:25', '1', 'local'),
(583, 1, 0, '2025-10-30 14:32:25', '1', 'local'),
(584, 1, 0, '2025-10-30 14:32:25', '1', 'local'),
(585, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(586, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(587, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(588, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(589, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(590, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(591, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(592, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(593, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(594, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(595, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(596, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(597, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(598, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(599, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(600, 1, 0, '2025-10-30 14:32:26', '1', 'local'),
(601, 1, 0, '2025-10-30 14:32:27', '1', 'local'),
(602, 1, 0, '2025-10-30 14:32:27', '1', 'local'),
(603, 1, 0, '2025-10-30 14:32:27', '1', 'local'),
(604, 1, 0, '2025-10-30 14:32:27', '1', 'local'),
(605, 1, 0, '2025-10-30 14:32:27', '1', 'local'),
(606, 1, 0, '2025-10-30 14:32:27', '1', 'local'),
(607, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(608, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(609, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(610, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(611, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(612, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(613, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(614, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(615, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(616, 1, 0, '2025-10-30 14:32:28', '1', 'local'),
(617, 1, 0, '2025-10-30 14:32:29', '1', 'local'),
(618, 1, 0, '2025-10-30 14:32:29', '1', 'local'),
(619, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(620, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(621, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(622, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(623, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(624, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(625, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(626, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(627, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(628, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(629, 1, 0, '2025-10-30 14:32:30', '1', 'local'),
(630, 1, 0, '2025-10-30 14:32:31', '1', 'local'),
(631, 1, 0, '2025-10-30 14:32:31', '1', 'local'),
(632, 1, 0, '2025-10-30 14:32:31', '1', 'local'),
(633, 1, 0, '2025-10-30 14:32:31', '1', 'local'),
(634, 1, 0, '2025-10-30 14:32:31', '1', 'local'),
(635, 1, 0, '2025-10-30 14:32:31', '1', 'local'),
(636, 1, 0, '2025-10-30 14:32:32', '1', 'local'),
(637, 1, 0, '2025-10-30 14:32:32', '1', 'local'),
(638, 1, 0, '2025-10-30 14:32:32', '1', 'local'),
(639, 1, 0, '2025-10-30 14:32:32', '1', 'local'),
(640, 1, 0, '2025-10-30 14:32:32', '1', 'local'),
(641, 1, 0, '2025-10-30 14:32:33', '1', 'local'),
(642, 1, 0, '2025-10-30 14:32:33', '1', 'local'),
(643, 1, 0, '2025-10-30 14:32:33', '1', 'local'),
(644, 1, 0, '2025-10-30 14:32:33', '1', 'local'),
(645, 1, 0, '2025-10-30 14:32:33', '1', 'local'),
(646, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(647, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(648, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(649, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(650, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(651, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(652, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(653, 1, 0, '2025-10-30 14:32:34', '1', 'local'),
(654, 1, 0, '2025-10-30 14:32:35', '1', 'local'),
(655, 1, 0, '2025-10-30 14:32:35', '1', 'local'),
(656, 1, 0, '2025-10-30 14:32:35', '1', 'local'),
(657, 1, 0, '2025-10-30 14:32:35', '1', 'local'),
(658, 1, 0, '2025-10-30 14:32:35', '1', 'local'),
(659, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(660, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(661, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(662, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(663, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(664, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(665, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(666, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(667, 1, 0, '2025-10-30 14:32:36', '1', 'local'),
(668, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(669, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(670, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(671, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(672, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(673, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(674, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(675, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(676, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(677, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(678, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(679, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(680, 1, 0, '2025-10-30 14:32:37', '1', 'local'),
(681, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(682, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(683, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(684, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(685, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(686, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(687, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(688, 1, 0, '2025-10-30 14:32:38', '1', 'local'),
(689, 1, 0, '2025-10-30 14:32:39', '1', 'local'),
(690, 1, 0, '2025-10-30 14:32:39', '1', 'local'),
(691, 1, 0, '2025-10-30 14:32:39', '1', 'local'),
(692, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(693, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(694, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(695, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(696, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(697, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(698, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(699, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(700, 1, 0, '2025-10-30 14:32:40', '1', 'local'),
(701, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(702, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(703, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(704, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(705, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(706, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(707, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(708, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(709, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(710, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(711, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(712, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(713, 1, 0, '2025-10-30 14:32:41', '1', 'local'),
(714, 1, 0, '2025-10-30 14:32:42', '1', 'local'),
(715, 1, 0, '2025-10-30 14:32:42', '1', 'local'),
(716, 1, 0, '2025-10-30 14:32:43', '1', 'local'),
(717, 1, 0, '2025-10-30 14:32:43', '1', 'local'),
(718, 1, 0, '2025-10-30 14:32:43', '1', 'local'),
(719, 1, 0, '2025-10-30 14:32:43', '1', 'local'),
(720, 1, 0, '2025-10-30 14:32:43', '1', 'local'),
(721, 1, 0, '2025-10-30 14:32:43', '1', 'local'),
(722, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(723, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(724, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(725, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(726, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(727, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(728, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(729, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(730, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(731, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(732, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(733, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(734, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(735, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(736, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(737, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(738, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(739, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(740, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(741, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(742, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(743, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(744, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(745, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(746, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(747, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(748, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(749, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(750, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(751, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(752, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(753, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(754, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(755, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(756, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(757, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(758, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(759, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(760, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(761, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(762, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(763, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(764, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(765, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(766, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(767, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(768, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(769, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(770, 1, 0, '2025-10-30 14:32:44', '1', 'local'),
(771, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(772, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(773, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(774, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(775, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(776, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(777, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(778, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(779, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(780, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(781, 1, 0, '2025-10-30 14:32:50', '1', 'local'),
(782, 1, 0, '2025-10-30 14:32:51', '1', 'local'),
(783, 1, 0, '2025-10-30 14:32:51', '1', 'local'),
(784, 1, 0, '2025-10-30 14:32:51', '1', 'local'),
(785, 1, 0, '2025-10-30 14:32:51', '1', 'local'),
(786, 1, 0, '2025-10-30 14:32:51', '1', 'local'),
(787, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(788, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(789, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(790, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(791, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(792, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(793, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(794, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(795, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(796, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(797, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(798, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(799, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(800, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(801, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(802, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(803, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(804, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(805, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(806, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(807, 1, 0, '2025-10-30 14:32:52', '1', 'local'),
(808, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(809, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(810, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(811, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(812, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(813, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(814, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(815, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(816, 1, 0, '2025-10-30 14:32:53', '1', 'local'),
(817, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(818, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(819, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(820, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(821, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(822, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(823, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(824, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(825, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(826, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(827, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(828, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(829, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(830, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(831, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(832, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(833, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(834, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(835, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(836, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(837, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(838, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(839, 1, 0, '2025-10-30 14:32:54', '1', 'local'),
(840, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(841, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(842, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(843, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(844, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(845, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(846, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(847, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(848, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(849, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(850, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(851, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(852, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(853, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(854, 1, 0, '2025-10-30 14:32:55', '1', 'local'),
(855, 1, 0, '2025-10-30 14:32:56', '1', 'local'),
(856, 1, 0, '2025-10-30 14:32:57', '1', 'local'),
(857, 1, 0, '2025-10-30 14:32:57', '1', 'local'),
(858, 1, 0, '2025-10-30 14:32:57', '1', 'local'),
(859, 1, 0, '2025-10-30 14:32:58', '1', 'local'),
(860, 1, 0, '2025-10-30 14:32:58', '1', 'local'),
(861, 1, 0, '2025-10-30 14:32:58', '1', 'local'),
(862, 1, 0, '2025-10-30 14:32:59', '1', 'local'),
(863, 1, 0, '2025-10-30 14:32:59', '1', 'local'),
(864, 1, 0, '2025-10-30 14:32:59', '1', 'local'),
(865, 1, 0, '2025-10-30 14:32:59', '1', 'local'),
(866, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(867, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(868, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(869, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(870, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(871, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(872, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(873, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(874, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(875, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(876, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(877, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(878, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(879, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(880, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(881, 1, 0, '2025-10-30 14:33:00', '1', 'local'),
(882, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(883, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(884, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(885, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(886, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(887, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(888, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(889, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(890, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(891, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(892, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(893, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(894, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(895, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(896, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(897, 1, 0, '2025-10-30 14:33:01', '1', 'local'),
(898, 1, 0, '2025-10-30 14:33:02', '1', 'local'),
(899, 1, 0, '2025-10-30 14:33:02', '1', 'local'),
(900, 1, 0, '2025-10-30 14:33:03', '1', 'local'),
(901, 1, 0, '2025-10-30 14:33:03', '1', 'local'),
(902, 1, 0, '2025-10-30 14:33:03', '1', 'local'),
(903, 1, 0, '2025-10-30 14:33:04', '1', 'local'),
(904, 1, 0, '2025-10-30 14:33:04', '1', 'local'),
(905, 1, 0, '2025-10-30 14:33:04', '1', 'local'),
(906, 1, 0, '2025-10-30 14:33:05', '1', 'local'),
(907, 1, 0, '2025-10-30 14:33:05', '1', 'local'),
(908, 1, 0, '2025-10-30 14:33:06', '1', 'local'),
(909, 1, 0, '2025-10-30 14:33:06', '1', 'local'),
(910, 1, 0, '2025-10-30 14:33:06', '1', 'local'),
(911, 1, 0, '2025-10-30 14:33:06', '1', 'local'),
(912, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(913, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(914, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(915, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(916, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(917, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(918, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(919, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(920, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(921, 1, 0, '2025-10-30 14:33:07', '1', 'local'),
(922, 1, 0, '2025-10-30 14:33:08', '1', 'local'),
(923, 1, 0, '2025-10-30 14:33:08', '1', 'local'),
(924, 1, 0, '2025-10-30 14:33:08', '1', 'local'),
(925, 1, 0, '2025-10-30 14:33:08', '1', 'local'),
(926, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(927, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(928, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(929, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(930, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(931, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(932, 1, 0, '2025-10-30 14:33:09', '1', 'local'),
(933, 1, 0, '2025-10-30 14:33:10', '1', 'local'),
(934, 1, 0, '2025-10-30 14:33:10', '1', 'local'),
(935, 1, 0, '2025-10-30 14:33:10', '1', 'local'),
(936, 1, 0, '2025-10-30 14:33:10', '1', 'local'),
(937, 1, 0, '2025-10-30 14:33:10', '1', 'local'),
(938, 1, 0, '2025-10-30 14:33:11', '1', 'local'),
(939, 1, 0, '2025-10-30 14:33:11', '1', 'local'),
(940, 1, 0, '2025-10-30 14:33:12', '1', 'local'),
(941, 1, 0, '2025-10-30 14:33:12', '1', 'local'),
(942, 1, 0, '2025-10-30 14:33:12', '1', 'local'),
(943, 1, 0, '2025-10-30 14:33:12', '1', 'local'),
(944, 1, 0, '2025-10-30 14:33:13', '1', 'local'),
(945, 1, 0, '2025-10-30 14:33:13', '1', 'local'),
(946, 1, 0, '2025-10-30 14:33:13', '1', 'local'),
(947, 1, 0, '2025-10-30 14:33:13', '1', 'local'),
(948, 1, 0, '2025-10-30 14:33:13', '1', 'local'),
(949, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(950, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(951, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(952, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(953, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(954, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(955, 1, 0, '2025-10-30 14:33:15', '1', 'local'),
(956, 1, 0, '2025-10-30 14:33:16', '1', 'local'),
(957, 1, 0, '2025-10-30 14:33:16', '1', 'local'),
(958, 1, 0, '2025-10-30 14:33:17', '1', 'local'),
(959, 1, 0, '2025-10-30 14:33:17', '1', 'local'),
(960, 1, 0, '2025-10-30 14:33:17', '1', 'local'),
(961, 1, 0, '2025-10-30 14:33:18', '1', 'local'),
(962, 1, 0, '2025-10-30 14:33:18', '1', 'local'),
(963, 1, 0, '2025-10-30 14:33:18', '1', 'local'),
(964, 1, 0, '2025-10-30 14:33:18', '1', 'local'),
(965, 1, 0, '2025-10-30 14:33:18', '1', 'local'),
(966, 1, 0, '2025-10-30 14:33:19', '1', 'local'),
(967, 1, 0, '2025-10-30 14:33:19', '1', 'local'),
(968, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(969, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(970, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(971, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(972, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(973, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(974, 1, 0, '2025-10-30 14:33:20', '1', 'local'),
(975, 1, 0, '2025-10-30 14:33:21', '1', 'local'),
(976, 1, 0, '2025-10-30 14:33:21', '1', 'local'),
(977, 1, 0, '2025-10-30 14:33:21', '1', 'local'),
(978, 1, 0, '2025-10-30 14:33:21', '1', 'local'),
(979, 1, 0, '2025-10-30 14:33:21', '1', 'local'),
(980, 1, 0, '2025-10-30 14:33:22', '1', 'local'),
(981, 1, 0, '2025-10-30 14:33:22', '1', 'local'),
(982, 1, 0, '2025-10-30 14:33:22', '1', 'local'),
(983, 1, 0, '2025-10-30 14:33:22', '1', 'local'),
(984, 1, 0, '2025-10-30 14:33:22', '1', 'local'),
(985, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(986, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(987, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(988, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(989, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(990, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(991, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(992, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(993, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(994, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(995, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(996, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(997, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(998, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(999, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(1000, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(1001, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(1002, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(1003, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(1004, 1, 0, '2025-10-30 14:33:23', '1', 'local'),
(1005, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1006, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1007, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1008, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1009, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1010, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1011, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1012, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1013, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1014, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1015, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1016, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1017, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1018, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1019, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1020, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1021, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1022, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1023, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1024, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1025, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1026, 1, 0, '2025-10-30 14:33:24', '1', 'local'),
(1027, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1028, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1029, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1030, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1031, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1032, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1033, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1034, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1035, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1036, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1037, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1038, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1039, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1040, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1041, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1042, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1043, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1044, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1045, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1046, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1047, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1048, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1049, 1, 0, '2025-10-30 14:33:25', '1', 'local'),
(1050, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1051, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1052, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1053, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1054, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1055, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1056, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1057, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1058, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1059, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1060, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1061, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1062, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1063, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1064, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1065, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1066, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1067, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1068, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1069, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1070, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1071, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1072, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1073, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1074, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1075, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1076, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1077, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1078, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1079, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1080, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1081, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1082, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1083, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1084, 1, 0, '2025-10-30 14:33:26', '1', 'local'),
(1085, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1086, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1087, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1088, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1089, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1090, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1091, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1092, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1093, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1094, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1095, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1096, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1097, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1098, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1099, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1100, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1101, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1102, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1103, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1104, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1105, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1106, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1107, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1108, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1109, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1110, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1111, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1112, 1, 0, '2025-10-30 14:33:27', '1', 'local'),
(1113, 1, 0, '2025-10-30 14:33:28', '1', 'local'),
(1114, 1, 0, '2025-10-30 14:33:28', '1', 'local'),
(1115, 1, 0, '2025-10-30 14:33:28', '1', 'local'),
(1116, 1, 0, '2025-10-30 14:33:28', '1', 'local'),
(1117, 1, 0, '2025-10-30 14:33:28', '1', 'local'),
(1118, 1, 0, '2025-10-30 14:33:28', '1', 'local'),
(1119, 1, 0, '2025-10-30 14:33:29', '1', 'local'),
(1120, 1, 0, '2025-10-30 14:33:29', '1', 'local'),
(1121, 1, 0, '2025-10-30 14:33:29', '1', 'local'),
(1122, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1123, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1124, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1125, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1126, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1127, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1128, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1129, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1130, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1131, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1132, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1133, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1134, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1135, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1136, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1137, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1138, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1139, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1140, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1141, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1142, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1143, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1144, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1145, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1146, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1147, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1148, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1149, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1150, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1151, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1152, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1153, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1154, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1155, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1156, 1, 0, '2025-10-30 14:33:30', '1', 'local'),
(1157, 1, 0, '2025-10-30 14:33:37', '1', 'local'),
(1158, 1, 0, '2025-10-30 14:33:37', '1', 'local'),
(1159, 1, 0, '2025-10-30 14:33:37', '1', 'local'),
(1160, 1, 0, '2025-10-30 14:33:37', '1', 'local'),
(1161, 1, 0, '2025-10-30 14:33:38', '1', 'local'),
(1162, 1, 0, '2025-10-30 14:33:38', '1', 'local'),
(1163, 1, 0, '2025-10-30 14:33:38', '1', 'local'),
(1164, 1, 0, '2025-10-30 14:33:38', '1', 'local'),
(1165, 1, 0, '2025-10-30 14:33:38', '1', 'local'),
(1166, 1, 0, '2025-10-30 14:33:38', '1', 'local'),
(1167, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1168, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1169, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1170, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1171, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1172, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1173, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1174, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1175, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1176, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1177, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1178, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1179, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1180, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1181, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1182, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1183, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1184, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1185, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1186, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1187, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1188, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1189, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1190, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1191, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1192, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1193, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1194, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1195, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1196, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1197, 1, 0, '2025-10-30 14:33:39', '1', 'local'),
(1198, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1199, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1200, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1201, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1202, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1203, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1204, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1205, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1206, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1207, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1208, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1209, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1210, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1211, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1212, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1213, 1, 0, '2025-10-30 14:33:40', '1', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(1214, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1215, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1216, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1217, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1218, 1, 0, '2025-10-30 14:33:40', '1', 'local'),
(1219, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1220, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1221, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1222, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1223, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1224, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1225, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1226, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1227, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1228, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1229, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1230, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1231, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1232, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1233, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1234, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1235, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1236, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1237, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1238, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1239, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1240, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1241, 1, 0, '2025-10-30 14:33:41', '1', 'local'),
(1242, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1243, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1244, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1245, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1246, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1247, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1248, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1249, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1250, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1251, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1252, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1253, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1254, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1255, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1256, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1257, 1, 0, '2025-10-30 14:33:42', '1', 'local'),
(1258, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1259, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1260, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1261, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1262, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1263, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1264, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1265, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1266, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1267, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1268, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1269, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1270, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1271, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1272, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1273, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1274, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1275, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1276, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1277, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1278, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1279, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1280, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1281, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1282, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1283, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1284, 1, 0, '2025-10-30 14:33:43', '1', 'local'),
(1285, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1286, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1287, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1288, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1289, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1290, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1291, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1292, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1293, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1294, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1295, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1296, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1297, 1, 0, '2025-10-30 14:33:44', '1', 'local'),
(1298, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1299, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1300, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1301, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1302, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1303, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1304, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1305, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1306, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1307, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1308, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1309, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1310, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1311, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1312, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1313, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1314, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1315, 1, 0, '2025-10-30 14:33:45', '1', 'local'),
(1316, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1317, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1318, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1319, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1320, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1321, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1322, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1323, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1324, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1325, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1326, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1327, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1328, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1329, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1330, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1331, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1332, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1333, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1334, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1335, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1336, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1337, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1338, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1339, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1340, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1341, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1342, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1343, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1344, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1345, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1346, 1, 0, '2025-10-30 14:33:46', '1', 'local'),
(1347, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1348, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1349, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1350, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1351, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1352, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1353, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1354, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1355, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1356, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1357, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1358, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1359, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1360, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1361, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1362, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1363, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1364, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1365, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1366, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1367, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1368, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1369, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1370, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1371, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1372, 1, 0, '2025-10-30 14:33:47', '1', 'local'),
(1373, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1374, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1375, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1376, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1377, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1378, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1379, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1380, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1381, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1382, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1383, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1384, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1385, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1386, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1387, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1388, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1389, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1390, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1391, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1392, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1393, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1394, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1395, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1396, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1397, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1398, 1, 0, '2025-10-30 14:33:48', '1', 'local'),
(1399, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1400, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1401, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1402, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1403, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1404, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1405, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1406, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1407, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1408, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1409, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1410, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1411, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1412, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1413, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1414, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1415, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1416, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1417, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1418, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1419, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1420, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1421, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1422, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1423, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1424, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1425, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1426, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1427, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1428, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1429, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1430, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1431, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1432, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1433, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1434, 1, 0, '2025-10-30 14:33:49', '1', 'local'),
(1435, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1436, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1437, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1438, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1439, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1440, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1441, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1442, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1443, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1444, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1445, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1446, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1447, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1448, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1449, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1450, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1451, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1452, 1, 0, '2025-10-30 14:33:50', '1', 'local'),
(1453, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1454, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1455, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1456, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1457, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1458, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1459, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1460, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1461, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1462, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1463, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1464, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1465, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1466, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1467, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1468, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1469, 1, 0, '2025-10-30 14:33:51', '1', 'local'),
(1470, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1471, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1472, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1473, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1474, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1475, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1476, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1477, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1478, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1479, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1480, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1481, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1482, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1483, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1484, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1485, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1486, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1487, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1488, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1489, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1490, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1491, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1492, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1493, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1494, 1, 0, '2025-10-30 14:33:52', '1', 'local'),
(1495, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1496, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1497, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1498, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1499, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1500, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1501, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1502, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1503, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1504, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1505, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1506, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1507, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1508, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1509, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1510, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1511, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1512, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1513, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1514, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1515, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1516, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1517, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1518, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1519, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1520, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1521, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1522, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1523, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1524, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1525, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1526, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1527, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1528, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1529, 1, 0, '2025-10-30 14:33:53', '1', 'local'),
(1530, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1531, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1532, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1533, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1534, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1535, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1536, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1537, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1538, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1539, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1540, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1541, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1542, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1543, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1544, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1545, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1546, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1547, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1548, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1549, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1550, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1551, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1552, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1553, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1554, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1555, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1556, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1557, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1558, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1559, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1560, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1561, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1562, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1563, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1564, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1565, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1566, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1567, 1, 0, '2025-10-30 14:33:54', '1', 'local'),
(1568, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1569, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1570, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1571, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1572, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1573, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1574, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1575, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1576, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1577, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1578, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1579, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1580, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1581, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1582, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1583, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1584, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1585, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1586, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1587, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1588, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1589, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1590, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1591, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1592, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1593, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1594, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1595, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1596, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1597, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1598, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1599, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1600, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1601, 1, 0, '2025-10-30 14:33:55', '1', 'local'),
(1602, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1603, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1604, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1605, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1606, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1607, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1608, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1609, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1610, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1611, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1612, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1613, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1614, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1615, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1616, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1617, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1618, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1619, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1620, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1621, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1622, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1623, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1624, 1, 0, '2025-10-30 14:33:56', '1', 'local'),
(1625, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1626, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1627, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1628, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1629, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1630, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1631, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1632, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1633, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1634, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1635, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1636, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1637, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1638, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1639, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1640, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1641, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1642, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1643, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1644, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1645, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1646, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1647, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1648, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1649, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1650, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1651, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1652, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1653, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1654, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1655, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1656, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1657, 1, 0, '2025-10-30 14:33:57', '1', 'local'),
(1658, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1659, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1660, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1661, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1662, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1663, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1664, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1665, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1666, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1667, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1668, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1669, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1670, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1671, 1, 0, '2025-10-30 14:33:58', '1', 'local'),
(1672, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1673, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1674, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1675, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1676, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1677, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1678, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1679, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1680, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1681, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1682, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1683, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1684, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1685, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1686, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1687, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1688, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1689, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1690, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1691, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1692, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1693, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1694, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1695, 1, 0, '2025-10-30 14:33:59', '1', 'local'),
(1696, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1697, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1698, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1699, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1700, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1701, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1702, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1703, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1704, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1705, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1706, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1707, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1708, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1709, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1710, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1711, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1712, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1713, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1714, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1715, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1716, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1717, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1718, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1719, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1720, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1721, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1722, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1723, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1724, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1725, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1726, 1, 0, '2025-10-30 14:34:00', '1', 'local'),
(1727, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1728, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1729, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1730, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1731, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1732, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1733, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1734, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1735, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1736, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1737, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1738, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1739, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1740, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1741, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1742, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1743, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1744, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1745, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1746, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1747, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1748, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1749, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1750, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1751, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1752, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1753, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1754, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1755, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1756, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1757, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1758, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1759, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1760, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1761, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1762, 1, 0, '2025-10-30 14:34:01', '1', 'local'),
(1763, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1764, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1765, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1766, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1767, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1768, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1769, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1770, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1771, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1772, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1773, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1774, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1775, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1776, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1777, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1778, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1779, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1780, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1781, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1782, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1783, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1784, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1785, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1786, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1787, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1788, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1789, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1790, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1791, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1792, 1, 0, '2025-10-30 14:34:02', '1', 'local'),
(1793, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1794, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1795, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1796, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1797, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1798, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1799, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1800, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1801, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1802, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1803, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1804, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1805, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1806, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1807, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1808, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1809, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1810, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1811, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1812, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1813, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1814, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1815, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1816, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1817, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1818, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1819, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1820, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1821, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1822, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1823, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1824, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1825, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1826, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1827, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1828, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1829, 1, 0, '2025-10-30 14:34:03', '1', 'local'),
(1830, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1831, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1832, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1833, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1834, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1835, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1836, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1837, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1838, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1839, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1840, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1841, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1842, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1843, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1844, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1845, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1846, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1847, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1848, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1849, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1850, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1851, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1852, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1853, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1854, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1855, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1856, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1857, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1858, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1859, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1860, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1861, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1862, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1863, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1864, 1, 0, '2025-10-30 14:34:04', '1', 'local'),
(1865, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1866, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1867, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1868, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1869, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1870, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1871, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1872, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1873, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1874, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1875, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1876, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1877, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1878, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1879, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1880, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1881, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1882, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1883, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1884, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1885, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1886, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1887, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1888, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1889, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1890, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1891, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1892, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1893, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1894, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1895, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1896, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1897, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1898, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1899, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1900, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1901, 1, 0, '2025-10-30 14:34:05', '1', 'local'),
(1902, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1903, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1904, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1905, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1906, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1907, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1908, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1909, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1910, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1911, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1912, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1913, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1914, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1915, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1916, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1917, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1918, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1919, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1920, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1921, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1922, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1923, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1924, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1925, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1926, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1927, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1928, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1929, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1930, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1931, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1932, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1933, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1934, 1, 0, '2025-10-30 14:34:06', '1', 'local'),
(1935, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1936, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1937, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1938, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1939, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1940, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1941, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1942, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1943, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1944, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1945, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1946, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1947, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1948, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1949, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1950, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1951, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1952, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1953, 1, 0, '2025-10-30 14:34:07', '1', 'local'),
(1954, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1955, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1956, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1957, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1958, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1959, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1960, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1961, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1962, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1963, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1964, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1965, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1966, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1967, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1968, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1969, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1970, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1971, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1972, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1973, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1974, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1975, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1976, 1, 0, '2025-10-30 14:34:08', '1', 'local'),
(1977, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1978, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1979, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1980, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1981, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1982, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1983, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1984, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1985, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1986, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1987, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1988, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1989, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1990, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1991, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1992, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1993, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1994, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1995, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1996, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1997, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1998, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(1999, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2000, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2001, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2002, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2003, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2004, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2005, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2006, 1, 0, '2025-10-30 14:34:09', '1', 'local'),
(2007, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2008, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2009, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2010, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2011, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2012, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2013, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2014, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2015, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2016, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2017, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2018, 1, 0, '2025-10-30 14:34:10', '1', 'local'),
(2019, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2020, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2021, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2022, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2023, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2024, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2025, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2026, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2027, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2028, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2029, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2030, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2031, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2032, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2033, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2034, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2035, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2036, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2037, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2038, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2039, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2040, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2041, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2042, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2043, 1, 0, '2025-10-30 14:34:11', '1', 'local'),
(2044, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2045, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2046, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2047, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2048, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2049, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2050, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2051, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2052, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2053, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2054, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2055, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2056, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2057, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2058, 1, 0, '2025-10-30 14:34:12', '1', 'local'),
(2059, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2060, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2061, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2062, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2063, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2064, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2065, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2066, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2067, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2068, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2069, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2070, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2071, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2072, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2073, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2074, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2075, 1, 0, '2025-10-30 14:34:13', '1', 'local'),
(2076, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2077, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2078, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2079, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2080, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2081, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2082, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2083, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2084, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2085, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2086, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2087, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2088, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2089, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2090, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2091, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2092, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2093, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2094, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2095, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2096, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2097, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2098, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2099, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2100, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2101, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2102, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2103, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2104, 1, 0, '2025-10-30 14:34:14', '1', 'local'),
(2105, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2106, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2107, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2108, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2109, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2110, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2111, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2112, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2113, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2114, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2115, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2116, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2117, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2118, 1, 0, '2025-10-30 14:34:15', '1', 'local'),
(2119, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2120, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2121, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2122, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2123, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2124, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2125, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2126, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2127, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2128, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2129, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2130, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2131, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2132, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2133, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2134, 1, 0, '2025-10-30 14:34:16', '1', 'local'),
(2135, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2136, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2137, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2138, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2139, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2140, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2141, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2142, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2143, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2144, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2145, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2146, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2147, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2148, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2149, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2150, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2151, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2152, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2153, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2154, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2155, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2156, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2157, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2158, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2159, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2160, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2161, 1, 0, '2025-10-30 14:34:17', '1', 'local'),
(2162, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2163, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2164, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2165, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2166, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2167, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2168, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2169, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2170, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2171, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2172, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2173, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2174, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2175, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2176, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2177, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2178, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2179, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2180, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2181, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2182, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2183, 1, 0, '2025-10-30 14:34:18', '1', 'local'),
(2184, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2185, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2186, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2187, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2188, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2189, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2190, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2191, 1, 0, '2025-10-30 14:34:19', '1', 'local'),
(2192, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2193, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2194, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2195, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2196, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2197, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2198, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2199, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2200, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2201, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2202, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2203, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2204, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2205, 1, 0, '2025-10-30 14:34:20', '1', 'local'),
(2206, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2207, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2208, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2209, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2210, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2211, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2212, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2213, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2214, 1, 0, '2025-10-30 14:34:21', '1', 'local'),
(2215, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2216, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2217, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2218, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2219, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2220, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2221, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2222, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2223, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2224, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2225, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2226, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2227, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2228, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2229, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2230, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2231, 1, 0, '2025-10-30 14:34:22', '1', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(2232, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2233, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2234, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2235, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2236, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2237, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2238, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2239, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2240, 1, 0, '2025-10-30 14:34:22', '1', 'local'),
(2241, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2242, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2243, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2244, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2245, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2246, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2247, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2248, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2249, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2250, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2251, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2252, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2253, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2254, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2255, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2256, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2257, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2258, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2259, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2260, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2261, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2262, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2263, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2264, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2265, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2266, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2267, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2268, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2269, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2270, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2271, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2272, 1, 0, '2025-10-30 14:34:23', '1', 'local'),
(2273, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2274, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2275, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2276, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2277, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2278, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2279, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2280, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2281, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2282, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2283, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2284, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2285, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2286, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2287, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2288, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2289, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2290, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2291, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2292, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2293, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2294, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2295, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2296, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2297, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2298, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2299, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2300, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2301, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2302, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2303, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2304, 1, 0, '2025-10-30 14:34:24', '1', 'local'),
(2305, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2306, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2307, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2308, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2309, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2310, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2311, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2312, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2313, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2314, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2315, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2316, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2317, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2318, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2319, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2320, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2321, 1, 0, '2025-10-30 14:34:25', '1', 'local'),
(2322, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2323, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2324, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2325, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2326, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2327, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2328, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2329, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2330, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2331, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2332, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2333, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2334, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2335, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2336, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2337, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2338, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2339, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2340, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2341, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2342, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2343, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2344, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2345, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2346, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2347, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2348, 1, 0, '2025-10-30 14:34:26', '1', 'local'),
(2349, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2350, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2351, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2352, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2353, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2354, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2355, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2356, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2357, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2358, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2359, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2360, 1, 0, '2025-10-30 14:34:27', '1', 'local'),
(2361, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2362, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2363, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2364, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2365, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2366, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2367, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2368, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2369, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2370, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2371, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2372, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2373, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2374, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2375, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2376, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2377, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2378, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2379, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2380, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2381, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2382, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2383, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2384, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2385, 1, 0, '2025-10-30 14:34:28', '1', 'local'),
(2386, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2387, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2388, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2389, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2390, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2391, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2392, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2393, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2394, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2395, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2396, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2397, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2398, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2399, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2400, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2401, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2402, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2403, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2404, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2405, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2406, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2407, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2408, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2409, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2410, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2411, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2412, 1, 0, '2025-10-30 14:34:29', '1', 'local'),
(2413, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2414, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2415, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2416, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2417, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2418, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2419, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2420, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2421, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2422, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2423, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2424, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2425, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2426, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2427, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2428, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2429, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2430, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2431, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2432, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2433, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2434, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2435, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2436, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2437, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2438, 1, 0, '2025-10-30 14:34:30', '1', 'local'),
(2439, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2440, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2441, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2442, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2443, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2444, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2445, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2446, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2447, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2448, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2449, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2450, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2451, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2452, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2453, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2454, 1, 0, '2025-10-30 14:34:31', '1', 'local'),
(2455, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2456, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2457, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2458, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2459, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2460, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2461, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2462, 1, 0, '2025-10-30 14:34:32', '1', 'local'),
(2463, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2464, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2465, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2466, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2467, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2468, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2469, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2470, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2471, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2472, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2473, 1, 0, '2025-10-30 14:34:33', '1', 'local'),
(2474, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2475, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2476, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2477, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2478, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2479, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2480, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2481, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2482, 1, 0, '2025-10-30 14:34:34', '1', 'local'),
(2483, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2484, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2485, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2486, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2487, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2488, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2489, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2490, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2491, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2492, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2493, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2494, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2495, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2496, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2497, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2498, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2499, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2500, 1, 0, '2025-10-30 14:34:35', '1', 'local'),
(2501, 1, 0, '2025-10-30 14:34:36', '1', 'local'),
(2502, 1, 0, '2025-10-30 14:34:36', '1', 'local'),
(2503, 1, 0, '2025-10-30 14:34:36', '1', 'local'),
(2504, 1, 0, '2025-10-30 14:34:36', '1', 'local'),
(2505, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2506, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2507, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2508, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2509, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2510, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2511, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2512, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2513, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2514, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2515, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2516, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2517, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2518, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2519, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2520, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2521, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2522, 1, 0, '2025-10-30 14:34:37', '1', 'local'),
(2523, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2524, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2525, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2526, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2527, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2528, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2529, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2530, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2531, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2532, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2533, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2534, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2535, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2536, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2537, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2538, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2539, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2540, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2541, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2542, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2543, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2544, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2545, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2546, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2547, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2548, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2549, 1, 0, '2025-10-30 14:34:38', '1', 'local'),
(2550, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2551, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2552, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2553, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2554, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2555, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2556, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2557, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2558, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2559, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2560, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2561, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2562, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2563, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2564, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2565, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2566, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2567, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2568, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2569, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2570, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2571, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2572, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2573, 1, 0, '2025-10-30 14:34:39', '1', 'local'),
(2574, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2575, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2576, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2577, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2578, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2579, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2580, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2581, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2582, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2583, 1, 0, '2025-10-30 14:34:40', '1', 'local'),
(2584, 1, 0, '2025-10-30 14:34:41', '1', 'local'),
(2585, 1, 0, '2025-10-30 14:34:41', '1', 'local'),
(2586, 1, 0, '2025-10-30 14:34:41', '1', 'local'),
(2587, 1, 0, '2025-10-30 14:34:41', '1', 'local'),
(2588, 1, 0, '2025-10-30 14:34:41', '1', 'local'),
(2589, 1, 0, '2025-10-30 14:34:41', '1', 'local'),
(2590, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2591, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2592, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2593, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2594, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2595, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2596, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2597, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2598, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2599, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2600, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2601, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2602, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2603, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2604, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2605, 1, 0, '2025-10-30 14:34:42', '1', 'local'),
(2606, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2607, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2608, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2609, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2610, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2611, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2612, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2613, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2614, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2615, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2616, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2617, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2618, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2619, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2620, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2621, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2622, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2623, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2624, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2625, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2626, 1, 0, '2025-10-30 14:34:43', '1', 'local'),
(2627, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2628, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2629, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2630, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2631, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2632, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2633, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2634, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2635, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2636, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2637, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2638, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2639, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2640, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2641, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2642, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2643, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2644, 1, 0, '2025-10-30 14:34:44', '1', 'local'),
(2645, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2646, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2647, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2648, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2649, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2650, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2651, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2652, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2653, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2654, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2655, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2656, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2657, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2658, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2659, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2660, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2661, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2662, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2663, 1, 0, '2025-10-30 14:34:45', '1', 'local'),
(2664, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2665, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2666, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2667, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2668, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2669, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2670, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2671, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2672, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2673, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2674, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2675, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2676, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2677, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2678, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2679, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2680, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2681, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2682, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2683, 1, 0, '2025-10-30 14:34:46', '1', 'local'),
(2684, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2685, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2686, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2687, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2688, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2689, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2690, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2691, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2692, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2693, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2694, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2695, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2696, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2697, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2698, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2699, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2700, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2701, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2702, 1, 0, '2025-10-30 14:34:47', '1', 'local'),
(2703, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2704, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2705, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2706, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2707, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2708, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2709, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2710, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2711, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2712, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2713, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2714, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2715, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2716, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2717, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2718, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2719, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2720, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2721, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2722, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2723, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2724, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2725, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2726, 1, 0, '2025-10-30 14:34:48', '1', 'local'),
(2727, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2728, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2729, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2730, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2731, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2732, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2733, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2734, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2735, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2736, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2737, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2738, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2739, 1, 0, '2025-10-30 14:34:49', '1', 'local'),
(2740, 1, 0, '2025-10-30 14:34:50', '1', 'local'),
(2741, 1, 0, '2025-10-30 14:34:50', '1', 'local'),
(2742, 1, 0, '2025-10-30 14:34:50', '1', 'local'),
(2743, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2744, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2745, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2746, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2747, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2748, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2749, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2750, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2751, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2752, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2753, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2754, 1, 0, '2025-10-30 14:34:51', '1', 'local'),
(2755, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2756, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2757, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2758, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2759, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2760, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2761, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2762, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2763, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2764, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2765, 1, 0, '2025-10-30 14:34:52', '1', 'local'),
(2766, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2767, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2768, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2769, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2770, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2771, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2772, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2773, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2774, 1, 0, '2025-10-30 14:34:53', '1', 'local'),
(2775, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2776, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2777, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2778, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2779, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2780, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2781, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2782, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2783, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2784, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2785, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2786, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2787, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2788, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2789, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2790, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2791, 1, 0, '2025-10-30 14:34:54', '1', 'local'),
(2792, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2793, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2794, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2795, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2796, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2797, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2798, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2799, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2800, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2801, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2802, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2803, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2804, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2805, 1, 0, '2025-10-30 14:34:55', '1', 'local'),
(2806, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2807, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2808, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2809, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2810, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2811, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2812, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2813, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2814, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2815, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2816, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2817, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2818, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2819, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2820, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2821, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2822, 1, 0, '2025-10-30 14:34:56', '1', 'local'),
(2823, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2824, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2825, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2826, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2827, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2828, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2829, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2830, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2831, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2832, 1, 0, '2025-10-30 14:34:57', '1', 'local'),
(2833, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2834, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2835, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2836, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2837, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2838, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2839, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2840, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2841, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2842, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2843, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2844, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2845, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2846, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2847, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2848, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2849, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2850, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2851, 1, 0, '2025-10-30 14:34:58', '1', 'local'),
(2852, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2853, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2854, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2855, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2856, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2857, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2858, 1, 0, '2025-10-30 14:34:59', '1', 'local'),
(2859, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2860, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2861, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2862, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2863, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2864, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2865, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2866, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2867, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2868, 1, 0, '2025-10-30 14:35:00', '1', 'local'),
(2869, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2870, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2871, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2872, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2873, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2874, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2875, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2876, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2877, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2878, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2879, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2880, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2881, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2882, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2883, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2884, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2885, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2886, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2887, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2888, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2889, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2890, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2891, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2892, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2893, 1, 0, '2025-10-30 14:35:01', '1', 'local'),
(2894, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2895, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2896, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2897, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2898, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2899, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2900, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2901, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2902, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2903, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2904, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2905, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2906, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2907, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2908, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2909, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2910, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2911, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2912, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2913, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2914, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2915, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2916, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2917, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2918, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2919, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2920, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2921, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2922, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2923, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2924, 1, 0, '2025-10-30 14:35:02', '1', 'local'),
(2925, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2926, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2927, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2928, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2929, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2930, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2931, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2932, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2933, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2934, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2935, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2936, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2937, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2938, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2939, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2940, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2941, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2942, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2943, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2944, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2945, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2946, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2947, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2948, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2949, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2950, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2951, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2952, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2953, 1, 0, '2025-10-30 14:35:03', '1', 'local'),
(2954, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2955, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2956, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2957, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2958, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2959, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2960, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2961, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2962, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2963, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2964, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2965, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2966, 1, 0, '2025-10-30 14:35:04', '1', 'local'),
(2967, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2968, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2969, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2970, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2971, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2972, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2973, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2974, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2975, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2976, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2977, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2978, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2979, 1, 0, '2025-10-30 14:35:05', '1', 'local'),
(2980, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2981, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2982, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2983, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2984, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2985, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2986, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2987, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2988, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2989, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2990, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2991, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2992, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2993, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2994, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2995, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2996, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2997, 1, 0, '2025-10-30 14:35:06', '1', 'local'),
(2998, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(2999, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3000, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3001, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3002, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3003, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3004, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3005, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3006, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3007, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3008, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3009, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3010, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3011, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3012, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3013, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3014, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3015, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3016, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3017, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3018, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3019, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3020, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3021, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3022, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3023, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3024, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3025, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3026, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3027, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3028, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3029, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3030, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3031, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3032, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3033, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3034, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3035, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3036, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3037, 1, 0, '2025-10-30 14:35:07', '1', 'local'),
(3038, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3039, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3040, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3041, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3042, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3043, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3044, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3045, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3046, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3047, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3048, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3049, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3050, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3051, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3052, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3053, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3054, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3055, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3056, 1, 0, '2025-10-30 14:35:08', '1', 'local'),
(3057, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3058, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3059, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3060, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3061, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3062, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3063, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3064, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3065, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3066, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3067, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3068, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3069, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3070, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3071, 1, 0, '2025-10-30 14:35:09', '1', 'local'),
(3072, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3073, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3074, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3075, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3076, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3077, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3078, 1, 0, '2025-10-30 14:35:10', '1', 'local'),
(3079, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3080, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3081, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3082, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3083, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3084, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3085, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3086, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3087, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3088, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3089, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3090, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3091, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3092, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3093, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3094, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3095, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3096, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3097, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3098, 1, 0, '2025-10-30 14:35:11', '1', 'local'),
(3099, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3100, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3101, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3102, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3103, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3104, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3105, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3106, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3107, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3108, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3109, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3110, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3111, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3112, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3113, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3114, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3115, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3116, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3117, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3118, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3119, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3120, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3121, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3122, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3123, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3124, 1, 0, '2025-10-30 14:35:12', '1', 'local'),
(3125, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3126, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3127, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3128, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3129, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3130, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3131, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3132, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3133, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3134, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3135, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3136, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3137, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3138, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3139, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3140, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3141, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3142, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3143, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3144, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3145, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3146, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3147, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3148, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3149, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3150, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3151, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3152, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3153, 1, 0, '2025-10-30 14:35:13', '1', 'local'),
(3154, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3155, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3156, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3157, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3158, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3159, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3160, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3161, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3162, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3163, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3164, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3165, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3166, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3167, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3168, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3169, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3170, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3171, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3172, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3173, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3174, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3175, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3176, 1, 0, '2025-10-30 14:35:14', '1', 'local'),
(3177, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3178, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3179, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3180, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3181, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3182, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3183, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3184, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3185, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3186, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3187, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3188, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3189, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3190, 1, 0, '2025-10-30 14:35:15', '1', 'local'),
(3191, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3192, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3193, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3194, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3195, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3196, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3197, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3198, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3199, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3200, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3201, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3202, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3203, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3204, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3205, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3206, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3207, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3208, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3209, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3210, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3211, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3212, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3213, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3214, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3215, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3216, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3217, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3218, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3219, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3220, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3221, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3222, 1, 0, '2025-10-30 14:35:16', '1', 'local'),
(3223, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3224, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3225, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3226, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3227, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3228, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3229, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3230, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3231, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3232, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3233, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3234, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3235, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3236, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3237, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3238, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3239, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3240, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3241, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3242, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3243, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3244, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3245, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3246, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3247, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3248, 1, 0, '2025-10-30 14:35:17', '1', 'local'),
(3249, 1, 0, '2025-10-30 14:35:18', '1', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(3250, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3251, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3252, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3253, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3254, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3255, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3256, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3257, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3258, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3259, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3260, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3261, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3262, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3263, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3264, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3265, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3266, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3267, 1, 0, '2025-10-30 14:35:18', '1', 'local'),
(3268, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3269, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3270, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3271, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3272, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3273, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3274, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3275, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3276, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3277, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3278, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3279, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3280, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3281, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3282, 1, 0, '2025-10-30 14:35:19', '1', 'local'),
(3283, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3284, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3285, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3286, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3287, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3288, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3289, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3290, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3291, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3292, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3293, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3294, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3295, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3296, 1, 0, '2025-10-30 14:35:20', '1', 'local'),
(3297, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3298, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3299, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3300, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3301, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3302, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3303, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3304, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3305, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3306, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3307, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3308, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3309, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3310, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3311, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3312, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3313, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3314, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3315, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3316, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3317, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3318, 1, 0, '2025-10-30 14:35:21', '1', 'local'),
(3319, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3320, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3321, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3322, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3323, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3324, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3325, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3326, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3327, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3328, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3329, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3330, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3331, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3332, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3333, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3334, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3335, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3336, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3337, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3338, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3339, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3340, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3341, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3342, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3343, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3344, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3345, 1, 0, '2025-10-30 14:35:22', '1', 'local'),
(3346, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3347, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3348, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3349, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3350, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3351, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3352, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3353, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3354, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3355, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3356, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3357, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3358, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3359, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3360, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3361, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3362, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3363, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3364, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3365, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3366, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3367, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3368, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3369, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3370, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3371, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3372, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3373, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3374, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3375, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3376, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3377, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3378, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3379, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3380, 1, 0, '2025-10-30 14:35:23', '1', 'local'),
(3381, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3382, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3383, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3384, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3385, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3386, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3387, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3388, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3389, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3390, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3391, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3392, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3393, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3394, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3395, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3396, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3397, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3398, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3399, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3400, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3401, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3402, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3403, 1, 0, '2025-10-30 14:35:24', '1', 'local'),
(3404, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3405, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3406, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3407, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3408, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3409, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3410, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3411, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3412, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3413, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3414, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3415, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3416, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3417, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3418, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3419, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3420, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3421, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3422, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3423, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3424, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3425, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3426, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3427, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3428, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3429, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3430, 1, 0, '2025-10-30 14:35:25', '1', 'local'),
(3431, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3432, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3433, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3434, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3435, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3436, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3437, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3438, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3439, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3440, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3441, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3442, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3443, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3444, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3445, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3446, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3447, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3448, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3449, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3450, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3451, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3452, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3453, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3454, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3455, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3456, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3457, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3458, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3459, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3460, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3461, 1, 0, '2025-10-30 14:35:26', '1', 'local'),
(3462, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3463, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3464, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3465, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3466, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3467, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3468, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3469, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3470, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3471, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3472, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3473, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3474, 1, 0, '2025-10-30 14:35:27', '1', 'local'),
(3475, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3476, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3477, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3478, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3479, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3480, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3481, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3482, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3483, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3484, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3485, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3486, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3487, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3488, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3489, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3490, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3491, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3492, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3493, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3494, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3495, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3496, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3497, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3498, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3499, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3500, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3501, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3502, 1, 0, '2025-10-30 14:35:28', '1', 'local'),
(3503, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3504, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3505, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3506, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3507, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3508, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3509, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3510, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3511, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3512, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3513, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3514, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3515, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3516, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3517, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3518, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3519, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3520, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3521, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3522, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3523, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3524, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3525, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3526, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3527, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3528, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3529, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3530, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3531, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3532, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3533, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3534, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3535, 1, 0, '2025-10-30 14:35:29', '1', 'local'),
(3536, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3537, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3538, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3539, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3540, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3541, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3542, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3543, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3544, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3545, 1, 0, '2025-10-30 14:35:30', '1', 'local'),
(3546, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3547, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3548, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3549, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3550, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3551, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3552, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3553, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3554, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3555, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3556, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3557, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3558, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3559, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3560, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3561, 1, 0, '2025-10-30 14:35:31', '1', 'local'),
(3562, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3563, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3564, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3565, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3566, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3567, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3568, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3569, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3570, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3571, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3572, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3573, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3574, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3575, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3576, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3577, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3578, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3579, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3580, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3581, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3582, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3583, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3584, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3585, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3586, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3587, 1, 0, '2025-10-30 14:35:32', '1', 'local'),
(3588, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3589, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3590, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3591, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3592, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3593, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3594, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3595, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3596, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3597, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3598, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3599, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3600, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3601, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3602, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3603, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3604, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3605, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3606, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3607, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3608, 1, 0, '2025-10-30 14:35:33', '1', 'local'),
(3609, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3610, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3611, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3612, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3613, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3614, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3615, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3616, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3617, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3618, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3619, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3620, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3621, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3622, 1, 0, '2025-10-30 14:35:34', '1', 'local'),
(3623, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3624, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3625, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3626, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3627, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3628, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3629, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3630, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3631, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3632, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3633, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3634, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3635, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3636, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3637, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3638, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3639, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3640, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3641, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3642, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3643, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3644, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3645, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3646, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3647, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3648, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3649, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3650, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3651, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3652, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3653, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3654, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3655, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3656, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3657, 1, 0, '2025-10-30 14:35:35', '1', 'local'),
(3658, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3659, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3660, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3661, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3662, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3663, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3664, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3665, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3666, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3667, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3668, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3669, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3670, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3671, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3672, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3673, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3674, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3675, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3676, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3677, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3678, 1, 0, '2025-10-30 14:35:36', '1', 'local'),
(3679, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3680, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3681, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3682, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3683, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3684, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3685, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3686, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3687, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3688, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3689, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3690, 1, 0, '2025-10-30 14:35:37', '1', 'local'),
(3691, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3692, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3693, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3694, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3695, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3696, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3697, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3698, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3699, 1, 0, '2025-10-30 14:35:38', '1', 'local'),
(3700, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3701, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3702, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3703, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3704, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3705, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3706, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3707, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3708, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3709, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3710, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3711, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3712, 1, 0, '2025-10-30 14:35:39', '1', 'local'),
(3713, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3714, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3715, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3716, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3717, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3718, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3719, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3720, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3721, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3722, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3723, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3724, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3725, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3726, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3727, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3728, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3729, 1, 0, '2025-10-30 14:35:40', '1', 'local'),
(3730, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3731, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3732, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3733, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3734, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3735, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3736, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3737, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3738, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3739, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3740, 1, 0, '2025-10-30 14:35:41', '1', 'local'),
(3741, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3742, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3743, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3744, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3745, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3746, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3747, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3748, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3749, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3750, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3751, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3752, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3753, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3754, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3755, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3756, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3757, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3758, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3759, 1, 0, '2025-10-30 14:35:42', '1', 'local'),
(3760, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3761, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3762, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3763, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3764, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3765, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3766, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3767, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3768, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3769, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3770, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3771, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3772, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3773, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3774, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3775, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3776, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3777, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3778, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3779, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3780, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3781, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3782, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3783, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3784, 1, 0, '2025-10-30 14:35:43', '1', 'local'),
(3785, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3786, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3787, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3788, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3789, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3790, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3791, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3792, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3793, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3794, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3795, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3796, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3797, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3798, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3799, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3800, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3801, 1, 0, '2025-10-30 14:35:44', '1', 'local'),
(3802, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3803, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3804, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3805, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3806, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3807, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3808, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3809, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3810, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3811, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3812, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3813, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3814, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3815, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3816, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3817, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3818, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3819, 1, 0, '2025-10-30 14:35:45', '1', 'local'),
(3820, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3821, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3822, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3823, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3824, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3825, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3826, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3827, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3828, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3829, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3830, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3831, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3832, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3833, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3834, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3835, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3836, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3837, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3838, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3839, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3840, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3841, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3842, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3843, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3844, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3845, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3846, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3847, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3848, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3849, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3850, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3851, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3852, 1, 0, '2025-10-30 14:35:46', '1', 'local'),
(3853, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3854, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3855, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3856, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3857, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3858, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3859, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3860, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3861, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3862, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3863, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3864, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3865, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3866, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3867, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3868, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3869, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3870, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3871, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3872, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3873, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3874, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3875, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3876, 1, 0, '2025-10-30 14:35:47', '1', 'local'),
(3877, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3878, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3879, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3880, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3881, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3882, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3883, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3884, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3885, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3886, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3887, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3888, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3889, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3890, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3891, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3892, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3893, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3894, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3895, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3896, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3897, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3898, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3899, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3900, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3901, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3902, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3903, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3904, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3905, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3906, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3907, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3908, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3909, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3910, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3911, 1, 0, '2025-10-30 14:35:48', '1', 'local'),
(3912, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3913, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3914, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3915, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3916, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3917, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3918, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3919, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3920, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3921, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3922, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3923, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3924, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3925, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3926, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3927, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3928, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3929, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3930, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3931, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3932, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3933, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3934, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3935, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3936, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3937, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3938, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3939, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3940, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3941, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3942, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3943, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3944, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3945, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3946, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3947, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3948, 1, 0, '2025-10-30 14:35:49', '1', 'local'),
(3949, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3950, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3951, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3952, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3953, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3954, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3955, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3956, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3957, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3958, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3959, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3960, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3961, 1, 0, '2025-10-30 14:35:50', '1', 'local'),
(3962, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3963, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3964, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3965, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3966, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3967, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3968, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3969, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3970, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3971, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3972, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3973, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3974, 1, 0, '2025-10-30 14:35:51', '1', 'local'),
(3975, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3976, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3977, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3978, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3979, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3980, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3981, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3982, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3983, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3984, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3985, 1, 0, '2025-10-30 14:35:52', '1', 'local'),
(3986, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3987, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3988, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3989, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3990, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3991, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3992, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3993, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3994, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3995, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3996, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3997, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3998, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(3999, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4000, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4001, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4002, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4003, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4004, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4005, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4006, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4007, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4008, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4009, 1, 0, '2025-10-30 14:35:53', '1', 'local'),
(4010, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4011, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4012, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4013, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4014, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4015, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4016, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4017, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4018, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4019, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4020, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4021, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4022, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4023, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4024, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4025, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4026, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4027, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4028, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4029, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4030, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4031, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4032, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4033, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4034, 1, 0, '2025-10-30 14:35:54', '1', 'local'),
(4035, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4036, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4037, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4038, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4039, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4040, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4041, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4042, 1, 0, '2025-10-30 14:35:55', '1', 'local'),
(4043, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4044, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4045, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4046, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4047, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4048, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4049, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4050, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4051, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4052, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4053, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4054, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4055, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4056, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4057, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4058, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4059, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4060, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4061, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4062, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4063, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4064, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4065, 1, 0, '2025-10-30 14:35:56', '1', 'local'),
(4066, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4067, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4068, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4069, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4070, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4071, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4072, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4073, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4074, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4075, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4076, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4077, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4078, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4079, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4080, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4081, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4082, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4083, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4084, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4085, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4086, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4087, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4088, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4089, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4090, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4091, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4092, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4093, 1, 0, '2025-10-30 14:35:57', '1', 'local'),
(4094, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4095, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4096, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4097, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4098, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4099, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4100, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4101, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4102, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4103, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4104, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4105, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4106, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4107, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4108, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4109, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4110, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4111, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4112, 1, 0, '2025-10-30 14:35:58', '1', 'local'),
(4113, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4114, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4115, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4116, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4117, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4118, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4119, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4120, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4121, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4122, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4123, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4124, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4125, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4126, 1, 0, '2025-10-30 14:35:59', '1', 'local'),
(4127, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4128, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4129, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4130, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4131, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4132, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4133, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4134, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4135, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4136, 1, 0, '2025-10-30 14:36:00', '1', 'local'),
(4137, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4138, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4139, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4140, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4141, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4142, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4143, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4144, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4145, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4146, 1, 0, '2025-10-30 14:36:01', '1', 'local'),
(4147, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4148, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4149, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4150, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4151, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4152, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4153, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4154, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4155, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4156, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4157, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4158, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4159, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4160, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4161, 1, 0, '2025-10-30 14:36:02', '1', 'local'),
(4162, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4163, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4164, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4165, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4166, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4167, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4168, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4169, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4170, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4171, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4172, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4173, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4174, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4175, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4176, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4177, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4178, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4179, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4180, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4181, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4182, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4183, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4184, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4185, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4186, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4187, 1, 0, '2025-10-30 14:36:03', '1', 'local'),
(4188, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4189, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4190, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4191, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4192, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4193, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4194, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4195, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4196, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4197, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4198, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4199, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4200, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4201, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4202, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4203, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4204, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4205, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4206, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4207, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4208, 1, 0, '2025-10-30 14:36:04', '1', 'local'),
(4209, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4210, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4211, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4212, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4213, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4214, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4215, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4216, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4217, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4218, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4219, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4220, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4221, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4222, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4223, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4224, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4225, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4226, 1, 0, '2025-10-30 14:36:05', '1', 'local'),
(4227, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4228, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4229, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4230, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4231, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4232, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4233, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4234, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4235, 1, 0, '2025-10-30 14:36:06', '1', 'local'),
(4236, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4237, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4238, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4239, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4240, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4241, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4242, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4243, 1, 0, '2025-10-30 14:36:07', '1', 'local'),
(4244, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4245, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4246, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4247, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4248, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4249, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4250, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4251, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4252, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4253, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4254, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4255, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4256, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4257, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4258, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4259, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4260, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4261, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4262, 1, 0, '2025-10-30 14:36:08', '1', 'local'),
(4263, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4264, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4265, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4266, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4267, 1, 0, '2025-10-30 14:36:09', '1', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(4268, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4269, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4270, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4271, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4272, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4273, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4274, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4275, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4276, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4277, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4278, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4279, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4280, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4281, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4282, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4283, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4284, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4285, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4286, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4287, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4288, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4289, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4290, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4291, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4292, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4293, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4294, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4295, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4296, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4297, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4298, 1, 0, '2025-10-30 14:36:09', '1', 'local'),
(4299, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4300, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4301, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4302, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4303, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4304, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4305, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4306, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4307, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4308, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4309, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4310, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4311, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4312, 1, 0, '2025-10-30 14:36:10', '1', 'local'),
(4313, 1, 0, '2025-10-30 14:36:11', '1', 'local'),
(4314, 1, 0, '2025-10-30 14:36:11', '1', 'local'),
(4315, 1, 0, '2025-10-30 14:36:11', '1', 'local'),
(4316, 1, 0, '2025-10-30 14:36:11', '1', 'local'),
(4317, 1, 0, '2025-10-30 14:36:11', '1', 'local'),
(4318, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4319, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4320, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4321, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4322, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4323, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4324, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4325, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4326, 1, 0, '2025-10-30 14:36:12', '1', 'local'),
(4327, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4328, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4329, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4330, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4331, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4332, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4333, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4334, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4335, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4336, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4337, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4338, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4339, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4340, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4341, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4342, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4343, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4344, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4345, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4346, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4347, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4348, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4349, 1, 0, '2025-10-30 14:36:13', '1', 'local'),
(4350, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4351, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4352, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4353, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4354, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4355, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4356, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4357, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4358, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4359, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4360, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4361, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4362, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4363, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4364, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4365, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4366, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4367, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4368, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4369, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4370, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4371, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4372, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4373, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4374, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4375, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4376, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4377, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4378, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4379, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4380, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4381, 1, 0, '2025-10-30 14:36:14', '1', 'local'),
(4382, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4383, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4384, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4385, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4386, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4387, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4388, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4389, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4390, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4391, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4392, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4393, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4394, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4395, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4396, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4397, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4398, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4399, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4400, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4401, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4402, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4403, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4404, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4405, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4406, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4407, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4408, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4409, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4410, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4411, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4412, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4413, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4414, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4415, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4416, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4417, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4418, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4419, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4420, 1, 0, '2025-10-30 14:36:15', '1', 'local'),
(4421, 1, 0, '2025-10-30 14:36:16', '1', 'local'),
(4422, 1, 0, '2025-10-30 14:36:16', '1', 'local'),
(4423, 1, 0, '2025-10-30 14:36:16', '1', 'local'),
(4424, 1, 0, '2025-10-30 14:36:16', '1', 'local'),
(4425, 1, 0, '2025-10-30 14:36:16', '1', 'local'),
(4426, 1, 0, '2025-10-30 14:36:16', '1', 'local'),
(4427, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4428, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4429, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4430, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4431, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4432, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4433, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4434, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4435, 1, 0, '2025-10-30 14:36:17', '1', 'local'),
(4436, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4437, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4438, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4439, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4440, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4441, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4442, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4443, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4444, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4445, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4446, 1, 0, '2025-10-30 14:36:18', '1', 'local'),
(4447, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4448, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4449, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4450, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4451, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4452, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4453, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4454, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4455, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4456, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4457, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4458, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4459, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4460, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4461, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4462, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4463, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4464, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4465, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4466, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4467, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4468, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4469, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4470, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4471, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4472, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4473, 1, 0, '2025-10-30 14:36:19', '1', 'local'),
(4474, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4475, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4476, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4477, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4478, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4479, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4480, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4481, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4482, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4483, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4484, 1, 0, '2025-10-30 14:36:20', '1', 'local'),
(4485, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4486, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4487, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4488, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4489, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4490, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4491, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4492, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4493, 1, 0, '2025-10-30 14:36:21', '1', 'local'),
(4494, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4495, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4496, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4497, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4498, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4499, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4500, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4501, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4502, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4503, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4504, 1, 0, '2025-10-30 14:36:22', '1', 'local'),
(4505, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4506, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4507, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4508, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4509, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4510, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4511, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4512, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4513, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4514, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4515, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4516, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4517, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4518, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4519, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4520, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4521, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4522, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4523, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4524, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4525, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4526, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4527, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4528, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4529, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4530, 1, 0, '2025-10-30 14:36:23', '1', 'local'),
(4531, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4532, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4533, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4534, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4535, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4536, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4537, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4538, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4539, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4540, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4541, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4542, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4543, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4544, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4545, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4546, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4547, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4548, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4549, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4550, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4551, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4552, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4553, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4554, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4555, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4556, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4557, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4558, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4559, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4560, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4561, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4562, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4563, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4564, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4565, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4566, 1, 0, '2025-10-30 14:36:24', '1', 'local'),
(4567, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4568, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4569, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4570, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4571, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4572, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4573, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4574, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4575, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4576, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4577, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4578, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4579, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4580, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4581, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4582, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4583, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4584, 1, 0, '2025-10-30 14:36:25', '1', 'local'),
(4585, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4586, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4587, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4588, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4589, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4590, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4591, 1, 0, '2025-10-30 14:36:26', '1', 'local'),
(4592, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4593, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4594, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4595, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4596, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4597, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4598, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4599, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4600, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4601, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4602, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4603, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4604, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4605, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4606, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4607, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4608, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4609, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4610, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4611, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4612, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4613, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4614, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4615, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4616, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4617, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4618, 1, 0, '2025-10-30 14:36:27', '1', 'local'),
(4619, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4620, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4621, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4622, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4623, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4624, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4625, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4626, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4627, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4628, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4629, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4630, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4631, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4632, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4633, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4634, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4635, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4636, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4637, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4638, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4639, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4640, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4641, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4642, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4643, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4644, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4645, 1, 0, '2025-10-30 14:36:28', '1', 'local'),
(4646, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4647, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4648, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4649, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4650, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4651, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4652, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4653, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4654, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4655, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4656, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4657, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4658, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4659, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4660, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4661, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4662, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4663, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4664, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4665, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4666, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4667, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4668, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4669, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4670, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4671, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4672, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4673, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4674, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4675, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4676, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4677, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4678, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4679, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4680, 1, 0, '2025-10-30 14:36:29', '1', 'local'),
(4681, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4682, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4683, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4684, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4685, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4686, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4687, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4688, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4689, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4690, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4691, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4692, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4693, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4694, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4695, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4696, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4697, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4698, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4699, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4700, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4701, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4702, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4703, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4704, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4705, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4706, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4707, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4708, 1, 0, '2025-10-30 14:36:30', '1', 'local'),
(4709, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4710, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4711, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4712, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4713, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4714, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4715, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4716, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4717, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4718, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4719, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4720, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4721, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4722, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4723, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4724, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4725, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4726, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4727, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4728, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4729, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4730, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4731, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4732, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4733, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4734, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4735, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4736, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4737, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4738, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4739, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4740, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4741, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4742, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4743, 1, 0, '2025-10-30 14:36:31', '1', 'local'),
(4744, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4745, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4746, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4747, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4748, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4749, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4750, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4751, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4752, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4753, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4754, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4755, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4756, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4757, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4758, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4759, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4760, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4761, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4762, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4763, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4764, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4765, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4766, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4767, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4768, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4769, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4770, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4771, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4772, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4773, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4774, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4775, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4776, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4777, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4778, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4779, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4780, 1, 0, '2025-10-30 14:36:32', '1', 'local'),
(4781, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4782, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4783, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4784, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4785, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4786, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4787, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4788, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4789, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4790, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4791, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4792, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4793, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4794, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4795, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4796, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4797, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4798, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4799, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4800, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4801, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4802, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4803, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4804, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4805, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4806, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4807, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4808, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4809, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4810, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4811, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4812, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4813, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4814, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4815, 1, 0, '2025-10-30 14:36:33', '1', 'local'),
(4816, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4817, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4818, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4819, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4820, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4821, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4822, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4823, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4824, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4825, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4826, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4827, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4828, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4829, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4830, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4831, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4832, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4833, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4834, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4835, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4836, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4837, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4838, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4839, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4840, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4841, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4842, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4843, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4844, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4845, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4846, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4847, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4848, 1, 0, '2025-10-30 14:36:34', '1', 'local'),
(4849, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4850, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4851, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4852, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4853, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4854, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4855, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4856, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4857, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4858, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4859, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4860, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4861, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4862, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4863, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4864, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4865, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4866, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4867, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4868, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4869, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4870, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4871, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4872, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4873, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4874, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4875, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4876, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4877, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4878, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4879, 1, 0, '2025-10-30 14:36:35', '1', 'local'),
(4880, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4881, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4882, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4883, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4884, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4885, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4886, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4887, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4888, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4889, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4890, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4891, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4892, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4893, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4894, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4895, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4896, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4897, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4898, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4899, 1, 0, '2025-10-30 14:36:36', '1', 'local'),
(4900, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4901, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4902, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4903, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4904, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4905, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4906, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4907, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4908, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4909, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4910, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4911, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4912, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4913, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4914, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4915, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4916, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4917, 1, 0, '2025-10-30 14:36:37', '1', 'local'),
(4918, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4919, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4920, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4921, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4922, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4923, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4924, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4925, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4926, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4927, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4928, 1, 0, '2025-10-30 14:36:38', '1', 'local'),
(4929, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4930, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4931, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4932, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4933, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4934, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4935, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4936, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4937, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4938, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4939, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4940, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4941, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4942, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4943, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4944, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4945, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4946, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4947, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4948, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4949, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4950, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4951, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4952, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4953, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4954, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4955, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4956, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4957, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4958, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4959, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4960, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4961, 1, 0, '2025-10-30 14:36:39', '1', 'local'),
(4962, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4963, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4964, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4965, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4966, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4967, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4968, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4969, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4970, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4971, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4972, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4973, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4974, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4975, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4976, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4977, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4978, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4979, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4980, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4981, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4982, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4983, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4984, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4985, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4986, 1, 0, '2025-10-30 14:36:40', '1', 'local'),
(4987, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4988, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4989, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4990, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4991, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4992, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4993, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4994, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4995, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4996, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4997, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4998, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(4999, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5000, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5001, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5002, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5003, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5004, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5005, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5006, 1, 0, '2025-10-30 14:36:41', '1', 'local'),
(5007, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5008, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5009, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5010, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5011, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5012, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5013, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5014, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5015, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5016, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5017, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5018, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5019, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5020, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5021, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5022, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5023, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5024, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5025, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5026, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5027, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5028, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5029, 1, 0, '2025-10-30 14:36:42', '1', 'local'),
(5030, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5031, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5032, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5033, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5034, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5035, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5036, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5037, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5038, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5039, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5040, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5041, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5042, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5043, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5044, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5045, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5046, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5047, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5048, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5049, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5050, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5051, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5052, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5053, 1, 0, '2025-10-30 14:36:43', '1', 'local'),
(5054, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5055, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5056, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5057, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5058, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5059, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5060, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5061, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5062, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5063, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5064, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5065, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5066, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5067, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5068, 1, 0, '2025-10-30 14:36:44', '1', 'local'),
(5069, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5070, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5071, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5072, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5073, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5074, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5075, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5076, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5077, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5078, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5079, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5080, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5081, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5082, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5083, 1, 0, '2025-10-30 14:36:45', '1', 'local'),
(5084, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5085, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5086, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5087, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5088, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5089, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5090, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5091, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5092, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5093, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5094, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5095, 1, 0, '2025-10-30 14:36:46', '1', 'local'),
(5096, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5097, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5098, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5099, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5100, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5101, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5102, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5103, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5104, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5105, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5106, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5107, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5108, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5109, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5110, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5111, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5112, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5113, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5114, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5115, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5116, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5117, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5118, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5119, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5120, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5121, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5122, 1, 0, '2025-10-30 14:36:47', '1', 'local'),
(5123, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5124, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5125, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5126, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5127, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5128, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5129, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5130, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5131, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5132, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5133, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5134, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5135, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5136, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5137, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5138, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5139, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5140, 1, 0, '2025-10-30 14:36:48', '1', 'local'),
(5141, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5142, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5143, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5144, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5145, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5146, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5147, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5148, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5149, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5150, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5151, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5152, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5153, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5154, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5155, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5156, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5157, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5158, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5159, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5160, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5161, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5162, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5163, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5164, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5165, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5166, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5167, 1, 0, '2025-10-30 14:36:49', '1', 'local'),
(5168, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5169, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5170, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5171, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5172, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5173, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5174, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5175, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5176, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5177, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5178, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5179, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5180, 1, 0, '2025-10-30 14:36:50', '1', 'local'),
(5181, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5182, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5183, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5184, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5185, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5186, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5187, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5188, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5189, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5190, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5191, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5192, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5193, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5194, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5195, 1, 0, '2025-10-30 14:36:51', '1', 'local'),
(5196, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5197, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5198, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5199, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5200, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5201, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5202, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5203, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5204, 1, 0, '2025-10-30 14:36:52', '1', 'local'),
(5205, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5206, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5207, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5208, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5209, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5210, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5211, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5212, 1, 0, '2025-10-30 14:36:53', '1', 'local'),
(5213, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5214, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5215, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5216, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5217, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5218, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5219, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5220, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5221, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5222, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5223, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5224, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5225, 1, 0, '2025-10-30 14:36:54', '1', 'local'),
(5226, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5227, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5228, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5229, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5230, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5231, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5232, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5233, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5234, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5235, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5236, 1, 0, '2025-10-30 14:36:55', '1', 'local'),
(5237, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5238, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5239, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5240, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5241, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5242, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5243, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5244, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5245, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5246, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5247, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5248, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5249, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5250, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5251, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5252, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5253, 1, 0, '2025-10-30 14:36:56', '1', 'local'),
(5254, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5255, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5256, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5257, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5258, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5259, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5260, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5261, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5262, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5263, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5264, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5265, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5266, 1, 0, '2025-10-30 14:36:57', '1', 'local'),
(5267, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5268, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5269, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5270, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5271, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5272, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5273, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5274, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5275, 1, 0, '2025-10-30 14:36:58', '1', 'local'),
(5276, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5277, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5278, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5279, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5280, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5281, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5282, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5283, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5284, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5285, 1, 0, '2025-10-30 14:36:59', '1', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(5286, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5287, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5288, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5289, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5290, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5291, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5292, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5293, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5294, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5295, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5296, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5297, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5298, 1, 0, '2025-10-30 14:36:59', '1', 'local'),
(5299, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5300, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5301, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5302, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5303, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5304, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5305, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5306, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5307, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5308, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5309, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5310, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5311, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5312, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5313, 1, 0, '2025-10-30 14:37:00', '1', 'local'),
(5314, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5315, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5316, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5317, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5318, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5319, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5320, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5321, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5322, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5323, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5324, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5325, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5326, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5327, 1, 0, '2025-10-30 14:37:01', '1', 'local'),
(5328, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5329, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5330, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5331, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5332, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5333, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5334, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5335, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5336, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5337, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5338, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5339, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5340, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5341, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5342, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5343, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5344, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5345, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5346, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5347, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5348, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5349, 1, 0, '2025-10-30 14:37:02', '1', 'local'),
(5350, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5351, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5352, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5353, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5354, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5355, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5356, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5357, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5358, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5359, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5360, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5361, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5362, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5363, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5364, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5365, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5366, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5367, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5368, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5369, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5370, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5371, 1, 0, '2025-10-30 14:37:03', '1', 'local'),
(5372, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5373, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5374, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5375, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5376, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5377, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5378, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5379, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5380, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5381, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5382, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5383, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5384, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5385, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5386, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5387, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5388, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5389, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5390, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5391, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5392, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5393, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5394, 1, 0, '2025-10-30 14:37:04', '1', 'local'),
(5395, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5396, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5397, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5398, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5399, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5400, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5401, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5402, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5403, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5404, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5405, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5406, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5407, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5408, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5409, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5410, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5411, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5412, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5413, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5414, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5415, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5416, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5417, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5418, 1, 0, '2025-10-30 14:37:05', '1', 'local'),
(5419, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5420, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5421, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5422, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5423, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5424, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5425, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5426, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5427, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5428, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5429, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5430, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5431, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5432, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5433, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5434, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5435, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5436, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5437, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5438, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5439, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5440, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5441, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5442, 1, 0, '2025-10-30 14:37:06', '1', 'local'),
(5443, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5444, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5445, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5446, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5447, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5448, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5449, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5450, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5451, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5452, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5453, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5454, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5455, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5456, 1, 0, '2025-10-30 14:37:07', '1', 'local'),
(5457, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5458, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5459, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5460, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5461, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5462, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5463, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5464, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5465, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5466, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5467, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5468, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5469, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5470, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5471, 1, 0, '2025-10-30 14:37:08', '1', 'local'),
(5472, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5473, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5474, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5475, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5476, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5477, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5478, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5479, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5480, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5481, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5482, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5483, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5484, 1, 0, '2025-10-30 14:37:09', '1', 'local'),
(5485, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5486, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5487, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5488, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5489, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5490, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5491, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5492, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5493, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5494, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5495, 1, 0, '2025-10-30 14:37:10', '1', 'local'),
(5496, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5497, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5498, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5499, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5500, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5501, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5502, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5503, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5504, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5505, 1, 0, '2025-10-30 14:37:11', '1', 'local'),
(5506, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5507, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5508, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5509, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5510, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5511, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5512, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5513, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5514, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5515, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5516, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5517, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5518, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5519, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5520, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5521, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5522, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5523, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5524, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5525, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5526, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5527, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5528, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5529, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5530, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5531, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5532, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5533, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5534, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5535, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5536, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5537, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5538, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5539, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5540, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5541, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5542, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5543, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5544, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5545, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5546, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5547, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5548, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5549, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5550, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5551, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5552, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5553, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5554, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5555, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5556, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5557, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5558, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5559, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5560, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5561, 1, 0, '2025-10-30 14:37:12', '1', 'local'),
(5562, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5563, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5564, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5565, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5566, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5567, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5568, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5569, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5570, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5571, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5572, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5573, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5574, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5575, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5576, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5577, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5578, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5579, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5580, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5581, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5582, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5583, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5584, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5585, 1, 0, '2025-10-30 14:37:13', '1', 'local'),
(5586, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5587, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5588, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5589, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5590, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5591, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5592, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5593, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5594, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5595, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5596, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5597, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5598, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5599, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5600, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5601, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5602, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5603, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5604, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5605, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5606, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5607, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5608, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5609, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5610, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5611, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5612, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5613, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5614, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5615, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5616, 1, 0, '2025-10-30 14:37:14', '1', 'local'),
(5617, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5618, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5619, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5620, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5621, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5622, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5623, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5624, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5625, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5626, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5627, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5628, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5629, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5630, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5631, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5632, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5633, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5634, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5635, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5636, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5637, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5638, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5639, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5640, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5641, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5642, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5643, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5644, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5645, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5646, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5647, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5648, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5649, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5650, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5651, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5652, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5653, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5654, 1, 0, '2025-10-30 14:37:15', '1', 'local'),
(5655, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5656, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5657, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5658, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5659, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5660, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5661, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5662, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5663, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5664, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5665, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5666, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5667, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5668, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5669, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5670, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5671, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5672, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5673, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5674, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5675, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5676, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5677, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5678, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5679, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5680, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5681, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5682, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5683, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5684, 1, 0, '2025-10-30 14:37:16', '1', 'local'),
(5685, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5686, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5687, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5688, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5689, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5690, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5691, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5692, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5693, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5694, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5695, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5696, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5697, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5698, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5699, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5700, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5701, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5702, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5703, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5704, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5705, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5706, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5707, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5708, 1, 0, '2025-10-30 14:37:17', '1', 'local'),
(5709, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5710, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5711, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5712, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5713, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5714, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5715, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5716, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5717, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5718, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5719, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5720, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5721, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5722, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5723, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5724, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5725, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5726, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5727, 1, 0, '2025-10-30 14:37:18', '1', 'local'),
(5728, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5729, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5730, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5731, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5732, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5733, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5734, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5735, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5736, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5737, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5738, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5739, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5740, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5741, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5742, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5743, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5744, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5745, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5746, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5747, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5748, 1, 0, '2025-10-30 14:37:19', '1', 'local'),
(5749, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5750, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5751, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5752, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5753, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5754, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5755, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5756, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5757, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5758, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5759, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5760, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5761, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5762, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5763, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5764, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5765, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5766, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5767, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5768, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5769, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5770, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5771, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5772, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5773, 1, 0, '2025-10-30 14:37:20', '1', 'local'),
(5774, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5775, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5776, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5777, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5778, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5779, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5780, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5781, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5782, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5783, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5784, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5785, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5786, 1, 0, '2025-10-30 14:37:21', '1', 'local'),
(5787, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5788, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5789, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5790, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5791, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5792, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5793, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5794, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5795, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5796, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5797, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5798, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5799, 1, 0, '2025-10-30 14:37:22', '1', 'local'),
(5800, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5801, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5802, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5803, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5804, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5805, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5806, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5807, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5808, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5809, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5810, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5811, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5812, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5813, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5814, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5815, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5816, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5817, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5818, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5819, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5820, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5821, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5822, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5823, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5824, 1, 0, '2025-10-30 14:37:23', '1', 'local'),
(5825, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5826, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5827, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5828, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5829, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5830, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5831, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5832, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5833, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5834, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5835, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5836, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5837, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5838, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5839, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5840, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5841, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5842, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5843, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5844, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5845, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5846, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5847, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5848, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5849, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5850, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5851, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5852, 1, 0, '2025-10-30 14:37:24', '1', 'local'),
(5853, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5854, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5855, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5856, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5857, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5858, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5859, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5860, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5861, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5862, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5863, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5864, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5865, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5866, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5867, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5868, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5869, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5870, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5871, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5872, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5873, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5874, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5875, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5876, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5877, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5878, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5879, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5880, 1, 0, '2025-10-30 14:37:25', '1', 'local'),
(5881, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5882, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5883, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5884, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5885, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5886, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5887, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5888, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5889, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5890, 1, 0, '2025-10-30 14:37:26', '1', 'local'),
(5891, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5892, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5893, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5894, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5895, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5896, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5897, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5898, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5899, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5900, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5901, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5902, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5903, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5904, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5905, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5906, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5907, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5908, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5909, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5910, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5911, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5912, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5913, 1, 0, '2025-10-30 14:37:27', '1', 'local'),
(5914, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5915, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5916, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5917, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5918, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5919, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5920, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5921, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5922, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5923, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5924, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5925, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5926, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5927, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5928, 1, 0, '2025-10-30 14:37:28', '1', 'local'),
(5929, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5930, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5931, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5932, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5933, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5934, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5935, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5936, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5937, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5938, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5939, 1, 0, '2025-10-30 14:37:29', '1', 'local'),
(5940, 1, 0, '2025-10-30 14:37:30', '1', 'local'),
(5941, 1, 0, '2025-10-30 14:37:30', '1', 'local'),
(5942, 1, 0, '2025-10-30 14:37:30', '1', 'local'),
(5943, 1, 0, '2025-10-30 14:37:30', '1', 'local'),
(5944, 1, 0, '2025-10-30 14:37:30', '1', 'local'),
(5945, 1, 0, '2025-10-30 14:37:30', '1', 'local'),
(5946, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5947, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5948, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5949, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5950, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5951, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5952, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5953, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5954, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5955, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5956, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5957, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5958, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5959, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5960, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5961, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5962, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5963, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5964, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5965, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5966, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5967, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5968, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5969, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5970, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5971, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5972, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5973, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5974, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5975, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5976, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5977, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5978, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5979, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5980, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5981, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5982, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5983, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5984, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5985, 1, 0, '2025-10-30 14:37:31', '1', 'local'),
(5986, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5987, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5988, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5989, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5990, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5991, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5992, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5993, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5994, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5995, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5996, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5997, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5998, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(5999, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(6000, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(6001, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(6002, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(6003, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(6004, 1, 0, '2025-10-30 14:37:32', '1', 'local'),
(6005, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6006, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6007, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6008, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6009, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6010, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6011, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6012, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6013, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6014, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6015, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6016, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6017, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6018, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6019, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6020, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6021, 1, 0, '2025-10-30 14:37:33', '1', 'local'),
(6022, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6023, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6024, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6025, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6026, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6027, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6028, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6029, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6030, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6031, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6032, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6033, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6034, 1, 0, '2025-10-30 14:37:34', '1', 'local'),
(6035, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6036, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6037, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6038, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6039, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6040, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6041, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6042, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6043, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6044, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6045, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6046, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6047, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6048, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6049, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6050, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6051, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6052, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6053, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6054, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6055, 1, 0, '2025-10-30 14:37:35', '1', 'local'),
(6056, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6057, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6058, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6059, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6060, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6061, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6062, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6063, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6064, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6065, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6066, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6067, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6068, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6069, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6070, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6071, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6072, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6073, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6074, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6075, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6076, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6077, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6078, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6079, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6080, 1, 0, '2025-10-30 14:37:36', '1', 'local'),
(6081, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6082, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6083, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6084, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6085, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6086, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6087, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6088, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6089, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6090, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6091, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6092, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6093, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6094, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6095, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6096, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6097, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6098, 1, 0, '2025-10-30 14:37:37', '1', 'local'),
(6099, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6100, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6101, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6102, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6103, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6104, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6105, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6106, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6107, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6108, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6109, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6110, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6111, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6112, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6113, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6114, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6115, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6116, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6117, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6118, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6119, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6120, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6121, 1, 0, '2025-10-30 14:37:38', '1', 'local'),
(6122, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6123, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6124, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6125, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6126, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6127, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6128, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6129, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6130, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6131, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6132, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6133, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6134, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6135, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6136, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6137, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6138, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6139, 1, 0, '2025-10-30 14:37:39', '1', 'local'),
(6140, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6141, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6142, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6143, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6144, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6145, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6146, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6147, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6148, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6149, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6150, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6151, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6152, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6153, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6154, 1, 0, '2025-10-30 14:37:40', '1', 'local'),
(6155, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6156, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6157, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6158, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6159, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6160, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6161, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6162, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6163, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6164, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6165, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6166, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6167, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6168, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6169, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6170, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6171, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6172, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6173, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6174, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6175, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6176, 1, 0, '2025-10-30 14:37:41', '1', 'local'),
(6177, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6178, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6179, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6180, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6181, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6182, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6183, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6184, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6185, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6186, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6187, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6188, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6189, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6190, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6191, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6192, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6193, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6194, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6195, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6196, 1, 0, '2025-10-30 14:37:42', '1', 'local'),
(6197, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6198, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6199, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6200, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6201, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6202, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6203, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6204, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6205, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6206, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6207, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6208, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6209, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6210, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6211, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6212, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6213, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6214, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6215, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6216, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6217, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6218, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6219, 1, 0, '2025-10-30 14:37:43', '1', 'local'),
(6220, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6221, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6222, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6223, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6224, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6225, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6226, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6227, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6228, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6229, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6230, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6231, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6232, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6233, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6234, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6235, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6236, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6237, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6238, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6239, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6240, 1, 0, '2025-10-30 14:37:44', '1', 'local'),
(6241, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6242, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6243, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6244, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6245, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6246, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6247, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6248, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6249, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6250, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6251, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6252, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6253, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6254, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6255, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6256, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6257, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6258, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6259, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6260, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6261, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6262, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6263, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6264, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6265, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6266, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6267, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6268, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6269, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6270, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6271, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6272, 1, 0, '2025-10-30 14:37:45', '1', 'local'),
(6273, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6274, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6275, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6276, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6277, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6278, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6279, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6280, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6281, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6282, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6283, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6284, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6285, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6286, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6287, 1, 0, '2025-10-30 14:37:46', '1', 'local'),
(6288, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6289, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6290, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6291, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6292, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6293, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6294, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6295, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6296, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6297, 1, 0, '2025-10-30 14:37:47', '1', 'local'),
(6298, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6299, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6300, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6301, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6302, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6303, 1, 0, '2025-10-30 14:37:48', '1', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(6304, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6305, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6306, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6307, 1, 0, '2025-10-30 14:37:48', '1', 'local'),
(6308, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6309, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6310, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6311, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6312, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6313, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6314, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6315, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6316, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6317, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6318, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6319, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6320, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6321, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6322, 1, 0, '2025-10-30 14:37:49', '1', 'local'),
(6323, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6324, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6325, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6326, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6327, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6328, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6329, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6330, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6331, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6332, 1, 0, '2025-10-30 14:37:50', '1', 'local'),
(6333, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6334, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6335, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6336, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6337, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6338, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6339, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6340, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6341, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6342, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6343, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6344, 1, 0, '2025-10-30 14:37:51', '1', 'local'),
(6345, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6346, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6347, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6348, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6349, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6350, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6351, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6352, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6353, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6354, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6355, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6356, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6357, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6358, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6359, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6360, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6361, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6362, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6363, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6364, 1, 0, '2025-10-30 14:37:52', '1', 'local'),
(6365, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6366, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6367, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6368, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6369, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6370, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6371, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6372, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6373, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6374, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6375, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6376, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6377, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6378, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6379, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6380, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6381, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6382, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6383, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6384, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6385, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6386, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6387, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6388, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6389, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6390, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6391, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6392, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6393, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6394, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6395, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6396, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6397, 1, 0, '2025-10-30 14:37:53', '1', 'local'),
(6398, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6399, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6400, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6401, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6402, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6403, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6404, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6405, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6406, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6407, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6408, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6409, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6410, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6411, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6412, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6413, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6414, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6415, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6416, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6417, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6418, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6419, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6420, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6421, 1, 0, '2025-10-30 14:37:54', '1', 'local'),
(6422, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6423, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6424, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6425, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6426, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6427, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6428, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6429, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6430, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6431, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6432, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6433, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6434, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6435, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6436, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6437, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6438, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6439, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6440, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6441, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6442, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6443, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6444, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6445, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6446, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6447, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6448, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6449, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6450, 1, 0, '2025-10-30 14:37:55', '1', 'local'),
(6451, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6452, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6453, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6454, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6455, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6456, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6457, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6458, 1, 0, '2025-10-30 14:37:56', '1', 'local'),
(6459, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6460, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6461, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6462, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6463, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6464, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6465, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6466, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6467, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6468, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6469, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6470, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6471, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6472, 1, 0, '2025-10-30 14:37:57', '1', 'local'),
(6473, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6474, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6475, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6476, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6477, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6478, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6479, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6480, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6481, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6482, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6483, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6484, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6485, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6486, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6487, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6488, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6489, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6490, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6491, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6492, 1, 0, '2025-10-30 14:37:58', '1', 'local'),
(6493, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6494, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6495, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6496, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6497, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6498, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6499, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6500, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6501, 1, 0, '2025-10-30 14:37:59', '1', 'local'),
(6502, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6503, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6504, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6505, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6506, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6507, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6508, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6509, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6510, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6511, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6512, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6513, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6514, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6515, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6516, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6517, 1, 0, '2025-10-30 14:38:00', '1', 'local'),
(6518, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6519, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6520, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6521, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6522, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6523, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6524, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6525, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6526, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6527, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6528, 1, 0, '2025-10-30 14:38:01', '1', 'local'),
(6529, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6530, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6531, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6532, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6533, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6534, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6535, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6536, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6537, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6538, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6539, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6540, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6541, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6542, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6543, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6544, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6545, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6546, 1, 0, '2025-10-30 14:38:02', '1', 'local'),
(6547, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6548, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6549, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6550, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6551, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6552, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6553, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6554, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6555, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6556, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6557, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6558, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6559, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6560, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6561, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6562, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6563, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6564, 1, 0, '2025-10-30 14:38:03', '1', 'local'),
(6565, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6566, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6567, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6568, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6569, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6570, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6571, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6572, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6573, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6574, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6575, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6576, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6577, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6578, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6579, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6580, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6581, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6582, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6583, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6584, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6585, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6586, 1, 0, '2025-10-30 14:38:04', '1', 'local'),
(6587, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6588, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6589, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6590, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6591, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6592, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6593, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6594, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6595, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6596, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6597, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6598, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6599, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6600, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6601, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6602, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6603, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6604, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6605, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6606, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6607, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6608, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6609, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6610, 1, 0, '2025-10-30 14:38:05', '1', 'local'),
(6611, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6612, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6613, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6614, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6615, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6616, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6617, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6618, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6619, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6620, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6621, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6622, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6623, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6624, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6625, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6626, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6627, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6628, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6629, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6630, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6631, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6632, 1, 0, '2025-10-30 14:38:06', '1', 'local'),
(6633, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6634, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6635, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6636, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6637, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6638, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6639, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6640, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6641, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6642, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6643, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6644, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6645, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6646, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6647, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6648, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6649, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6650, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6651, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6652, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6653, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6654, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6655, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6656, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6657, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6658, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6659, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6660, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6661, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6662, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6663, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6664, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6665, 1, 0, '2025-10-30 14:38:07', '1', 'local'),
(6666, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6667, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6668, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6669, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6670, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6671, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6672, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6673, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6674, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6675, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6676, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6677, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6678, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6679, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6680, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6681, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6682, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6683, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6684, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6685, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6686, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6687, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6688, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6689, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6690, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6691, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6692, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6693, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6694, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6695, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6696, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6697, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6698, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6699, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6700, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6701, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6702, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6703, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6704, 1, 0, '2025-10-30 14:38:08', '1', 'local'),
(6705, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6706, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6707, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6708, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6709, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6710, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6711, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6712, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6713, 1, 0, '2025-10-30 14:38:09', '1', 'local'),
(6714, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6715, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6716, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6717, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6718, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6719, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6720, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6721, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6722, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6723, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6724, 1, 0, '2025-10-30 14:38:10', '1', 'local'),
(6725, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6726, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6727, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6728, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6729, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6730, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6731, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6732, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6733, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6734, 1, 0, '2025-10-30 14:38:11', '1', 'local'),
(6735, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6736, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6737, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6738, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6739, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6740, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6741, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6742, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6743, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6744, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6745, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6746, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6747, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6748, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6749, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6750, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6751, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6752, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6753, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6754, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6755, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6756, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6757, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6758, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6759, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6760, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6761, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6762, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6763, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6764, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6765, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6766, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6767, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6768, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6769, 1, 0, '2025-10-30 14:38:12', '1', 'local'),
(6770, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6771, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6772, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6773, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6774, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6775, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6776, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6777, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6778, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6779, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6780, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6781, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6782, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6783, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6784, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6785, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6786, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6787, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6788, 1, 0, '2025-10-30 14:38:13', '1', 'local'),
(6789, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6790, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6791, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6792, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6793, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6794, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6795, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6796, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6797, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6798, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6799, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6800, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6801, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6802, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6803, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6804, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6805, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6806, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6807, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6808, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6809, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6810, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6811, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6812, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6813, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6814, 1, 0, '2025-10-30 14:38:14', '1', 'local'),
(6815, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6816, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6817, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6818, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6819, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6820, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6821, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6822, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6823, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6824, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6825, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6826, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6827, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6828, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6829, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6830, 1, 0, '2025-10-30 14:38:15', '1', 'local'),
(6831, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6832, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6833, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6834, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6835, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6836, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6837, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6838, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6839, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6840, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6841, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6842, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6843, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6844, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6845, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6846, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6847, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6848, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6849, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6850, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6851, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6852, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6853, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6854, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6855, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6856, 1, 0, '2025-10-30 14:38:16', '1', 'local'),
(6857, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6858, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6859, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6860, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6861, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6862, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6863, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6864, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6865, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6866, 1, 0, '2025-10-30 14:38:17', '1', 'local'),
(6867, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6868, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6869, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6870, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6871, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6872, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6873, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6874, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6875, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6876, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6877, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6878, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6879, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6880, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6881, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6882, 1, 0, '2025-10-30 14:38:18', '1', 'local'),
(6883, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6884, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6885, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6886, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6887, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6888, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6889, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6890, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6891, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6892, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6893, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6894, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6895, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6896, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6897, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6898, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6899, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6900, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6901, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6902, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6903, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6904, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6905, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6906, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6907, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6908, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6909, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6910, 1, 0, '2025-10-30 14:38:19', '1', 'local'),
(6911, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6912, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6913, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6914, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6915, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6916, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6917, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6918, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6919, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6920, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6921, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6922, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6923, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6924, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6925, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6926, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6927, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6928, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6929, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6930, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6931, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6932, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6933, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6934, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6935, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6936, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6937, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6938, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6939, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6940, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6941, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6942, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6943, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6944, 1, 0, '2025-10-30 14:38:20', '1', 'local'),
(6945, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6946, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6947, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6948, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6949, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6950, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6951, 1, 0, '2025-10-30 14:38:21', '1', 'local'),
(6952, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6953, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6954, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6955, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6956, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6957, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6958, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6959, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6960, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6961, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6962, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6963, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6964, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6965, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6966, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6967, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6968, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6969, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6970, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6971, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6972, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6973, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6974, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6975, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6976, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6977, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6978, 1, 0, '2025-10-30 14:38:22', '1', 'local'),
(6979, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6980, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6981, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6982, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6983, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6984, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6985, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6986, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6987, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6988, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6989, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6990, 1, 0, '2025-10-30 14:38:23', '1', 'local'),
(6991, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6992, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6993, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6994, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6995, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6996, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6997, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6998, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(6999, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7000, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7001, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7002, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7003, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7004, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7005, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7006, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7007, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7008, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7009, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7010, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7011, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7012, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7013, 1, 0, '2025-10-30 14:38:24', '1', 'local'),
(7014, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7015, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7016, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7017, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7018, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7019, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7020, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7021, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7022, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7023, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7024, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7025, 1, 0, '2025-10-30 14:38:25', '1', 'local'),
(7026, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7027, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7028, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7029, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7030, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7031, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7032, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7033, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7034, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7035, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7036, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7037, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7038, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7039, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7040, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7041, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7042, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7043, 1, 0, '2025-10-30 14:38:26', '1', 'local'),
(7044, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7045, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7046, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7047, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7048, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7049, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7050, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7051, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7052, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7053, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7054, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7055, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7056, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7057, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7058, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7059, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7060, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7061, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7062, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7063, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7064, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7065, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7066, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7067, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7068, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7069, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7070, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7071, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7072, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7073, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7074, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7075, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7076, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7077, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7078, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7079, 1, 0, '2025-10-30 14:38:27', '1', 'local'),
(7080, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7081, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7082, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7083, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7084, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7085, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7086, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7087, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7088, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7089, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7090, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7091, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7092, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7093, 1, 0, '2025-10-30 14:38:28', '1', 'local'),
(7094, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7095, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7096, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7097, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7098, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7099, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7100, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7101, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7102, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7103, 1, 0, '2025-10-30 14:38:29', '1', 'local'),
(7104, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7105, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7106, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7107, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7108, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7109, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7110, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7111, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7112, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7113, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7114, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7115, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7116, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7117, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7118, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7119, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7120, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7121, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7122, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7123, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7124, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7125, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7126, 1, 0, '2025-10-30 14:38:30', '1', 'local'),
(7127, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7128, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7129, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7130, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7131, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7132, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7133, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7134, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7135, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7136, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7137, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7138, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7139, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7140, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7141, 1, 0, '2025-10-30 14:38:31', '1', 'local'),
(7142, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7143, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7144, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7145, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7146, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7147, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7148, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7149, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7150, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7151, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7152, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7153, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7154, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7155, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7156, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7157, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7158, 1, 0, '2025-10-30 14:38:32', '1', 'local'),
(7159, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7160, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7161, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7162, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7163, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7164, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7165, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7166, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7167, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7168, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7169, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7170, 1, 0, '2025-10-30 14:38:33', '1', 'local'),
(7171, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7172, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7173, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7174, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7175, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7176, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7177, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7178, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7179, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7180, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7181, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7182, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7183, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7184, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7185, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7186, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7187, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7188, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7189, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7190, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7191, 1, 0, '2025-10-30 14:38:34', '1', 'local'),
(7192, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7193, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7194, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7195, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7196, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7197, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7198, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7199, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7200, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7201, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7202, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7203, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7204, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7205, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7206, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7207, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7208, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7209, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7210, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7211, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7212, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7213, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7214, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7215, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7216, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7217, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7218, 1, 0, '2025-10-30 14:38:35', '1', 'local'),
(7219, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7220, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7221, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7222, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7223, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7224, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7225, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7226, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7227, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7228, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7229, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7230, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7231, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7232, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7233, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7234, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7235, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7236, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7237, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7238, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7239, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7240, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7241, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7242, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7243, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7244, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7245, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7246, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7247, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7248, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7249, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7250, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7251, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7252, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7253, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7254, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7255, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7256, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7257, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7258, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7259, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7260, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7261, 1, 0, '2025-10-30 14:38:36', '1', 'local'),
(7262, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7263, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7264, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7265, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7266, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7267, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7268, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7269, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7270, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7271, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7272, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7273, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7274, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7275, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7276, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7277, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7278, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7279, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7280, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7281, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7282, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7283, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7284, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7285, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7286, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7287, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7288, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7289, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7290, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7291, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7292, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7293, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7294, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7295, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7296, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7297, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7298, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7299, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7300, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7301, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7302, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7303, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7304, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7305, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7306, 1, 0, '2025-10-30 14:38:37', '1', 'local'),
(7307, NULL, 4246, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7308, NULL, 4491, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7309, NULL, 4194, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7310, NULL, 8981, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7311, NULL, 3966, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7312, NULL, 4853, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7313, NULL, 6596, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7314, NULL, 7595, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7315, NULL, 6524, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7316, NULL, 1090, '2025-11-06 04:00:00', 'preparacion', 'local'),
(7317, NULL, 8261, '2025-11-06 04:00:00', 'preparacion', 'local');
INSERT INTO `orden` (`id`, `id_cliente`, `nro_orden`, `fecha`, `status`, `tipo`) VALUES
(7389, 114, 62002100, '2026-03-05 21:52:13', 'en cocina', 'delivery'),
(7390, 114, 68736100, '2026-03-05 21:58:04', 'en cocina', 'delivery'),
(7391, 114, 86624300, '2026-03-05 22:03:08', 'en cocina', 'delivery'),
(7392, 114, 77912100, '2026-03-05 22:04:00', 'en cocina', 'delivery'),
(7393, 114, 19272100, '2026-03-05 22:06:24', 'en cocina', 'delivery');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_mesa`
--

CREATE TABLE `orden_mesa` (
  `id` int NOT NULL,
  `id_orden` int NOT NULL,
  `id_mesa` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `orden_mesa`
--

INSERT INTO `orden_mesa` (`id`, `id_orden`, `id_mesa`) VALUES
(1, 80, 1),
(2, 81, 3),
(3, 90, 7),
(4, 91, 8),
(5, 117, 3),
(6, 118, 3),
(7, 119, 3),
(14, 126, 3),
(15, 127, 3),
(16, 128, 1),
(17, 129, 3),
(18, 130, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id` int NOT NULL,
  `id_metodo_pago` int NOT NULL,
  `monto` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tasa` float NOT NULL,
  `comprobante` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `referencia` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`id`, `id_metodo_pago`, `monto`, `fecha`, `tasa`, `comprobante`, `referencia`, `status`) VALUES
(50, 3, 796.16, '2025-07-07 14:08:50', 111.42, 'cap.jpg', '2569', 1),
(51, 12, 8.88, '2025-07-07 14:11:23', 111.42, 'cap.jpg', '1456', 1),
(52, 3, 836.55, '2025-08-09 15:53:03', 112.83, 'cap.jpg', '7841', 1),
(53, 3, 758.71, '2025-07-09 19:21:51', 113.75, 'cap.jpg', '1247', 1),
(54, 3, 535.76, '2025-07-09 19:28:52', 113.75, 'cap.jpg', '7896', 1),
(55, 3, 197.93, '2025-07-09 20:49:13', 113.75, 'cap.jpg', '2998', 1),
(56, 11, 147.88, '2025-07-10 14:46:48', 113.75, 'cap.jpg', '6484', 1),
(64, 3, 2340.28, '2025-07-16 15:23:56', 116.82, 'cap.jpg', '8484', 1),
(70, 3, 673.49, '2025-07-25 14:21:42', 121.35, 'cap.jpg', '59595', 1),
(71, 3, 916.92, '2025-08-06 12:51:57', 128.24, 'cap.jpg', '59595', 1),
(72, 3, 818.17, '2025-08-06 12:57:59', 128.24, 'cap.jpg', '1891', 1),
(73, 3, 1636.34, '2025-08-06 13:10:04', 128.24, 'cap.jpg', '5494', 1),
(74, 3, 83.36, '2025-08-06 13:24:44', 128.24, 'cap.jpg', '995', 1),
(75, 3, 166.71, '2025-08-06 13:26:44', 128.24, 'cap.jpg', '13123', 1),
(76, 3, 1295.22, '2025-08-06 13:28:11', 128.24, 'cap.jpg', '1323', 1),
(77, 11, 916.92, '2025-08-06 13:35:00', 128.24, 'cap.jpg', '49489', 1),
(78, 3, 734.79, '2025-08-06 13:48:31', 128.24, 'cap.jpg', '81981', 1),
(79, 3, 855.36, '2025-08-06 14:04:46', 128.24, 'cap.jpg', '2313', 1),
(80, 3, 743.79, '2025-08-06 14:06:41', 128.24, 'cap.jpg', '58948', 1),
(81, 3, 223.14, '2025-08-06 14:19:23', 128.24, 'cap.jpg', '9595', 1),
(82, 3, 954.11, '2025-08-06 14:21:35', 128.24, 'cap.jpg', '9595', 1),
(83, 3, 83.36, '2025-08-06 14:35:31', 128.24, 'cap.jpg', '8962', 1),
(84, 3, 165.43, '2025-08-06 14:37:43', 128.24, 'cap.jpg', '48648', 1),
(85, 11, 1140.05, '2025-08-06 14:38:35', 128.24, 'cap.jpg', '9780', 1),
(87, 3, 1241.13, '2025-08-09 12:16:53', 131.12, 'cap.jpg', '59595', 1),
(88, 3, 936.93, '2025-08-09 12:27:27', 131.12, 'cap.jpg', '8984', 1),
(89, 3, 836.55, '2025-08-09 13:16:22', 131.12, 'cap.jpg', '9595', 1),
(90, 3, 168.83, '2025-08-09 13:20:45', 131.12, 'cap.jpg', '9445', 1),
(91, 3, 655.6, '2025-08-09 13:24:45', 131.12, 'cap.jpg', '994', 1),
(92, 3, 1000, '2025-08-12 13:03:42', 132.3, 'cap.jpg', '6262', 1),
(93, 11, 985, '2025-08-12 13:03:43', 132.3, 'cap.jpg', '69292', 1),
(101, 3, 20, '2025-08-14 14:34:04', 134.48, 'cap.jpg', '9594', 1),
(105, 3, 1000, '2025-08-20 13:03:17', 138.13, 'cap.jpg', '6484', 1),
(106, 3, 800, '2025-08-20 13:04:12', 138.13, 'cap.jpg', '94884', 1),
(145, 1, 200, '2025-10-24 19:48:36', 1, NULL, 'REF-RESERVA-001', 1),
(146, 1, 116, '2025-10-24 19:48:36', 1, NULL, 'REF-001', 1),
(147, 1, 200, '2025-10-24 19:49:21', 1, NULL, 'REF-RESERVA-001', 1),
(148, 1, 116, '2025-10-24 19:49:21', 1, NULL, 'REF-001', 1),
(149, 1, 200, '2025-10-24 19:49:44', 1, NULL, 'REF-RESERVA-001', 1),
(150, 1, 116, '2025-10-24 19:49:44', 1, NULL, 'REF-001', 1),
(152, 1, 200, '2025-10-24 19:49:56', 1, NULL, 'REF-RESERVA-001', 1),
(153, 1, 116, '2025-10-24 19:49:56', 1, NULL, 'REF-001', 1),
(155, 1, 200, '2025-10-24 19:50:27', 1, NULL, 'REF-RESERVA-001', 1),
(156, 1, 116, '2025-10-24 19:50:27', 1, NULL, 'REF-001', 1),
(158, 1, 200, '2025-10-24 19:50:52', 1, NULL, 'REF-RESERVA-001', 1),
(159, 1, 116, '2025-10-24 19:50:52', 1, NULL, 'REF-001', 1),
(161, 1, 200, '2025-10-24 19:57:57', 1, NULL, 'REF-RESERVA-001', 1),
(162, 1, 116, '2025-10-24 19:57:57', 1, NULL, 'REF-001', 1),
(164, 1, 200, '2025-10-24 19:58:09', 1, NULL, 'REF-RESERVA-001', 1),
(165, 1, 116, '2025-10-24 19:58:09', 1, NULL, 'REF-001', 1),
(166, 1, 200, '2025-10-26 18:01:16', 1, NULL, 'REF-RESERVA-001', 1),
(167, 1, 116, '2025-10-26 18:01:16', 1, NULL, 'REF-001', 1),
(169, 1, 200, '2025-10-26 18:02:17', 1, NULL, 'REF-RESERVA-001', 1),
(170, 1, 116, '2025-10-26 18:02:17', 1, NULL, 'REF-001', 1),
(172, 1, 200, '2025-10-26 18:07:05', 1, NULL, 'REF-RESERVA-001', 1),
(173, 1, 116, '2025-10-26 18:07:05', 1, NULL, 'REF-001', 1),
(175, 1, 200, '2025-10-26 18:09:31', 1, NULL, 'REF-RESERVA-001', 1),
(176, 1, 116, '2025-10-26 18:09:31', 1, NULL, 'REF-001', 1),
(178, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(179, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(180, 1, 200, '2025-11-06 03:33:19', 1, NULL, 'REF-RESERVA-001', 1),
(181, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(183, 1, 200, '2025-11-06 03:34:11', 1, NULL, 'REF-RESERVA-001', 1),
(184, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(186, 1, 200, '2025-11-06 03:34:31', 1, NULL, 'REF-RESERVA-001', 1),
(187, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(189, 1, 200, '2025-11-06 03:35:44', 1, NULL, 'REF-RESERVA-001', 1),
(190, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(192, 1, 200, '2025-11-06 03:49:17', 1, NULL, 'REF-RESERVA-001', 1),
(193, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(195, 1, 200, '2025-11-06 03:50:47', 1, NULL, 'REF-RESERVA-001', 1),
(196, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(198, 1, 200, '2025-11-06 04:10:19', 1, NULL, 'REF-RESERVA-001', 1),
(199, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(201, 1, 200, '2025-11-06 04:10:44', 1, NULL, 'REF-RESERVA-001', 1),
(202, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(204, 1, 200, '2025-11-06 04:12:33', 1, NULL, 'REF-RESERVA-001', 1),
(205, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(207, 1, 200, '2025-11-06 04:13:35', 1, NULL, 'REF-RESERVA-001', 1),
(208, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(210, 1, 200, '2025-11-06 04:15:19', 1, NULL, 'REF-RESERVA-001', 1),
(211, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(213, 1, 200, '2025-11-06 04:17:45', 1, NULL, 'REF-RESERVA-001', 1),
(214, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(216, 1, 200, '2025-11-06 04:18:04', 1, NULL, 'REF-RESERVA-001', 1),
(217, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(219, 1, 200, '2025-11-06 04:19:26', 1, NULL, 'REF-RESERVA-001', 1),
(220, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(222, 1, 200, '2025-11-06 04:21:22', 1, NULL, 'REF-RESERVA-001', 1),
(223, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(225, 1, 200, '2025-11-06 04:22:45', 1, NULL, 'REF-RESERVA-001', 1),
(226, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(228, 1, 200, '2025-11-06 04:23:52', 1, NULL, 'REF-RESERVA-001', 1),
(229, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(230, 1, 200, '2025-11-06 04:24:46', 1, NULL, 'REF-RESERVA-001', 1),
(231, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(232, 1, 200, '2025-11-06 04:24:53', 1, NULL, 'REF-RESERVA-001', 1),
(233, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(235, 1, 200, '2025-11-06 04:25:15', 1, NULL, 'REF-RESERVA-001', 1),
(236, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(238, 1, 200, '2025-11-06 04:26:09', 1, NULL, 'REF-RESERVA-001', 1),
(239, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(241, 1, 200, '2025-11-06 04:26:52', 1, NULL, 'REF-RESERVA-001', 1),
(242, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(244, 1, 200, '2025-11-06 04:46:37', 1, NULL, 'REF-RESERVA-001', 1),
(245, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(247, 1, 200, '2025-11-06 04:47:20', 1, NULL, 'REF-RESERVA-001', 1),
(248, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(250, 1, 200, '2025-11-06 04:49:52', 1, NULL, 'REF-RESERVA-001', 1),
(251, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(253, 1, 200, '2025-11-06 04:50:16', 1, NULL, 'REF-RESERVA-001', 1),
(254, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(256, 1, 200, '2025-11-06 04:50:38', 1, NULL, 'REF-RESERVA-001', 1),
(257, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(259, 1, 200, '2025-11-06 04:51:02', 1, NULL, 'REF-RESERVA-001', 1),
(260, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(262, 1, 200, '2025-11-06 06:01:43', 1, NULL, 'REF-RESERVA-001', 1),
(263, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(265, 1, 200, '2025-11-06 11:45:16', 1, NULL, 'REF-RESERVA-001', 1),
(266, 1, 116, '2025-11-06 00:00:00', 1, NULL, 'REF-001', 1),
(269, 1, 200, '2025-11-11 19:21:07', 1, NULL, 'REF-RESERVA-001', 1),
(270, 1, 116, '2025-11-11 00:00:00', 1, NULL, 'REF-001', 1),
(272, 1, 200, '2025-11-11 19:21:29', 1, NULL, 'REF-RESERVA-001', 1),
(273, 1, 116, '2025-11-11 00:00:00', 1, NULL, 'REF-001', 1),
(275, 1, 200, '2025-11-11 22:42:31', 1, NULL, 'REF-RESERVA-001', 1),
(276, 1, 116, '2025-11-11 00:00:00', 1, NULL, 'REF-001', 1),
(278, 1, 200, '2026-03-03 22:33:53', 1, NULL, 'REF-RESERVA-001', 1),
(279, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(281, 1, 200, '2026-03-03 22:34:33', 1, NULL, 'REF-RESERVA-001', 1),
(282, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(284, 1, 200, '2026-03-03 22:38:06', 1, NULL, 'REF-RESERVA-001', 1),
(285, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(287, 1, 200, '2026-03-03 22:38:16', 1, NULL, 'REF-RESERVA-001', 1),
(288, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(290, 1, 200, '2026-03-03 22:38:33', 1, NULL, 'REF-RESERVA-001', 1),
(291, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(293, 1, 200, '2026-03-03 22:52:02', 1, NULL, 'REF-RESERVA-001', 1),
(294, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(296, 1, 200, '2026-03-03 23:00:20', 1, NULL, 'REF-RESERVA-001', 1),
(297, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(299, 1, 200, '2026-03-03 23:41:28', 1, NULL, 'REF-RESERVA-001', 1),
(300, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(302, 1, 200, '2026-03-03 23:47:22', 1, NULL, 'REF-RESERVA-001', 1),
(303, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1),
(305, 1, 200, '2026-03-03 23:55:23', 1, NULL, 'REF-RESERVA-001', 1),
(306, 1, 116, '2026-03-03 00:00:00', 1, NULL, 'REF-001', 1);

--
-- Disparadores `pagos`
--
DELIMITER $$
CREATE TRIGGER `pagos_AFTER_INSERT` AFTER INSERT ON `pagos` FOR EACH ROW BEGIN
	 DECLARE metodo VARCHAR(25);
    DECLARE tasa_movimiento FLOAT;

    -- Obtener nombre del método de pago
    SELECT nombre 
    INTO metodo
    FROM metodo_pago
    WHERE id = NEW.id_metodo_pago;

    -- Determinar la tasa según el método de pago
    IF metodo IN ('Transferencia', 'Pago Movil', 'Efectivo') THEN
        SET tasa_movimiento = NEW.tasa;
    ELSE
        SET tasa_movimiento = 1;
    END IF;

    -- Insertar en movimientos_capital
    INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
    VALUES (
        NEW.monto, 
        CONCAT('Ingreso por ', metodo), 
        NOW(),
        tasa_movimiento
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos_entrada_materia_prima`
--

CREATE TABLE `pagos_entrada_materia_prima` (
  `id` int NOT NULL,
  `id_metodo_pago` int NOT NULL,
  `id_entrada` int NOT NULL,
  `tasa` float NOT NULL DEFAULT '1',
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `precio_compra` float NOT NULL,
  `comprobante` varchar(500) NOT NULL,
  `referencia` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pagos_entrada_materia_prima`
--

INSERT INTO `pagos_entrada_materia_prima` (`id`, `id_metodo_pago`, `id_entrada`, `tasa`, `fecha`, `precio_compra`, `comprobante`, `referencia`) VALUES
(42, 3, 85, 171.85, '2025-09-25 20:16:15', 1500, 'cap.jpg', '48484'),
(43, 11, 86, 197.25, '2025-10-14 10:55:45', 342.34, 'sharadas.jpg', 'trhf'),
(44, 4, 154, 427.93, '2026-03-05 17:27:45', 1, 'cerrar.png', '123123123123'),
(45, 4, 155, 427.93, '2026-03-05 17:51:14', 1.11, 'cerrar.png', '123123123123');

--
-- Disparadores `pagos_entrada_materia_prima`
--
DELIMITER $$
CREATE TRIGGER `pagos_entrada_materia_prima_AFTER_INSERT` AFTER INSERT ON `pagos_entrada_materia_prima` FOR EACH ROW BEGIN
DECLARE metodo_nombre VARCHAR(25);
    DECLARE tasa_movimiento FLOAT;
    DECLARE monto_egreso FLOAT;
    
    -- Obtener el nombre del método de pago
    SELECT nombre INTO metodo_nombre 
    FROM metodo_pago 
    WHERE id = NEW.id_metodo_pago;
    
    -- Determinar la tasa según el método de pago
    IF metodo_nombre IN ('Pago Movil', 'Transferencia', 'Efectivo') THEN
        SET tasa_movimiento = NEW.tasa;
    ELSE
        SET tasa_movimiento = 1;
    END IF;
    
    -- Calcular el monto del egreso (negativo porque es un gasto)
    SET monto_egreso = -NEW.precio_compra;
    
    -- Insertar el movimiento de capital
    INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
    VALUES (
        monto_egreso, 
        CONCAT('Egreso por entrada de materia prima nro ', NEW.id_entrada),
        NEW.fecha,
        tasa_movimiento
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos_entrada_producto_procesado`
--

CREATE TABLE `pagos_entrada_producto_procesado` (
  `id` int NOT NULL,
  `id_entrada` int NOT NULL,
  `id_metodo_pago` int NOT NULL,
  `tasa` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `precio_compra` float NOT NULL,
  `comprobante` varchar(500) NOT NULL,
  `referencia` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pagos_entrada_producto_procesado`
--

INSERT INTO `pagos_entrada_producto_procesado` (`id`, `id_entrada`, `id_metodo_pago`, `tasa`, `fecha`, `precio_compra`, `comprobante`, `referencia`) VALUES
(3, 26, 3, 150.8, '2025-09-03 14:02:05', 5500, 'cap.jpg', '62626'),
(4, 27, 3, 151.76, '2025-09-04 10:37:23', 3500, 'cap.jpg', '62626'),
(5, 83, 1, 1, '2025-10-26 18:06:53', 250, 'COMP-PROC-1761498413', 'REF-PROC-1761498413'),
(6, 85, 1, 1, '2025-10-26 18:07:05', 250, 'COMP-PROC-1761498425', 'REF-PROC-1761498425'),
(7, 87, 1, 1, '2025-10-26 18:09:30', 250, 'COMP-PROC-1761498570', 'REF-PROC-1761498570'),
(8, 110, 1, 1, '2025-11-06 04:24:45', 250, 'ejemplo.jpg', 'REF-PROC-1762399485'),
(9, 112, 1, 1, '2025-11-06 04:24:52', 250, 'ejemplo.jpg', 'REF-PROC-1762399492'),
(10, 114, 1, 1, '2025-11-06 04:25:14', 250, 'ejemplo.jpg', 'REF-PROC-1762399514'),
(11, 116, 1, 1, '2025-11-06 04:26:09', 250, 'ejemplo.jpg', 'REF-PROC-1762399569'),
(12, 118, 1, 1, '2025-11-06 04:26:52', 250, 'ejemplo.jpg', 'REF-PROC-1762399612'),
(13, 120, 1, 1, '2025-11-06 04:46:37', 250, 'ejemplo.jpg', 'REF-PROC-1762400797'),
(14, 122, 1, 1, '2025-11-06 04:47:19', 250, 'ejemplo.jpg', 'REF-PROC-1762400839'),
(15, 124, 1, 1, '2025-11-06 04:49:52', 250, 'ejemplo.jpg', 'REF-PROC-1762400992'),
(16, 126, 1, 1, '2025-11-06 04:50:16', 250, 'ejemplo.jpg', 'REF-PROC-1762401016'),
(17, 128, 1, 1, '2025-11-06 04:50:37', 250, 'ejemplo.jpg', 'REF-PROC-1762401037'),
(18, 130, 1, 1, '2025-11-06 04:51:02', 250, 'ejemplo.jpg', 'REF-PROC-1762401062'),
(19, 132, 1, 1, '2025-11-06 06:01:43', 250, 'ejemplo.jpg', 'REF-PROC-1762405303'),
(20, 134, 1, 1, '2025-11-06 11:45:16', 250, 'ejemplo.jpg', 'REF-PROC-1762425916'),
(21, 138, 1, 1, '2025-11-11 19:21:29', 250, 'ejemplo.jpg', 'REF-PROC-1762885289'),
(22, 140, 1, 1, '2025-11-11 22:42:31', 250, 'ejemplo.jpg', 'REF-PROC-1762897351'),
(23, 142, 1, 1, '2026-03-03 22:33:53', 250, 'ejemplo.jpg', 'REF-PROC-1772573633'),
(24, 144, 1, 1, '2026-03-03 22:34:33', 250, 'ejemplo.jpg', 'REF-PROC-1772573673'),
(25, 146, 1, 1, '2026-03-03 22:38:06', 250, 'ejemplo.jpg', 'REF-PROC-1772573886'),
(26, 148, 1, 1, '2026-03-03 22:38:15', 250, 'ejemplo.jpg', 'REF-PROC-1772573895'),
(27, 150, 1, 1, '2026-03-03 22:38:33', 250, 'ejemplo.jpg', 'REF-PROC-1772573913'),
(28, 152, 1, 1, '2026-03-03 22:52:02', 250, 'ejemplo.jpg', 'REF-PROC-1772574722'),
(29, 154, 1, 1, '2026-03-03 23:00:20', 250, 'ejemplo.jpg', 'REF-PROC-1772575220'),
(30, 156, 1, 1, '2026-03-03 23:41:28', 250, 'ejemplo.jpg', 'REF-PROC-1772577688'),
(31, 158, 1, 1, '2026-03-03 23:47:22', 250, 'ejemplo.jpg', 'REF-PROC-1772578042'),
(32, 160, 1, 1, '2026-03-03 23:55:23', 250, 'ejemplo.jpg', 'REF-PROC-1772578523');

--
-- Disparadores `pagos_entrada_producto_procesado`
--
DELIMITER $$
CREATE TRIGGER `pagos_entrada_producto_procesado_AFTER_INSERT` AFTER INSERT ON `pagos_entrada_producto_procesado` FOR EACH ROW BEGIN
DECLARE metodo_nombre VARCHAR(25);
    DECLARE tasa_movimiento FLOAT;
    DECLARE monto_egreso FLOAT;
    
    -- Obtener el nombre del método de pago
    SELECT nombre INTO metodo_nombre 
    FROM metodo_pago 
    WHERE id = NEW.id_metodo_pago;
    
    -- Determinar la tasa según el método de pago
    IF metodo_nombre IN ('Pago Movil', 'Transferencia', 'Efectivo') THEN
        SET tasa_movimiento = NEW.tasa;
    ELSE
        SET tasa_movimiento = 1;
    END IF;
    
    -- Calcular el monto del egreso (negativo porque es un gasto)
    SET monto_egreso = -NEW.precio_compra;
    
    -- Insertar el movimiento de capital
    INSERT INTO movimientos_capital (monto, descripcion, fecha, tasa)
    VALUES (
        monto_egreso, 
        CONCAT('Egreso por entrada de materia prima nro ', NEW.id_entrada),
        NEW.fecha,
        tasa_movimiento
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago_reserva`
--

CREATE TABLE `pago_reserva` (
  `id` int NOT NULL,
  `id_reserva` int DEFAULT NULL,
  `id_pago` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pago_reserva`
--

INSERT INTO `pago_reserva` (`id`, `id_reserva`, `id_pago`) VALUES
(5, 8, 70),
(6, 9, 91),
(7, 10, 92),
(8, 10, 93),
(15, 9, 101),
(17, 10, 106),
(56, 47, 145),
(57, 48, 147),
(58, 49, 149),
(60, 51, 152),
(62, 53, 155),
(64, 55, 158),
(66, 57, 161),
(68, 59, 164),
(69, 60, 166),
(71, 62, 169),
(73, 64, 172),
(75, 66, 175),
(81, 68, 180),
(83, 69, 183),
(85, 71, 186),
(87, 73, 189),
(89, 75, 192),
(91, 77, 195),
(93, 79, 198),
(95, 81, 201),
(97, 83, 204),
(99, 85, 207),
(101, 87, 210),
(103, 89, 213),
(105, 91, 216),
(107, 93, 219),
(109, 95, 222),
(111, 97, 225),
(113, 99, 228),
(114, 100, 230),
(115, 101, 232),
(117, 103, 235),
(119, 105, 238),
(121, 107, 241),
(123, 109, 244),
(125, 111, 247),
(127, 113, 250),
(129, 115, 253),
(131, 117, 256),
(133, 119, 259),
(135, 121, 262),
(137, 123, 265),
(140, 126, 269),
(142, 128, 272),
(144, 130, 275),
(146, 132, 278),
(148, 134, 281),
(150, 136, 284),
(152, 138, 287),
(154, 140, 290),
(156, 142, 293),
(158, 144, 296),
(160, 146, 299),
(162, 148, 302),
(164, 150, 305);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago_venta`
--

CREATE TABLE `pago_venta` (
  `id` int NOT NULL,
  `id_venta` int DEFAULT NULL,
  `id_pago` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pago_venta`
--

INSERT INTO `pago_venta` (`id`, `id_venta`, `id_pago`) VALUES
(5, 57, 50),
(6, 58, 51),
(7, 59, 52),
(8, 60, 53),
(9, 61, 54),
(10, 62, 55),
(11, 63, 56),
(19, 71, 64),
(20, 72, 71),
(21, 73, 72),
(22, 74, 73),
(23, 75, 74),
(24, 76, 75),
(25, 77, 76),
(26, 78, 77),
(27, 79, 78),
(28, 80, 79),
(29, 81, 80),
(30, 82, 81),
(31, 83, 82),
(32, 84, 83),
(33, 85, 84),
(34, 86, 85),
(35, 87, 87),
(36, 88, 88),
(37, 89, 89),
(38, 90, 90),
(39, 91, 105),
(78, 132, 146),
(79, 133, 148),
(80, 134, 150),
(82, 136, 153),
(84, 138, 156),
(86, 140, 159),
(88, 142, 162),
(90, 144, 165),
(91, 146, 167),
(93, 149, 170),
(95, 152, 173),
(97, 155, 176),
(101, 157, 178),
(103, 158, 179),
(105, 159, 181),
(107, 161, 184),
(109, 163, 187),
(111, 165, 190),
(113, 167, 193),
(115, 169, 196),
(117, 171, 199),
(119, 173, 202),
(121, 175, 205),
(123, 177, 208),
(125, 179, 211),
(127, 181, 214),
(129, 183, 217),
(131, 185, 220),
(133, 187, 223),
(135, 190, 226),
(137, 193, 229),
(138, 195, 231),
(139, 197, 233),
(141, 200, 236),
(143, 203, 239),
(145, 206, 242),
(147, 209, 245),
(149, 212, 248),
(151, 215, 251),
(153, 218, 254),
(155, 221, 257),
(157, 224, 260),
(159, 227, 263),
(161, 230, 266),
(163, 234, 270),
(165, 237, 273),
(167, 240, 276),
(169, 243, 279),
(171, 246, 282),
(173, 249, 285),
(175, 252, 288),
(177, 255, 291),
(179, 258, 294),
(181, 261, 297),
(183, 264, 300),
(185, 267, 303),
(187, 270, 306);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquetes_mesas`
--

CREATE TABLE `paquetes_mesas` (
  `id` int NOT NULL,
  `id_paquete` int DEFAULT NULL,
  `id_mesa` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `paquetes_mesas`
--

INSERT INTO `paquetes_mesas` (`id`, `id_paquete`, `id_mesa`) VALUES
(11, 4, 1),
(12, 4, 3),
(14, 6, 8),
(15, 7, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquetes_reservacion`
--

CREATE TABLE `paquetes_reservacion` (
  `id` int NOT NULL,
  `nombre` varchar(500) NOT NULL,
  `precio` float NOT NULL,
  `active` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `paquetes_reservacion`
--

INSERT INTO `paquetes_reservacion` (`id`, `nombre`, `precio`, `active`) VALUES
(4, 'Paquete Basico', 5.55, 1),
(6, 'Paquete Normal', 3.5, 1),
(7, 'Paquete Maximus', 15, 1),
(8, 'Paquete prueba', 5, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_preparados`
--

CREATE TABLE `productos_preparados` (
  `id` int NOT NULL,
  `id_categoria` int NOT NULL DEFAULT '10',
  `nombre` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `precio` float NOT NULL,
  `detalles` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `productos_preparados`
--

INSERT INTO `productos_preparados` (`id`, `id_categoria`, `nombre`, `imagen`, `precio`, `detalles`, `active`, `tipo`) VALUES
(41, 7, 'Hamburguesa sencilla', 'banner_captcha.png', 5.5, 'mucho detalle aqui', 1, 'producto'),
(42, 7, 'Pruba', '7893000979932.jpg', 0.56, 'dadkawpdkpoakdokada', 0, 'producto'),
(43, 7, 'Ninncwda', '7702535011805-20-281-29.webp', 74.87, 'dawdalwdmawldmwadaw', 0, 'producto'),
(44, 7, 'SWSADA', 'harina-pan.jpg', 0.56, 'DAWDADAWDADADADA', 0, 'producto'),
(45, 7, 'Super Smasher', 'banner_register.png', 0.56, 'mucha descripcion', 1, 'producto'),
(46, 10, 'Carne', '2c51307c-9d9f-41fb-9419-1e61a44891f0.jpeg', 0.56, NULL, 1, 'adicional'),
(47, 10, 'Papitas', 'DIABLITOS-UNDERWOOD.jpg', 0.25, NULL, 1, 'adicional'),
(48, 10, 'Nuggets', 'arroz.jpeg', 2, NULL, 1, 'adicional'),
(49, 10, 'Ensalada', '7594005430045.jpg', 1.5, NULL, 1, 'adicional'),
(50, 10, 'Salsa Inglesa', 'harina-pan.jpg', 0.55, NULL, 1, 'adicional'),
(51, 10, 'Jamon', '7502223708136_1.jpg', 2.5, NULL, 1, 'adicional'),
(52, 5, 'Smash Burger', '5e5294ee-d7d2-424d-ac2e-5802bbad41ab.jpeg', 6.16, 'dawdawdawdawdadawd', 1, 'producto'),
(53, 4, 'Perro Caliente Max', 'banner_register.png', 3.8, 'algun detalle q poner', 1, 'producto'),
(54, 8, 'Pizza Max', 'banner_login.png', 15, 'una pizza muy grande', 1, 'producto');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_procesados`
--

CREATE TABLE `productos_procesados` (
  `id` int NOT NULL,
  `nombre` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `precio` float NOT NULL,
  `detalles` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `id_categoria` int NOT NULL,
  `existencia` float NOT NULL DEFAULT '0',
  `stock_min` float NOT NULL DEFAULT '0',
  `stock_max` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos_procesados`
--

INSERT INTO `productos_procesados` (`id`, `nombre`, `imagen`, `precio`, `detalles`, `active`, `id_categoria`, `existencia`, `stock_min`, `stock_max`) VALUES
(41, 'Gloup 1L', 'ImgThumb.jpg', 5, 'dawdwdwadascacacac', 1, 1, 1638, 2, 20),
(42, 'Coca Cola', 'OIP.jpeg', 1.5, 'Coca cola de 1.5L', 1, 1, 40, 10, 50),
(43, 'Sun 1L', 'ImgThumb.jpg', 1, 'bebida alternativa a gloup', 1, 1, 0, 3, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_preparado_detalle_orden`
--

CREATE TABLE `producto_preparado_detalle_orden` (
  `id` int NOT NULL,
  `id_producto` int NOT NULL,
  `id_orden` int NOT NULL,
  `cantidad` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `descripcion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `adicionales` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_preparado_detalle_orden`
--

INSERT INTO `producto_preparado_detalle_orden` (`id`, `id_producto`, `id_orden`, `cantidad`, `descripcion`, `adicionales`, `active`) VALUES
(142, 41, 80, '1', '', '', 1),
(143, 52, 81, '1', '', 'Salsa Inglesa', 1),
(144, 50, 81, '1', NULL, NULL, 1),
(145, 45, 81, '1', '', '', 1),
(147, 52, 83, '1', '', '', 1),
(148, 41, 84, '1', '', 'Jamon', 1),
(149, 51, 84, '1', NULL, NULL, 1),
(150, 41, 85, '1', '', '', 1),
(151, 41, 86, '1', 'sin mostaza', 'Papitas', 1),
(152, 47, 86, '1', NULL, NULL, 1),
(153, 45, 87, '1', '', 'Nuggets', 1),
(154, 48, 87, '1', NULL, NULL, 1),
(155, 45, 89, '2', '', '', 1),
(156, 52, 90, '1', '', '', 1),
(157, 52, 102, '1', '', 'Salsa Inglesa', 1),
(158, 50, 102, '1', NULL, NULL, 1),
(159, 41, 103, '1', '', '', 1),
(160, 41, 104, '1', '', 'Jamon,Ensalada', 1),
(161, 49, 104, '1', NULL, NULL, 1),
(162, 51, 104, '1', NULL, NULL, 1),
(163, 45, 105, '1', '', '', 1),
(164, 45, 106, '1', '', '', 1),
(165, 45, 106, '1', '', '', 1),
(166, 52, 107, '1', '', 'Salsa Inglesa,Nuggets', 1),
(167, 48, 107, '1', NULL, NULL, 1),
(168, 50, 107, '1', NULL, NULL, 1),
(169, 52, 108, '1', '', '', 1),
(170, 41, 110, '1', '', 'Papitas', 1),
(171, 47, 110, '1', NULL, NULL, 1),
(172, 52, 113, '1', '', 'Papitas', 1),
(173, 47, 113, '1', NULL, NULL, 1),
(174, 45, 114, '1', '', '', 1),
(175, 45, 115, '1', '', 'Salsa Inglesa', 1),
(176, 50, 115, '1', NULL, NULL, 1),
(177, 52, 116, '1', '', 'Ensalada', 1),
(178, 49, 116, '1', NULL, NULL, 1),
(179, 52, 117, '1', '', 'Nuggets', 1),
(180, 48, 117, '1', NULL, NULL, 1),
(181, 52, 118, '1', '', '', 1),
(182, 41, 119, '1', '', '', 1),
(189, 41, 126, '1', '', '', 1),
(190, 52, 127, '1', '', '', 1),
(191, 52, 128, '1', '', '', 1),
(192, 41, 129, '1', '', '', 1),
(193, 45, 130, '1', '', 'Salsa Inglesa', 1),
(194, 50, 130, '1', NULL, NULL, 1),
(195, 45, 132, '1', '', 'Ensalada', 1),
(196, 49, 132, '1', NULL, NULL, 1),
(197, 52, 132, '1', '', '', 1),
(198, 52, 132, '1', '', '', 1),
(199, 41, 131, '1', '', '', 1),
(203, 41, 127, '1', '', '', 1),
(250, 41, 7389, '1', NULL, NULL, 1),
(251, 41, 7390, '1', NULL, NULL, 1),
(252, 41, 7391, '1', NULL, NULL, 1),
(253, 41, 7392, '1', NULL, NULL, 1),
(254, 41, 7393, '1', NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_procesado_detalle_orden`
--

CREATE TABLE `producto_procesado_detalle_orden` (
  `id` int NOT NULL,
  `id_producto` int NOT NULL,
  `id_orden` int NOT NULL,
  `cantidad` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_procesado_detalle_orden`
--

INSERT INTO `producto_procesado_detalle_orden` (`id`, `id_producto`, `id_orden`, `cantidad`) VALUES
(16, 42, 80, '1'),
(17, 41, 81, '1'),
(18, 42, 80, '1'),
(19, 41, 81, '1'),
(20, 42, 87, '1'),
(21, 42, 88, '1'),
(22, 42, 91, '1'),
(23, 42, 104, '1'),
(24, 41, 109, '1'),
(25, 41, 111, '1'),
(26, 42, 112, '1'),
(27, 42, 132, '1'),
(28, 42, 132, '1'),
(29, 42, 131, '1'),
(30, 42, 101, '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id` int NOT NULL,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `razon_social` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `documento` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `n_telefono1` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `n_telefono2` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `direccion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id`, `nombre`, `razon_social`, `documento`, `n_telefono1`, `n_telefono2`, `direccion`, `active`) VALUES
(1, 'Luis Perez', 'Montecarmelo', 'V-5435543', '+584126742231', '', 'una direccion para especificar', 1),
(2, 'Lucas Martinez', 'El tunal', 'V-10254789', '+584126879568', '', 'sede central de tunal, quibor', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recetas`
--

CREATE TABLE `recetas` (
  `id` int NOT NULL,
  `id_producto` int NOT NULL,
  `active` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `recetas`
--

INSERT INTO `recetas` (`id`, `id_producto`, `active`) VALUES
(13, 41, 1),
(16, 48, 1),
(17, 45, 1),
(18, 50, 1),
(19, 54, 1),
(55, 41, 1),
(57, 41, 1),
(59, 41, 1),
(61, 41, 1),
(62, 41, 1),
(63, 41, 1),
(65, 41, 1),
(67, 41, 1),
(69, 41, 1),
(71, 41, 1),
(73, 41, 1),
(74, 41, 1),
(76, 41, 1),
(78, 41, 1),
(80, 41, 1),
(82, 41, 1),
(84, 41, 1),
(86, 41, 1),
(88, 41, 1),
(90, 41, 1),
(92, 41, 1),
(94, 41, 1),
(96, 41, 1),
(98, 41, 1),
(100, 41, 1),
(102, 41, 1),
(104, 41, 1),
(106, 41, 1),
(108, 41, 1),
(110, 41, 1),
(112, 41, 1),
(114, 41, 1),
(116, 41, 1),
(118, 41, 1),
(120, 41, 1),
(122, 41, 1),
(123, 41, 1),
(124, 41, 1),
(126, 41, 1),
(128, 41, 1),
(130, 41, 1),
(132, 41, 1),
(134, 41, 1),
(136, 41, 1),
(138, 41, 1),
(140, 41, 1),
(142, 41, 1),
(144, 41, 1),
(146, 41, 1),
(149, 41, 1),
(151, 41, 1),
(153, 41, 1),
(155, 41, 1),
(157, 41, 1),
(159, 41, 1),
(161, 41, 1),
(163, 41, 1),
(165, 41, 1),
(167, 41, 1),
(169, 41, 1),
(171, 41, 1),
(173, 41, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reservaciones`
--

CREATE TABLE `reservaciones` (
  `id` int NOT NULL,
  `id_paquete` int NOT NULL,
  `id_orden` int NOT NULL,
  `id_caja` int NOT NULL,
  `descripcion` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fecha_bloqueo` datetime DEFAULT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_final` datetime DEFAULT NULL,
  `metodo_pedido` varchar(45) DEFAULT NULL,
  `status` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `reservaciones`
--

INSERT INTO `reservaciones` (`id`, `id_paquete`, `id_orden`, `id_caja`, `descripcion`, `fecha_bloqueo`, `fecha_inicio`, `fecha_final`, `metodo_pedido`, `status`) VALUES
(8, 6, 101, 30, NULL, '2025-08-19 18:30:00', '2025-08-19 19:30:00', NULL, 'Sistema', 'finalizada'),
(9, 8, 131, 31, NULL, '2025-08-21 18:30:00', '2025-08-21 19:30:00', NULL, 'Sistema', 'confirmada'),
(10, 7, 132, 31, NULL, '2025-08-30 18:30:00', '2025-08-30 19:30:00', '2025-08-20 13:04:11', 'Sistema', 'finalizada'),
(41, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:45:39', '2025-10-26 19:45:39', 'online', 'confirmada'),
(43, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:46:20', '2025-10-26 19:46:20', 'online', 'confirmada'),
(45, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:47:34', '2025-10-26 19:47:34', 'online', 'confirmada'),
(47, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:48:36', '2025-10-26 19:48:36', 'online', 'confirmada'),
(48, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:49:21', '2025-10-26 19:49:21', 'online', 'confirmada'),
(49, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:49:44', '2025-10-26 19:49:44', 'online', 'confirmada'),
(51, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:49:56', '2025-10-26 19:49:56', 'online', 'confirmada'),
(53, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:50:27', '2025-10-26 19:50:27', 'online', 'confirmada'),
(55, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:50:52', '2025-10-26 19:50:52', 'online', 'confirmada'),
(57, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:57:57', '2025-10-26 19:57:57', 'online', 'confirmada'),
(59, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-25 19:58:09', '2025-10-26 19:58:09', 'online', 'confirmada'),
(60, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-27 18:01:16', '2025-10-28 18:01:16', 'online', 'confirmada'),
(62, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-27 18:02:17', '2025-10-28 18:02:17', 'online', 'confirmada'),
(64, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-27 18:07:05', '2025-10-28 18:07:05', 'online', 'confirmada'),
(66, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-10-27 18:09:31', '2025-10-28 18:09:31', 'online', 'confirmada'),
(68, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(69, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(71, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(73, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(75, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(77, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(79, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(81, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(83, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(85, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(87, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(89, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(91, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(93, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(95, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(97, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(99, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(100, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(101, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(103, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(105, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(107, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(109, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(111, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(113, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(115, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(117, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(119, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(121, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(123, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-07 00:00:00', '2025-11-08 00:00:00', 'online', 'confirmada'),
(126, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-12 00:00:00', '2025-11-13 00:00:00', 'online', 'confirmada'),
(128, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-12 00:00:00', '2025-11-13 00:00:00', 'online', 'confirmada'),
(130, 4, 80, 27, 'Reservación de prueba integración', NULL, '2025-11-12 00:00:00', '2025-11-13 00:00:00', 'online', 'confirmada'),
(132, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(134, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(136, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(138, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(140, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(142, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(144, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(146, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(148, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada'),
(150, 4, 80, 27, 'Reservación de prueba integración', NULL, '2026-03-04 00:00:00', '2026-03-05 00:00:00', 'online', 'confirmada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades`
--

CREATE TABLE `unidades` (
  `id` int NOT NULL,
  `nombre` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `alias` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `unidades`
--

INSERT INTO `unidades` (`id`, `nombre`, `alias`, `active`) VALUES
(1, 'Litro', 'Lt', '1'),
(2, 'Gramo', 'Gr', '1'),
(3, 'Kilogramo', 'Kg', '1'),
(4, 'Unidad', 'Ud', '1'),
(5, 'Mililitro', 'Ml', '1'),
(7, 'Prueba', 'P', '0'),
(8, 'Prueba1', '1', '0'),
(9, 'Prueba2', '2', '0'),
(10, 'Prueba3', '2', '0'),
(11, 'PRUEBS', 'pr', '0'),
(12, 'Otra', 'ass', '0'),
(122, 'Oo', 'Ml', '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id` int NOT NULL,
  `id_caja` int NOT NULL,
  `id_orden` int NOT NULL,
  `IVA` float DEFAULT NULL,
  `monto_final` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `direccion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id`, `id_caja`, `id_orden`, `IVA`, `monto_final`, `fecha`, `direccion`, `active`) VALUES
(57, 27, 83, NULL, 7.15, '2025-07-07 14:08:46', 'circunvalacion', 1),
(58, 27, 84, NULL, 8.88, '2025-07-07 14:11:23', 'fraternidad', 1),
(59, 28, 85, NULL, 6.38, '2025-07-09 13:49:15', 'direccion de envio', 1),
(60, 28, 86, NULL, 6.67, '2025-07-09 19:21:51', 'en mi casa', 1),
(61, 28, 87, NULL, 4.71, '2025-07-09 19:28:51', 'en mi casa', 1),
(62, 28, 88, NULL, 1.74, '2025-07-09 20:49:13', 'NAAD', 1),
(63, 29, 89, NULL, 1.3, '2025-07-10 14:46:47', 'nada', 1),
(71, 29, 81, NULL, 20.03, '2025-07-16 15:23:56', 'BURGER HOUSE', 1),
(72, 30, 102, NULL, 7.15, '2025-08-06 12:51:54', 'en mi casa', 1),
(73, 30, 103, NULL, 6.38, '2025-08-06 12:57:55', 'nose', 1),
(74, 30, 104, NULL, 12.76, '2025-08-06 13:10:04', 'en mi casa', 1),
(75, 30, 105, NULL, 0.65, '2025-08-06 13:24:43', 'nada', 1),
(76, 30, 106, NULL, 1.3, '2025-08-06 13:26:43', 'dasda', 1),
(77, 30, 107, NULL, 10.1, '2025-08-06 13:28:11', 'quien sabe', 1),
(78, 30, 108, NULL, 7.15, '2025-08-06 13:34:59', 'uguig', 1),
(79, 30, 109, NULL, 5.8, '2025-08-06 13:48:30', 'dadwda', 1),
(80, 30, 110, NULL, 6.67, '2025-08-06 14:04:45', 'nose', 1),
(81, 30, 111, NULL, 5.8, '2025-08-06 14:06:40', 'ijij', 1),
(82, 30, 112, NULL, 1.74, '2025-08-06 14:19:21', 'en mi casa', 1),
(83, 30, 113, NULL, 7.44, '2025-08-06 14:21:34', 'nose', 1),
(84, 30, 114, NULL, 0.65, '2025-08-06 14:35:30', 'nada', 1),
(85, 30, 115, NULL, 1.29, '2025-08-06 14:37:43', 'add', 1),
(86, 30, 116, NULL, 8.89, '2025-08-06 14:38:35', 'dadwad', 1),
(87, 31, 117, NULL, 9.47, '2025-08-09 12:16:53', 'BURGER HOUSE', 1),
(88, 31, 118, NULL, 7.15, '2025-08-09 12:27:27', 'BURGER HOUSE', 1),
(89, 31, 129, NULL, 6.38, '2025-08-09 13:16:22', 'BURGER HOUSE', 1),
(90, 31, 130, NULL, 1.29, '2025-08-09 13:20:45', 'BURGER HOUSE', 1),
(91, 31, 128, NULL, 7.15, '2025-08-20 13:03:17', 'BURGER HOUSE', 1),
(126, 27, 80, 16, 116, '2025-10-24 19:45:39', 'Dirección de prueba', 1),
(128, 27, 80, 16, 116, '2025-10-24 19:46:20', 'Dirección de prueba', 1),
(130, 27, 80, 16, 116, '2025-10-24 19:47:34', 'Dirección de prueba', 1),
(132, 27, 80, 16, 116, '2025-10-24 19:48:36', 'Dirección de prueba', 1),
(133, 27, 80, 16, 116, '2025-10-24 19:49:21', 'Dirección de prueba', 1),
(134, 27, 80, 16, 116, '2025-10-24 19:49:44', 'Dirección de prueba', 1),
(136, 27, 80, 16, 116, '2025-10-24 19:49:56', 'Dirección de prueba', 1),
(138, 27, 80, 16, 116, '2025-10-24 19:50:27', 'Dirección de prueba', 1),
(140, 27, 80, 16, 116, '2025-10-24 19:50:52', 'Dirección de prueba', 1),
(142, 27, 80, 16, 116, '2025-10-24 19:57:57', 'Dirección de prueba', 1),
(144, 27, 80, 16, 116, '2025-10-24 19:58:09', 'Dirección de prueba', 1),
(145, 27, 80, 16, 116, '2025-10-26 18:01:16', 'Calle Principal #123, Ciudad', 1),
(146, 27, 80, 16, 116, '2025-10-26 18:01:16', 'Dirección de prueba', 1),
(148, 27, 80, 16, 116, '2025-10-26 18:02:16', 'Calle Principal #123, Ciudad', 1),
(149, 27, 80, 16, 116, '2025-10-26 18:02:17', 'Dirección de prueba', 1),
(151, 27, 80, 16, 116, '2025-10-26 18:07:04', 'Calle Principal #123, Ciudad', 1),
(152, 27, 80, 16, 116, '2025-10-26 18:07:05', 'Dirección de prueba', 1),
(154, 27, 80, 16, 116, '2025-10-26 18:09:30', 'Calle Principal #123, Ciudad', 1),
(155, 27, 80, 16, 116, '2025-10-26 18:09:31', 'Dirección de prueba', 1),
(157, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(158, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(159, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(161, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(163, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(165, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(167, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(169, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(171, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(173, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(175, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(177, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(179, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(181, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(183, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(185, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(187, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(189, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(190, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(192, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(193, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(194, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(195, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(196, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(197, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(199, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(200, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(202, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(203, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(205, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(206, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(208, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(209, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(211, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(212, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(214, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(215, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(217, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(218, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(220, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(221, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(223, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(224, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(226, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(227, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(229, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Calle Principal #123, Ciudad', 1),
(230, 27, 80, 16, 116, '2025-11-06 00:00:00', 'Dirección de prueba', 1),
(233, 27, 80, 16, 116, '2025-11-11 00:00:00', 'Calle Principal #123, Ciudad', 1),
(234, 27, 80, 16, 116, '2025-11-11 00:00:00', 'Dirección de prueba', 1),
(236, 27, 80, 16, 116, '2025-11-11 00:00:00', 'Calle Principal #123, Ciudad', 1),
(237, 27, 80, 16, 116, '2025-11-11 00:00:00', 'Dirección de prueba', 1),
(239, 27, 80, 16, 116, '2025-11-11 00:00:00', 'Calle Principal #123, Ciudad', 1),
(240, 27, 80, 16, 116, '2025-11-11 00:00:00', 'Dirección de prueba', 1),
(242, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(243, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(245, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(246, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(248, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(249, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(251, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(252, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(254, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(255, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(257, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(258, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(260, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(261, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(263, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(264, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(266, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(267, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(269, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Calle Principal #123, Ciudad', 1),
(270, 27, 80, 16, 116, '2026-03-03 00:00:00', 'Dirección de prueba', 1),
(272, 35, 7393, NULL, 6.38, '2026-03-05 18:06:25', 'dddd', 1);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inventario_materia_prima`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_inventario_materia_prima` (
`entradas` double
,`materia_prima` varchar(20)
,`salidas` double
,`stock_actual` float
,`unidad` varchar(4)
,`valor_stock` double
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inventario_productos_procesados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_inventario_productos_procesados` (
`entradas` double
,`producto` varchar(500)
,`salidas` double
,`stock_actual` float
,`valor_stock` double
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_resumen_clientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_resumen_clientes` (
`apellido` varchar(45)
,`cliente` text
,`imagen_1` varchar(500)
,`imagen_2` varchar(500)
,`imagen_3` varchar(500)
,`producto_1` varchar(500)
,`producto_2` varchar(500)
,`producto_3` varchar(500)
,`telefono` varchar(20)
,`total_gastado` double
,`ultima_orden` varchar(24)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_resumen_financiero`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_resumen_financiero` (
`gastos` double
,`ingresos` double
,`utilidad_neta` double
,`ventas` double
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_stats_ordenes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_stats_ordenes` (
`anulada` decimal(23,0)
,`en camino` decimal(23,0)
,`en cocina` decimal(23,0)
,`en mesa` decimal(23,0)
,`entregada` decimal(23,0)
,`pagado` decimal(23,0)
,`para despachar` decimal(23,0)
,`por verificar` decimal(23,0)
,`terminada` decimal(23,0)
,`total` bigint
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inventario_materia_prima`
--
DROP TABLE IF EXISTS `vista_inventario_materia_prima`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario_materia_prima`  AS WITH     `entradas_totales` as (select `detalles_entradas_materia_prima`.`id_materia_prima` AS `id_materia_prima`,sum(`detalles_entradas_materia_prima`.`cantidad`) AS `total_comprado` from `detalles_entradas_materia_prima` group by `detalles_entradas_materia_prima`.`id_materia_prima`), `valor_entradas_normalizado` as (select `emp`.`id_materia_prima` AS `id_materia_prima`,sum((case when (`pemp`.`id_metodo_pago` in (1,2,12,13)) then `pemp`.`precio_compra` else (`pemp`.`precio_compra` / `pemp`.`tasa`) end)) AS `costo_total_dolares`,sum(`emp`.`cantidad`) AS `cantidad_total` from (`pagos_entrada_materia_prima` `pemp` join `detalles_entradas_materia_prima` `emp` on((`pemp`.`id_entrada` = `emp`.`id_entrada`))) group by `emp`.`id_materia_prima`) select `mp`.`nombre` AS `materia_prima`,coalesce(`et`.`total_comprado`,0) AS `entradas`,(coalesce(`et`.`total_comprado`,0) - `mp`.`existencia`) AS `salidas`,(case when (`ven`.`cantidad_total` > 0) then round(((`ven`.`costo_total_dolares` / `ven`.`cantidad_total`) * `mp`.`existencia`),2) else 0 end) AS `valor_stock`,`mp`.`existencia` AS `stock_actual`,`u`.`alias` AS `unidad` from (((`materia_prima` `mp` left join `unidades` `u` on((`mp`.`id_unidad` = `u`.`id`))) left join `entradas_totales` `et` on((`mp`.`id` = `et`.`id_materia_prima`))) left join `valor_entradas_normalizado` `ven` on((`mp`.`id` = `ven`.`id_materia_prima`))) where (`mp`.`active` = 1)  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inventario_productos_procesados`
--
DROP TABLE IF EXISTS `vista_inventario_productos_procesados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario_productos_procesados`  AS WITH     `entradas_totales` as (select `entradas_producto_procesado`.`id_producto` AS `id_producto`,sum(`entradas_producto_procesado`.`cantidad`) AS `total_comprado` from `entradas_producto_procesado` group by `entradas_producto_procesado`.`id_producto`), `valor_entradas_normalizado` as (select `epp`.`id_producto` AS `id_producto`,sum((case when (`pepp`.`id_metodo_pago` in (1,2,12,13)) then `pepp`.`precio_compra` else (`pepp`.`precio_compra` / `pepp`.`tasa`) end)) AS `costo_total_dolares`,sum(`epp`.`cantidad`) AS `cantidad_total` from (`pagos_entrada_producto_procesado` `pepp` join `entradas_producto_procesado` `epp` on((`pepp`.`id_entrada` = `epp`.`id`))) group by `epp`.`id_producto`) select `pp`.`nombre` AS `producto`,coalesce(`et`.`total_comprado`,0) AS `entradas`,(coalesce(`et`.`total_comprado`,0) - `pp`.`existencia`) AS `salidas`,(case when (`ven`.`cantidad_total` > 0) then round(((`ven`.`costo_total_dolares` / `ven`.`cantidad_total`) * `pp`.`existencia`),2) else 0 end) AS `valor_stock`,`pp`.`existencia` AS `stock_actual` from ((`productos_procesados` `pp` left join `entradas_totales` `et` on((`pp`.`id` = `et`.`id_producto`))) left join `valor_entradas_normalizado` `ven` on((`pp`.`id` = `ven`.`id_producto`))) where (`pp`.`active` = 1)  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_resumen_clientes`
--
DROP TABLE IF EXISTS `vista_resumen_clientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_resumen_clientes`  AS WITH     `total_gasto` as (select `o`.`id_cliente` AS `id_cliente`,sum(`v`.`monto_final`) AS `total_gastado` from (`ventas` `v` join `orden` `o` on((`o`.`id` = `v`.`id_orden`))) where (`o`.`id_cliente` is not null) group by `o`.`id_cliente`), `ultima_orden` as (select `orden`.`id_cliente` AS `id_cliente`,max(`orden`.`fecha`) AS `ultima_fecha` from `orden` where (`orden`.`id_cliente` is not null) group by `orden`.`id_cliente`), `productos_cliente` as (select `o`.`id_cliente` AS `id_cliente`,`p`.`nombre` AS `producto`,`p`.`imagen` AS `imagen`,sum(`od`.`cantidad`) AS `total_consumido`,row_number() OVER (PARTITION BY `o`.`id_cliente` ORDER BY sum(`od`.`cantidad`) desc )  AS `rn` from ((`orden` `o` join `producto_preparado_detalle_orden` `od` on((`od`.`id_orden` = `o`.`id`))) join `productos_preparados` `p` on((`p`.`id` = `od`.`id_producto`))) where ((`p`.`tipo` = 'producto') and (`o`.`id_cliente` is not null)) group by `o`.`id_cliente`,`p`.`nombre`,`p`.`imagen`), `clientes_con_productos` as (select distinct `productos_cliente`.`id_cliente` AS `id_cliente` from `productos_cliente`), `top_1` as (select `productos_cliente`.`id_cliente` AS `id_cliente`,`productos_cliente`.`producto` AS `producto1`,`productos_cliente`.`imagen` AS `imagen1` from `productos_cliente` where (`productos_cliente`.`rn` = 1)), `top_2` as (select `productos_cliente`.`id_cliente` AS `id_cliente`,`productos_cliente`.`producto` AS `producto2`,`productos_cliente`.`imagen` AS `imagen2` from `productos_cliente` where (`productos_cliente`.`rn` = 2)), `top_3` as (select `productos_cliente`.`id_cliente` AS `id_cliente`,`productos_cliente`.`producto` AS `producto3`,`productos_cliente`.`imagen` AS `imagen3` from `productos_cliente` where (`productos_cliente`.`rn` = 3)) select `c`.`nombre` AS `cliente`,`c`.`apellido` AS `apellido`,`c`.`telefono` AS `telefono`,date_format(`uo`.`ultima_fecha`,'%Y-%m-%d %H:%i:%s') AS `ultima_orden`,round(coalesce(`tg`.`total_gastado`,0),2) AS `total_gastado`,coalesce(`t1`.`producto1`,'Sin producto') AS `producto_1`,`t1`.`imagen1` AS `imagen_1`,coalesce(`t2`.`producto2`,'Sin producto') AS `producto_2`,`t2`.`imagen2` AS `imagen_2`,coalesce(`t3`.`producto3`,'Sin producto') AS `producto_3`,`t3`.`imagen3` AS `imagen_3` from ((((((`clientes` `c` join `clientes_con_productos` `cp` on((`c`.`id` = `cp`.`id_cliente`))) left join `total_gasto` `tg` on((`c`.`id` = `tg`.`id_cliente`))) left join `ultima_orden` `uo` on((`c`.`id` = `uo`.`id_cliente`))) left join `top_1` `t1` on((`c`.`id` = `t1`.`id_cliente`))) left join `top_2` `t2` on((`c`.`id` = `t2`.`id_cliente`))) left join `top_3` `t3` on((`c`.`id` = `t3`.`id_cliente`))) where (`c`.`active` = 1)  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_resumen_financiero`
--
DROP TABLE IF EXISTS `vista_resumen_financiero`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_resumen_financiero`  AS SELECT round(ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) > 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0),2) AS `ingresos`, round(ifnull(sum((case when (((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) > 0) and (`movimientos_capital`.`descripcion` like '%Ingreso por venta%')) then (`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) end)),0),2) AS `ventas`, round(ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) < 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0),2) AS `gastos`, round((ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) > 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0) + ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) < 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0)),2) AS `utilidad_neta` FROM `movimientos_capital` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_stats_ordenes`
--
DROP TABLE IF EXISTS `vista_stats_ordenes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_stats_ordenes`  AS SELECT count(`orden`.`id`) AS `total`, sum((`orden`.`status` = 'por verificar')) AS `por verificar`, sum((`orden`.`status` = 'en cocina')) AS `en cocina`, sum((`orden`.`status` = 'para despachar')) AS `para despachar`, sum((`orden`.`status` = 'en camino')) AS `en camino`, sum((`orden`.`status` = 'entregada')) AS `entregada`, sum((`orden`.`status` = 'pagado')) AS `pagado`, sum((`orden`.`status` = 'en mesa')) AS `en mesa`, sum((`orden`.`status` = 'anulada')) AS `anulada`, sum((`orden`.`status` = '1')) AS `terminada` FROM `orden` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario` (`id_usuario`);

--
-- Indices de la tabla `capital`
--
ALTER TABLE `capital`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `categorias_productos`
--
ALTER TABLE `categorias_productos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `categoria_materia_prima`
--
ALTER TABLE `categoria_materia_prima`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `configuraciones`
--
ALTER TABLE `configuraciones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `delivery`
--
ALTER TABLE `delivery`
  ADD PRIMARY KEY (`id`),
  ADD KEY `asdfg_idx` (`id_usuario_delivery`),
  ADD KEY `asdfgh_idx` (`id_venta`);

--
-- Indices de la tabla `detalles_entradas_materia_prima`
--
ALTER TABLE `detalles_entradas_materia_prima`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_materia_prima_idx` (`id_materia_prima`),
  ADD KEY `id_entrada_materia_prima_1_idx` (`id_entrada`);

--
-- Indices de la tabla `detalles_receta`
--
ALTER TABLE `detalles_receta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Id_receta` (`id_receta`,`id_materia_prima`),
  ADD KEY `Id_materia_prima_ibfk_1` (`id_materia_prima`);

--
-- Indices de la tabla `entradas_materia_prima`
--
ALTER TABLE `entradas_materia_prima`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_provedor` (`id_proveedor`);

--
-- Indices de la tabla `entradas_producto_procesado`
--
ALTER TABLE `entradas_producto_procesado`
  ADD PRIMARY KEY (`id`),
  ADD KEY `rov_idx` (`id_proveedor`),
  ADD KEY `pro_idx` (`id_producto`),
  ADD KEY `nose_fg_idx` (`id_unidad`);

--
-- Indices de la tabla `materia_prima`
--
ALTER TABLE `materia_prima`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_unidad_idx` (`id_unidad`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `mesas`
--
ALTER TABLE `mesas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `movimientos_capital`
--
ALTER TABLE `movimientos_capital`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `orden`
--
ALTER TABLE `orden`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Id_cliente` (`id_cliente`),
  ADD KEY `idx_cliente` (`id_cliente`),
  ADD KEY `idx_fecha` (`fecha`);

--
-- Indices de la tabla `orden_mesa`
--
ALTER TABLE `orden_mesa`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pokpoj_idx` (`id_mesa`),
  ADD KEY `qwrqwripo_idx` (`id_orden`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idMetodoPago` (`id_metodo_pago`);

--
-- Indices de la tabla `pagos_entrada_materia_prima`
--
ALTER TABLE `pagos_entrada_materia_prima`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_entrada_materia_prima_pago_idx` (`id_entrada`),
  ADD KEY `id_pago_materia_prima_pago_idx` (`id_metodo_pago`);

--
-- Indices de la tabla `pagos_entrada_producto_procesado`
--
ALTER TABLE `pagos_entrada_producto_procesado`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_entrada_producto_procesado_idx` (`id_entrada`),
  ADD KEY `id_pago_producto_procesado_idx` (`id_metodo_pago`);

--
-- Indices de la tabla `pago_reserva`
--
ALTER TABLE `pago_reserva`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id8_idx` (`id_reserva`),
  ADD KEY `id59_idx` (`id_pago`);

--
-- Indices de la tabla `pago_venta`
--
ALTER TABLE `pago_venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id59_idx` (`id_pago`),
  ADD KEY `id80333_idx` (`id_venta`);

--
-- Indices de la tabla `paquetes_mesas`
--
ALTER TABLE `paquetes_mesas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id121426_idx` (`id_paquete`),
  ADD KEY `id134135346_idx` (`id_mesa`);

--
-- Indices de la tabla `paquetes_reservacion`
--
ALTER TABLE `paquetes_reservacion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `productos_preparados`
--
ALTER TABLE `productos_preparados`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idCategoria` (`id_categoria`);

--
-- Indices de la tabla `productos_procesados`
--
ALTER TABLE `productos_procesados`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id20_idx` (`id_categoria`);

--
-- Indices de la tabla `producto_preparado_detalle_orden`
--
ALTER TABLE `producto_preparado_detalle_orden`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id11_idx` (`id_producto`),
  ADD KEY `id12_idx` (`id_orden`);

--
-- Indices de la tabla `producto_procesado_detalle_orden`
--
ALTER TABLE `producto_procesado_detalle_orden`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id12_idx` (`id_orden`),
  ADD KEY `id110_idx` (`id_producto`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `recetas`
--
ALTER TABLE `recetas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_p_idx` (`id_producto`);

--
-- Indices de la tabla `reservaciones`
--
ALTER TABLE `reservaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id1231446_idx` (`id_paquete`),
  ADD KEY `ioeiofjpowjf_idx` (`id_orden`),
  ADD KEY `poppuo_idx` (`id_caja`);

--
-- Indices de la tabla `unidades`
--
ALTER TABLE `unidades`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idCaja` (`id_caja`),
  ADD KEY `id-orden_idx` (`id_orden`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- AUTO_INCREMENT de la tabla `capital`
--
ALTER TABLE `capital`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `categorias_productos`
--
ALTER TABLE `categorias_productos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=116;

--
-- AUTO_INCREMENT de la tabla `categoria_materia_prima`
--
ALTER TABLE `categoria_materia_prima`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT de la tabla `configuraciones`
--
ALTER TABLE `configuraciones`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT de la tabla `delivery`
--
ALTER TABLE `delivery`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT de la tabla `detalles_entradas_materia_prima`
--
ALTER TABLE `detalles_entradas_materia_prima`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT de la tabla `detalles_receta`
--
ALTER TABLE `detalles_receta`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=261;

--
-- AUTO_INCREMENT de la tabla `entradas_materia_prima`
--
ALTER TABLE `entradas_materia_prima`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT de la tabla `entradas_producto_procesado`
--
ALTER TABLE `entradas_producto_procesado`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT de la tabla `materia_prima`
--
ALTER TABLE `materia_prima`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT de la tabla `mesas`
--
ALTER TABLE `mesas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT de la tabla `movimientos_capital`
--
ALTER TABLE `movimientos_capital`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=438;

--
-- AUTO_INCREMENT de la tabla `orden`
--
ALTER TABLE `orden`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7394;

--
-- AUTO_INCREMENT de la tabla `orden_mesa`
--
ALTER TABLE `orden_mesa`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=308;

--
-- AUTO_INCREMENT de la tabla `pagos_entrada_materia_prima`
--
ALTER TABLE `pagos_entrada_materia_prima`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT de la tabla `pagos_entrada_producto_procesado`
--
ALTER TABLE `pagos_entrada_producto_procesado`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `pago_reserva`
--
ALTER TABLE `pago_reserva`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=166;

--
-- AUTO_INCREMENT de la tabla `pago_venta`
--
ALTER TABLE `pago_venta`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=189;

--
-- AUTO_INCREMENT de la tabla `paquetes_mesas`
--
ALTER TABLE `paquetes_mesas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `paquetes_reservacion`
--
ALTER TABLE `paquetes_reservacion`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT de la tabla `productos_preparados`
--
ALTER TABLE `productos_preparados`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- AUTO_INCREMENT de la tabla `productos_procesados`
--
ALTER TABLE `productos_procesados`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=128;

--
-- AUTO_INCREMENT de la tabla `producto_preparado_detalle_orden`
--
ALTER TABLE `producto_preparado_detalle_orden`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=255;

--
-- AUTO_INCREMENT de la tabla `producto_procesado_detalle_orden`
--
ALTER TABLE `producto_procesado_detalle_orden`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT de la tabla `recetas`
--
ALTER TABLE `recetas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;

--
-- AUTO_INCREMENT de la tabla `reservaciones`
--
ALTER TABLE `reservaciones`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT de la tabla `unidades`
--
ALTER TABLE `unidades`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=123;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=273;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `delivery`
--
ALTER TABLE `delivery`
  ADD CONSTRAINT `asdfgh` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalles_entradas_materia_prima`
--
ALTER TABLE `detalles_entradas_materia_prima`
  ADD CONSTRAINT `id_entrada_materia_prima_1` FOREIGN KEY (`id_entrada`) REFERENCES `entradas_materia_prima` (`id`),
  ADD CONSTRAINT `id_materia_prima` FOREIGN KEY (`id_materia_prima`) REFERENCES `materia_prima` (`id`);

--
-- Filtros para la tabla `detalles_receta`
--
ALTER TABLE `detalles_receta`
  ADD CONSTRAINT `Id_materia_prima_ibfk_1` FOREIGN KEY (`id_materia_prima`) REFERENCES `materia_prima` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Id_receta_prima_ibfk_2` FOREIGN KEY (`id_receta`) REFERENCES `recetas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas_materia_prima`
--
ALTER TABLE `entradas_materia_prima`
  ADD CONSTRAINT `id_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas_producto_procesado`
--
ALTER TABLE `entradas_producto_procesado`
  ADD CONSTRAINT `nose_fg` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id`),
  ADD CONSTRAINT `pro` FOREIGN KEY (`id_producto`) REFERENCES `productos_procesados` (`id`),
  ADD CONSTRAINT `rov` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id`);

--
-- Filtros para la tabla `materia_prima`
--
ALTER TABLE `materia_prima`
  ADD CONSTRAINT `id_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria_materia_prima` (`id`),
  ADD CONSTRAINT `id_unidad` FOREIGN KEY (`id_unidad`) REFERENCES `unidades` (`id`);

--
-- Filtros para la tabla `orden`
--
ALTER TABLE `orden`
  ADD CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id`);

--
-- Filtros para la tabla `orden_mesa`
--
ALTER TABLE `orden_mesa`
  ADD CONSTRAINT `pokpoj` FOREIGN KEY (`id_mesa`) REFERENCES `mesas` (`id`),
  ADD CONSTRAINT `qwrqwripo` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id`);

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodo_pago` (`id`);

--
-- Filtros para la tabla `pagos_entrada_materia_prima`
--
ALTER TABLE `pagos_entrada_materia_prima`
  ADD CONSTRAINT `id_entrada_materia_prima_pago` FOREIGN KEY (`id_entrada`) REFERENCES `entradas_materia_prima` (`id`),
  ADD CONSTRAINT `id_pago_materia_prima_pago` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodo_pago` (`id`);

--
-- Filtros para la tabla `pagos_entrada_producto_procesado`
--
ALTER TABLE `pagos_entrada_producto_procesado`
  ADD CONSTRAINT `id_entrada_producto_procesado` FOREIGN KEY (`id_entrada`) REFERENCES `entradas_producto_procesado` (`id`),
  ADD CONSTRAINT `id_pago_producto_procesado` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodo_pago` (`id`);

--
-- Filtros para la tabla `pago_reserva`
--
ALTER TABLE `pago_reserva`
  ADD CONSTRAINT `id59` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `id8` FOREIGN KEY (`id_reserva`) REFERENCES `reservaciones` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Filtros para la tabla `pago_venta`
--
ALTER TABLE `pago_venta`
  ADD CONSTRAINT `id59022` FOREIGN KEY (`id_pago`) REFERENCES `pagos` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `id80333` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Filtros para la tabla `paquetes_mesas`
--
ALTER TABLE `paquetes_mesas`
  ADD CONSTRAINT `id121426` FOREIGN KEY (`id_paquete`) REFERENCES `paquetes_reservacion` (`id`),
  ADD CONSTRAINT `id134135346` FOREIGN KEY (`id_mesa`) REFERENCES `mesas` (`id`);

--
-- Filtros para la tabla `productos_preparados`
--
ALTER TABLE `productos_preparados`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_productos` (`id`);

--
-- Filtros para la tabla `productos_procesados`
--
ALTER TABLE `productos_procesados`
  ADD CONSTRAINT `id20` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_productos` (`id`);

--
-- Filtros para la tabla `producto_preparado_detalle_orden`
--
ALTER TABLE `producto_preparado_detalle_orden`
  ADD CONSTRAINT `id11` FOREIGN KEY (`id_producto`) REFERENCES `productos_preparados` (`id`),
  ADD CONSTRAINT `id12` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id`);

--
-- Filtros para la tabla `producto_procesado_detalle_orden`
--
ALTER TABLE `producto_procesado_detalle_orden`
  ADD CONSTRAINT `id110` FOREIGN KEY (`id_producto`) REFERENCES `productos_procesados` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `id568` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id`);

--
-- Filtros para la tabla `recetas`
--
ALTER TABLE `recetas`
  ADD CONSTRAINT `NON0ON` FOREIGN KEY (`id_producto`) REFERENCES `productos_preparados` (`id`);

--
-- Filtros para la tabla `reservaciones`
--
ALTER TABLE `reservaciones`
  ADD CONSTRAINT `id1231446` FOREIGN KEY (`id_paquete`) REFERENCES `paquetes_reservacion` (`id`),
  ADD CONSTRAINT `ioeiofjpowjf` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id`),
  ADD CONSTRAINT `poppuo` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `srxtrxrxr` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
