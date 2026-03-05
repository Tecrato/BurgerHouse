<?php
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/categoria.php')) {
        include_once __DIR__ . '/../views/categoria.php';
    } else {
        make_url_error("No se encontró la vista categoria.php", 404);
    }
    exit;
}

make_url_error("Accion no valida para categoria.", 404, ajax: true);
