<?php
use Shtch\Burgerhouse\function\AuthSession;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estás autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2) {
    if (file_exists(__DIR__ . '/../views/V_papelera.php')) {
        include_once __DIR__ . '/../views/V_papelera.php';
    } else {
        make_url_error("No se encontró la vista papelera.php", 404);
    }
    exit;
}

// No actions defined for papelera yet
make_url_error("Modulo papelera en desarrollo.", 501, ajax: $ajax);

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    $resultado_final = json_encode($resultado_final);
}
print_r($resultado_final);
