<?php
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/registro.php')) {
        include_once __DIR__ . '/../views/registro.php';
    } else {
        make_url_error("No se encontró la vista registro.php", 404);
    }
    exit;
}

make_url_error("Accion no valida para registro.", 404, ajax: true);
