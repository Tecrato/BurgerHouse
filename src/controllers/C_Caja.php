<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Caja;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/V_caja.php')) {
        include_once __DIR__ . '/../views/V_caja.php';
    } else {
        make_url_error("No se encontró la vista cash.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    if (!$session->has_permission('Caja', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Caja(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('Caja', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Caja(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add_many') {
    if (!$session->has_permission('Caja', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para agregar.", 400, ajax: true);
    }

    try {
        $lastIds = [];
        foreach ($_POST['lista'] as $item) {
            if (!is_array($item)) {
                make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
            }

            $itemModel = new Caja(...$item);
            $lastIds[] = $itemModel->agregar();
        }
        $resultado_final = ['success' => true, 'last_ids' => $lastIds];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    $active = $_POST['active'] ?? null;

    if ($active !== null && (string)$active === '0') {
        if (!$session->has_permission('Caja', 'eliminar')) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if ($active !== null && (string)$active === '1') {
        if (
            !$session->has_permission('Papelera', 'restaurar') &&
            !$session->has_permission('Caja', 'eliminar')
        ) {
            make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
        }
    } else if (!$session->has_permission('Caja', 'editar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Caja(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'detailCash') {
    if (!$session->has_permission('Caja', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Caja();
        $resultado_final = $modelo->cajaDetails((int)($_SESSION['id'] ?? 0));
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'closeCash') {
    if (!$session->has_permission('Caja', 'cerrar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Caja();
        $modelo->closeCash((int)($_POST['id'] ?? 0));
        $resultado_final = ['success' => true, 'message' => 'Caja cerrada'];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    if (!$session->has_permission('Caja', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    try {
        $modelo = new Caja(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para caja.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
