-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-03-2026 a las 20:52:20
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
CREATE DATABASE IF NOT EXISTS `burgerhouse` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `burgerhouse`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

DROP TABLE IF EXISTS `caja`;
CREATE TABLE IF NOT EXISTS `caja` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `monto_inicial_dolar` float NOT NULL,
  `monto_inicial_bs` float NOT NULL,
  `monto_final_bs` float DEFAULT NULL,
  `monto_final_dolar` float DEFAULT NULL,
  `fecha_apertura` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_cierre` datetime DEFAULT NULL,
  `estado` int NOT NULL DEFAULT '1',
  `total_ventas` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `capital`
--

DROP TABLE IF EXISTS `capital`;
CREATE TABLE IF NOT EXISTS `capital` (
  `id` int NOT NULL AUTO_INCREMENT,
  `monto` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias_productos`
--

DROP TABLE IF EXISTS `categorias_productos`;
CREATE TABLE IF NOT EXISTS `categorias_productos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_materia_prima`
--

DROP TABLE IF EXISTS `categoria_materia_prima`;
CREATE TABLE IF NOT EXISTS `categoria_materia_prima` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

DROP TABLE IF EXISTS `clientes`;
CREATE TABLE IF NOT EXISTS `clientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `apellido` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `documento` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuraciones`
--

DROP TABLE IF EXISTS `configuraciones`;
CREATE TABLE IF NOT EXISTS `configuraciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `llave` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `valor` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `delivery`
--

DROP TABLE IF EXISTS `delivery`;
CREATE TABLE IF NOT EXISTS `delivery` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_usuario_delivery` int NOT NULL,
  `id_venta` int NOT NULL,
  `active` tinyint DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `asdfg_idx` (`id_usuario_delivery`),
  KEY `asdfgh_idx` (`id_venta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_entradas_materia_prima`
--

DROP TABLE IF EXISTS `detalles_entradas_materia_prima`;
CREATE TABLE IF NOT EXISTS `detalles_entradas_materia_prima` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(45) NOT NULL,
  `id_materia_prima` int NOT NULL,
  `id_entrada` int NOT NULL,
  `fecha_vencimiento` datetime NOT NULL,
  `existencia` float NOT NULL,
  `cantidad` float DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  `broken` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `id_materia_prima_idx` (`id_materia_prima`),
  KEY `id_entrada_materia_prima_1_idx` (`id_entrada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Disparadores `detalles_entradas_materia_prima`
--
DROP TRIGGER IF EXISTS `detalles_entradas_materia_prima_AFTER_INSERT`;
DELIMITER $$
CREATE TRIGGER `detalles_entradas_materia_prima_AFTER_INSERT` AFTER INSERT ON `detalles_entradas_materia_prima` FOR EACH ROW BEGIN
 -- Actualizar la existencia sumando la cantidad de la nueva entrada
    UPDATE materia_prima 
    SET existencia = CAST(existencia AS DECIMAL(10,2)) + NEW.cantidad
    WHERE id = NEW.id_materia_prima;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `detalles_entradas_materia_prima_AFTER_UPDATE`;
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
DROP TRIGGER IF EXISTS `detalles_entradas_materia_prima_BEFORE_UPDATE`;
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

DROP TABLE IF EXISTS `detalles_receta`;
CREATE TABLE IF NOT EXISTS `detalles_receta` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_receta` int NOT NULL,
  `id_materia_prima` int NOT NULL,
  `cantidad` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Id_receta` (`id_receta`,`id_materia_prima`),
  KEY `Id_materia_prima_ibfk_1` (`id_materia_prima`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas_materia_prima`
--

DROP TABLE IF EXISTS `entradas_materia_prima`;
CREATE TABLE IF NOT EXISTS `entradas_materia_prima` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_proveedor` int NOT NULL,
  `fecha_compra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `id_provedor` (`id_proveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas_producto_procesado`
--

DROP TABLE IF EXISTS `entradas_producto_procesado`;
CREATE TABLE IF NOT EXISTS `entradas_producto_procesado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_producto` int NOT NULL,
  `id_proveedor` int NOT NULL,
  `id_unidad` int NOT NULL,
  `fecha_compra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_vencimiento` datetime DEFAULT NULL,
  `existencia` float NOT NULL,
  `cantidad` float NOT NULL,
  `active` int NOT NULL DEFAULT '1',
  `broken` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `rov_idx` (`id_proveedor`),
  KEY `pro_idx` (`id_producto`),
  KEY `nose_fg_idx` (`id_unidad`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `entradas_producto_procesado`
--
DROP TRIGGER IF EXISTS `entradas_producto_procesado_AFTER_INSERT`;
DELIMITER $$
CREATE TRIGGER `entradas_producto_procesado_AFTER_INSERT` AFTER INSERT ON `entradas_producto_procesado` FOR EACH ROW BEGIN
 -- Actualizar la existencia sumando la cantidad de la nueva entrada
    UPDATE productos_procesados
    SET existencia = CAST(existencia AS DECIMAL(10,2)) + NEW.cantidad
    WHERE id = NEW.id_producto;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `entradas_producto_procesado_AFTER_UPDATE`;
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
DROP TRIGGER IF EXISTS `entradas_producto_procesado_BEFORE_UPDATE`;
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

DROP TABLE IF EXISTS `materia_prima`;
CREATE TABLE IF NOT EXISTS `materia_prima` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `id_unidad` int NOT NULL,
  `nombre` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `stock_min` int NOT NULL,
  `stock_max` int NOT NULL,
  `existencia` float NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `id_unidad_idx` (`id_unidad`),
  KEY `id_categoria` (`id_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mesas`
--

DROP TABLE IF EXISTS `mesas`;
CREATE TABLE IF NOT EXISTS `mesas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sillas` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `estado` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'LIBRE',
  `vip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `active` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodo_pago`
--

DROP TABLE IF EXISTS `metodo_pago`;
CREATE TABLE IF NOT EXISTS `metodo_pago` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos_capital`
--

DROP TABLE IF EXISTS `movimientos_capital`;
CREATE TABLE IF NOT EXISTS `movimientos_capital` (
  `id` int NOT NULL AUTO_INCREMENT,
  `monto` float NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tasa` float NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Disparadores `movimientos_capital`
--
DROP TRIGGER IF EXISTS `movimientos_capital_AFTER_INSERT`;
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

DROP TABLE IF EXISTS `orden`;
CREATE TABLE IF NOT EXISTS `orden` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL,
  `nro_orden` float NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `tipo` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Id_cliente` (`id_cliente`),
  KEY `idx_cliente` (`id_cliente`),
  KEY `idx_fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_mesa`
--

DROP TABLE IF EXISTS `orden_mesa`;
CREATE TABLE IF NOT EXISTS `orden_mesa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_orden` int NOT NULL,
  `id_mesa` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pokpoj_idx` (`id_mesa`),
  KEY `qwrqwripo_idx` (`id_orden`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

DROP TABLE IF EXISTS `pagos`;
CREATE TABLE IF NOT EXISTS `pagos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_metodo_pago` int NOT NULL,
  `monto` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tasa` float NOT NULL,
  `comprobante` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `referencia` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idMetodoPago` (`id_metodo_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Disparadores `pagos`
--
DROP TRIGGER IF EXISTS `pagos_AFTER_INSERT`;
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

DROP TABLE IF EXISTS `pagos_entrada_materia_prima`;
CREATE TABLE IF NOT EXISTS `pagos_entrada_materia_prima` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_metodo_pago` int NOT NULL,
  `id_entrada` int NOT NULL,
  `tasa` float NOT NULL DEFAULT '1',
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `precio_compra` float NOT NULL,
  `comprobante` varchar(500) NOT NULL,
  `referencia` varchar(500) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_entrada_materia_prima_pago_idx` (`id_entrada`),
  KEY `id_pago_materia_prima_pago_idx` (`id_metodo_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Disparadores `pagos_entrada_materia_prima`
--
DROP TRIGGER IF EXISTS `pagos_entrada_materia_prima_AFTER_INSERT`;
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

DROP TABLE IF EXISTS `pagos_entrada_producto_procesado`;
CREATE TABLE IF NOT EXISTS `pagos_entrada_producto_procesado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_entrada` int NOT NULL,
  `id_metodo_pago` int NOT NULL,
  `tasa` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `precio_compra` float NOT NULL,
  `comprobante` varchar(500) NOT NULL,
  `referencia` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_entrada_producto_procesado_idx` (`id_entrada`),
  KEY `id_pago_producto_procesado_idx` (`id_metodo_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Disparadores `pagos_entrada_producto_procesado`
--
DROP TRIGGER IF EXISTS `pagos_entrada_producto_procesado_AFTER_INSERT`;
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

DROP TABLE IF EXISTS `pago_reserva`;
CREATE TABLE IF NOT EXISTS `pago_reserva` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_reserva` int DEFAULT NULL,
  `id_pago` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id8_idx` (`id_reserva`),
  KEY `id59_idx` (`id_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago_venta`
--

DROP TABLE IF EXISTS `pago_venta`;
CREATE TABLE IF NOT EXISTS `pago_venta` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_venta` int DEFAULT NULL,
  `id_pago` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id59_idx` (`id_pago`),
  KEY `id80333_idx` (`id_venta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquetes_mesas`
--

DROP TABLE IF EXISTS `paquetes_mesas`;
CREATE TABLE IF NOT EXISTS `paquetes_mesas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_paquete` int DEFAULT NULL,
  `id_mesa` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id121426_idx` (`id_paquete`),
  KEY `id134135346_idx` (`id_mesa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquetes_reservacion`
--

DROP TABLE IF EXISTS `paquetes_reservacion`;
CREATE TABLE IF NOT EXISTS `paquetes_reservacion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(500) NOT NULL,
  `precio` float NOT NULL,
  `active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_preparados`
--

DROP TABLE IF EXISTS `productos_preparados`;
CREATE TABLE IF NOT EXISTS `productos_preparados` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL DEFAULT '10',
  `nombre` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `precio` float NOT NULL,
  `detalles` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idCategoria` (`id_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_procesados`
--

DROP TABLE IF EXISTS `productos_procesados`;
CREATE TABLE IF NOT EXISTS `productos_procesados` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `precio` float NOT NULL,
  `detalles` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `id_categoria` int NOT NULL,
  `existencia` float NOT NULL DEFAULT '0',
  `stock_min` float NOT NULL DEFAULT '0',
  `stock_max` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `id20_idx` (`id_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_preparado_detalle_orden`
--

DROP TABLE IF EXISTS `producto_preparado_detalle_orden`;
CREATE TABLE IF NOT EXISTS `producto_preparado_detalle_orden` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `id_orden` int NOT NULL,
  `cantidad` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `descripcion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `adicionales` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `id11_idx` (`id_producto`),
  KEY `id12_idx` (`id_orden`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_procesado_detalle_orden`
--

DROP TABLE IF EXISTS `producto_procesado_detalle_orden`;
CREATE TABLE IF NOT EXISTS `producto_procesado_detalle_orden` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `id_orden` int NOT NULL,
  `cantidad` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id12_idx` (`id_orden`),
  KEY `id110_idx` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
CREATE TABLE IF NOT EXISTS `proveedores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `razon_social` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `documento` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `n_telefono1` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `n_telefono2` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `direccion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recetas`
--

DROP TABLE IF EXISTS `recetas`;
CREATE TABLE IF NOT EXISTS `recetas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `id_p_idx` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reservaciones`
--

DROP TABLE IF EXISTS `reservaciones`;
CREATE TABLE IF NOT EXISTS `reservaciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_paquete` int NOT NULL,
  `id_orden` int NOT NULL,
  `id_caja` int NOT NULL,
  `descripcion` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fecha_bloqueo` datetime DEFAULT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_final` datetime DEFAULT NULL,
  `metodo_pedido` varchar(45) DEFAULT NULL,
  `status` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id1231446_idx` (`id_paquete`),
  KEY `ioeiofjpowjf_idx` (`id_orden`),
  KEY `poppuo_idx` (`id_caja`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades`
--

DROP TABLE IF EXISTS `unidades`;
CREATE TABLE IF NOT EXISTS `unidades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `alias` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

DROP TABLE IF EXISTS `ventas`;
CREATE TABLE IF NOT EXISTS `ventas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_caja` int NOT NULL,
  `id_orden` int NOT NULL,
  `IVA` float DEFAULT NULL,
  `monto_final` float NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `direccion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idCaja` (`id_caja`),
  KEY `id-orden_idx` (`id_orden`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inventario_materia_prima`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vista_inventario_materia_prima`;
CREATE TABLE IF NOT EXISTS `vista_inventario_materia_prima` (
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
DROP VIEW IF EXISTS `vista_inventario_productos_procesados`;
CREATE TABLE IF NOT EXISTS `vista_inventario_productos_procesados` (
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
DROP VIEW IF EXISTS `vista_resumen_clientes`;
CREATE TABLE IF NOT EXISTS `vista_resumen_clientes` (
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
DROP VIEW IF EXISTS `vista_resumen_financiero`;
CREATE TABLE IF NOT EXISTS `vista_resumen_financiero` (
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
DROP VIEW IF EXISTS `vista_stats_ordenes`;
CREATE TABLE IF NOT EXISTS `vista_stats_ordenes` (
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

DROP VIEW IF EXISTS `vista_inventario_materia_prima`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario_materia_prima`  AS WITH     `entradas_totales` as (select `detalles_entradas_materia_prima`.`id_materia_prima` AS `id_materia_prima`,sum(`detalles_entradas_materia_prima`.`cantidad`) AS `total_comprado` from `detalles_entradas_materia_prima` group by `detalles_entradas_materia_prima`.`id_materia_prima`), `valor_entradas_normalizado` as (select `emp`.`id_materia_prima` AS `id_materia_prima`,sum((case when (`pemp`.`id_metodo_pago` in (1,2,12,13)) then `pemp`.`precio_compra` else (`pemp`.`precio_compra` / `pemp`.`tasa`) end)) AS `costo_total_dolares`,sum(`emp`.`cantidad`) AS `cantidad_total` from (`pagos_entrada_materia_prima` `pemp` join `detalles_entradas_materia_prima` `emp` on((`pemp`.`id_entrada` = `emp`.`id_entrada`))) group by `emp`.`id_materia_prima`) select `mp`.`nombre` AS `materia_prima`,coalesce(`et`.`total_comprado`,0) AS `entradas`,(coalesce(`et`.`total_comprado`,0) - `mp`.`existencia`) AS `salidas`,(case when (`ven`.`cantidad_total` > 0) then round(((`ven`.`costo_total_dolares` / `ven`.`cantidad_total`) * `mp`.`existencia`),2) else 0 end) AS `valor_stock`,`mp`.`existencia` AS `stock_actual`,`u`.`alias` AS `unidad` from (((`materia_prima` `mp` left join `unidades` `u` on((`mp`.`id_unidad` = `u`.`id`))) left join `entradas_totales` `et` on((`mp`.`id` = `et`.`id_materia_prima`))) left join `valor_entradas_normalizado` `ven` on((`mp`.`id` = `ven`.`id_materia_prima`))) where (`mp`.`active` = 1)  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inventario_productos_procesados`
--
DROP TABLE IF EXISTS `vista_inventario_productos_procesados`;

DROP VIEW IF EXISTS `vista_inventario_productos_procesados`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario_productos_procesados`  AS WITH     `entradas_totales` as (select `entradas_producto_procesado`.`id_producto` AS `id_producto`,sum(`entradas_producto_procesado`.`cantidad`) AS `total_comprado` from `entradas_producto_procesado` group by `entradas_producto_procesado`.`id_producto`), `valor_entradas_normalizado` as (select `epp`.`id_producto` AS `id_producto`,sum((case when (`pepp`.`id_metodo_pago` in (1,2,12,13)) then `pepp`.`precio_compra` else (`pepp`.`precio_compra` / `pepp`.`tasa`) end)) AS `costo_total_dolares`,sum(`epp`.`cantidad`) AS `cantidad_total` from (`pagos_entrada_producto_procesado` `pepp` join `entradas_producto_procesado` `epp` on((`pepp`.`id_entrada` = `epp`.`id`))) group by `epp`.`id_producto`) select `pp`.`nombre` AS `producto`,coalesce(`et`.`total_comprado`,0) AS `entradas`,(coalesce(`et`.`total_comprado`,0) - `pp`.`existencia`) AS `salidas`,(case when (`ven`.`cantidad_total` > 0) then round(((`ven`.`costo_total_dolares` / `ven`.`cantidad_total`) * `pp`.`existencia`),2) else 0 end) AS `valor_stock`,`pp`.`existencia` AS `stock_actual` from ((`productos_procesados` `pp` left join `entradas_totales` `et` on((`pp`.`id` = `et`.`id_producto`))) left join `valor_entradas_normalizado` `ven` on((`pp`.`id` = `ven`.`id_producto`))) where (`pp`.`active` = 1)  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_resumen_clientes`
--
DROP TABLE IF EXISTS `vista_resumen_clientes`;

DROP VIEW IF EXISTS `vista_resumen_clientes`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_resumen_clientes`  AS WITH     `total_gasto` as (select `o`.`id_cliente` AS `id_cliente`,sum(`v`.`monto_final`) AS `total_gastado` from (`ventas` `v` join `orden` `o` on((`o`.`id` = `v`.`id_orden`))) where (`o`.`id_cliente` is not null) group by `o`.`id_cliente`), `ultima_orden` as (select `orden`.`id_cliente` AS `id_cliente`,max(`orden`.`fecha`) AS `ultima_fecha` from `orden` where (`orden`.`id_cliente` is not null) group by `orden`.`id_cliente`), `productos_cliente` as (select `o`.`id_cliente` AS `id_cliente`,`p`.`nombre` AS `producto`,`p`.`imagen` AS `imagen`,sum(`od`.`cantidad`) AS `total_consumido`,row_number() OVER (PARTITION BY `o`.`id_cliente` ORDER BY sum(`od`.`cantidad`) desc )  AS `rn` from ((`orden` `o` join `producto_preparado_detalle_orden` `od` on((`od`.`id_orden` = `o`.`id`))) join `productos_preparados` `p` on((`p`.`id` = `od`.`id_producto`))) where ((`p`.`tipo` = 'producto') and (`o`.`id_cliente` is not null)) group by `o`.`id_cliente`,`p`.`nombre`,`p`.`imagen`), `clientes_con_productos` as (select distinct `productos_cliente`.`id_cliente` AS `id_cliente` from `productos_cliente`), `top_1` as (select `productos_cliente`.`id_cliente` AS `id_cliente`,`productos_cliente`.`producto` AS `producto1`,`productos_cliente`.`imagen` AS `imagen1` from `productos_cliente` where (`productos_cliente`.`rn` = 1)), `top_2` as (select `productos_cliente`.`id_cliente` AS `id_cliente`,`productos_cliente`.`producto` AS `producto2`,`productos_cliente`.`imagen` AS `imagen2` from `productos_cliente` where (`productos_cliente`.`rn` = 2)), `top_3` as (select `productos_cliente`.`id_cliente` AS `id_cliente`,`productos_cliente`.`producto` AS `producto3`,`productos_cliente`.`imagen` AS `imagen3` from `productos_cliente` where (`productos_cliente`.`rn` = 3)) select `c`.`nombre` AS `cliente`,`c`.`apellido` AS `apellido`,`c`.`telefono` AS `telefono`,date_format(`uo`.`ultima_fecha`,'%Y-%m-%d %H:%i:%s') AS `ultima_orden`,round(coalesce(`tg`.`total_gastado`,0),2) AS `total_gastado`,coalesce(`t1`.`producto1`,'Sin producto') AS `producto_1`,`t1`.`imagen1` AS `imagen_1`,coalesce(`t2`.`producto2`,'Sin producto') AS `producto_2`,`t2`.`imagen2` AS `imagen_2`,coalesce(`t3`.`producto3`,'Sin producto') AS `producto_3`,`t3`.`imagen3` AS `imagen_3` from ((((((`clientes` `c` join `clientes_con_productos` `cp` on((`c`.`id` = `cp`.`id_cliente`))) left join `total_gasto` `tg` on((`c`.`id` = `tg`.`id_cliente`))) left join `ultima_orden` `uo` on((`c`.`id` = `uo`.`id_cliente`))) left join `top_1` `t1` on((`c`.`id` = `t1`.`id_cliente`))) left join `top_2` `t2` on((`c`.`id` = `t2`.`id_cliente`))) left join `top_3` `t3` on((`c`.`id` = `t3`.`id_cliente`))) where (`c`.`active` = 1)  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_resumen_financiero`
--
DROP TABLE IF EXISTS `vista_resumen_financiero`;

DROP VIEW IF EXISTS `vista_resumen_financiero`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_resumen_financiero`  AS SELECT round(ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) > 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0),2) AS `ingresos`, round(ifnull(sum((case when (((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) > 0) and (`movimientos_capital`.`descripcion` like '%Ingreso por venta%')) then (`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) end)),0),2) AS `ventas`, round(ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) < 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0),2) AS `gastos`, round((ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) > 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0) + ifnull(sum((case when ((`movimientos_capital`.`monto` / `movimientos_capital`.`tasa`) < 0) then (`movimientos_capital`.`monto` * `movimientos_capital`.`tasa`) end)),0)),2) AS `utilidad_neta` FROM `movimientos_capital` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_stats_ordenes`
--
DROP TABLE IF EXISTS `vista_stats_ordenes`;

DROP VIEW IF EXISTS `vista_stats_ordenes`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_stats_ordenes`  AS SELECT count(`orden`.`id`) AS `total`, sum((`orden`.`status` = 'por verificar')) AS `por verificar`, sum((`orden`.`status` = 'en cocina')) AS `en cocina`, sum((`orden`.`status` = 'para despachar')) AS `para despachar`, sum((`orden`.`status` = 'en camino')) AS `en camino`, sum((`orden`.`status` = 'entregada')) AS `entregada`, sum((`orden`.`status` = 'pagado')) AS `pagado`, sum((`orden`.`status` = 'en mesa')) AS `en mesa`, sum((`orden`.`status` = 'anulada')) AS `anulada`, sum((`orden`.`status` = '1')) AS `terminada` FROM `orden` ;

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
