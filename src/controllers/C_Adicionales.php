<?php
use Shtch\Burgerhouse\models\ProductoProcesado;
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$adicionalModel = new ProductoProcesado();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estás autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

// if (!$session->is_admin()) {
//     make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: $ajax);
// }

if (count($url) < 2) {
    if (file_exists(__DIR__ . '/../views/adicionales.php')) {
        include_once __DIR__ . '/../views/adicionales.php';
    } else {
        make_url_error("No se encontró la vista adicionales.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('Adicionales', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: $ajax);
    }
    $resultado_final = $adicionalModel->search(...$parametros_paginacion);
    $ajax = true;
}


if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    $resultado_final = json_encode($resultado_final);
}
print_r($resultado_final);