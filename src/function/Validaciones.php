<?php
namespace Shtch\Burgerhouse\function;

class Validaciones {
    // ========== Métodos de validación generales ==========
    public static function validar_id($variable) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id'], $variable);
    }
    public static function validar_id_metodo_pago($id_metodo_pago) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_metodo_pago'], $id_metodo_pago);
    }

    public static function validar_active($active) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['active'], $active);
    }

    public static function validar_fecha($fecha) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha'], $fecha);
    }

    public static function validar_monto($monto) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['monto'], $monto);
    }

    public static function validar_cantidad($cantidad) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['cantidad'], $cantidad);
    }

    public static function validar_nombre($nombre) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['nombre'], $nombre);
    }

    public static function validar_apellido($apellido) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['apellido'], $apellido);
    }

    public static function validar_email($email) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['email'], $email);
    }

    public static function validar_password($password) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['password'], $password);
    }

    public static function validar_telefono($telefono) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['telefono'], $telefono);
    }

    public static function validar_documento($documento) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['documento'], $documento);
    }

    public static function validar_id_rol($id_rol) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_rol'], $id_rol);
    }

    public static function validar_session_id($session_id) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['session_id'], $session_id);
    }

    public static function validar_token($token) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['token'], $token);
    }

    public static function validar_token_expiracion($token_expiracion) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['token_expiracion'], $token_expiracion);
    }

    public static function validar_imagen($imagen) {
        if (is_array($imagen)) {
            $permitidos = ["image/jpeg", "image/jpg", "image/png", "image/gif"];
            return in_array($imagen["type"], $permitidos);
        }
        return (bool)preg_match($GLOBALS['expresiones_regulares']['imagen'], $imagen);
    }

    public static function validar_hash($hash) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['hash'], $hash);
    }

    public static function validar_nombre_like($nombre_like) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['nombre_like'], $nombre_like);
    }

    public static function validar_modulo($modulo) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['modulo'], $modulo);
    }

    public static function validar_accion($accion) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['accion'], $accion);
    }

    public static function validar_permiso($permiso) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['permiso'], $permiso);
    }

    public static function validar_id_permiso($id_permiso) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_permiso'], $id_permiso);
    }

    public static function validar_descripcion($descripcion) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['descripcion'], $descripcion);
    }

    public static function validar_precio($precio) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['precio'], $precio);
    }

    public static function validar_stock($stock) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['stock'], $stock);
    }

    public static function validar_direccion($direccion) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['direccion'], $direccion);
    }

    public static function validar_estado($estado) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['estado'], $estado);
    }

    public static function validar_referencia($referencia) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['referencia'], $referencia);
    }

    // ========== ID Validations ==========

    public static function validar_id_usuario($id_usuario) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_usuario'], $id_usuario);
    }

    public static function validar_id_usuario_delivery($id_usuario_delivery) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_usuario_delivery'], $id_usuario_delivery);
    }

    public static function validar_id_venta($id_venta) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_venta'], $id_venta);
    }

    public static function validar_id_materia_prima($id_materia_prima) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_materia_prima'], $id_materia_prima);
    }

    public static function validar_id_entrada($id_entrada) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_entrada'], $id_entrada);
    }

    public static function validar_id_receta($id_receta) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_receta'], $id_receta);
    }

    public static function validar_id_producto($id_producto) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_producto'], $id_producto);
    }

    public static function validar_id_orden($id_orden) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_orden'], $id_orden);
    }

    public static function validar_id_producto_preparado($id_producto_preparado) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_producto_preparado'], $id_producto_preparado);
    }

    public static function validar_id_entrada_materia_prima($id_entrada_materia_prima) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_entrada_materia_prima'], $id_entrada_materia_prima);
    }

    public static function validar_id_detalle_entrada_materia_prima($id_detalle_entrada_materia_prima) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_detalle_entrada_materia_prima'], $id_detalle_entrada_materia_prima);
    }

    public static function validar_id_proveedor($id_proveedor) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_proveedor'], $id_proveedor);
    }

    public static function validar_id_unidad($id_unidad) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_unidad'], $id_unidad);
    }

    public static function validar_id_categoria($id_categoria) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_categoria'], $id_categoria);
    }

    public static function validar_id_mesa($id_mesa) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_mesa'], $id_mesa);
    }

    public static function validar_id_reserva($id_reserva) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_reserva'], $id_reserva);
    }

    public static function validar_id_pago($id_pago) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_pago'], $id_pago);
    }

    public static function validar_id_paquete($id_paquete) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_paquete'], $id_paquete);
    }

    public static function validar_id_caja($id_caja) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_caja'], $id_caja);
    }

     public static function validar_id_cliente($id_cliente) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_cliente'], $id_cliente);
    }

    public static function validar_id_modulo($id_modulo) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['id_modulo'], $id_modulo);
    }

    // ========== Date Validations ==========
    public static function validar_fecha_compra($fecha_compra) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_compra'], $fecha_compra);
    }

    public static function validar_fecha_inicio($fecha_inicio) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_inicio'], $fecha_inicio);
    }

    public static function validar_fecha_final($fecha_final) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_final'], $fecha_final);
    }

    public static function validar_fecha_apertura($fecha_apertura) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_apertura'], $fecha_apertura);
    }

    public static function validar_fecha_cierre($fecha_cierre) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_cierre'], $fecha_cierre);
    }

    public static function validar_fecha_vencimiento($fecha_vencimiento) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_vencimiento'], $fecha_vencimiento);
    }

    public static function validar_fecha_bloqueo($fecha_bloqueo) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['fecha_bloqueo'], $fecha_bloqueo);
    }

    // ========== Text and Number Validations ==========
    public static function validar_total_ventas($total_ventas) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['total_ventas'], $total_ventas);
    }

    public static function validar_comprobante($comprobante) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['comprobante'], $comprobante);
    }

    public static function validar_stock_min($stock_min) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['stock_min'], $stock_min);
    }

    public static function validar_stock_max($stock_max) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['stock_max'], $stock_max);
    }

    public static function validar_tabla_str($tabla_str) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['tabla_str'], $tabla_str);
    }

    public static function validar_monto_inicial_dolar($monto_inicial_dolar) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['monto_inicial_dolar'], $monto_inicial_dolar);
    }

    public static function validar_monto_inicial_bs($monto_inicial_bs) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['monto_inicial_bs'], $monto_inicial_bs);
    }

    public static function validar_monto_final_dolar($monto_final_dolar) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['monto_final_dolar'], $monto_final_dolar);
    }

    public static function validar_monto_final_bs($monto_final_bs) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['monto_final_bs'], $monto_final_bs);
    }

    public static function validar_key($key) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['key'], $key);
    }

    public static function validar_value($value) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['value'], $value);
    }

    public static function validar_codigo($codigo) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['codigo'], $codigo);
    }

    public static function validar_existencia($existencia) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['existencia'], $existencia);
    }

    public static function validar_broken($broken) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['broken'], $broken);
    }

    public static function validar_adicionales($adicionales) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['adicionales'], $adicionales);
    }

    public static function validar_vip($vip) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['vip'], $vip);
    }

    public static function validar_sillas($sillas) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['sillas'], $sillas);
    }

    public static function validar_imagen_name($imagen_name) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['imagen_name'], $imagen_name);
    }

    public static function validar_status($status) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['status'], $status);
    }

    public static function validar_titulo($titulo) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['titulo'], $titulo);
    }

    public static function validar_mensaje($mensaje) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['mensaje'], $mensaje);
    }

    public static function validar_nro_orden($nro_orden) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['nro_orden'], $nro_orden);
    }

    public static function validar_tipo($tipo) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['tipo'], $tipo);
    }

    public static function validar_tasa($tasa) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['tasa'], $tasa);
    }

    public static function validar_permisos($permisos) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['permisos'], $permisos);
    }

    public static function validar_precio_compra($precio_compra) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['precio_compra'], $precio_compra);
    }

    public static function validar_detalles($detalles) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['detalles'], $detalles);
    }

    public static function validar_razon_social($razon_social) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['razon_social'], $razon_social);
    }

    public static function validar_n_telefono1($n_telefono1) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['n_telefono1'], $n_telefono1);
    }

    public static function validar_n_telefono2($n_telefono2) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['n_telefono2'], $n_telefono2);
    }

    public static function validar_metodo_pedido($metodo_pedido) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['metodo_pedido'], $metodo_pedido);
    }

    public static function validar_alias($alias) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['alias'], $alias);
    }

    public static function validar_IVA($IVA) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['IVA'], $IVA);
    }

    public static function validar_monto_final($monto_final) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['monto_final'], $monto_final);
    }
    public static function validar_valor($valor) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['valor'], $valor);
    }
    public static function validar_tabla($tabla) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['tabla'], $tabla);
    }
    public static function validar_llave($llave) {
        return (bool)preg_match($GLOBALS['expresiones_regulares']['llave'], $llave);
    }
}