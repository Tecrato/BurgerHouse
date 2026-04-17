-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-04-2026 a las 22:37:36
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
-- Base de datos: `usuarios_burgerhouse`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

CREATE TABLE `bitacora` (
  `id` int NOT NULL,
  `id_usuario` int NOT NULL,
  `tabla` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `accion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `descripcion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `bitacora`
--

INSERT INTO `bitacora` (`id`, `id_usuario`, `tabla`, `accion`, `fecha`, `descripcion`) VALUES
(26, 11, 'Adicionales', 'Agregar', '2025-05-28 08:17:19', 'Se agrego un nuevo adicional'),
(27, 11, 'Adicionales', 'Eliminacion', '2025-05-28 08:18:35', 'Se ha eliminado un adicional'),
(28, 11, 'Clientes', 'Eliminacion', '2025-05-28 08:49:48', 'Se elimino un cliente'),
(29, 11, 'Clientes', 'Actualizacion', '2025-05-28 08:51:01', 'Se actualizo un cliente'),
(30, 11, 'Clientes', 'Agregar', '2025-05-28 08:51:47', 'Se agrego un nuevo cliente'),
(31, 11, 'Clientes', 'Actualizacion', '2025-05-28 08:54:06', 'Se actualizo un cliente'),
(32, 11, 'Papelera', 'Restaurar', '2025-05-28 10:05:24', 'Se ha restaurado un elemento de la papelera'),
(33, 11, 'Producto procesado', 'Agregar', '2025-05-28 10:35:32', 'Se agrego un producto procesado'),
(34, 11, 'Papelera', 'Restaurar', '2025-05-28 10:47:39', 'Se ha restaurado un elemento de la papelera'),
(35, 11, 'Orden de domicilio', 'Creacion', '2025-05-28 11:38:22', 'Se creo una orden de domicilio'),
(36, 11, 'Producto procesado', 'Actualizacion', '2025-05-28 11:48:27', 'Se agrego un producto procesado'),
(37, 11, 'Clientes', 'Agregar', '2025-05-28 11:48:54', 'Se agrego un nuevo cliente'),
(38, 11, 'Caja', 'Agregar', '2025-05-28 12:51:06', 'Se abrio una caja'),
(39, 11, 'Orden de domicilio', 'Creacion', '2025-05-28 13:41:29', 'Se creo una orden de domicilio'),
(40, 11, 'Orden de cocina', 'Preparado', '2025-05-28 14:36:13', 'Se preparo una orden de cocina'),
(41, 11, 'Orden de cocina', 'Preparado', '2025-05-28 14:40:43', 'Se preparo una orden de cocina'),
(42, 11, 'Orden de delivery', 'Orden aceptada', '2025-05-28 15:13:47', 'Se acepto una orden de delivery'),
(43, 11, 'Usuarios', 'Login', '2025-05-29 10:11:20', 'inicio de sesion'),
(44, 11, 'orden', 'Actualizacion', '2025-05-29 13:22:41', 'Se verifico la orden 10466000'),
(45, 11, 'Orden de cocina', 'Preparado', '2025-05-29 13:31:15', 'Se preparo una orden de cocina'),
(46, 11, 'orden', 'Actualizacion', '2025-05-29 13:33:38', 'Se anulo la orden 83599400'),
(47, 11, 'orden', 'Actualizacion', '2025-05-29 13:33:44', 'Se verifico la orden 10466000'),
(48, 11, 'Orden de cocina', 'Preparado', '2025-05-29 13:33:50', 'Se preparo una orden de cocina'),
(49, 11, 'Orden de cocina', 'Preparado', '2025-05-29 17:24:23', 'Se preparo una orden de cocina'),
(50, 11, 'orden', 'Actualizacion', '2025-05-29 17:27:48', 'Se anulo la orden 83599400'),
(51, 11, 'Usuarios', 'Login', '2025-05-29 19:53:06', 'inicio de sesion'),
(52, 11, 'Usuarios', 'Agregar', '2025-05-29 21:47:47', 'Se agrego un usuario'),
(53, 11, 'Clientes', 'Eliminacion', '2025-05-29 21:50:38', 'Se elimino un cliente'),
(54, 11, 'Clientes', 'Eliminacion', '2025-05-29 21:50:42', 'Se elimino un cliente'),
(55, 11, 'orden', 'Actualizacion', '2025-05-29 22:00:50', 'Se verifico la orden 83599400'),
(56, 11, 'Orden de cocina', 'Preparado', '2025-05-29 22:00:59', 'Se preparo una orden de cocina'),
(57, 11, 'Orden de delivery', 'Orden aceptada', '2025-05-29 22:01:35', 'Se acepto una orden de delivery'),
(58, 11, 'Orden de delivery', 'Orden aceptada', '2025-05-29 22:08:21', 'Se acepto una orden de delivery'),
(59, 11, 'Orden de delivery', 'Orden aceptada', '2025-05-29 22:19:25', 'Se acepto una orden de delivery'),
(60, 11, 'Orden de delivery', 'Orden aceptada', '2025-05-29 22:20:24', 'Se acepto una orden de delivery'),
(61, 11, 'Orden de delivery', 'Orden aceptada', '2025-05-29 22:21:35', 'Se acepto una orden de delivery'),
(62, 14, 'Usuarios', 'Login', '2025-06-02 13:52:53', 'inicio de sesion'),
(63, 11, 'Orden de delivery', 'Orden aceptada', '2025-06-04 14:22:56', 'Se acepto una orden de delivery'),
(64, 11, 'Usuarios', 'Login', '2025-06-05 12:25:50', 'inicio de sesion'),
(65, 11, 'Usuarios', 'Login', '2025-06-06 11:19:40', 'inicio de sesion'),
(66, 11, 'orden', 'Actualizacion', '2025-06-06 11:20:23', 'Se verifico la orden 10466000'),
(67, 11, 'Entradas', 'Agregado', '2025-06-06 11:24:28', 'Se ha agregado una entrada de materia prima'),
(68, 11, 'Caja', 'Agregar', '2025-06-06 14:58:16', 'Se abrio una caja'),
(69, 11, 'Orden de domicilio', 'Creacion', '2025-06-06 15:10:54', 'Se creo una orden de domicilio'),
(70, 11, 'Orden de domicilio', 'Creacion', '2025-06-06 16:54:58', 'Se creo una orden de domicilio'),
(71, 11, 'orden', 'Actualizacion', '2025-06-06 16:56:33', 'Se anulo la orden 42777800'),
(72, 11, 'orden', 'Actualizacion', '2025-06-06 16:58:21', 'Se verifico la orden 42777800'),
(73, 11, 'orden', 'Actualizacion', '2025-06-06 17:02:27', 'Se verifico la orden 42777800'),
(74, 11, 'orden', 'Actualizacion', '2025-06-06 17:11:20', 'Se verifico la orden 42777800'),
(75, 11, 'Orden de cocina', 'Preparado', '2025-06-06 17:23:16', 'Se preparo una orden de cocina'),
(76, 11, 'Orden de cocina', 'Preparado', '2025-06-06 17:24:11', 'Se preparo una orden de cocina'),
(77, 11, 'orden', 'Actualizacion', '2025-06-06 17:25:30', 'Se entrego la orden 42777800'),
(78, 11, 'orden', 'Actualizacion', '2025-06-06 17:25:49', 'Se verifico la orden 42777800'),
(79, 11, 'orden', 'Actualizacion', '2025-06-06 17:29:37', 'Se verifico la orden 42777800'),
(80, 11, 'Orden de cocina', 'Preparado', '2025-06-06 17:29:48', 'Se preparo una orden de cocina'),
(81, 11, 'orden', 'Actualizacion', '2025-06-06 17:30:00', 'Se entrego la orden 42777800'),
(82, 11, 'orden', 'Actualizacion', '2025-06-06 17:41:37', 'Se verifico la orden 42777800'),
(83, 11, 'Orden de cocina', 'Preparado', '2025-06-06 17:45:55', 'Se preparo una orden de cocina'),
(84, 11, 'Orden de cocina', 'Preparado', '2025-06-06 17:49:35', 'Se preparo una orden de cocina'),
(85, 11, 'Usuarios', 'Login', '2025-06-06 21:05:09', 'inicio de sesion'),
(86, 11, 'Usuarios', 'Login', '2025-06-06 21:17:43', 'inicio de sesion'),
(87, 11, 'Usuarios', 'Login', '2025-06-06 22:11:54', 'inicio de sesion'),
(88, 11, 'Usuarios', 'Login', '2025-06-06 22:24:05', 'inicio de sesion'),
(89, 11, 'Usuarios', 'Login', '2025-06-07 12:36:46', 'inicio de sesion'),
(90, 11, 'Proveedores', 'Agregar', '2025-06-07 12:56:54', 'Se Agrego un proveedor'),
(91, 11, 'Usuarios', 'Login', '2025-06-09 11:06:06', 'inicio de sesion'),
(92, 11, 'Usuarios', 'Login', '2025-06-10 10:11:46', 'inicio de sesion'),
(93, 11, 'Caja', 'Agregar', '2025-06-10 15:51:36', 'Se abrio una caja'),
(94, 11, 'Orden de domicilio', 'Creacion', '2025-06-10 15:56:08', 'Se creo una orden de domicilio'),
(95, 11, 'Productos Preparados', 'Actualizacion', '2025-06-10 16:35:05', 'Se actualizo un producto preparado'),
(96, 11, 'Usuarios', 'Login', '2025-06-11 10:12:25', 'inicio de sesion'),
(97, 11, 'Caja', 'Agregar', '2025-06-11 12:08:15', 'Se abrio una caja'),
(98, 11, 'Orden de domicilio', 'Creacion', '2025-06-11 12:11:34', 'Se creo una orden de domicilio'),
(99, 11, 'Orden de domicilio', 'Creacion', '2025-06-11 12:14:19', 'Se creo una orden de domicilio'),
(100, 11, 'Orden de domicilio', 'Creacion', '2025-06-11 12:17:01', 'Se creo una orden de domicilio'),
(101, 11, 'Usuarios', 'Login', '2025-06-12 15:27:59', 'inicio de sesion'),
(102, 11, 'Usuarios', 'Login', '2025-06-13 09:41:13', 'inicio de sesion'),
(103, 11, 'capital', 'Agregar', '2025-06-13 15:06:39', 'Guardar Ingreso en capital de 10 $'),
(104, 11, 'capital', 'Agregar', '2025-06-13 15:07:46', 'Guardar Gasto en capital de 10 $'),
(105, 11, 'Usuarios', 'Login', '2025-06-16 10:29:57', 'inicio de sesion'),
(106, 11, 'Caja', 'Agregar', '2025-06-16 14:49:43', 'Se abrio una caja'),
(107, 11, 'Orden de domicilio', 'Creacion', '2025-06-16 14:51:06', 'Se creo una orden de domicilio'),
(108, 11, 'Orden de domicilio', 'Creacion', '2025-06-16 15:56:19', 'Se creo una orden de domicilio'),
(109, 11, 'Usuarios', 'Login', '2025-06-17 12:00:59', 'inicio de sesion'),
(110, 11, 'Caja', 'Cerrar', '2025-06-17 12:15:17', 'Se cerro la caja 15'),
(111, 11, 'Caja', 'Cerrar', '2025-06-17 12:16:11', 'Se cerro la caja 16'),
(112, 11, 'Caja', 'Cerrar', '2025-06-17 12:19:25', 'Se cerro la caja 11'),
(113, 11, 'Caja', 'Agregar', '2025-06-17 14:03:35', 'Se abrio una caja'),
(114, 11, 'Caja', 'Cerrar', '2025-06-17 14:04:58', 'Se cerro la caja 17'),
(115, 11, 'Caja', 'Agregar', '2025-06-17 14:09:59', 'Se abrio una caja'),
(116, 11, 'Caja', 'Cerrar', '2025-06-17 14:11:09', 'Se cerro la caja 18'),
(117, 11, 'Producto procesado', 'Actualizacion', '2025-06-17 16:44:44', 'Se agrego un producto procesado'),
(118, 11, 'Caja', 'Cerrar', '2025-06-17 19:03:26', 'Se cerro la caja 18'),
(119, 11, 'Usuarios', 'Login', '2025-06-18 09:34:14', 'inicio de sesion'),
(120, 11, 'Caja', 'Agregar', '2025-06-18 09:41:30', 'Se abrio una caja'),
(121, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 09:42:46', 'Se creo una orden de domicilio'),
(122, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 09:46:31', 'Se creo una orden de domicilio'),
(123, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 09:59:39', 'Se creo una orden de domicilio'),
(124, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:02:23', 'Se creo una orden de domicilio'),
(125, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:03:42', 'Se creo una orden de domicilio'),
(126, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:05:12', 'Se creo una orden de domicilio'),
(127, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:08:35', 'Se creo una orden de domicilio'),
(128, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:10:25', 'Se creo una orden de domicilio'),
(129, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:11:50', 'Se creo una orden de domicilio'),
(130, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 10:12:55', 'Se creo una orden de domicilio'),
(131, 11, 'Orden de cocina', 'Preparado', '2025-06-18 10:18:16', 'Se preparo una orden de cocina'),
(132, 11, 'Orden de domicilio', 'Creacion', '2025-06-18 14:10:10', 'Se creo una orden de domicilio'),
(133, 11, 'Usuarios', 'Login', '2025-06-19 10:51:43', 'inicio de sesion'),
(134, 11, 'Caja', 'Cerrar', '2025-06-19 10:52:41', 'Se cerro la caja 19'),
(135, 11, 'Caja', 'Agregar', '2025-06-19 10:52:52', 'Se abrio una caja'),
(136, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 10:53:54', 'Se creo una orden de domicilio'),
(137, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 10:53:54', 'Se creo una orden de domicilio'),
(138, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:18:44', 'Se creo una orden de domicilio'),
(139, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:19:52', 'Se creo una orden de domicilio'),
(140, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:19:52', 'Se creo una orden de domicilio'),
(141, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:21:59', 'Se creo una orden de domicilio'),
(142, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:23:22', 'Se creo una orden de domicilio'),
(143, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:24:07', 'Se creo una orden de domicilio'),
(144, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:27:34', 'Se creo una orden de domicilio'),
(145, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:28:35', 'Se creo una orden de domicilio'),
(146, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:30:50', 'Se creo una orden de domicilio'),
(147, 11, 'Orden de domicilio', 'Creacion', '2025-06-19 17:31:38', 'Se creo una orden de domicilio'),
(148, 11, 'Productos Preparados', 'Actualizacion', '2025-06-19 20:09:54', 'Se actualizo un producto preparado'),
(149, 11, 'Productos Preparados', 'Actualizacion', '2025-06-19 20:10:37', 'Se actualizo un producto preparado'),
(150, 11, 'Productos Preparados', 'Actualizacion', '2025-06-19 20:10:37', 'Se actualizo un producto preparado'),
(151, 11, 'Caja', 'Cerrar', '2025-06-19 20:33:04', 'Se cerro la caja 20'),
(152, 11, 'Usuarios', 'Login', '2025-06-20 08:34:11', 'inicio de sesion'),
(153, 11, 'Usuarios', 'Login', '2025-06-20 10:13:59', 'inicio de sesion'),
(154, 11, 'Caja', 'Agregar', '2025-06-20 10:15:09', 'Se abrio una caja'),
(155, 11, 'capital', 'Agregar', '2025-06-20 10:16:04', 'Guardar Gasto en capital de 2000 $'),
(156, 11, 'Usuarios', 'Login', '2025-06-20 14:47:41', 'inicio de sesion'),
(157, 11, 'Usuarios', 'Login', '2025-06-21 12:32:56', 'inicio de sesion'),
(158, 11, 'Usuarios', 'Login', '2025-06-23 09:37:36', 'inicio de sesion'),
(159, 11, 'Rol', 'Agregar', '2025-06-23 11:42:31', 'Se creo un rol'),
(160, 11, 'Rol', 'Editar', '2025-06-23 11:56:28', 'Se edito un rol'),
(161, 11, 'Rol', 'Editar', '2025-06-23 11:56:40', 'Se edito un rol'),
(162, 11, 'Rol', 'Editar', '2025-06-23 11:58:29', 'Se edito un rol'),
(163, 11, 'Rol', 'Editar', '2025-06-23 11:59:48', 'Se edito un rol'),
(164, 11, 'Rol', 'Editar', '2025-06-23 12:01:04', 'Se edito un rol'),
(165, 11, 'Rol', 'Editar', '2025-06-23 12:01:25', 'Se edito un rol'),
(166, 11, 'Rol', 'Editar', '2025-06-23 12:04:31', 'Se edito un rol'),
(167, 11, 'Rol', 'Editar', '2025-06-23 12:04:37', 'Se edito un rol'),
(168, 11, 'Producto procesado', 'Actualizacion', '2025-06-23 12:05:42', 'Se agrego un producto procesado'),
(169, 11, 'Producto procesado', 'Actualizacion', '2025-06-23 12:05:48', 'Se agrego un producto procesado'),
(170, 11, 'Producto procesado', 'Actualizacion', '2025-06-23 12:05:48', 'Se agrego un producto procesado'),
(171, 11, 'Rol', 'Editar', '2025-06-24 14:48:20', 'Se actualizo un rol'),
(172, 11, 'Rol', 'Editar', '2025-06-24 14:48:20', 'Se actualizo un rol'),
(173, 11, 'Rol', 'Editar', '2025-06-24 14:48:20', 'Se actualizo un rol'),
(174, 11, 'Rol', 'Editar', '2025-06-24 14:48:20', 'Se actualizo un rol'),
(175, 11, 'Rol', 'Editar', '2025-06-24 14:48:20', 'Se actualizo un rol'),
(176, 11, 'Rol', 'Eliminacion', '2025-06-23 12:31:51', 'Se elimino un rol'),
(177, 11, 'Usuarios', 'Login', '2025-06-24 14:36:45', 'inicio de sesion'),
(178, 11, 'Usuarios', 'Actualizacion', '2025-06-24 14:59:01', 'Se actualizo un usuario'),
(179, 11, 'Usuarios', 'Actualizacion', '2025-06-24 16:39:56', 'Se actualizo un usuario'),
(180, 11, 'Rol', 'Editar', '2025-06-24 16:42:34', 'Se actualizo un rol'),
(181, 11, 'Usuarios', 'Login', '2025-06-24 17:03:35', 'inicio de sesion'),
(182, 11, 'Perfil', 'Actualizacion', '2025-06-24 17:11:04', 'Se actualizo la imagen de perfil'),
(183, 11, 'Perfil', 'Actualizacion', '2025-06-24 17:11:19', 'Se actualizo la imagen de perfil'),
(184, 11, 'Perfil', 'Actualizacion', '2025-06-24 17:12:43', 'Se actualizo la imagen de perfil'),
(185, 11, 'Perfil', 'Actualizacion', '2025-06-24 17:13:00', 'Se actualizo la imagen de perfil'),
(186, 11, 'Perfil', 'Perfil actualizado', '2025-06-24 17:14:02', 'Se actualizo el perfil'),
(187, 11, 'Perfil', 'Perfil actualizado', '2025-06-24 17:14:10', 'Se actualizo el perfil'),
(188, 11, 'Perfil', 'Perfil actualizado', '2025-06-24 17:21:50', 'Se actualizo el perfil'),
(189, 11, 'Perfil', 'Actualizacion', '2025-06-24 17:27:58', 'Se actualizo la imagen de perfil'),
(190, 11, 'Perfil', 'Actualizacion', '2025-06-24 17:28:13', 'Se actualizo la imagen de perfil'),
(191, 11, 'Perfil', 'Perfil actualizado', '2025-06-24 17:28:21', 'Se actualizo el perfil'),
(192, 11, 'Caja', 'Cerrar', '2025-06-24 18:51:28', 'Se cerro la caja 21'),
(193, 11, 'Usuario', 'Perfil actualizado', '2025-06-24 19:59:56', 'Se actualizo el perfil'),
(194, 11, 'Usuario', 'Perfil actualizado', '2025-06-24 20:09:19', 'Se actualizo la contraseña'),
(195, 11, 'Perfil', 'Actualizacion', '2025-06-24 20:12:55', 'Se actualizo la imagen de perfil'),
(196, 11, 'Perfil', 'Actualizacion', '2025-06-24 20:13:15', 'Se actualizo la imagen de perfil'),
(197, 11, 'Usuarios', 'Login', '2025-06-25 10:12:36', 'inicio de sesion'),
(198, 11, 'Usuarios', 'Agregar', '2025-06-25 10:17:20', 'Se agrego un usuario'),
(199, 15, 'Usuarios', 'Login', '2025-06-25 10:17:51', 'inicio de sesion'),
(200, 11, 'Usuarios', 'Login', '2025-06-25 10:48:19', 'inicio de sesion'),
(201, 15, 'Usuarios', 'Login', '2025-06-25 10:48:43', 'inicio de sesion'),
(202, 15, 'Usuarios', 'Login', '2025-06-25 11:17:08', 'inicio de sesion'),
(203, 15, 'Usuarios', 'Login', '2025-06-25 11:36:08', 'inicio de sesion'),
(204, 11, 'Usuarios', 'Login', '2025-06-25 12:10:57', 'inicio de sesion'),
(205, 11, 'Usuarios', 'Login', '2025-06-25 12:25:22', 'inicio de sesion'),
(206, 15, 'Perfil', 'Actualizacion', '2025-06-25 12:59:07', 'Se actualizo la imagen de perfil'),
(207, 15, 'Usuarios', 'Login', '2025-06-25 13:00:26', 'inicio de sesion'),
(208, 11, 'Usuarios', 'Login', '2025-06-25 13:51:24', 'inicio de sesion'),
(209, 11, 'Usuarios', 'Login', '2025-06-25 13:55:04', 'inicio de sesion'),
(210, 11, 'Orden de cocina', 'Preparado', '2025-06-25 15:49:27', 'Se preparo una orden de cocina'),
(211, 15, 'Productos Preparados', 'Actualizacion', '2025-06-25 16:57:41', 'Se actualizo un producto preparado'),
(212, 15, 'Productos Preparados', 'Eliminacion', '2025-06-25 16:57:50', 'Se elimino un producto preparado'),
(213, 15, 'Papelera', 'Restaurar', '2025-06-25 16:58:13', 'Se ha restaurado un elemento de la papelera'),
(214, 15, 'Producto procesado', 'Actualizacion', '2025-06-25 17:28:55', 'Se agrego un producto procesado'),
(215, 15, 'Producto procesado', 'Actualizacion', '2025-06-25 17:29:02', 'Se agrego un producto procesado'),
(216, 15, 'Producto procesado', 'Actualizacion', '2025-06-25 17:29:02', 'Se agrego un producto procesado'),
(217, 15, 'Caja', 'Agregar', '2025-06-25 17:48:51', 'Se abrio una caja'),
(218, 11, 'Usuarios', 'Login', '2025-06-26 10:52:56', 'inicio de sesion'),
(219, 15, 'Usuarios', 'Login', '2025-06-26 10:53:34', 'inicio de sesion'),
(220, 11, 'Mesas', 'Edicion', '2025-06-26 12:13:53', 'Se Edito un mesa'),
(221, 11, 'Mesas', 'Edicion', '2025-06-26 12:13:53', 'Se Edito un mesa'),
(222, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:02', 'Se Edito un mesa'),
(223, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:02', 'Se Edito un mesa'),
(224, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:02', 'Se Edito un mesa'),
(225, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:17', 'Se Edito un mesa'),
(226, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:17', 'Se Edito un mesa'),
(227, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:17', 'Se Edito un mesa'),
(228, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:17', 'Se Edito un mesa'),
(229, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:31', 'Se Edito un mesa'),
(230, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:31', 'Se Edito un mesa'),
(231, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:31', 'Se Edito un mesa'),
(232, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:31', 'Se Edito un mesa'),
(233, 11, 'Mesas', 'Edicion', '2025-06-26 12:14:31', 'Se Edito un mesa'),
(234, 11, 'Mesas', 'Edicion', '2025-06-26 12:25:22', 'Se Edito un mesa'),
(235, 11, 'Mesas', 'Edicion', '2025-06-26 12:25:23', 'Se Edito un mesa'),
(236, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:26:47', 'Se preparo una orden de cocina'),
(237, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:26:50', 'Se preparo una orden de cocina'),
(238, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:26:53', 'Se preparo una orden de cocina'),
(239, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:26:56', 'Se preparo una orden de cocina'),
(240, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:26:58', 'Se preparo una orden de cocina'),
(241, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:27:01', 'Se preparo una orden de cocina'),
(242, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:27:04', 'Se preparo una orden de cocina'),
(243, 11, 'Orden de cocina', 'Preparado', '2025-06-26 13:27:07', 'Se preparo una orden de cocina'),
(244, 11, 'Orden de delivery', 'Orden aceptada', '2025-06-26 13:49:22', 'Se acepto una orden de delivery'),
(245, 11, 'Rol', 'Agregar', '2025-06-26 14:25:56', 'Se creo un rol'),
(246, 11, 'Rol', 'Editar', '2025-06-26 14:26:02', 'Se actualizo un rol'),
(247, 11, 'Usuario', 'Eliminacion', '2025-06-26 18:11:33', 'Se elimino un usuario'),
(248, 11, 'orden', 'Actualizacion', '2025-06-27 10:05:12', 'Se entrego la orden 68109000'),
(249, 11, 'Productos Preparados', 'Actualizacion', '2025-06-27 10:08:35', 'Se actualizo un producto preparado'),
(250, 11, 'Productos Preparados', 'Actualizacion', '2025-06-27 12:03:18', 'Se actualizo un producto preparado'),
(251, 11, 'Usuarios', 'Login', '2025-06-28 08:01:09', 'inicio de sesion'),
(252, 11, 'Mesas', 'Agregar', '2025-06-28 11:52:29', 'Se agrego una mesa'),
(253, 11, 'Usuarios', 'Login', '2025-06-29 11:43:05', 'inicio de sesion'),
(254, 11, 'Usuarios', 'Login', '2025-07-01 18:27:31', 'inicio de sesion'),
(255, 15, 'Usuarios', 'Login', '2025-07-01 19:58:54', 'inicio de sesion'),
(256, 15, 'Usuarios', 'Login', '2025-07-01 20:13:03', 'inicio de sesion'),
(257, 11, 'Usuarios', 'Login', '2025-07-02 10:18:03', 'inicio de sesion'),
(258, 11, 'Caja', 'Agregar', '2025-07-02 10:57:36', 'Se abrio una caja'),
(259, 11, 'Productos Preparados', 'Actualizacion', '2025-07-02 11:06:15', 'Se actualizo un producto preparado'),
(260, 11, 'Productos Preparados', 'Actualizacion', '2025-07-02 11:06:15', 'Se actualizo un producto preparado'),
(261, 11, 'Productos Preparados', 'Actualizacion', '2025-07-02 11:06:15', 'Se actualizo un producto preparado'),
(262, 11, 'Productos Preparados', 'Actualizacion', '2025-07-02 11:06:15', 'Se actualizo un producto preparado'),
(263, 11, 'orden', 'Actualizacion', '2025-07-02 11:28:40', 'Se verifico la orden 54799200'),
(264, 11, 'Orden de domicilio', 'Creacion', '2025-07-02 13:01:28', 'Se creo una orden de delivery'),
(265, 11, 'Orden de cocina', 'Preparado', '2025-07-02 13:09:59', 'Se preparo una orden de cocina'),
(266, 11, 'Orden de cocina', 'Preparado', '2025-07-02 13:11:59', 'Se preparo una orden de cocina'),
(267, 11, 'Orden de domicilio', 'Creacion', '2025-07-02 13:19:14', 'Se creo una orden de llevar'),
(268, 11, 'Orden de cocina', 'Preparado', '2025-07-02 13:19:26', 'Se preparo una orden de cocina'),
(269, 11, 'orden', 'Actualizacion', '2025-07-02 13:26:08', 'Se entrego la orden 40231700'),
(270, 15, 'Usuarios', 'Login', '2025-07-02 17:51:03', 'inicio de sesion'),
(271, 11, 'Usuarios', 'Login', '2025-07-02 18:22:58', 'inicio de sesion'),
(272, 15, 'Usuarios', 'Login', '2025-07-02 18:27:07', 'inicio de sesion'),
(273, 11, 'Usuarios', 'Login', '2025-07-02 18:31:50', 'inicio de sesion'),
(274, 11, 'Usuarios', 'Login', '2025-07-03 11:09:44', 'inicio de sesion'),
(275, 11, 'Mesas', 'Agregar', '2025-07-03 22:12:03', 'Se agrego una mesa'),
(276, 11, 'Mesas', 'Eliminacion', '2025-07-03 22:14:15', 'Se Elimino un mesa'),
(277, 11, 'Mesas', 'Eliminacion', '2025-07-03 22:27:54', 'Se Elimino un mesa'),
(278, 11, 'Mesas', 'Eliminacion', '2025-07-03 22:44:02', 'Se Elimino un mesa'),
(279, 11, 'Clientes', 'Eliminacion', '2025-07-03 22:45:29', 'Se elimino un cliente'),
(280, 11, 'Clientes', 'Agregar', '2025-07-03 22:49:14', 'Se agrego un nuevo cliente'),
(281, 11, 'Usuarios', 'Login', '2025-07-04 16:07:00', 'inicio de sesion'),
(282, 11, 'Mesas', 'Agregar', '2025-07-04 16:07:49', 'Se agrego una mesa'),
(283, 11, 'Mesas', 'Agregar', '2025-07-04 18:38:15', 'Se agrego una mesa'),
(284, 11, 'Unidades', 'Eliminacion', '2025-07-04 18:44:20', 'Se ha eliminado una Unidad'),
(285, 11, 'Unidades', 'Agregar', '2025-07-04 18:44:31', 'Se ha agregado una unidad'),
(286, 11, 'Unidades', 'Eliminacion', '2025-07-04 18:45:01', 'Se ha eliminado una Unidad'),
(287, 11, 'Papelera', 'Restaurar', '2025-07-04 19:09:07', 'Se ha restaurado un elemento de la papelera'),
(288, 11, 'Mesas', 'Agregar', '2025-07-04 19:48:37', 'Se agrego una mesa'),
(289, 11, 'Usuarios', 'Login', '2025-07-04 20:21:32', 'inicio de sesion'),
(290, 11, 'Mesas', 'Eliminacion', '2025-07-04 20:45:02', 'Se Elimino un mesa'),
(291, 11, 'Mesas', 'Eliminacion', '2025-07-04 20:47:39', 'Se Elimino un mesa'),
(292, 11, 'Mesas', 'Eliminacion', '2025-07-04 20:47:47', 'Se Elimino un mesa'),
(293, 11, 'Mesas', 'Eliminacion', '2025-07-04 20:47:52', 'Se Elimino un mesa'),
(294, 11, 'Papelera', 'Restaurar', '2025-07-04 20:50:23', 'Se ha restaurado un elemento de la papelera'),
(295, 11, 'Usuarios', 'Login', '2025-07-04 21:10:29', 'inicio de sesion'),
(296, 11, 'Mesas', 'Eliminacion', '2025-07-04 21:11:58', 'Se Elimino un mesa'),
(297, 11, 'Usuarios', 'Login', '2025-07-04 21:17:33', 'inicio de sesion'),
(298, 11, 'Usuarios', 'Login', '2025-07-05 10:40:19', 'inicio de sesion'),
(299, 11, 'Orden de cocina', 'En preparacion', '2025-07-05 11:58:43', 'Se envio una orden a preparar'),
(300, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-07-05 12:25:22', 'Se envio una orden a preparar'),
(301, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-07-05 12:25:39', 'Se envio una orden a despachar'),
(302, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-07-05 14:43:58', 'Se envio una orden a preparar'),
(303, 11, 'orden', 'Actualizacion', '2025-07-05 15:22:29', 'Se entrego la orden 63411000 a su mesa'),
(304, 11, 'Caja', 'Agregar', '2025-07-05 15:26:25', 'Se abrio una caja'),
(305, 11, 'Orden de domicilio', 'Creacion', '2025-07-05 15:27:17', 'Se creo una orden de llevar'),
(306, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-07-05 15:27:58', 'Se envio una orden a preparar'),
(307, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-07-05 15:28:04', 'Se envio una orden a despachar'),
(308, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-07-05 15:28:26', 'Se envio una orden a despachar'),
(309, 11, 'orden', 'Actualizacion', '2025-07-05 15:29:52', 'Se entrego la orden 91485100 a su mesa'),
(310, 11, 'Usuarios', 'Login', '2025-07-05 17:47:53', 'inicio de sesion'),
(311, 11, 'Usuarios', 'Login', '2025-07-05 18:19:51', 'inicio de sesion'),
(312, 15, 'Usuarios', 'Login', '2025-07-05 18:26:52', 'inicio de sesion'),
(313, 15, 'Usuarios', 'Login', '2025-07-06 11:10:14', 'inicio de sesion'),
(314, 11, 'Usuarios', 'Login', '2025-07-06 11:14:15', 'inicio de sesion'),
(315, 15, 'Usuarios', 'Login', '2025-07-06 13:22:03', 'inicio de sesion'),
(316, 11, 'Usuarios', 'Login', '2025-07-07 10:54:22', 'inicio de sesion'),
(317, 11, 'orden', 'Actualizacion', '2025-07-07 12:12:19', 'Se anulo la orden 53447800'),
(318, 11, 'orden', 'Actualizacion', '2025-07-07 12:18:51', 'Se verifico la orden 53447800'),
(319, 11, 'orden', 'Actualizacion', '2025-07-07 12:20:57', 'Se verifico la orden 53447800'),
(320, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-07-07 12:21:31', 'Se envio una orden a preparar'),
(321, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-07-07 12:21:44', 'Se envio una orden a despachar'),
(322, 11, 'orden', 'Actualizacion', '2025-07-07 12:22:33', 'Se despacho la orden 53447800'),
(323, 11, 'orden', 'Actualizacion', '2025-07-07 12:29:02', 'Se anulo la orden 53447800'),
(324, 11, 'orden', 'Actualizacion', '2025-07-07 12:41:19', 'Se anulo la orden 53447800'),
(325, 11, 'Caja', 'Agregar', '2025-07-07 14:07:10', 'Se abrio una caja'),
(326, 11, 'Orden de domicilio', 'Creacion', '2025-07-07 14:08:51', 'Se creo una orden de llevar'),
(327, 11, 'Orden de domicilio', 'Creacion', '2025-07-07 14:11:23', 'Se creo una orden de llevar'),
(328, 11, 'Categoria de Producto', 'Eliminacion', '2025-07-07 15:34:53', 'Se elimino una categoria de productos'),
(329, 11, 'Categoria de Producto', 'Eliminacion', '2025-07-07 15:34:53', 'Se elimino una categoria de productos'),
(330, 11, 'Categoria de Producto', 'Eliminacion', '2025-07-07 15:34:53', 'Se elimino una categoria de productos'),
(331, 11, 'Categoria de Producto', 'Eliminacion', '2025-07-07 15:34:53', 'Se elimino una categoria de productos'),
(332, 11, 'Usuarios', 'Login', '2025-07-09 11:13:22', 'inicio de sesion'),
(333, 11, 'Caja', 'Cerrar', '2025-07-09 12:57:18', 'Se cerro la caja 27'),
(334, 11, 'Caja', 'Agregar', '2025-07-09 12:57:29', 'Se abrio una caja'),
(335, 11, 'Orden de domicilio', 'Creacion', '2025-07-09 13:49:25', 'Se creo una orden de delivery'),
(336, 11, 'Orden de domicilio', 'Creacion', '2025-07-09 19:21:59', 'Se creo una orden de delivery'),
(337, 11, 'Orden de domicilio', 'Creacion', '2025-07-09 19:29:01', 'Se creo una orden de delivery'),
(338, 11, 'Orden de domicilio', 'Creacion', '2025-07-09 20:49:22', 'Se creo una orden de delivery'),
(339, 11, 'Usuarios', 'Login', '2025-07-10 11:54:44', 'inicio de sesion'),
(340, 11, 'Caja', 'Cerrar', '2025-07-10 14:45:39', 'Se cerro la caja 28'),
(341, 11, 'Caja', 'Agregar', '2025-07-10 14:45:52', 'Se abrio una caja'),
(342, 11, 'Orden de domicilio', 'Creacion', '2025-07-10 14:47:03', 'Se creo una orden de llevar'),
(343, 11, 'Usuarios', 'Login', '2025-07-12 08:06:26', 'inicio de sesion'),
(344, 11, 'Usuarios', 'Login', '2025-07-15 11:19:17', 'inicio de sesion'),
(345, 11, 'Usuarios', 'Login', '2025-07-16 11:01:42', 'inicio de sesion'),
(346, 11, 'Orden local', 'Creacion', '2025-07-16 13:47:22', 'Se creo una orden local'),
(347, 11, 'Orden local', 'Creacion', '2025-07-16 13:50:57', 'Se creo una orden local'),
(348, 11, 'Orden local', 'Pago', '2025-07-16 15:24:08', 'Se pago la orden 81'),
(349, 11, 'Usuarios', 'Login', '2025-07-17 11:29:31', 'inicio de sesion'),
(350, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-07-17 12:16:13', 'Se envio una orden a preparar'),
(351, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-07-17 12:16:23', 'Se envio una orden a despachar'),
(352, 11, 'orden', 'Actualizacion', '2025-07-17 12:16:50', 'Se entrego la orden 61900800 a su mesa'),
(353, 15, 'Usuarios', 'Login', '2025-07-17 12:48:12', 'inicio de sesion'),
(354, 11, 'Usuarios', 'Login', '2025-07-17 13:59:10', 'inicio de sesion'),
(355, 11, 'Usuarios', 'Login', '2025-07-23 10:06:39', 'inicio de sesion'),
(356, 11, 'Paquete', 'Paquete creado', '2025-07-23 13:12:23', 'Se agrego un nuevo paquete'),
(357, 11, 'paquetes', 'Eliminacion', '2025-07-23 13:31:40', 'Se elimino un paquete de reserva'),
(358, 11, 'paquete', 'Paquete creado', '2025-07-23 15:23:47', 'Se agrego un nuevo paquete'),
(359, 11, 'paquete', 'Actualizacion', '2025-07-23 15:45:11', 'Se edito el paquete 6'),
(360, 11, 'paquete', 'Actualizacion', '2025-07-23 15:47:14', 'Se edito el paquete 6'),
(361, 11, 'paquete', 'Actualizacion', '2025-07-23 15:47:56', 'Se edito el paquete 6'),
(362, 11, 'paquete', 'Actualizacion', '2025-07-23 15:48:17', 'Se edito el paquete 6'),
(363, 11, 'paquete', 'Actualizacion', '2025-07-23 15:48:38', 'Se edito el paquete 6'),
(364, 11, 'paquete', 'Actualizacion', '2025-07-23 15:50:48', 'Se edito el paquete 6'),
(365, 11, 'paquete', 'Actualizacion', '2025-07-23 15:52:23', 'Se edito el paquete 6'),
(366, 11, 'paquete', 'Actualizacion', '2025-07-23 15:53:23', 'Se edito el paquete 6'),
(367, 11, 'paquete', 'Actualizacion', '2025-07-23 15:53:35', 'Se edito el paquete 6'),
(368, 11, 'paquete', 'Actualizacion', '2025-07-23 15:53:56', 'Se edito el paquete 6'),
(369, 11, 'paquete', 'Actualizacion', '2025-07-23 15:54:35', 'Se edito el paquete 6'),
(370, 11, 'paquete', 'Actualizacion', '2025-07-23 15:54:46', 'Se edito el paquete 6'),
(371, 11, 'paquete', 'Actualizacion', '2025-07-23 16:01:13', 'Se edito el paquete 6'),
(372, 11, 'paquete', 'Actualizacion', '2025-07-23 16:01:31', 'Se edito el paquete 7'),
(373, 11, 'paquete', 'Actualizacion', '2025-07-23 16:01:48', 'Se edito el paquete 4'),
(374, 11, 'paquete', 'Actualizacion', '2025-07-23 16:02:54', 'Se edito el paquete 4'),
(375, 11, 'Papelera', 'Restaurar', '2025-07-23 16:57:47', 'Se ha restaurado un elemento de la papelera'),
(376, 11, 'Papelera', 'Restaurar', '2025-07-23 16:57:56', 'Se ha restaurado un elemento de la papelera'),
(377, 11, 'Usuarios', 'Login', '2025-07-24 11:25:09', 'inicio de sesion'),
(378, 11, 'Usuarios', 'Login', '2025-07-25 10:36:49', 'inicio de sesion'),
(379, 11, 'Caja', 'Cerrar', '2025-07-25 12:23:49', 'Se cerro la caja 29'),
(380, 11, 'Caja', 'Agregar', '2025-07-25 12:24:01', 'Se abrio una caja'),
(381, 11, 'reserva', 'Creacion', '2025-07-25 14:07:53', 'Se agrego una reserva para el 31/7/2025'),
(382, 11, 'reserva', 'Creacion', '2025-07-25 14:09:34', 'Se agrego una reserva para el 28/7/2025'),
(383, 11, 'reserva', 'Creacion', '2025-07-25 14:12:14', 'Se agrego una reserva para el 31/7/2025'),
(384, 11, 'reserva', 'Creacion', '2025-07-25 14:21:42', 'Se agrego una reserva para el 31/7/2025'),
(385, 11, 'Usuarios', 'Login', '2025-08-06 11:00:47', 'inicio de sesion'),
(386, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 12:52:08', 'Se creo una orden de delivery'),
(387, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 12:58:08', 'Se creo una orden de delivery'),
(388, 15, 'Usuarios', 'Login', '2025-08-06 13:08:39', 'inicio de sesion'),
(389, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 13:10:12', 'Se creo una orden de llevar'),
(390, 11, 'Usuarios', 'Login', '2025-08-06 13:10:58', 'inicio de sesion'),
(391, 15, 'Usuarios', 'Login', '2025-08-06 13:11:24', 'inicio de sesion'),
(392, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 13:24:52', 'Se creo una orden de delivery'),
(393, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 13:26:51', 'Se creo una orden de delivery'),
(394, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 13:28:19', 'Se creo una orden de llevar'),
(395, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 13:35:09', 'Se creo una orden de delivery'),
(396, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 13:48:39', 'Se creo una orden de llevar'),
(397, 15, 'Usuarios', 'Login', '2025-08-06 14:03:39', 'inicio de sesion'),
(398, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:04:55', 'Se creo una orden de delivery'),
(399, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:06:50', 'Se creo una orden de llevar'),
(400, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:19:35', 'Se creo una orden de delivery'),
(401, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:21:44', 'Se creo una orden de llevar'),
(402, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:35:50', 'Se creo una orden de delivery'),
(403, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:37:50', 'Se creo una orden de llevar'),
(404, 11, 'Orden de domicilio', 'Creacion', '2025-08-06 14:38:42', 'Se creo una orden de delivery'),
(405, 11, 'Usuarios', 'Login', '2025-08-08 10:37:56', 'inicio de sesion'),
(406, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 11:06:56', 'Se envio una orden a preparar'),
(407, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 11:07:56', 'Se envio una orden a preparar'),
(408, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 11:12:42', 'Se envio una orden a preparar'),
(409, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 11:17:49', 'Se envio una orden a preparar'),
(410, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 11:20:12', 'Se envio una orden a preparar'),
(411, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 11:24:44', 'Se envio una orden a preparar'),
(412, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-08 11:26:11', 'Se envio una orden a despachar'),
(413, 11, 'Orden de delivery', 'Orden aceptada', '2025-08-08 12:11:03', 'Se acepto una orden de delivery'),
(414, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 12:40:57', 'Se envio una orden a preparar'),
(415, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-08 12:41:08', 'Se envio una orden a despachar'),
(416, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-08 12:43:58', 'Se envio una orden a preparar'),
(417, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-08 12:44:22', 'Se envio una orden a despachar'),
(418, 11, 'Usuarios', 'Login', '2025-08-09 12:11:12', 'inicio de sesion'),
(419, 11, 'Caja', 'Cerrar', '2025-08-09 12:13:04', 'Se cerro la caja 30'),
(420, 11, 'Caja', 'Agregar', '2025-08-09 12:13:13', 'Se abrio una caja'),
(421, 11, 'Orden local', 'Creacion', '2025-08-09 12:13:50', 'Se creo una orden local'),
(422, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 12:15:02', 'Se envio una orden a preparar'),
(423, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 12:15:21', 'Se envio una orden a despachar'),
(424, 11, 'orden', 'Actualizacion', '2025-08-09 12:15:52', 'Se entrego la orden 72337000 a su mesa'),
(425, 11, 'Orden local', 'Pago', '2025-08-09 12:17:05', 'Se pago la orden 117'),
(426, 11, 'Orden local', 'Creacion', '2025-08-09 12:25:58', 'Se creo una orden local'),
(427, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 12:26:26', 'Se envio una orden a preparar'),
(428, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 12:26:36', 'Se envio una orden a despachar'),
(429, 11, 'orden', 'Actualizacion', '2025-08-09 12:26:48', 'Se entrego la orden 52566000 a su mesa'),
(430, 11, 'Orden local', 'Pago', '2025-08-09 12:27:39', 'Se pago la orden 118'),
(431, 11, 'Orden local', 'Creacion', '2025-08-09 12:29:02', 'Se creo una orden local'),
(432, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 12:29:17', 'Se envio una orden a preparar'),
(433, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 12:29:23', 'Se envio una orden a despachar'),
(434, 11, 'orden', 'Actualizacion', '2025-08-09 12:29:37', 'Se entrego la orden 63436300 a su mesa'),
(435, 11, 'Orden local', 'Creacion', '2025-08-09 12:45:51', 'Se creo una orden local'),
(436, 11, 'Orden local', 'Creacion', '2025-08-09 12:45:51', 'Se creo una orden local'),
(437, 11, 'Orden local', 'Creacion', '2025-08-09 12:45:51', 'Se creo una orden local'),
(438, 11, 'Orden local', 'Creacion', '2025-08-09 12:53:15', 'Se creo una orden local'),
(439, 11, 'Orden local', 'Creacion', '2025-08-09 12:53:15', 'Se creo una orden local'),
(440, 11, 'Orden local', 'Creacion', '2025-08-09 12:53:15', 'Se creo una orden local'),
(441, 11, 'Orden local', 'Creacion', '2025-08-09 12:57:23', 'Se creo una orden local'),
(442, 11, 'Orden local', 'Creacion', '2025-08-09 12:59:59', 'Se creo una orden local'),
(443, 11, 'Orden local', 'Creacion', '2025-08-09 13:01:15', 'Se creo una orden local'),
(444, 11, 'Orden local', 'Creacion', '2025-08-09 13:01:37', 'Se creo una orden local'),
(445, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 13:06:24', 'Se envio una orden a preparar'),
(446, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 13:06:29', 'Se envio una orden a despachar'),
(447, 11, 'orden', 'Actualizacion', '2025-08-09 13:06:43', 'Se entrego la orden 44447700 a su mesa'),
(448, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 13:10:30', 'Se envio una orden a preparar'),
(449, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 13:10:35', 'Se envio una orden a despachar'),
(450, 11, 'orden', 'Actualizacion', '2025-08-09 13:10:58', 'Se entrego la orden 12591700 a su mesa'),
(451, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 13:11:45', 'Se envio una orden a preparar'),
(452, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 13:11:50', 'Se envio una orden a despachar'),
(453, 11, 'orden', 'Actualizacion', '2025-08-09 13:12:08', 'Se entrego la orden 35454300 a su mesa'),
(454, 11, 'orden', 'Actualizacion', '2025-08-09 13:13:54', 'Se entrego la orden 12591700 a su mesa'),
(455, 11, 'orden', 'Actualizacion', '2025-08-09 13:14:30', 'Se entrego la orden 12591700 a su mesa'),
(456, 11, 'orden', 'Actualizacion', '2025-08-09 13:14:40', 'Se entrego la orden 44447700 a su mesa'),
(457, 11, 'Orden local', 'Pago', '2025-08-09 13:16:31', 'Se pago la orden 129'),
(458, 11, 'Orden local', 'Creacion', '2025-08-09 13:18:34', 'Se creo una orden local'),
(459, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-09 13:19:00', 'Se envio una orden a preparar'),
(460, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-09 13:19:12', 'Se envio una orden a despachar'),
(461, 11, 'orden', 'Actualizacion', '2025-08-09 13:19:49', 'Se entrego la orden 95047700 a su mesa'),
(462, 11, 'Orden local', 'Pago', '2025-08-09 13:20:56', 'Se pago la orden 130'),
(463, 11, 'paquete', 'Paquete creado', '2025-08-09 13:23:41', 'Se agrego un nuevo paquete'),
(464, 11, 'reserva', 'Creacion', '2025-08-09 13:24:45', 'Se agrego una reserva para el 9/8/2025'),
(465, 11, 'Usuarios', 'Login', '2025-08-10 12:18:19', 'inicio de sesion'),
(466, 11, 'Usuarios', 'Login', '2025-08-12 10:32:18', 'inicio de sesion'),
(467, 11, 'Reservas', 'Actualizacion', '2025-08-12 11:31:20', 'Se actualizo la fecha de una reserva 9'),
(468, 11, 'reserva', 'Creacion', '2025-08-12 13:03:43', 'Se agrego una reserva para el 30/8/2025'),
(469, 11, 'Usuarios', 'Login', '2025-08-13 12:53:12', 'inicio de sesion'),
(470, 11, 'Reservas', 'Actualizacion', '2025-08-13 14:17:16', 'Se actualizo el paquete de la reserva8'),
(471, 11, 'Usuarios', 'Login', '2025-08-14 11:08:42', 'inicio de sesion'),
(472, 11, 'Reservas', 'Actualizacion', '2025-08-14 13:57:00', 'Se actualizo el paquete de la reserva 9'),
(473, 11, 'Reservas', 'Actualizacion', '2025-08-14 13:57:51', 'Se actualizo el paquete de la reserva 9'),
(474, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:08:13', 'Se actualizo el paquete de la reserva 8'),
(475, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:09:32', 'Se actualizo el paquete de la reserva 8'),
(476, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:15:39', 'Se actualizo el paquete de la reserva 8'),
(477, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:19:36', 'Se actualizo el paquete de la reserva 8'),
(478, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:24:00', 'Se actualizo el paquete de la reserva 8'),
(479, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:34:04', 'Se actualizo el paquete de la reserva 9'),
(480, 11, 'Reservas', 'Actualizacion', '2025-08-14 14:36:12', 'Se actualizo el paquete de la reserva 8'),
(481, 11, 'Usuarios', 'Login', '2025-08-15 11:43:15', 'inicio de sesion'),
(482, 11, 'Reservacion', 'Anular', '2025-08-15 12:42:30', 'Se anulo la reserva 8'),
(483, 11, 'Reservacion', 'Anular', '2025-08-15 12:42:59', 'Se anulo la reserva 9'),
(484, 11, 'Reservacion', 'Verificacion', '2025-08-15 12:53:07', 'Se verifico la reserva 8'),
(485, 15, 'Usuarios', 'Login', '2025-08-15 12:58:34', 'inicio de sesion'),
(486, 11, 'Usuarios', 'Login', '2025-08-19 10:44:39', 'inicio de sesion'),
(487, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-19 12:55:26', 'Se envio una orden a preparar'),
(488, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-19 12:55:42', 'Se envio una orden a despachar'),
(489, 11, 'orden', 'Actualizacion', '2025-08-19 14:38:39', 'Se entrego la orden null a su mesa'),
(490, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-19 14:45:46', 'Se envio una orden a preparar'),
(491, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-19 14:45:54', 'Se envio una orden a despachar'),
(492, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-19 14:48:23', 'Se envio una orden a preparar'),
(493, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-19 14:48:36', 'Se envio una orden a despachar'),
(494, 11, 'orden', 'Actualizacion', '2025-08-19 14:49:56', 'Se entrego la orden null a su mesa'),
(495, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-20 11:46:55', 'Se envio una orden a preparar'),
(496, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-20 11:47:02', 'Se envio una orden a despachar'),
(497, 11, 'orden', 'Actualizacion', '2025-08-20 11:47:19', 'Se entrego la orden null a su mesa'),
(498, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-20 11:48:08', 'Se envio una orden a preparar'),
(499, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-20 11:48:13', 'Se envio una orden a despachar'),
(500, 11, 'orden', 'Actualizacion', '2025-08-20 11:48:41', 'Se entrego la orden null a su mesa'),
(501, 11, 'Orden Reservacion', 'Pago', '2025-08-20 12:36:35', 'Se pago la orden 132'),
(502, 11, 'Orden local', 'Pago', '2025-08-20 12:58:22', 'Se pago la orden 128'),
(503, 11, 'Orden local', 'Pago', '2025-08-20 13:03:26', 'Se pago la orden 128'),
(504, 11, 'Orden Reservacion', 'Pago', '2025-08-20 13:04:22', 'Se pago la orden 132'),
(505, 11, 'Orden de cocina', 'La orden se encuentra en preparacion', '2025-08-20 13:25:34', 'Se envio una orden a preparar'),
(506, 11, 'Orden de cocina', 'La orden se encuentra para despachar', '2025-08-20 13:25:55', 'Se envio una orden a despachar'),
(507, 11, 'orden', 'Actualizacion', '2025-08-20 13:45:10', 'Se enviola orden null a su mesa'),
(508, 11, 'Usuarios', 'Login', '2025-08-20 14:28:48', 'inicio de sesion'),
(509, 11, 'Usuarios', 'Login', '2025-08-21 10:43:47', 'inicio de sesion'),
(510, 11, 'Usuarios', 'Login', '2025-08-25 09:49:30', 'inicio de sesion'),
(511, 11, 'Recetas', 'Agregar', '2025-08-25 10:48:05', 'Se agrego una nueva receta'),
(512, 11, 'Recetas', 'Agregar', '2025-08-25 10:49:04', 'Se agrego una nueva receta'),
(513, 11, 'Entradas', 'Agregado', '2025-08-25 11:20:24', 'Se ha agregado una entrada de materia prima'),
(514, 11, 'Entradas', 'Agregado', '2025-08-25 11:21:24', 'Se ha agregado una entrada de materia prima'),
(515, 11, 'Entradas', 'Agregado', '2025-08-25 11:22:04', 'Se ha agregado una entrada de materia prima'),
(516, 11, 'Entradas', 'Agregado', '2025-08-25 11:23:53', 'Se ha agregado una entrada de materia prima'),
(517, 11, 'Usuarios', 'Login', '2025-08-26 10:50:29', 'inicio de sesion'),
(518, 11, 'Recetas', 'Agregar', '2025-08-26 10:55:28', 'Se agrego una nueva receta'),
(519, 11, 'Entradas', 'Agregado', '2025-08-26 10:57:11', 'Se ha agregado una entrada de materia prima'),
(520, 11, 'orden', 'Actualizacion', '2025-08-26 13:26:56', 'Se anulo la orden 48539300'),
(521, 11, 'Entradas', 'Agregado', '2025-08-26 13:49:48', 'Se ha agregado una entrada de materia prima'),
(522, 11, 'Usuarios', 'Login', '2025-08-27 10:05:38', 'inicio de sesion'),
(523, 11, 'Usuarios', 'Login', '2025-08-28 09:46:41', 'inicio de sesion'),
(524, 11, 'Entradas', 'Agregado', '2025-08-28 14:12:58', 'Se ha agregado una entrada de materia prima'),
(525, 11, 'Entradas', 'Agregado', '2025-08-28 14:16:04', 'Se ha agregado una entrada de materia prima'),
(526, 11, 'Entradas', 'Agregado', '2025-08-28 14:19:19', 'Se ha agregado una entrada de materia prima'),
(527, 11, 'Productos Preparados', 'Agregar', '2025-08-28 15:46:22', 'Se agrego un producto preparado'),
(528, 11, 'Productos Preparados', 'Agregar', '2025-08-28 16:11:49', 'Se agrego un producto preparado'),
(529, 11, 'Recetas', 'Agregar', '2025-08-28 16:26:32', 'Se agrego una nueva receta'),
(530, 11, 'Entradas', 'Agregado', '2025-08-28 16:34:01', 'Se ha agregado una entrada de materia prima'),
(531, 11, 'Entradas', 'Agregado', '2025-08-29 11:30:35', 'Se ha agregado una entrada de materia prima'),
(532, 11, 'Entradas', 'Agregado', '2025-08-29 12:08:30', 'Se ha agregado una entrada de materia prima'),
(533, 11, 'Materia Prima', 'Actualizacion', '2025-08-29 12:09:26', 'Se actualizo una materia prima'),
(534, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(535, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(536, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(537, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(538, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(539, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(540, 11, 'Entradas', 'Agregado', '2025-09-01 13:49:58', 'Se agrego una entrada de materia prima'),
(541, 11, 'Usuarios', 'Login', '2025-09-01 10:19:40', 'inicio de sesion'),
(542, 11, 'Entrada de Materia Prima', 'Eliminacion', '2025-09-01 13:49:58', 'Se elimino una Entrada de Materia Prima'),
(543, 11, 'Entradas', 'Agregado', '2025-09-01 14:11:55', 'Se agrego una entrada de materia prima'),
(544, 11, 'Entradas', 'Agregado', '2025-09-01 14:46:25', 'Se agrego una entrada de materia prima'),
(545, 11, 'Entradas', 'Actualizado', '2025-09-01 14:46:53', 'Se actualizo una entrada de materia prima'),
(546, 11, 'Entradas', 'Actualizado', '2025-09-01 14:46:53', 'Se actualizo una entrada de materia prima'),
(547, 11, 'Entradas', 'Actualizado', '2025-09-01 14:46:53', 'Se actualizo una entrada de materia prima'),
(548, 11, 'Entradas', 'Actualizado', '2025-09-01 14:47:33', 'Se actualizo una entrada de materia prima'),
(549, 11, 'Entradas', 'Actualizado', '2025-09-01 14:47:51', 'Se actualizo una entrada de materia prima'),
(550, 11, 'Entradas', 'Actualizado', '2025-09-01 14:47:52', 'Se actualizo una entrada de materia prima'),
(551, 11, 'Entradas', 'Actualizado', '2025-09-01 14:48:21', 'Se actualizo una entrada de materia prima'),
(552, 11, 'Entradas', 'Actualizado', '2025-09-01 14:48:21', 'Se actualizo una entrada de materia prima'),
(553, 11, 'Entradas', 'Actualizado', '2025-09-01 14:48:56', 'Se actualizo una entrada de materia prima'),
(554, 11, 'Entradas', 'Actualizado', '2025-09-01 14:49:36', 'Se actualizo una entrada de materia prima'),
(555, 11, 'Entradas', 'Actualizado', '2025-09-01 14:49:36', 'Se actualizo una entrada de materia prima'),
(556, 11, 'Entradas', 'Actualizado', '2025-09-01 15:09:00', 'Se actualizo una entrada de materia prima'),
(557, 11, 'Entradas', 'Actualizado', '2025-09-01 15:09:19', 'Se actualizo una entrada de materia prima'),
(558, 11, 'Entradas', 'Actualizado', '2025-09-01 15:11:17', 'Se actualizo una entrada de materia prima'),
(559, 11, 'Usuarios', 'Login', '2025-09-02 11:00:52', 'inicio de sesion'),
(560, 11, 'Usuarios', 'Login', '2025-09-03 11:16:22', 'inicio de sesion'),
(561, 11, 'Entradas', 'Agregado', '2025-09-03 12:40:25', 'Se agrego una entrada de materia prima'),
(562, 11, 'Entradas', 'Agregado', '2025-09-03 12:42:45', 'Se agrego una entrada de materia prima'),
(563, 11, 'Entradas', 'Actualizado', '2025-09-03 13:06:05', 'Se actualizo una entrada de materia prima'),
(564, 11, 'Entradas', 'Actualizado', '2025-09-03 13:07:22', 'Se actualizo una entrada de materia prima'),
(565, 11, 'Entradas', 'Actualizado', '2025-09-03 13:11:22', 'Se actualizo una entrada de materia prima'),
(566, 11, 'Producto procesado', 'Agregar', '2025-09-03 13:43:07', 'Se agrego un producto procesado'),
(567, 11, 'Producto procesado', 'Actualizacion', '2025-09-03 13:48:14', 'Se agrego un producto procesado'),
(568, 11, 'Producto procesado', 'Actualizacion', '2025-09-03 13:49:36', 'Se agrego un producto procesado'),
(569, 11, 'Producto procesado', 'Actualizacion', '2025-09-03 13:49:36', 'Se agrego un producto procesado'),
(570, 11, 'Entradas', 'Agregado', '2025-09-03 14:02:06', 'Se agrego una entrada de materia prima'),
(571, 11, 'Usuarios', 'Login', '2025-09-04 10:12:59', 'inicio de sesion');
INSERT INTO `bitacora` (`id`, `id_usuario`, `tabla`, `accion`, `fecha`, `descripcion`) VALUES
(572, 11, 'Entradas', 'Agregado', '2025-09-04 10:37:23', 'Se agrego una entrada de materia prima'),
(573, 15, 'Usuarios', 'Login', '2025-09-04 12:41:44', 'inicio de sesion'),
(574, 11, 'Usuarios', 'Login', '2025-09-24 12:00:37', 'inicio de sesion'),
(575, 11, 'Usuarios', 'Login', '2025-09-25 10:46:48', 'inicio de sesion'),
(576, 11, 'Entradas', 'Agregado', '2025-09-25 14:16:41', 'Se agrego una entrada de materia prima'),
(577, 11, 'Entradas', 'Agregado', '2025-09-25 14:19:38', 'Se agrego una entrada de materia prima'),
(578, 11, 'Entradas', 'Agregado', '2025-09-25 15:09:32', 'Se agrego una entrada de materia prima'),
(579, 11, 'Entradas', 'Agregado', '2025-09-25 15:12:37', 'Se agrego una entrada de materia prima'),
(580, 11, 'Entradas', 'Agregado', '2025-09-25 15:15:08', 'Se agrego una entrada de materia prima'),
(581, 11, 'Entradas', 'Agregado', '2025-09-25 15:16:14', 'Se agrego una entrada de materia prima'),
(582, 11, 'Entradas', 'Agregado', '2025-09-25 15:23:05', 'Se agrego una entrada de materia prima'),
(583, 11, 'Entradas', 'Agregado', '2025-09-25 20:16:16', 'Se agrego una entrada de materia prima'),
(584, 11, 'Usuarios', 'Login', '2025-09-29 11:00:44', 'inicio de sesion'),
(585, 11, 'Entradas', 'Actualizado', '2025-09-29 12:49:34', 'Se actualizo una entrada de materia prima'),
(586, 11, 'Usuarios', 'Login', '2025-09-30 10:52:20', 'inicio de sesion'),
(587, 11, 'Usuarios', 'Login', '2025-09-30 10:56:52', 'inicio de sesion'),
(593, 13, 'Usuarios', 'Login', '2025-10-13 20:27:57', 'inicio de sesion'),
(615, 14, 'Usuarios', 'Login', '2025-10-16 20:21:44', 'inicio de sesion'),
(631, 14, 'Usuarios', 'Login', '2025-10-26 18:38:17', 'inicio de sesion'),
(632, 14, 'Usuarios', 'Login', '2025-10-28 17:37:55', 'inicio de sesion'),
(633, 14, 'Caja', 'Agregar', '2025-10-30 09:57:02', 'Se abrio una caja'),
(634, 14, 'Caja', 'Cerrar', '2025-10-30 10:15:23', 'Se cerro la caja 87'),
(635, 14, 'Caja', 'Cerrar', '2025-10-30 10:15:25', 'Se cerro la caja 86'),
(636, 14, 'Caja', 'Cerrar', '2025-10-30 10:15:27', 'Se cerro la caja 85'),
(637, 14, 'Caja', 'Cerrar', '2025-10-30 10:15:31', 'Se cerro la caja 84'),
(653, 14, 'Usuarios', 'Login', '2026-02-06 11:58:57', 'inicio de sesion'),
(654, 14, 'Usuarios', 'Agregar', '2026-02-06 15:06:00', 'Se agrego un usuario'),
(655, 25, 'Usuarios', 'Login', '2026-02-06 17:57:14', 'inicio de sesion'),
(656, 25, 'Usuarios', 'Login', '2026-02-06 18:00:39', 'inicio de sesion'),
(657, 25, 'Usuarios', 'Login', '2026-02-06 18:13:53', 'inicio de sesion'),
(658, 25, 'Usuarios', 'Login', '2026-02-06 18:22:54', 'inicio de sesion'),
(659, 25, 'Usuarios', 'Login', '2026-02-07 00:56:45', 'inicio de sesion'),
(660, 25, 'Usuarios', 'Login', '2026-02-24 15:40:35', 'inicio de sesion'),
(661, 25, 'Usuarios', 'Login', '2026-02-24 22:01:12', 'inicio de sesion'),
(662, 25, 'Usuarios', 'Login', '2026-02-24 22:05:29', 'inicio de sesion'),
(665, 25, 'undefined', 'undefined', '2026-02-28 15:57:51', 'undefined'),
(666, 25, 'Caja', 'Agregar', '2026-02-28 16:10:04', 'Se abrio una caja'),
(667, 25, 'Caja', 'Cerrar', '2026-02-28 16:10:09', 'Se cerro la caja 126'),
(668, 25, 'undefined', 'undefined', '2026-03-01 01:25:55', 'undefined'),
(669, 25, 'undefined', 'undefined', '2026-03-01 02:43:44', 'undefined'),
(670, 25, 'Usuarios', 'Login', '2026-03-01 03:44:30', 'inicio de sesion'),
(671, 25, 'Usuarios', 'Login', '2026-03-01 04:20:47', 'inicio de sesion'),
(672, 25, 'Usuarios', 'Login', '2026-03-01 04:35:13', 'inicio de sesion'),
(673, 25, 'Caja', 'Agregar', '2026-03-01 13:08:49', 'Se abrio una caja'),
(674, 25, 'Caja', 'Cerrar', '2026-03-01 13:09:09', 'Se cerro la caja 127'),
(675, 25, 'Caja', 'Cerrar', '2026-03-01 13:09:14', 'Se cerro la caja 125'),
(676, 25, 'Caja', 'Cerrar', '2026-03-01 13:09:18', 'Se cerro la caja 123'),
(677, 25, 'Caja', 'Agregar', '2026-03-01 21:27:16', 'Se abrio una caja'),
(678, 25, 'Usuarios', 'Login', '2026-03-02 19:05:40', 'inicio de sesion'),
(679, 25, 'Unidades', 'Editar', '2026-03-03 16:29:43', 'Se ha editado una unidad'),
(680, 25, 'Usuarios', 'Login', '2026-03-03 16:43:15', 'inicio de sesion'),
(691, 25, 'Usuarios', 'Actualizacion', '2026-03-05 03:33:26', 'Se actualizo un usuario'),
(692, 25, 'Usuarios', 'Actualizacion', '2026-03-05 03:33:36', 'Se actualizo un usuario'),
(693, 25, 'Usuarios', 'Actualizacion', '2026-03-05 04:40:53', 'Se actualizo un usuario'),
(694, 25, 'Usuarios', 'Actualizacion', '2026-03-05 04:40:58', 'Se actualizo un usuario'),
(695, 25, 'Usuarios', 'Login', '2026-03-05 13:22:21', 'inicio de sesion'),
(696, 25, 'Unidades', 'Agregar', '2026-03-05 14:41:31', 'Se ha agregado una unidad'),
(697, 25, 'Unidades', 'Eliminacion', '2026-03-05 14:41:35', 'Se ha eliminado una Unidad'),
(698, 25, 'Entradas', 'Agregado', '2026-03-05 17:27:45', 'Se agrego una entrada de materia prima'),
(699, 25, 'Entradas', 'Agregado', '2026-03-05 17:51:15', 'Se agrego una entrada de materia prima'),
(700, 25, 'paquete', 'Paquete creado', '2026-03-08 13:23:48', 'Se agrego un nuevo paquete'),
(701, 25, 'paquetes', 'Eliminacion', '2026-03-08 13:23:55', 'Se elimino un paquete de reserva'),
(702, 25, 'capital', 'Agregar', '2026-03-10 02:03:29', 'Guardar Gasto en capital de 10,00 $'),
(703, 25, 'capital', 'Agregar', '2026-03-10 02:09:33', 'Guardar Gasto en capital de 10,00 $'),
(704, 25, 'capital', 'Agregar', '2026-03-10 02:10:18', 'Guardar Gasto en capital de 10,00 $'),
(705, 25, 'capital', 'Agregar', '2026-03-10 02:14:25', 'Guardar Gasto en capital de 10,00 $'),
(706, 25, 'capital', 'Agregar', '2026-03-10 02:14:40', 'Guardar Ingreso en capital de 10,00 $'),
(707, 25, 'Categoria de Producto', 'Agregar', '2026-03-10 15:23:49', 'Se agrego una categoria de productos'),
(708, 25, 'Categoria de Producto', 'Agregar', '2026-03-10 15:37:44', 'Se agrego una categoria de productos'),
(709, 25, 'capital', 'Agregar', '2026-03-10 15:46:14', 'Guardar Ingreso en capital de 10,00 $'),
(710, 25, 'capital', 'Agregar', '2026-03-10 15:46:42', 'Guardar Gasto en capital de 10,00 $'),
(711, 25, 'Categoria de Producto', 'Actualizacion', '2026-03-10 16:16:21', 'Se actualizo una categoria de productos'),
(712, 25, 'Categoria de Producto', 'Eliminacion', '2026-03-10 18:29:33', 'Se elimino una categoria de productos'),
(713, 25, 'Mesas', 'Edicion', '2026-03-10 20:53:52', 'Se Edito un mesa'),
(714, 25, 'Mesas', 'Edicion', '2026-03-10 20:54:06', 'Se Edito un mesa'),
(715, 25, 'Mesas', 'Edicion', '2026-03-10 21:00:48', 'Se Edito un mesa'),
(716, 25, 'Mesas', 'Edicion', '2026-03-10 21:03:47', 'Se Edito un mesa'),
(717, 25, 'Mesas', 'Edicion', '2026-03-10 21:11:29', 'Se Edito un mesa'),
(718, 25, 'Mesas', 'Edicion', '2026-03-10 21:12:30', 'Se Edito un mesa'),
(719, 25, 'Mesas', 'Edicion', '2026-03-10 21:16:21', 'Se Edito un mesa'),
(720, 25, 'Mesas', 'Edicion', '2026-03-10 21:20:30', 'Se Edito un mesa'),
(721, 25, 'Mesas', 'Edicion', '2026-03-10 21:21:49', 'Se Edito un mesa'),
(722, 25, 'Mesas', 'Edicion', '2026-03-10 21:22:14', 'Se Edito un mesa'),
(723, 25, 'Mesas', 'Edicion', '2026-03-10 21:23:53', 'Se Edito un mesa'),
(724, 25, 'Mesas', 'Edicion', '2026-03-10 21:25:07', 'Se Edito un mesa'),
(725, 25, 'Mesas', 'Edicion', '2026-03-10 21:26:10', 'Se Edito un mesa'),
(726, 25, 'Mesas', 'Edicion', '2026-03-10 21:28:25', 'Se Edito un mesa'),
(727, 25, 'Mesas', 'Edicion', '2026-03-10 21:29:51', 'Se Edito un mesa'),
(728, 25, 'Mesas', 'Edicion', '2026-03-10 21:44:10', 'Se Edito un mesa'),
(729, 25, 'Mesas', 'Edicion', '2026-03-10 21:45:18', 'Se Edito un mesa'),
(730, 25, 'Mesas', 'Edicion', '2026-03-10 21:52:50', 'Se Edito un mesa'),
(731, 25, 'Mesas', 'Edicion', '2026-03-10 21:53:04', 'Se Edito un mesa'),
(732, 25, 'Mesas', 'Eliminacion', '2026-03-10 23:24:44', 'Se Elimino un mesa'),
(733, 25, 'Mesas', 'Agregar', '2026-03-10 23:24:58', 'Se agregó una mesa con el id: 70'),
(734, 25, 'Mesas', 'Eliminacion', '2026-03-10 23:27:28', 'Se Elimino un mesa'),
(735, 25, 'Mesas', 'Agregar', '2026-03-10 23:27:38', 'Se agregó una mesa con el id: 71'),
(736, 25, 'Mesas', 'Eliminacion', '2026-03-10 23:28:43', 'Se Elimino un mesa'),
(737, 25, 'Mesas', 'Agregar', '2026-03-10 23:28:53', 'Se agregó una mesa con el id: 72'),
(738, 25, 'Unidades', 'Agregar', '2026-03-11 00:45:06', 'Se ha agregado una unidad'),
(739, 25, 'Unidades', 'Eliminacion', '2026-03-11 00:45:11', 'Se ha eliminado una Unidad'),
(740, 25, 'Usuarios', 'Login', '2026-03-16 14:39:18', 'inicio de sesion'),
(741, 25, 'Permisos', 'Actualizar', '2026-03-16 16:15:28', 'Permiso agregar del módulo mesas eliminado'),
(742, 25, 'Usuarios', 'Login', '2026-03-16 16:23:35', 'inicio de sesion'),
(743, 25, 'Permisos', 'Actualizar', '2026-03-16 16:27:05', 'Permiso consultar del módulo mesas agregado'),
(744, 25, 'Usuarios', 'Login', '2026-03-16 17:59:13', 'inicio de sesion'),
(745, 25, 'Permisos', 'Actualizar', '2026-03-16 18:08:43', 'Permiso consultar del módulo caja agregado'),
(746, 25, 'Permisos', 'Actualizar', '2026-03-16 18:18:17', 'Permiso consultar del módulo caja agregado'),
(747, 25, 'Permisos', 'Actualizar', '2026-03-16 19:11:51', 'Permiso editar del módulo mesas agregado'),
(748, 25, 'Permisos', 'Actualizar', '2026-03-16 19:12:04', 'Permiso editar del módulo mesas agregado'),
(749, 25, 'Permisos', 'Actualizar', '2026-03-16 19:12:15', 'Permiso eliminar del módulo mesas agregado'),
(750, 13, 'Mesas', 'Eliminacion', '2026-03-16 19:12:17', 'Se Elimino un mesa'),
(751, 25, 'Permisos', 'Actualizar', '2026-03-16 19:16:44', 'Permiso consultar del módulo Papelera agregado'),
(752, 13, 'Papelera', 'Restaurar', '2026-03-16 19:17:04', 'Se ha restaurado un elemento de la papelera'),
(753, 13, 'Papelera', 'Restaurar', '2026-03-16 19:17:06', 'Se ha restaurado un elemento de la papelera'),
(754, 13, 'Papelera', 'Restaurar', '2026-03-16 19:17:10', 'Se ha restaurado un elemento de la papelera'),
(755, 13, 'Papelera', 'Restaurar', '2026-03-16 19:17:11', 'Se ha restaurado un elemento de la papelera'),
(756, 25, 'Entradas', 'Agregado', '2026-03-20 21:12:48', 'Se agrego una entrada de materia prima');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_roles`
--

CREATE TABLE `detalles_roles` (
  `id` int NOT NULL,
  `id_rol` int NOT NULL,
  `modulo` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `permisos` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `detalles_roles`
--

INSERT INTO `detalles_roles` (`id`, `id_rol`, `modulo`, `permisos`) VALUES
(33, 1, 'mesas', 'consultar,agregar,editar,eliminar'),
(34, 1, 'ordenes', 'consultar'),
(35, 1, 'Producto preparado', 'consultar,agregar,editar,eliminar'),
(36, 1, 'Producto procesado', 'consultar,agregar,editar,eliminar'),
(37, 1, 'Materia prima', 'consultar,agregar,editar,eliminar'),
(38, 1, 'Entradas de materia prima', 'agregar,editar,eliminar'),
(39, 1, 'Recetas', 'consultar,agregar,editar'),
(40, 1, 'Adicionales', 'consultar,agregar,editar,eliminar'),
(41, 1, 'Entradas de productos procesados', 'agregar,editar,eliminar'),
(42, 1, 'proveedores', 'consultar,agregar,editar,eliminar'),
(43, 1, 'estadisticas', 'consultar'),
(44, 1, 'bitacora', 'consultar'),
(45, 1, 'clientes', 'consultar,agregar,editar,eliminar'),
(46, 1, 'unidades', 'consultar,agregar,editar,eliminar'),
(47, 1, 'categorias', 'consultar,agregar,editar,eliminar'),
(48, 1, 'metodo pago', 'consultar,agregar,editar,eliminar'),
(49, 1, 'usuarios', 'consultar,agregar,editar,eliminar'),
(50, 1, 'cocina', 'consultar,preparar,ver detalles'),
(52, 1, 'Ordenes (llevar)', 'consultar,verificar,anular,despachar,crear'),
(53, 1, 'delivery', 'consultar,aceptar entrega,ver detalles'),
(54, 1, 'capital', 'consultar,guardar gasto,guardar ingreso'),
(55, 1, 'caja', 'consultar,abrir,cerrar,ver detalles'),
(56, 1, 'roles y permisos', 'consultar,agregar,asignar roles,editar,eliminar'),
(57, 1, 'Mantenimiento', 'consultar,importar,exportar,eliminar'),
(59, 1, 'Papelera', 'consultar,restaurar'),
(78, 3, 'cocina', 'consultar,preparar,ver detalles'),
(79, 3, 'mesas', ''),
(80, 3, 'Materia prima', ''),
(81, 3, 'ordenes', 'consultar'),
(84, 3, 'estadisticas', ''),
(85, 3, 'capital', ''),
(86, 3, 'Papelera', ''),
(87, 3, 'Producto preparado', ''),
(88, 3, 'Entradas de materia prima', ''),
(89, 3, 'Recetas', ''),
(90, 3, 'Adicionales', ''),
(91, 3, 'Producto procesado', ''),
(92, 3, 'Entradas de productos procesados', ''),
(93, 3, 'proveedores', ''),
(94, 3, 'clientes', ''),
(95, 3, 'caja', ''),
(96, 3, 'categorias', ''),
(97, 3, 'metodo pago', ''),
(98, 3, 'usuarios', ''),
(99, 3, 'unidades', ''),
(101, 3, 'Mantenimiento', ''),
(103, 3, 'roles y permisos', ''),
(105, 1, 'Ordenes (delivery)', 'consultar,verificar,anular,crear'),
(106, 1, 'Ordenes (local)', 'consultar,agregar productos,pagar,despachar,crear'),
(107, 3, 'Ordenes (local)', ''),
(108, 3, 'Ordenes (delivery)', 'consultar,verificar,anular,crear'),
(109, 3, 'Ordenes (llevar)', 'consultar,verificar,anular,despachar,crear'),
(110, 1, 'paquetes', 'consultar,agregar,editar,eliminar'),
(111, 1, 'reservaciones', 'consultar,agendar reservacion,anular reservacion,verificar reservacion,editar'),
(112, 3, 'delivery', 'consultar,aceptar entrega'),
(113, 1, 'facturas', 'consultar'),
(114, 3, 'paquetes', ''),
(115, 3, 'reservaciones', ''),
(116, 3, 'facturas', ''),
(117, 3, 'Ordenes (reservas)', 'consultar,agregar productos'),
(118, 1, 'Ordenes (reservas)', 'consultar,agregar productos,pagar,despachar'),
(144, 2, 'mesas', 'consultar');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

CREATE TABLE `modulos` (
  `id` int NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `modulos`
--

INSERT INTO `modulos` (`id`, `nombre`, `descripcion`, `active`) VALUES
(1, 'mesas', 'Gestión de mesas del restaurante', 1),
(2, 'ordenes', 'Vista general de órdenes', 1),
(3, 'Producto preparado', 'Gestión de productos preparados', 1),
(4, 'Producto procesado', 'Gestión de productos procesados', 1),
(5, 'Materia prima', 'Gestión de materia prima', 1),
(6, 'Entradas de materia prima', 'Registro de entradas de materia prima', 1),
(7, 'Recetas', 'Gestión de recetas', 1),
(8, 'Adicionales', 'Gestión de adicionales', 1),
(9, 'Entradas de productos procesados', 'Registro de entradas de productos procesados', 1),
(10, 'proveedores', 'Gestión de proveedores', 1),
(11, 'estadisticas', 'Estadísticas del sistema', 1),
(12, 'bitacora', 'Bitácora de actividades', 1),
(13, 'clientes', 'Gestión de clientes', 1),
(14, 'unidades', 'Gestión de unidades de medida', 1),
(15, 'categorias', 'Gestión de categorías', 1),
(16, 'metodo pago', 'Gestión de métodos de pago', 1),
(17, 'usuarios', 'Gestión de usuarios', 1),
(18, 'cocina', 'Módulo de cocina', 1),
(19, 'Ordenes (llevar)', 'Órdenes para llevar', 1),
(20, 'delivery', 'Órdenes de delivery', 1),
(21, 'capital', 'Gestión de capital', 1),
(22, 'caja', 'Gestión de caja', 1),
(23, 'roles y permisos', 'Gestión de roles y permisos', 1),
(24, 'Mantenimiento', 'Mantenimiento del sistema', 1),
(25, 'Papelera', 'Papelera de reciclaje', 1),
(26, 'Ordenes (delivery)', 'Órdenes de delivery', 1),
(27, 'Ordenes (local)', 'Órdenes locales', 1),
(28, 'Ordenes (reservas)', 'Órdenes de reservas', 1),
(29, 'paquetes', 'Gestión de paquetes', 1),
(30, 'reservaciones', 'Gestión de reservaciones', 1),
(31, 'facturas', 'Gestión de facturas', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id` int NOT NULL,
  `id_usuario` int NOT NULL,
  `titulo` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `mensaje` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `notificaciones`
--

INSERT INTO `notificaciones` (`id`, `id_usuario`, `titulo`, `mensaje`, `status`, `fecha`) VALUES
(19, 11, 'La orden tomada', 'La orden 0087 esta en camino para despachar', 1, '2025-08-08 12:11:07'),
(20, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0116', 1, '2025-08-08 12:40:58'),
(21, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0088', 1, '2025-08-08 12:41:08'),
(22, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0114', 1, '2025-08-08 12:43:59'),
(23, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0114', 1, '2025-08-08 12:44:22'),
(24, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0117', 1, '2025-08-09 12:15:02'),
(25, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0117', 1, '2025-08-09 12:15:21'),
(26, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0117', 1, '2025-08-09 12:17:05'),
(27, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0118', 1, '2025-08-09 12:26:26'),
(28, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0118', 1, '2025-08-09 12:26:36'),
(29, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0118', 1, '2025-08-09 12:27:39'),
(30, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0119', 1, '2025-08-09 12:29:14'),
(31, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0119', 1, '2025-08-09 12:29:23'),
(32, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0129', 1, '2025-08-09 13:06:24'),
(33, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0129', 1, '2025-08-09 13:06:27'),
(34, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0128', 1, '2025-08-09 13:10:30'),
(35, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0128', 1, '2025-08-09 13:10:35'),
(36, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0127', 1, '2025-08-09 13:11:45'),
(37, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0127', 1, '2025-08-09 13:11:51'),
(38, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0129', 1, '2025-08-09 13:16:33'),
(39, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0130', 1, '2025-08-09 13:19:00'),
(40, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0130', 1, '2025-08-09 13:19:12'),
(41, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0130', 1, '2025-08-09 13:21:01'),
(42, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0132', 1, '2025-08-19 12:55:26'),
(43, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0132', 1, '2025-08-19 12:55:42'),
(44, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0132', 1, '2025-08-19 14:45:48'),
(45, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0132', 1, '2025-08-19 14:45:55'),
(46, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0132', 1, '2025-08-19 14:48:21'),
(47, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0132', 1, '2025-08-19 14:48:36'),
(48, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0131', 1, '2025-08-20 11:46:55'),
(49, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0131', 1, '2025-08-20 11:47:03'),
(50, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0131', 1, '2025-08-20 11:48:08'),
(51, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0131', 1, '2025-08-20 11:48:14'),
(52, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0132', 1, '2025-08-20 12:36:35'),
(53, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0128', 1, '2025-08-20 13:03:27'),
(54, 11, 'Se ha pagado una orden', 'Se ha pagado una orden con el nro 0132', 1, '2025-08-20 13:04:22'),
(55, 11, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 0101', 1, '2025-08-20 13:25:34'),
(56, 11, 'La orden se encuentra para despachar', 'Se envio una orden a despachar con el nro 0101', 1, '2025-08-20 13:25:56'),
(57, 11, 'Producto con stock bajo', 'El producto Gloup 1L tiene un stock bajo', 1, '2025-09-04 12:11:04'),
(58, 11, 'Producto con stock bajo', 'El producto Sun 1L tiene un stock bajo', 1, '2025-09-04 12:11:14'),
(59, 11, 'Producto con stock bajo', 'El producto Gloup 1L tiene un stock bajo', 1, '2025-09-04 12:15:27'),
(60, 11, 'Producto con stock bajo', 'El producto Sun 1L tiene un stock bajo', 1, '2025-09-04 12:15:29'),
(61, 11, 'Producto con stock bajo', 'El producto Gloup 1L tiene un stock bajo', 1, '2025-09-04 12:19:32'),
(62, 11, 'Producto con stock bajo', 'El producto Sun 1L tiene un stock bajo', 1, '2025-09-04 12:19:33'),
(63, 11, 'Producto con stock bajo', 'El producto Gloup 1L tiene un stock bajo', 1, '2025-09-04 12:22:42'),
(64, 11, 'Producto con stock bajo', 'El producto Sun 1L tiene un stock bajo', 1, '2025-09-04 12:22:48'),
(65, 11, 'Producto con stock bajo', 'El producto Gloup 1L tiene un stock bajo', 1, '2025-09-04 12:29:39'),
(146, 25, 'La orden se encuentra en preparacion', 'Se envio una orden a preparar con el nro 7393', 0, '2026-03-10 15:19:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `id` int NOT NULL,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`id`, `nombre`, `descripcion`, `active`) VALUES
(1, 'consultar', 'Permiso para consultar/ver datos', 1),
(2, 'agregar', 'Permiso para agregar nuevos registros', 1),
(3, 'editar', 'Permiso para editar registros', 1),
(4, 'eliminar', 'Permiso para eliminar registros', 1),
(5, 'preparar', 'Permiso para preparar órdenes en cocina', 1),
(6, 'ver detalles', 'Permiso para ver detalles', 1),
(7, 'verificar', 'Permiso para verificar órdenes', 1),
(8, 'anular', 'Permiso para anular órdenes', 1),
(9, 'despachar', 'Permiso para despachar órdenes', 1),
(10, 'crear', 'Permiso para crear órdenes', 1),
(11, 'aceptar entrega', 'Permiso para aceptar entregas de delivery', 1),
(12, 'guardar gasto', 'Permiso para guardar gastos en capital', 1),
(13, 'guardar ingreso', 'Permiso para guardar ingresos en capital', 1),
(14, 'abrir', 'Permiso para abrir caja', 1),
(15, 'cerrar', 'Permiso para cerrar caja', 1),
(16, 'asignar roles', 'Permiso para asignar roles a usuarios', 1),
(17, 'importar', 'Permiso para importar datos', 1),
(18, 'exportar', 'Permiso para exportar datos', 1),
(19, 'restaurar', 'Permiso para restaurar elementos de papelera', 1),
(20, 'pagar', 'Permiso para procesar pagos', 1),
(21, 'agregar productos', 'Permiso para agregar productos a órdenes', 1),
(22, 'agendar reservacion', 'Permiso para agendar reservaciones', 1),
(23, 'anular reservacion', 'Permiso para anular reservaciones', 1),
(24, 'verificar reservacion', 'Permiso para verificar reservaciones', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `nombre` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id`, `nombre`, `descripcion`, `active`) VALUES
(1, 'Super Admin', 'Rol con acceso a todas las funciones del ecommerce', 1),
(2, 'Cajero', 'Rol destinado a la atencion de usuarios y recibir pagos en BurgerHouse', 1),
(3, 'Cocinero', 'Rol destinado a la preparacion de comida de Burger House', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles_modulos_permisos`
--

CREATE TABLE `roles_modulos_permisos` (
  `id` int NOT NULL,
  `id_rol` int NOT NULL,
  `id_modulo` int NOT NULL,
  `id_permiso` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `roles_modulos_permisos`
--

INSERT INTO `roles_modulos_permisos` (`id`, `id_rol`, `id_modulo`, `id_permiso`) VALUES
(4, 1, 1, 1),
(3, 1, 1, 2),
(2, 1, 1, 3),
(1, 1, 1, 4),
(5, 1, 2, 1),
(9, 1, 3, 1),
(8, 1, 3, 2),
(7, 1, 3, 3),
(6, 1, 3, 4),
(13, 1, 4, 1),
(12, 1, 4, 2),
(11, 1, 4, 3),
(10, 1, 4, 4),
(17, 1, 5, 1),
(16, 1, 5, 2),
(15, 1, 5, 3),
(14, 1, 5, 4),
(20, 1, 6, 2),
(19, 1, 6, 3),
(18, 1, 6, 4),
(23, 1, 7, 1),
(22, 1, 7, 2),
(21, 1, 7, 3),
(27, 1, 8, 1),
(26, 1, 8, 2),
(25, 1, 8, 3),
(24, 1, 8, 4),
(30, 1, 9, 2),
(29, 1, 9, 3),
(28, 1, 9, 4),
(34, 1, 10, 1),
(33, 1, 10, 2),
(32, 1, 10, 3),
(31, 1, 10, 4),
(35, 1, 11, 1),
(36, 1, 12, 1),
(40, 1, 13, 1),
(39, 1, 13, 2),
(38, 1, 13, 3),
(37, 1, 13, 4),
(44, 1, 14, 1),
(43, 1, 14, 2),
(42, 1, 14, 3),
(41, 1, 14, 4),
(48, 1, 15, 1),
(47, 1, 15, 2),
(46, 1, 15, 3),
(45, 1, 15, 4),
(52, 1, 16, 1),
(51, 1, 16, 2),
(50, 1, 16, 3),
(49, 1, 16, 4),
(56, 1, 17, 1),
(55, 1, 17, 2),
(54, 1, 17, 3),
(53, 1, 17, 4),
(59, 1, 18, 1),
(58, 1, 18, 5),
(57, 1, 18, 6),
(64, 1, 19, 1),
(63, 1, 19, 7),
(62, 1, 19, 8),
(61, 1, 19, 9),
(60, 1, 19, 10),
(67, 1, 20, 1),
(65, 1, 20, 6),
(66, 1, 20, 11),
(70, 1, 21, 1),
(69, 1, 21, 12),
(68, 1, 21, 13),
(74, 1, 22, 1),
(71, 1, 22, 6),
(73, 1, 22, 14),
(72, 1, 22, 15),
(79, 1, 23, 1),
(78, 1, 23, 2),
(76, 1, 23, 3),
(75, 1, 23, 4),
(77, 1, 23, 16),
(83, 1, 24, 1),
(80, 1, 24, 4),
(82, 1, 24, 17),
(81, 1, 24, 18),
(85, 1, 25, 1),
(84, 1, 25, 19),
(93, 1, 26, 1),
(92, 1, 26, 7),
(91, 1, 26, 8),
(90, 1, 26, 10),
(98, 1, 27, 1),
(95, 1, 27, 9),
(94, 1, 27, 10),
(96, 1, 27, 20),
(97, 1, 27, 21),
(125, 1, 28, 1),
(122, 1, 28, 9),
(123, 1, 28, 20),
(124, 1, 28, 21),
(111, 1, 29, 1),
(110, 1, 29, 2),
(109, 1, 29, 3),
(108, 1, 29, 4),
(116, 1, 30, 1),
(112, 1, 30, 3),
(115, 1, 30, 22),
(114, 1, 30, 23),
(113, 1, 30, 24),
(119, 1, 31, 1),
(126, 2, 1, 1),
(130, 2, 1, 3),
(132, 2, 1, 4),
(129, 2, 22, 1),
(133, 2, 25, 1),
(127, 3, 1, 1),
(131, 3, 1, 3),
(89, 3, 2, 1),
(88, 3, 18, 1),
(87, 3, 18, 5),
(86, 3, 18, 6),
(107, 3, 19, 1),
(106, 3, 19, 7),
(105, 3, 19, 8),
(104, 3, 19, 9),
(103, 3, 19, 10),
(118, 3, 20, 1),
(117, 3, 20, 11),
(128, 3, 22, 1),
(102, 3, 26, 1),
(101, 3, 26, 7),
(100, 3, 26, 8),
(99, 3, 26, 10),
(121, 3, 28, 1),
(120, 3, 28, 21);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int NOT NULL,
  `id_rol` int NOT NULL,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `hash` text CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `apellido` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `session_id` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL DEFAULT '1',
  `email` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL,
  `token` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL DEFAULT 'token',
  `token_expiracion` datetime DEFAULT NULL,
  `imagen` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `id_rol`, `nombre`, `hash`, `apellido`, `active`, `session_id`, `email`, `token`, `token_expiracion`, `imagen`) VALUES
(11, 1, 'Alejandro', 'Alejandro202**', 'Vargas', 1, '1', 'garnicaluis391@gmail.com', '9070', '2025-06-24 20:16:33', 'nacht-black-clover_3840x2160_xtrafondos.com.jpg'),
(13, 2, 'Pedro', '$2y$10$JzHkrSQ4EAAWib41czCfC.q9TWA2PxvKcab1eEI1KvKol3hgcNKcW', 'Perez', 1, 'l1dCGuiJgQ', 'pedro202@gmail.com', 'token', NULL, ''),
(14, 1, 'Rolando', 'Martinez25/', 'Martinez', 1, 'eGb0Acm4SF', 'martinezj@gmail.com', 'token', NULL, ''),
(15, 3, 'Luis', 'Luisgv202*', 'Garnica', 1, '1', 'l4rius2002@gmail.com', 'token', NULL, '103327.jpg'),
(25, 1, 'Persona', '$2y$10$8oqGSd2b.Q0QuQxiGyRevuUcYuDlmi3JSCSUmJG6ydJgPdFI.ylOm', 'Humana', 1, 'kFd6DKaENg', 'yolokratos903@gmail.com', 'token', NULL, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Usuario` (`id_usuario`);

--
-- Indices de la tabla `detalles_roles`
--
ALTER TABLE `detalles_roles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_rol` (`id_rol`);

--
-- Indices de la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre_UNIQUE` (`nombre`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario` (`id_usuario`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre_UNIQUE` (`nombre`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `roles_modulos_permisos`
--
ALTER TABLE `roles_modulos_permisos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rol_modulo_permiso_unique` (`id_rol`,`id_modulo`,`id_permiso`),
  ADD KEY `id_rol` (`id_rol`),
  ADD KEY `id_modulo` (`id_modulo`),
  ADD KEY `id_permiso` (`id_permiso`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idRol` (`id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=757;

--
-- AUTO_INCREMENT de la tabla `detalles_roles`
--
ALTER TABLE `detalles_roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=194;

--
-- AUTO_INCREMENT de la tabla `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT de la tabla `roles_modulos_permisos`
--
ALTER TABLE `roles_modulos_permisos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=134;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD CONSTRAINT `bitacora_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `detalles_roles`
--
ALTER TABLE `detalles_roles`
  ADD CONSTRAINT `detalles_roles_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `roles_modulos_permisos`
--
ALTER TABLE `roles_modulos_permisos`
  ADD CONSTRAINT `roles_modulos_permisos_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `roles_modulos_permisos_ibfk_2` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `roles_modulos_permisos_ibfk_3` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
