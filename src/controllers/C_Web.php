<?php
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/web.php')) {
        include_once __DIR__ . '/../views/web.php';
    } else {
        make_url_error("No se encontró la vista web.php", 404);
    }
    exit;
}

make_url_error("Accion no valida para web.", 404, ajax: true);
