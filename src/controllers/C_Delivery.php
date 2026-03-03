<?php
use Shtch\Burgerhouse\models\Delivery;
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estás autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2) {
    if (file_exists(__DIR__ . '/../views/V_delivery.php')) {
        include_once __DIR__ . '/../views/V_delivery.php';
    } else {
        make_url_error("No se encontró la vista delivery.php", 404);
    }
    exit;
}

$modelo = new Delivery(...$_POST);

if ($url[1] === 'get_all') {
    if (!$session->has_permission('ordenes', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: $ajax);
    }
    $resultado_final = $modelo->search(...$parametros_paginacion);
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('ordenes', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: $ajax);
    }
    $id = $modelo->agregar();
    $resultado_final = ['success' => true, 'last_id' => $id];
    $ajax = true;
} else if ($url[1] === 'update') {
    if (!$session->has_permission('ordenes', 'modificar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: $ajax);
    }
    $resultado_final = $modelo->actualizar();
    $ajax = true;
} else if ($url[1] === 'delete') {
    if (!$session->has_permission('ordenes', 'borrar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: $ajax);
    }
    $resultado_final = $modelo->borrar();
    $ajax = true;
} else {
    make_url_error("Accion no valida para delivery.", 404, ajax: $ajax);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    $resultado_final = json_encode($resultado_final);
}
print_r($resultado_final);
