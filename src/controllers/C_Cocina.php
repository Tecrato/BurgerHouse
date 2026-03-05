<?php
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (!$session->has_permission('cocina', 'consultar')) {
    make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/kitchen.php')) {
        include_once __DIR__ . '/../views/kitchen.php';
    } else {
        make_url_error("No se encontro la vista kitchen.php", 404, ajax: true);
    }
    exit;
}

make_url_error("Accion no valida para cocina.", 404, ajax: true);
