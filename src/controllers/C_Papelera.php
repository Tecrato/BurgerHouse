<?php
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_papelera.php')) {
        include_once __DIR__ . '/../views/V_papelera.php';
    } else {
        make_url_error("No se encontró la vista V_papelera.php", 404);
    }
    exit;
}

// Modulo papelera en desarrollo - solo vista
make_url_error("Modulo papelera en desarrollo.", 501, ajax: true);
