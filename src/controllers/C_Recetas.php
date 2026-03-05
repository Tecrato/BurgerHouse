<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Detalle_receta;
use Shtch\Burgerhouse\models\Receta;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/recetas.php')) {
        include_once __DIR__ . '/../views/recetas.php';
    } else {
        make_url_error("No se encontró la vista recetas.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('recetas', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Receta(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('recetas', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id_producto']) || !isset($_POST['lista'])) {
        make_url_error("Faltan datos requeridos para crear la receta.", 400, ajax: true);
    }

    try {
        $receta = new Receta();
        $receta->clear();
        $receta->__construct(id_producto: $_POST['id_producto']);
        $last_id = $receta->agregar();

        for ($i = 0; $i < count($_POST['lista']); $i++) {
            $detalle = new Detalle_receta(...['id_receta' => $last_id, ...$_POST['lista'][$i]]);
            $detalle->agregar();
        }

        $resultado_final = ['success' => true, 'last_id' => $last_id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    if (!$session->has_permission('recetas', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Receta(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'delete') {
    if (!$session->has_permission('recetas', 'eliminar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id'])) {
        make_url_error("No se recibio el id para eliminar.", 400, ajax: true);
    }

    try {
        $modelo = new Receta(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    if (!$session->has_permission('recetas', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Receta(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para recetas.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
