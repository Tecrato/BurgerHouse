<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Materia_prima;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_materia_prima.php')) {
        include_once __DIR__ . '/../views/V_materia_prima.php';
    } else if (file_exists(__DIR__ . '/../views/materia_prima.php')) {
        include_once __DIR__ . '/../views/materia_prima.php';
    } else {
        make_url_error("No se encontro una vista para materia_prima.", 404, ajax: $ajax);
    }
    exit;
}

$accion = strtolower($url[1]);

if ($accion === 'get_all') {
    try {
        $modelo = new Materia_prima(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'add') {
    try {
        $modelo = new Materia_prima(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'add_many') {
    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para agregar.", 400, ajax: true);
    }

    try {
        foreach ($_POST['lista'] as $item) {
            if (!is_array($item)) {
                make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
            }
            $itemModel = new Materia_prima(...$item);
            $itemModel->agregar();
        }
        $resultado_final = ['success' => true];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'update') {
    try {
        $modelo = new Materia_prima(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'updatemany' || $accion === 'update_many') {
    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para actualizar.", 400, ajax: true);
    }

    $ok = true;
    foreach ($_POST['lista'] as $item) {
        if (!is_array($item)) {
            make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
        }

        $itemModel = new Materia_prima(...$item);
        $res = $itemModel->actualizar();
        if (($res['success'] ?? false) !== true) {
            $ok = false;
        }
    }

    $resultado_final = ['success' => $ok];
    $ajax = true;
} else if ($accion === 'delete') {
    if (!isset($_POST['id'])) {
        make_url_error("No se recibio el id para eliminar.", 400, ajax: true);
    }

    try {
        $modelo = new Materia_prima(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'deletemany' || $accion === 'delete_many' || $accion === 'check') {
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

        $itemModel = new Materia_prima(id: $id);
        $deleted = $itemModel->borrar();
        if ($deleted === 0 || $deleted === false) {
            $ok = false;
        }
    }

    $resultado_final = ['success' => $ok];
    $ajax = true;
} else if ($accion === 'count' || $accion === 'total') {
    try {
        $modelo = new Materia_prima(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para materia_prima.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
