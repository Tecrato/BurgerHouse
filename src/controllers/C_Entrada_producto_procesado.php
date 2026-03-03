<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Entrada_producto_procesado;
use Shtch\Burgerhouse\models\Pago_entrada_producto_procesado;
use Shtch\Burgerhouse\models\Vista;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2) {
    make_url_error("Accion no valida para entrada_producto_procesado.", 404, ajax: true);
}

$accion = strtolower($url[1]);

if ($accion === 'get_all') {
    try {
        $modelo = new Entrada_producto_procesado(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'add') {
    try {
        $modelo = new Entrada_producto_procesado(...$_POST);
        $id = $modelo->agregar();
        $resultado_final = ['success' => true, 'last_id' => $id];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'add_many') {
    try {
        if (
            !isset($_POST['lista']) ||
            !is_array($_POST['lista']) ||
            !isset($_POST['lista']['detalles_entrada']) ||
            !is_array($_POST['lista']['detalles_entrada']) ||
            count($_POST['lista']['detalles_entrada']) === 0
        ) {
            make_url_error("No se recibio una lista valida para agregar.", 400, ajax: true);
        }

        $pago_producto_procesado = new Pago_entrada_producto_procesado();
        $lista_entrada = $_POST['lista']['detalles_entrada'];

        $targetDir = __DIR__ . '/../media/pay_entrys_product_process';
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        for ($i = 0; $i < count($lista_entrada); $i++) {
            $db = new Entrada_producto_procesado();
            $db->clear();
            $db->__construct(
                id_proveedor: $lista_entrada[$i]['id_proveedor'] ?? null,
                id_producto: $lista_entrada[$i]['id_producto'] ?? null,
                id_unidad: $lista_entrada[$i]['id_unidad'] ?? null,
                cantidad: $lista_entrada[$i]['cantidad'] ?? null,
                existencia: $lista_entrada[$i]['existencia'] ?? null,
                codigo: $lista_entrada[$i]['codigo'] ?? null,
                fecha_vencimiento: $lista_entrada[$i]['fecha_vencimiento'] ?? null
            );
            $last_id = $db->agregar();

            if (isset($lista_entrada[$i]['payment']) && is_array($lista_entrada[$i]['payment'])) {
                for ($j = 0; $j < count($lista_entrada[$i]['payment']); $j++) {
                    $pago_producto_procesado->clear();
                    $pago_producto_procesado->__construct(...['id_entrada' => $last_id, ...$lista_entrada[$i]['payment'][$j]]);
                    $pago_producto_procesado->agregar();

                    if (
                        isset($_FILES['lista']['tmp_name']['detalles_entrada'][$i]['payment'][$j]['imagen']) &&
                        isset($_FILES['lista']['name']['detalles_entrada'][$i]['payment'][$j]['imagen'])
                    ) {
                        $tmpPath = $_FILES['lista']['tmp_name']['detalles_entrada'][$i]['payment'][$j]['imagen'];
                        $fileName = $_FILES['lista']['name']['detalles_entrada'][$i]['payment'][$j]['imagen'];
                        if ($tmpPath !== '' && $fileName !== '') {
                            move_uploaded_file($tmpPath, $targetDir . '/' . $fileName);
                        }
                    }
                }
            }
        }

        $resultado_final = ['success' => true];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'update') {
    try {
        $modelo = new Entrada_producto_procesado(...$_POST);
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

        $itemModel = new Entrada_producto_procesado(...$item);
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
        $modelo = new Entrada_producto_procesado(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'count' || $accion === 'total') {
    try {
        $modelo = new Entrada_producto_procesado(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'inventario') {
    try {
        $db = new Vista("vista_inventario_productos_procesados");
        $resultado_final = $db->search();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para entrada_producto_procesado.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
