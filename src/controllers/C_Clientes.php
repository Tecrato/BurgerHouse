<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Cliente;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_clientes.php')) {
        include_once __DIR__ . '/../views/V_clientes.php';
    } else {
        make_url_error("No se encontro la vista clients.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('clientes', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Cliente(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('clientes', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Cliente(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add_many') {
    if (!$session->has_permission('clientes', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para agregar.", 400, ajax: true);
    }

    try {
        $ids = [];
        foreach ($_POST['lista'] as $item) {
            if (!is_array($item)) {
                make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
            }
            $itemModel = new Cliente(...$item);
            $ids[] = $itemModel->agregar();
        }
        $resultado_final = ['success' => true, 'lista' => $ids];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    $active = $_POST['active'] ?? null;

    if ($active !== null && (string)$active === '0') {
        if (!$session->has_permission('clientes', 'eliminar')) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if ($active !== null && (string)$active === '1') {
        if (
            !$session->has_permission('Papelera', 'restaurar') &&
            !$session->has_permission('clientes', 'eliminar')
        ) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if (!$session->has_permission('clientes', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Cliente(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'updatemany' || $url[1] === 'update_many') {
    if (!$session->has_permission('clientes', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para actualizar.", 400, ajax: true);
    }

    $ok = true;
    try {
        foreach ($_POST['lista'] as $item) {
            if (!is_array($item)) {
                make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
            }
            $itemModel = new Cliente(...$item);
            $res = $itemModel->actualizar();
            if (($res['success'] ?? false) !== true) {
                $ok = false;
            }
        }
        $resultado_final = ['success' => $ok];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'delete') {
    if (!$session->has_permission('clientes', 'eliminar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['id'])) {
        make_url_error("No se recibio el id para eliminar.", 400, ajax: true);
    }

    try {
        $modelo = new Cliente(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'deletemany' || $url[1] === 'delete_many' || $url[1] === 'check') {
    if (!$session->has_permission('clientes', 'eliminar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    $lista = null;
    if (isset($_POST['lista']) && is_array($_POST['lista'])) {
        $lista = $_POST['lista'];
    } else if (isset($_POST['ids']) && is_array($_POST['ids'])) {
        $lista = $_POST['ids'];
    }

    if (!is_array($lista) || count($lista) === 0) {
        make_url_error("No se recibio una lista valida para eliminar.", 400, ajax: true);
    }

    $ok = true;
    foreach ($lista as $item) {
        $id = null;
        if (is_array($item)) {
            $id = $item['id'] ?? null;
        } else if (is_numeric($item)) {
            $id = $item;
        }

        if ($id === null) {
            make_url_error("Cada item debe incluir un id valido.", 400, ajax: true);
        }

        $itemModel = new Cliente(id: $id);
        $deleted = $itemModel->borrar();
        if ($deleted === 0 || $deleted === false) {
            $ok = false;
        }
    }

    $resultado_final = ['success' => $ok];
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    if (!$session->has_permission('clientes', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Cliente(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para clientes.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
