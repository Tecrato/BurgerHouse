<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Entrada_materia_prima;
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;
use Shtch\Burgerhouse\models\Pago_entrada_materia_prima;
use Shtch\Burgerhouse\models\Vista;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2) {
    make_url_error("Accion no valida para entrada_materia_prima.", 404, ajax: true);
}

$accion = strtolower($url[1]);

if ($accion === 'get_all') {
    try {
        $modelo = new Entrada_materia_prima(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'add') {
    try {
        $modelo = new Entrada_materia_prima(...$_POST);
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
            !isset($_POST['lista']['info_entrada']) ||
            !is_array($_POST['lista']['info_entrada']) ||
            count($_POST['lista']['info_entrada']) === 0
        ) {
            make_url_error("No se recibio una lista valida para agregar.", 400, ajax: true);
        }

        $pago_materia_prima = new Pago_entrada_materia_prima();
        $detalle_entrada = new Detalle_entrada_materia_prima();
        $lista_entrada = $_POST['lista']['info_entrada'];

        $targetDir = __DIR__ . '/../media/pay_entrys_rawmaterial';
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        foreach ($lista_entrada as $i => $entrada) {
            $db = new Entrada_materia_prima(id_proveedor: $entrada['id_proveedor'] ?? null);
            $last_id = $db->agregar();
            $pago_materia_prima->clear();

            if (isset($entrada['payment']) && is_array($entrada['payment'])) {
                foreach ($entrada['payment'] as $j => $paymentItem) {
                    $pago_materia_prima->__construct(...['id_entrada' => $last_id, ...$paymentItem]);
                    $pago_materia_prima->agregar();

                    if (
                        isset($_FILES['lista']['tmp_name']['info_entrada'][$i]['payment'][$j]['imagen']) &&
                        isset($_FILES['lista']['name']['info_entrada'][$i]['payment'][$j]['imagen'])
                    ) {
                        $tmpPath = $_FILES['lista']['tmp_name']['info_entrada'][$i]['payment'][$j]['imagen'];
                        $fileName = $_FILES['lista']['name']['info_entrada'][$i]['payment'][$j]['imagen'];
                        if ($tmpPath !== '' && $fileName !== '') {
                            move_uploaded_file($tmpPath, $targetDir . '/' . $fileName);
                        }
                    }
                }
            }

            if (isset($entrada['detalles_entrada']) && is_array($entrada['detalles_entrada'])) {
                foreach ($entrada['detalles_entrada'] as $detalleItem) {
                    $detalle_entrada->clear();
                    $detalle_entrada->__construct(
                        id_materia_prima: $detalleItem['id_materia_prima'] ?? null,
                        id_entrada: $last_id,
                        cantidad: $detalleItem['cantidad'] ?? null,
                        codigo: $detalleItem['codigo'] ?? null,
                        fecha_vencimiento: $detalleItem['fecha_vencimiento'] ?? null,
                        existencia: $detalleItem['existencia'] ?? null
                    );
                    $detalle_entrada->agregar();
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
        $modelo = new Entrada_materia_prima(...$_POST);
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

        $itemModel = new Entrada_materia_prima(...$item);
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
        $modelo = new Entrada_materia_prima(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'count' || $accion === 'total') {
    try {
        $modelo = new Entrada_materia_prima(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'inventario') {
    try {
        $db = new Vista("vista_inventario_materia_prima");
        $resultado_final = $db->search();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($accion === 'brokenear_materia') {
    if (!isset($_POST['id']) || !isset($_POST['cantidad'])) {
        make_url_error("Debe enviar id y cantidad para brokenear materia.", 400, ajax: true);
    }

    $idDetalle = (int)$_POST['id'];
    $cantidad = (float)$_POST['cantidad'];
    if ($idDetalle <= 0 || $cantidad <= 0) {
        make_url_error("Datos invalidos para brokenear materia.", 400, ajax: true);
    }

    $db = new Detalle_entrada_materia_prima(id: $idDetalle);
    $registro = $db->search(0, 1);
    if (!is_array($registro) || count($registro) === 0) {
        make_url_error("No se encontro la entrada de materia prima.", 404, ajax: true);
    }

    $existenciaActual = (float)$registro[0]['existencia'];
    $brokenActual = (float)$registro[0]['broken'];
    $existenciaNueva = $existenciaActual - $cantidad;
    if ($existenciaNueva < 0) {
        make_url_error("No hay existencia suficiente para descontar esa cantidad.", 400, ajax: true);
    }

    $db->clear();
    $db->__construct(id: $idDetalle, existencia: $existenciaNueva, broken: $brokenActual + $cantidad);
    $res = $db->actualizar();

    if (($res['success'] ?? false) !== true) {
        make_url_error($res['message'] ?? 'No se pudo actualizar la entrada.', 400, ajax: true);
    }

    $resultado_final = ['success' => true];
    $ajax = true;
} else {
    make_url_error("Accion no valida para entrada_materia_prima.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
