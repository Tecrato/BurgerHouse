<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\DetalleOrdenProductoPreparado;
use Shtch\Burgerhouse\models\DetalleOrdenProductoProcesado;
use Shtch\Burgerhouse\models\Orden;
use Shtch\Burgerhouse\models\Receta;
use Shtch\Burgerhouse\models\Detalle_receta;
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;
use Shtch\Burgerhouse\models\Entrada_producto_procesado;
use Shtch\Burgerhouse\models\ProductoProcesado;
use Shtch\Burgerhouse\models\Notificacion;
use Shtch\Burgerhouse\models\Materia_prima;
use Pusher\Pusher;
use Kunnu\Dropbox\Dropbox;
use Kunnu\Dropbox\DropboxApp;
use Exception;
use DateTime;

class OrderController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("orders");
        $this->db = new Orden();
    }
    public function add()
    {
        try {
            $l = $_POST;
            $result_detalle_preparado = true;
            $result_detalle_procesado = true;

            $message_error_detalle_preparado = null;
            $message_error_detalle_procesado = null;
            unset($l['lista_detalle_preparado']);
            unset($l['lista_detalle_procesado']);
            $clase_detalle_producto_preparado = new DetalleOrdenProductoPreparado();
            $clase_detalle_producto_procesado = new DetalleOrdenProductoProcesado();

            $detalles_receta = [];
            $detalles_productos = [];

            if (in_array($_POST['tipo'], ["delivery", "llevar", "local"])) {
                if (isset($_POST['lista_detalle_preparado'])) {
                    $receta = new Receta();
                    $detalle_receta = new Detalle_receta();

                    for ($i = 0; $i < count($_POST['lista_detalle_preparado']); $i++) {
                        $idProducto     = $_POST['lista_detalle_preparado'][$i]['id_producto'];
                        $cantidadPedido = $_POST['lista_detalle_preparado'][$i]['cantidad'];
                        $receta->__construct(id_producto: $idProducto);
                        foreach ($receta->search() as $key) {
                            $detalle_receta->__construct(id_receta: $key["id"]);
                            foreach ($detalle_receta->search() as $detalle) {
                                $detalle['cantidad'] = $detalle['cantidad'] * $cantidadPedido;
                                $detalles_receta[] = $detalle;
                            }
                        }
                    }
                    $result = OrderController::VerifyPrepared($detalles_receta);
                    $result["success"] ? $result_detalle_preparado = true : $result_detalle_preparado = false;
                    $message_error_detalle_preparado = $result["faltantes"];
                }
                if (isset($_POST['lista_detalle_procesado'])) {
                    $productos = new ProductoProcesado();

                    foreach ($_POST['lista_detalle_procesado'] as $detalle) {
                        $idProducto = $detalle['id_producto'];
                        foreach ($productos->search(0, 1000) as $producto) {
                            if ($producto['id'] == $detalle['id_producto']) {
                                $detalle['producto'] = $producto['nombre'];
                                $detalles_productos[] = $detalle;
                            }
                        }
                    }
                    $result = OrderController::VeryfyProcess($detalles_productos);
                    $result["success"] ? $result_detalle_procesado = true : $result_detalle_procesado = false;
                    $message_error_detalle_procesado = $result["faltantes"];
                }

                $ok = false;
                if (isset($_POST['lista_detalle_preparado']) && isset($_POST['lista_detalle_procesado'])) {
                    $ok = ($result_detalle_preparado && $result_detalle_procesado);
                } elseif (isset($_POST['lista_detalle_preparado'])) {
                    $ok = $result_detalle_preparado;
                } elseif (isset($_POST['lista_detalle_procesado'])) {
                    $ok = $result_detalle_procesado;
                }

                if ($ok) {
                    $this->db->__construct(tipo: $_POST['tipo'], id_cliente: $_POST['id_cliente'] ?? null, status: $_POST['status'], nro_orden: $_POST['nro_orden']);
                    $last_id = $this->db->agregar();
                    if (isset($_POST['lista_detalle_preparado'])) {
                        for ($i = 0; $i < count($_POST['lista_detalle_preparado']); $i++) {
                            $clase_detalle_producto_preparado->__construct(...['id_orden' => $last_id, ...$_POST['lista_detalle_preparado'][$i]]);
                            $clase_detalle_producto_preparado->agregar();
                        }
                        OrderController::descountPrepared($detalles_receta);
                        OrderController::verifyStockPrepared($detalles_receta);
                    }
                    if (isset($_POST['lista_detalle_procesado'])) {
                        for ($i = 0; $i < count($_POST['lista_detalle_procesado']); $i++) {
                            $clase_detalle_producto_procesado->__construct(...['id_orden' => $last_id, ...$_POST['lista_detalle_procesado'][$i]]);
                            $clase_detalle_producto_procesado->agregar();
                        }
                        OrderController::descountProcess($detalles_productos);
                        OrderController::verifyStockProcess($detalles_productos);
                    }
                    echo json_encode(['success' => true, 'last_id' => $last_id]);
                } else {
                    echo json_encode(['success' => false, 'message' => [
                        "detalle_preparado" => $message_error_detalle_preparado,
                        "detalle_procesado" => $message_error_detalle_procesado
                    ]]);
                }
            } else {
                $this->db->__construct(tipo: $_POST['tipo'], id_cliente: $_POST['id_cliente'] ?? null, status: $_POST['status'], nro_orden: $_POST['nro_orden']);
                $last_id = $this->db->agregar();
                echo json_encode(['success' => true, 'last_id' => $last_id]);
            }
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function add_process_and_prepared()
    {
        try {
            $l = $_POST;
            $result_detalle_preparado = true;
            $result_detalle_procesado = true;

            $message_error_detalle_preparado = null;
            $message_error_detalle_procesado = null;
            unset($l['lista_detalle_preparado']);
            unset($l['lista_detalle_procesado']);
            $clase_detalle_producto_preparado = new DetalleOrdenProductoPreparado();
            $clase_detalle_producto_procesado = new DetalleOrdenProductoProcesado();

            $detalles_receta = [];
            $detalles_productos = [];

            if (isset($_POST['lista_detalle_preparado'])) {
                $receta = new Receta();
                $detalle_receta = new Detalle_receta();

                for ($i = 0; $i < count($_POST['lista_detalle_preparado']); $i++) {
                    $idProducto     = $_POST['lista_detalle_preparado'][$i]['id_producto'];
                    $cantidadPedido = $_POST['lista_detalle_preparado'][$i]['cantidad'];
                    $receta->__construct(id_producto: $idProducto);
                    foreach ($receta->search() as $key) {
                        $detalle_receta->__construct(id_receta: $key["id"]);
                        foreach ($detalle_receta->search() as $detalle) {
                            $detalle['cantidad'] = $detalle['cantidad'] * $cantidadPedido;
                            $detalles_receta[] = $detalle;
                        }
                    }
                }
                $result = OrderController::VerifyPrepared($detalles_receta);
                $result["success"] ? $result_detalle_preparado = true : $result_detalle_preparado = false;
                $message_error_detalle_preparado = $result["faltantes"];
            }
            if (isset($_POST['lista_detalle_procesado'])) {
                $productos = new ProductoProcesado();

                foreach ($_POST['lista_detalle_procesado'] as $detalle) {
                    $idProducto = $detalle['id_producto'];
                    foreach ($productos->search(0, 1000) as $producto) {
                        if ($producto['id'] == $detalle['id_producto']) {
                            $detalle['producto'] = $producto['nombre'];
                            $detalles_productos[] = $detalle;
                        }
                    }
                }
                $result = OrderController::VeryfyProcess($detalles_productos);
                $result["success"] ? $result_detalle_procesado = true : $result_detalle_procesado = false;
                $message_error_detalle_procesado = $result["faltantes"];
            }

            $ok = false;
            if (isset($_POST['lista_detalle_preparado']) && isset($_POST['lista_detalle_procesado'])) {
                $ok = ($result_detalle_preparado && $result_detalle_procesado);
            } elseif (isset($_POST['lista_detalle_preparado'])) {
                $ok = $result_detalle_preparado;
            } elseif (isset($_POST['lista_detalle_procesado'])) {
                $ok = $result_detalle_procesado;
            }

            if ($ok) {
                if (isset($_POST['lista_detalle_preparado'])) {
                    for ($i = 0; $i < count($_POST['lista_detalle_preparado']); $i++) {
                        $clase_detalle_producto_preparado->__construct(...$_POST['lista_detalle_preparado'][$i]);
                        $clase_detalle_producto_preparado->agregar();
                    }
                    OrderController::descountPrepared($detalles_receta);
                    OrderController::verifyStockPrepared($detalles_receta);
                }
                if (isset($_POST['lista_detalle_procesado'])) {
                    for ($i = 0; $i < count($_POST['lista_detalle_procesado']); $i++) {
                        $clase_detalle_producto_procesado->__construct(...$_POST['lista_detalle_procesado'][$i]);
                        $clase_detalle_producto_procesado->agregar();
                    }
                    OrderController::descountProcess($detalles_productos);
                    OrderController::verifyStockProcess($detalles_productos);
                }
                echo json_encode(['success' => true]);
            } else {
                echo json_encode(['success' => false, 'message' => [
                    "detalle_preparado" => $message_error_detalle_preparado,
                    "detalle_procesado" => $message_error_detalle_procesado
                ]]);
            }
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public static function getDropboxAccessToken($clientId, $clientSecret, $refreshToken)
    {
        $ch = curl_init('https://api.dropboxapi.com/oauth2/token');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_USERPWD, "$clientId:$clientSecret");
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'grant_type' => 'refresh_token',
            'refresh_token' => $refreshToken
        ]));
        $response = curl_exec($ch);
        curl_close($ch);

        $data = json_decode($response, true);
        if (isset($data['access_token'])) {
            return $data['access_token'];
        } else {
            throw new Exception("No se pudo renovar el token: " . $response);
        }
    }
    public function sendInvoice()
    {
        $tmpPath = $_FILES['pdf']['tmp_name'];
        $filename = $_FILES['pdf']['name'];
        $dropboxPath = "/facturas/" . date('Y-m-d') . "/" . uniqid() . "-" . $filename;

        try {
            $clientId = 'bjv6fj53algyuvy';
            $clientSecret = 'xctzdywh51b3oxy';
            $refreshToken = 'c3RXYAqJBP4AAAAAAAAAAU5M0GoRBtJnQYrvl6gPHYlmDSir37GjiGXiQC7KQZxm';

            $accessToken = OrderController::getDropboxAccessToken($clientId, $clientSecret, $refreshToken);

            $app = new DropboxApp($clientId, $clientSecret, $accessToken);
            $dropbox = new Dropbox($app);

            $uploadedFile = $dropbox->upload($tmpPath, $dropboxPath, ['autorename' => true]);
            $listResponse = $dropbox->postToAPI('/sharing/list_shared_links', [
                'path' => $uploadedFile->getPathDisplay(),
                'direct_only' => true
            ]);
            $listData = $listResponse->getDecodedBody();

            if (!empty($listData['links'])) {
                $url = str_replace('?dl=0', '?raw=1', $listData['links'][0]['url']);
            } else {
                $createResponse = $dropbox->postToAPI('/sharing/create_shared_link_with_settings', [
                    'path' => $uploadedFile->getPathDisplay(),
                    'settings' => ['requested_visibility' => 'public']
                ]);
                $linkData = $createResponse->getDecodedBody();
                $url = str_replace('?dl=0', '?raw=1', $linkData['url']);
            }
            echo json_encode(['url' => $url]);
        } catch (Exception $e) {
            echo json_encode(['error' => 'Error en Dropbox', 'detalle' => $e->getMessage()]);
        }
    }
    public static function VerifyPrepared($detalle_receta)
    {
        date_default_timezone_set('America/Caracas');
        $entradas_materia_prima = new Detalle_entrada_materia_prima();
        $entradas_materia_prima->__construct(active: 1);
        $result_entrys = $entradas_materia_prima->search(0, 100, "fecha_vencimiento", "ASC");
        $date_now = new DateTime();

        $recetaPosible = true;
        $faltantes = [];

        foreach ($detalle_receta as $detalle) {
            $faltante = $detalle['cantidad'];
            foreach ($result_entrys as $entrada) {
                if (
                    $detalle['id_materia_prima'] == $entrada['id_materia_prima'] &&
                    new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                    $entrada['existencia'] > 0
                ) {
                    $descontar = min($faltante, $entrada['existencia']);
                    $faltante -= $descontar;
                    if ($faltante <= 0) break;
                }
            }

            if ($faltante > 0) {
                $recetaPosible = false;
                $faltantes[] = [
                    'producto' => $detalle['ingrediente'],
                    'faltante' => $faltante
                ];
            }
        }

        return [
            'success' => $recetaPosible,
            'faltantes' => $faltantes
        ];
    }
    public static function descountPrepared($detalle_receta)
    {
        date_default_timezone_set('America/Caracas');
        $entradas_materia_prima = new Detalle_entrada_materia_prima();
        $entradas_materia_prima->__construct(active: 1);
        $result_entrys = $entradas_materia_prima->search(0, 100, "fecha_vencimiento", "ASC");
        $date_now = new DateTime();

        foreach ($detalle_receta as $detalle) {
            $cantidad_a_descontar = $detalle['cantidad'];
            foreach ($result_entrys as &$entrada) {
                if (
                    $detalle['id_materia_prima'] == $entrada['id_materia_prima'] &&
                    new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                    $entrada['existencia'] > 0
                ) {
                    $descontar = min($cantidad_a_descontar, $entrada['existencia']);
                    if ($descontar <= 0) continue;

                    $entradas_materia_prima->__construct(
                        id: $entrada['id'],
                        existencia: $entrada['existencia'] - $descontar
                    );
                    $entradas_materia_prima->actualizar();

                    $entrada['existencia'] -= $descontar;
                    $cantidad_a_descontar -= $descontar;

                    if ($cantidad_a_descontar <= 0) break;
                }
            }
        }
    }
    public static function VeryfyProcess($detalle_producto)
    {
        date_default_timezone_set('America/Caracas');
        $entradas_process = new Entrada_producto_procesado();
        $entradas_process->__construct(active: 1);
        $result_entrys = $entradas_process->search(0, 100, "fecha_vencimiento", "ASC");
        $date_now = new DateTime();

        $isSale = true;
        $faltantes = [];

        foreach ($detalle_producto as $detalle) {
            $faltante = $detalle['cantidad'];
            foreach ($result_entrys as $entrada) {
                if (
                    $detalle['id_producto'] == $entrada['id_producto'] &&
                    new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                    $entrada['existencia'] > 0
                ) {
                    $descontar = min($faltante, $entrada['existencia']);
                    $faltante -= $descontar;
                    if ($faltante <= 0) break;
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

        // if ($isSale) {
        //     foreach ($detalle_producto as $detalle) {
        //         $cantidad_a_descontar = $detalle['cantidad'];
        //         foreach ($result_entrys as &$entrada) {
        //             if (
        //                 $detalle['id_producto'] == $entrada['id_producto'] &&
        //                 new DateTime($entrada['fecha_vencimiento']) > $date_now &&
        //                 $entrada['existencia'] > 0
        //             ) {
        //                 $descontar = min($cantidad_a_descontar, $entrada['existencia']);
        //                 if ($descontar <= 0) continue;

        //                 $entradas_process->__construct(
        //                     id: $entrada['id'],
        //                     existencia: $entrada['existencia'] - $descontar
        //                 );
        //                 $entradas_process->actualizar();

        //                 $entrada['existencia'] -= $descontar;
        //                 $cantidad_a_descontar -= $descontar;

        //                 if ($cantidad_a_descontar <= 0) break;
        //             }
        //         }
        //     }
        // }

        return [
            'success' => $isSale,
            'faltantes' => $faltantes
        ];
    }
    public static function descountProcess($detalle_producto)
    {
        date_default_timezone_set('America/Caracas');
        $entradas_process = new Entrada_producto_procesado();
        $entradas_process->__construct(active: 1);
        $result_entrys = $entradas_process->search(0, 100, "fecha_vencimiento", "ASC");
        $date_now = new DateTime();

        foreach ($detalle_producto as $detalle) {
            $cantidad_a_descontar = $detalle['cantidad'];
            foreach ($result_entrys as &$entrada) {
                if (
                    $detalle['id_producto'] == $entrada['id_producto'] &&
                    new DateTime($entrada['fecha_vencimiento']) > $date_now &&
                    $entrada['existencia'] > 0
                ) {
                    $descontar = min($cantidad_a_descontar, $entrada['existencia']);
                    if ($descontar <= 0) continue;

                    $entradas_process->__construct(
                        id: $entrada['id'],
                        existencia: $entrada['existencia'] - $descontar
                    );
                    $entradas_process->actualizar();

                    $entrada['existencia'] -= $descontar;
                    $cantidad_a_descontar -= $descontar;

                    if ($cantidad_a_descontar <= 0) break;
                }
            }
        }
    }
    public static function verifyStockProcess($detalle_producto)
    {
        $productos = new ProductoProcesado();
        $notification = new Notificacion();
        $productos->__construct(active: 1);
        $result_productos = $productos->search(0, 1000);

        foreach ($detalle_producto as $producto_order) {
            foreach ($result_productos as $producto) {
                $stock_min = $producto['stock_min'];
                $stock_max = $producto['stock_max'];
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
                    $data = ['message' => $message,  'time' => date('Y-m-d H:i:s'), 'event' => $event];
                    $pusher->trigger($channel, $event, $data);
                }
            }
        }
    }
    public static function verifyStockPrepared($detalles_receta)
    {
        $materia_prima = new Materia_prima();
        $notification = new Notificacion();
        $materia_prima->__construct(active: 1);
        $result_productos = $materia_prima->search(0, 1000);

        foreach ($detalles_receta as $detalle_receta) {
            foreach ($result_productos as $producto) {
                $stock_min = $producto['stock_min'];
                $stock_max = $producto['stock_max'];
                if ($producto['existencia'] <= $stock_min && $detalle_receta['id_materia_prima'] == $producto['id']) {
                    $notification->__construct(
                        id_usuario: $_SESSION['id'],
                        titulo: "Producto con stock bajo",
                        mensaje: "El producto " . $producto['nombre'] . " tiene un stock bajo",
                        status: 1
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
                    $data = ['message' => $message,  'time' => date('Y-m-d H:i:s'), 'event' => $event];
                    $pusher->trigger($channel, $event, $data);
                }
            }
        }
    }
    public function update()
    {
        
    }
}
