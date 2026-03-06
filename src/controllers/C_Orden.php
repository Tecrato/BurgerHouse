<?php
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\Orden;
use Shtch\Burgerhouse\models\DetalleOrdenProductoPreparado;
use Shtch\Burgerhouse\models\DetalleOrdenProductoProcesado;
use Shtch\Burgerhouse\models\Receta;
use Shtch\Burgerhouse\models\Detalle_receta;
use Shtch\Burgerhouse\models\ProductoProcesado;
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;
use Shtch\Burgerhouse\models\Entrada_producto_procesado;
use Shtch\Burgerhouse\models\Materia_prima;
use Shtch\Burgerhouse\models\Notificacion;
use Pusher\Pusher;
use Kunnu\Dropbox\DropboxApp;
use Kunnu\Dropbox\Dropbox;

$session = new AuthSession();
$resultado_final = '';

if (!$session->usuario) {
    make_url_error("No estas autenticado. Redirigiendo a login...", 401, ajax: $ajax);
}

if (count($url) < 2 || $url[1] === 'view') {
    if (file_exists(__DIR__ . '/../views/orders.php')) {
        include_once __DIR__ . '/../views/orders.php';
    } else {
        make_url_error("No se encontro la vista orders.php", 404);
    }
    exit;
}

if ($url[1] === 'get_all') {
    try {
        $modelo = new Orden(...$_POST);
        $resultado_final = $modelo->search(...$parametros_paginacion);
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'add' || $url[1] === 'add_process_and_prepared') {
    try {
        $result_detalle_preparado = true;
        $result_detalle_procesado = true;

        $message_error_detalle_preparado = null;
        $message_error_detalle_procesado = null;

        $es_add_orden = $url[1] === 'add';
        $tipo_orden = $_POST['tipo'] ?? null;
        $requiere_detalles = $es_add_orden && in_array($tipo_orden, ["delivery", "llevar", "local"]);

        $lista_detalle_preparado = $_POST['lista_detalle_preparado'] ?? null;
        $lista_detalle_procesado = $_POST['lista_detalle_procesado'] ?? null;

        $clase_detalle_producto_preparado = new DetalleOrdenProductoPreparado();
        $clase_detalle_producto_procesado = new DetalleOrdenProductoProcesado();

        $detalles_receta = [];
        $detalles_productos = [];

        if (isset($lista_detalle_preparado) && is_array($lista_detalle_preparado)) {
            $receta = new Receta();
            $detalle_receta = new Detalle_receta();

            for ($i = 0; $i < count($lista_detalle_preparado); $i++) {
                $idProducto = $lista_detalle_preparado[$i]['id_producto'];
                $cantidadPedido = $lista_detalle_preparado[$i]['cantidad'];
                $receta->__construct(id_producto: $idProducto);
                foreach ($receta->search() as $key) {
                    $detalle_receta->__construct(id_receta: $key['id']);
                    foreach ($detalle_receta->search() as $detalle) {
                        $detalle['cantidad'] = $detalle['cantidad'] * $cantidadPedido;
                        $detalles_receta[] = $detalle;
                    }
                }
            }

            date_default_timezone_set('America/Caracas');
            $date_now = new DateTime();

            $recetaPosible = true;
            $faltantes = [];
            foreach ($detalles_receta as $detalle) {
                $faltante = $detalle['cantidad'];
                $entradas_materia_prima = new Detalle_entrada_materia_prima(active: 1, id_materia_prima: $detalle['id_materia_prima']);
                $result_entrys = $entradas_materia_prima->search(0, 100, "fecha_vencimiento", "asc");

                foreach ($result_entrys as $entrada) {
                    if (
                        $detalle['id_materia_prima'] == $entrada['id_materia_prima'] &&
                        new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                        $entrada['existencia'] > 0
                    ) {
                        $descontar = min($faltante, $entrada['existencia']);
                        $faltante -= $descontar;
                        if ($faltante <= 0) {
                            break;
                        }
                    }
                }

                if ($faltante > 0) {
                    $recetaPosible = false;
                    $faltantes[] = [
                        'producto' => $detalle['ingrediente'],
                        'faltante' => $faltante,
                        'diferencia' => $result_entrys
                    ];
                }
            }

            $result_detalle_preparado = $recetaPosible;
            $message_error_detalle_preparado = $faltantes;
        }

        if (isset($lista_detalle_procesado) && is_array($lista_detalle_procesado)) {
            $productos = new ProductoProcesado();
            foreach ($lista_detalle_procesado as $detalle) {
                foreach ($productos->search(0, 1000) as $producto) {
                    if ($producto['id'] == $detalle['id_producto']) {
                        $detalle['producto'] = $producto['nombre'];
                        $detalles_productos[] = $detalle;
                    }
                }
            }

            date_default_timezone_set('America/Caracas');
            $entradas_process = new Entrada_producto_procesado();
            $entradas_process->__construct(active: 1);
            $result_entrys = $entradas_process->search(0, 100, "fecha_vencimiento", "ASC");
            $date_now = new DateTime();

            $isSale = true;
            $faltantes = [];
            foreach ($detalles_productos as $detalle) {
                $faltante = $detalle['cantidad'];
                foreach ($result_entrys as $entrada) {
                    if (
                        $detalle['id_producto'] == $entrada['id_producto'] &&
                        new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                        $entrada['existencia'] > 0
                    ) {
                        $descontar = min($faltante, $entrada['existencia']);
                        $faltante -= $descontar;
                        if ($faltante <= 0) {
                            break;
                        }
                    }
                }

                if ($faltante > 0) {
                    $isSale = false;
                    $faltantes[] = [
                        'producto' => $detalle['producto'],
                        'faltante' => $faltante
                    ];
                }
            }

            $result_detalle_procesado = $isSale;
            $message_error_detalle_procesado = $faltantes;
        }

        $ok = false;
        if (isset($lista_detalle_preparado) && isset($lista_detalle_procesado)) {
            $ok = ($result_detalle_preparado && $result_detalle_procesado);
        } else if (isset($lista_detalle_preparado)) {
            $ok = $result_detalle_preparado;
        } else if (isset($lista_detalle_procesado)) {
            $ok = $result_detalle_procesado;
        } else if ($es_add_orden && !$requiere_detalles) {
            $ok = true;
        }

        if ($ok) {
            $last_id = null;

            if ($es_add_orden) {
                if (
                    !isset($_POST['tipo']) ||
                    !isset($_POST['status']) ||
                    !isset($_POST['nro_orden'])
                ) {
                    make_url_error("Faltan campos para crear la orden.", 400, ajax: true);
                }

                $db = new Orden();
                $db->__construct(
                    tipo: $_POST['tipo'],
                    id_cliente: $_POST['id_cliente'] ?? null,
                    status: $_POST['status'],
                    nro_orden: $_POST['nro_orden']
                );
                $last_id = $db->agregar();
            }

            if (isset($lista_detalle_preparado) && is_array($lista_detalle_preparado)) {
                for ($i = 0; $i < count($lista_detalle_preparado); $i++) {
                    if ($es_add_orden) {
                        $clase_detalle_producto_preparado->__construct(...['id_orden' => $last_id, ...$lista_detalle_preparado[$i]]);
                    } else {
                        $clase_detalle_producto_preparado->__construct(...$lista_detalle_preparado[$i]);
                    }
                    $clase_detalle_producto_preparado->agregar();
                }

                date_default_timezone_set('America/Caracas');
                $entradas_materia_prima = new Detalle_entrada_materia_prima();
                $entradas_materia_prima->__construct(active: 1);
                $result_entrys = $entradas_materia_prima->search(0, 100, "fecha_vencimiento", "ASC");
                $date_now = new DateTime();

                foreach ($detalles_receta as $detalle) {
                    $cantidad_a_descontar = $detalle['cantidad'];
                    foreach ($result_entrys as &$entrada) {
                        if (
                            $detalle['id_materia_prima'] == $entrada['id_materia_prima'] &&
                            new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                            $entrada['existencia'] > 0
                        ) {
                            $descontar = min($cantidad_a_descontar, $entrada['existencia']);
                            if ($descontar <= 0) {
                                continue;
                            }

                            $entradas_materia_prima->__construct(
                                id: $entrada['id'],
                                existencia: $entrada['existencia'] - $descontar
                            );
                            $entradas_materia_prima->actualizar();

                            $entrada['existencia'] -= $descontar;
                            $cantidad_a_descontar -= $descontar;

                            if ($cantidad_a_descontar <= 0) {
                                break;
                            }
                        }
                    }
                }

                $materia_prima = new Materia_prima();
                $notification = new Notificacion();
                $materia_prima->__construct(active: 1);
                $result_productos = $materia_prima->search(0, 1000);

                foreach ($detalles_receta as $detalle_receta_item) {
                    foreach ($result_productos as $producto) {
                        $stock_min = $producto['stock_min'];
                        if ($producto['existencia'] <= $stock_min && $detalle_receta_item['id_materia_prima'] == $producto['id']) {
                            $notification->__construct(
                                id_usuario: $_SESSION['id'],
                                titulo: "Producto con stock bajo",
                                mensaje: "El producto " . $producto['nombre'] . " tiene un stock bajo",
                                status: 0
                            );
                            $notification->agregar();
                            date_default_timezone_set('America/Caracas');
                            $channel = 'General';
                            $event = "notificaciones";
                            $message = "El producto " . $producto['nombre'] . " tiene un stock bajo";
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
                        }
                    }
                }
            }

            if (isset($lista_detalle_procesado) && is_array($lista_detalle_procesado)) {
                for ($i = 0; $i < count($lista_detalle_procesado); $i++) {
                    if ($es_add_orden) {
                        $clase_detalle_producto_procesado->__construct(...['id_orden' => $last_id, ...$lista_detalle_procesado[$i]]);
                    } else {
                        $clase_detalle_producto_procesado->__construct(...$lista_detalle_procesado[$i]);
                    }
                    $clase_detalle_producto_procesado->agregar();
                }

                date_default_timezone_set('America/Caracas');
                $entradas_process = new Entrada_producto_procesado();
                $entradas_process->__construct(active: 1);
                $result_entrys = $entradas_process->search(0, 100, "fecha_vencimiento", "ASC");
                $date_now = new DateTime();

                foreach ($detalles_productos as $detalle) {
                    $cantidad_a_descontar = $detalle['cantidad'];
                    foreach ($result_entrys as &$entrada) {
                        if (
                            $detalle['id_producto'] == $entrada['id_producto'] &&
                            new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                            $entrada['existencia'] > 0
                        ) {
                            $descontar = min($cantidad_a_descontar, $entrada['existencia']);
                            if ($descontar <= 0) {
                                continue;
                            }

                            $entradas_process->__construct(
                                id: $entrada['id'],
                                existencia: $entrada['existencia'] - $descontar
                            );
                            $entradas_process->actualizar();

                            $entrada['existencia'] -= $descontar;
                            $cantidad_a_descontar -= $descontar;

                            if ($cantidad_a_descontar <= 0) {
                                break;
                            }
                        }
                    }
                }

                $productos = new ProductoProcesado();
                $notification = new Notificacion();
                $productos->__construct(active: 1);
                $result_productos = $productos->search(0, 1000);

                foreach ($detalles_productos as $producto_order) {
                    foreach ($result_productos as $producto) {
                        $stock_min = $producto['stock_min'];
                        if ($producto['existencia'] <= $stock_min && $producto_order['id_producto'] == $producto['id']) {
                            $notification->__construct(
                                id_usuario: $_SESSION['id'],
                                titulo: "Producto con stock bajo",
                                mensaje: "El producto " . $producto['nombre'] . " tiene un stock bajo",
                                status: 0
                            );
                            $notification->agregar();
                            date_default_timezone_set('America/Caracas');
                            $channel = 'General';
                            $event = "notificaciones";
                            $message = "El producto " . $producto['nombre'] . " tiene un stock bajo";
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
                        }
                    }
                }
            }

            if ($es_add_orden) {
                $resultado_final = ['success' => true, 'last_id' => $last_id];
            } else {
                $resultado_final = ['success' => true];
            }
        } else {
            $resultado_final = [
                'success' => false,
                'message' => [
                    'detalle_preparado' => $message_error_detalle_preparado,
                    'detalle_procesado' => $message_error_detalle_procesado
                ]
            ];
        }
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'update') {
    try {
        $modelo = new Orden(...$_POST);
        $resultado_final = $modelo->actualizar();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'delete') {
    try {
        if (!isset($_POST['id'])) {
            make_url_error("No se recibio el id para eliminar.", 400, ajax: true);
        }
        $modelo = new Orden(id: $_POST['id']);
        $resultado_final = ['success' => $modelo->borrar()];
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    try {
        $modelo = new Orden(...$_POST);
        $resultado_final = $modelo->count();
    } catch (Exception $e) {
        make_url_error($e->getMessage(), 400, ajax: true);
    }
    $ajax = true;
} else if ($url[1] === 'sendInvoice') {
    try {
        $tmpPath = $_FILES['pdf']['tmp_name'];
        $filename = $_FILES['pdf']['name'];
        $dropboxPath = "/facturas/" . date('Y-m-d') . "/" . uniqid() . "-" . $filename;

        $clientId = 'bjv6fj53algyuvy';
        $clientSecret = 'xctzdywh51b3oxy';
        $refreshToken = 'c3RXYAqJBP4AAAAAAAAAAU5M0GoRBtJnQYrvl6gPHYlmDSir37GjiGXiQC7KQZxm';

        $ch = curl_init('https://api.dropboxapi.com/oauth2/token');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_USERPWD, "$clientId:$clientSecret");
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'grant_type' => 'refresh_token',
            'refresh_token' => $refreshToken
        ]));
        $response = curl_exec($ch);
        curl_close($ch);

        $dataToken = json_decode($response, true);
        if (!isset($dataToken['access_token'])) {
            throw new Exception("No se pudo renovar el token: " . $response);
        }

        $app = new DropboxApp($clientId, $clientSecret, $dataToken['access_token']);
        $dropbox = new Dropbox($app);

        $uploadedFile = $dropbox->upload($tmpPath, $dropboxPath, ['autorename' => true]);
        $listResponse = $dropbox->postToAPI('/sharing/list_shared_links', [
            'path' => $uploadedFile->getPathDisplay(),
            'direct_only' => true
        ]);
        $listData = $listResponse->getDecodedBody();

        if (!empty($listData['links'])) {
            $urlDropbox = str_replace('?dl=0', '?raw=1', $listData['links'][0]['url']);
        } else {
            $createResponse = $dropbox->postToAPI('/sharing/create_shared_link_with_settings', [
                'path' => $uploadedFile->getPathDisplay(),
                'settings' => ['requested_visibility' => 'public']
            ]);
            $linkData = $createResponse->getDecodedBody();
            $urlDropbox = str_replace('?dl=0', '?raw=1', $linkData['url']);
        }

        $resultado_final = ['url' => $urlDropbox];
    } catch (Exception $e) {
        $resultado_final = ['error' => 'Error en Dropbox', 'detalle' => $e->getMessage()];
    }
    $ajax = true;
} else {
    make_url_error("Accion no valida para orden.", 404, ajax: true);
}

if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
