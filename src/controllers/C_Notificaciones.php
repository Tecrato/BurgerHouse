<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Notificacion;
use Pusher\Pusher;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2) {
    if (file_exists(__DIR__ . '/../views/notifications.php')) {
        include_once __DIR__ . '/../views/notifications.php';
    } else {
        make_url_error("No se encontro la vista notifications.php", 404);
    }
    exit;
}

$modelo = new Notificacion(...$_POST);

if ($url[1] === 'get_all') {
    $n = (int)($parametros_paginacion['nro_page'] ?? 0);
    $limite = (int)($parametros_paginacion['limite_registros'] ?? 9);
    $orderBy = (string)($parametros_paginacion['columna_orden'] ?? 'id');
    $orderType = strtoupper((string)($parametros_paginacion['orden_direccion'] ?? 'ASC'));

    $resultado_final = $modelo->search($n, $limite, $orderBy, $orderType);
    $ajax = true;
} else if ($url[1] === 'add') {
    $id = $modelo->agregar();
    $resultado_final = ['success' => true, 'last_id' => $id];
    $ajax = true;
} else if ($url[1] === 'update') {
    $resultado_final = $modelo->actualizar();
    $ajax = true;
} else if ($url[1] === 'updateMany' || $url[1] === 'update_many') {
    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para actualizar.", 400, ajax: true);
    }

    $ok = true;
    $updated = 0;

    foreach ($_POST['lista'] as $item) {
        if (!is_array($item)) {
            make_url_error("Cada item de la lista debe ser un arreglo valido.", 400, ajax: true);
        }

        $itemModel = new Notificacion(...$item);
        $res = $itemModel->actualizar();

        if (($res['success'] ?? false) !== true || ($res['message'] ?? false) === false) {
            $ok = false;
        }

        $updated++;
    }

    $resultado_final = [
        'success' => $ok,
        'status' => $ok ? 'success' : 'error',
        'updated' => $updated
    ];
    $ajax = true;
} else if ($url[1] === 'delete') {
    $id = $_POST['id'] ?? null;
    if (!is_numeric($id)) {
        make_url_error("ID invalido para eliminar.", 400, ajax: true);
    }

    $deleteModel = new Notificacion();
    $deleteModel->add_variables(['a.id' => (int)$id]);
    $deleted = $deleteModel->borrar();

    $ok = !($deleted === 0 || $deleted === false);
    $resultado_final = [
        'success' => $ok,
        'status' => $ok ? 'success' : 'error',
        'message' => $ok ? 'Notificacion eliminada' : 'No se pudo eliminar la notificacion'
    ];
    $ajax = true;
} else if ($url[1] === 'delete_many' || $url[1] === 'check') {
    if (!isset($_POST['lista']) || !is_array($_POST['lista']) || count($_POST['lista']) === 0) {
        make_url_error("No se recibio una lista valida para eliminar.", 400, ajax: true);
    }

    $ok = true;
    $deletedCount = 0;

    foreach ($_POST['lista'] as $item) {
        if (!is_array($item) || !isset($item['id']) || !is_numeric($item['id'])) {
            make_url_error("Cada item debe incluir un id numerico valido.", 400, ajax: true);
        }

        $deleteModel = new Notificacion();
        $deleteModel->add_variables(['a.id' => (int)$item['id']]);
        $deleted = $deleteModel->borrar();

        if ($deleted === 0 || $deleted === false) {
            $ok = false;
            continue;
        }

        $deletedCount++;
    }

    $resultado_final = [
        'success' => $ok,
        'status' => $ok ? 'success' : 'error',
        'deleted' => $deletedCount
    ];
    $ajax = true;
} else if ($url[1] === 'sendNotifications') {
    try {
        date_default_timezone_set('America/Caracas');

        $channel = trim((string)($_POST['channel'] ?? ''));
        $event = trim((string)($_POST['event'] ?? ''));
        $message = trim((string)($_POST['message'] ?? ''));

        if ($channel === '' || $event === '' || $message === '') {
            make_url_error("Debe enviar channel, event y message para la notificacion.", 400, ajax: true);
        }

        $pusher = new Pusher(
            '2a7ca356d030e2945ae9',
            '3c3f676721576bb7c676',
            '2016820',
            [
                'cluster' => 'us2',
                'useTLS' => true
            ]
        );

        $data = ['message' => $message, 'time' => date('Y-m-d H:i:s'), 'event' => $event];
        $pusher->trigger($channel, $event, $data);

        $resultado_final = ['success' => true];
        $ajax = true;
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 500, ajax: true);
    }
} else {
    make_url_error("Accion no valida para notificaciones.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
