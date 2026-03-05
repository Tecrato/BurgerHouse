<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Vista;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/vistas.php')) {
        include_once __DIR__ . '/../views/vistas.php';
    } else {
        make_url_error("No se encontró la vista vistas.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('vistas', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $_POST = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $tabla = $_POST['nombre_vista'] ?? null;
        if (!$tabla) {
            make_url_error("nombre_vista es requerido", 400, ajax: true);
        }
        $variables = (array)($_POST['variables'] ?? []);
        $modelo = new Vista($tabla, $variables);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'check') {
    // Verificación de sesión - no requiere permisos especiales
    $ajax = true;
} else {
    make_url_error("Accion no valida para vistas.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
