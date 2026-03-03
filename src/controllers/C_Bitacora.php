<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Bitacora;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}


if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_bitacora.php')) {
        include_once __DIR__ . '/../views/V_bitacora.php';
    } else {
        make_url_error("No se encontró la vista V_bitacora.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') { // crear aqui 2 if mas para mi bitacora y la del sistema
    if (!$session->has_permission('bitacora', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }
    if (!$session->is_admin()) {
        $_POST['id_usuario'] = $session->usuario['id'];
    }
    $modelo = new Bitacora(...$_POST);
    $resultado_final = $modelo->search(...$parametros_paginacion);
    $ajax = true;
} else if ($url[1] === 'add') {
    
    try {
        $_POST['id_usuario'] = $session->usuario['id'];
        $modelo = new Bitacora(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }

    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    if (!$session->has_permission('bitacora', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }
    try {
        if (!$session->is_admin()) {
            $_POST['id_usuario'] = $session->usuario['id'];
        }
        $modelo = new Bitacora(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para bitacora.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
