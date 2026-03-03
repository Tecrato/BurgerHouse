<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Vista;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_index.php')) {
        include_once __DIR__ . '/../views/V_index.php';
    } else {
        make_url_error("No se encontro la vista V_index.php", 404);
    }
    exit;
}

if (strtolower($url[1]) === 'clientesfrecuentes') {
    $ajax = true;
    try {
        $model = new Vista("vista_resumen_clientes");
        $resultado_final = $model->search();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
} else {
    make_url_error("Accion no valida para home.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
