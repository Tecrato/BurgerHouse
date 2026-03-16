<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Permiso;
use Shtch\Burgerhouse\models\Detalle_modulo_permiso;
use Shtch\Burgerhouse\models\Modulo;
use Shtch\Burgerhouse\models\Rol_modulo_permiso;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/permissions.php')) {
        include_once __DIR__ . '/../views/permissions.php';
    } else {
        make_url_error("No se encontró la vista permisos.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('permisos', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Permiso(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('permisos', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Permiso(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    $active = $_POST['active'] ?? null;

    if ($active !== null && (string)$active === '0') {
        if (!$session->has_permission('permisos', 'eliminar')) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if ($active !== null && (string)$active === '1') {
        if (
            !$session->has_permission('Papelera', 'restaurar') &&
            !$session->has_permission('permisos', 'eliminar')
        ) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if (!$session->has_permission('permisos', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Permiso(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'delete') {
    if (!$session->has_permission('permisos', 'eliminar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id'])) {
        make_url_error("No se recibio el id para eliminar.", 400, ajax: true);
    }

    try {
        $modelo = new Permiso(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    if (!$session->has_permission('permisos', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Permiso(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'get_modulos') {
    if (!$session->has_permission('permisos', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Modulo(...$_POST);
        $resultado_final = $modelo->search();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'get_permisos_by_rol_modulo') {
    if (!$session->has_permission('permisos', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id_rol']) || !isset($_POST['id_modulo'])) {
        make_url_error("Faltan parametros id_rol o id_modulo.", 400, ajax: true);
    }

    try {
        $modelo = new Detalle_modulo_permiso(
            null,
            $_POST['id_rol'],
            $_POST['id_modulo'],
            null
        );
        $resultado_final = $modelo->search();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'toggle_permiso') {
    if (!$session->has_permission('permisos', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id_rol']) || !isset($_POST['id_modulo']) || !isset($_POST['id_permiso'])) {
        make_url_error("Faltan parametros necesarios (id_rol, id_modulo, id_permiso).", 400, ajax: true);
    }

    try {
        $modelo = new Rol_modulo_permiso(
            null,
            $_POST['id_rol'],
            $_POST['id_modulo'],
            $_POST['id_permiso']
        );
        $resultado_final = $modelo->toggle();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para permisos.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
