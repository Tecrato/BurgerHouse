<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Caja;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2) {
    if (file_exists(__DIR__ . '/../views/cash.php')) {
        include_once __DIR__ . '/../views/cash.php';
    } else {
        make_url_error("No se encontro la vista cash.php", 404);
    }
    exit;
}

$modelo = new Caja(...$_POST);

if ($url[1] === 'get_all') {
    if (!$session->has_permission('Caja', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    $n = (int)($parametros_paginacion['nro_page'] ?? 0);
    $limite = (int)($parametros_paginacion['limite_registros'] ?? 9);
    $orderBy = (string)($parametros_paginacion['columna_orden'] ?? 'id');
    $orderType = strtoupper((string)($parametros_paginacion['orden_direccion'] ?? 'ASC'));

    $resultado_final = $modelo->search($n, $limite, $orderBy, $orderType);
    $ajax = true;
} else if ($url[1] === 'add') {
    if (!$session->has_permission('Caja', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    $id = $modelo->agregar();
    $resultado_final = ['success' => true, 'last_id' => $id];
    $ajax = true;
} else if ($url[1] === 'add_many') {
    if (!$session->has_permission('Caja', 'agregar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para agregar.", 400, ajax: true);
    }

    $lastIds = [];
    foreach ($_POST['lista'] as $item) {
        if (!is_array($item)) {
            make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
        }

        $itemModel = new Caja(...$item);
        $lastIds[] = $itemModel->agregar();
    }

    $resultado_final = ['success' => true, 'last_ids' => $lastIds];
    $ajax = true;
} else if ($url[1] === 'update') {
    if (!$session->has_permission('Caja', 'modificar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    $resultado_final = $modelo->actualizar();
    $ajax = true;
} else if ($url[1] === 'detailCash') {
    if (!$session->has_permission('Caja', 'consultar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    $resultado_final = $modelo->cajaDetails((int)($_SESSION['id'] ?? 0));
    $ajax = true;
} else if ($url[1] === 'closeCash') {
    if (!$session->has_permission('Caja', 'cerrar')) {
        make_url_error("No tienes permiso para acceder a este recurso.", 403, ajax: true);
    }

    $modelo->closeCash((int)($_POST['id'] ?? 0));
    $resultado_final = ['success' => true, 'message' => 'Caja cerrada'];
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
