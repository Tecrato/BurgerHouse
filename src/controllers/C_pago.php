<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Pago;

function payment_view(...$args)
{
    view('payment');
}

function payment_get_all(...$args)
{
    get_all(new Pago(), ...$args);
}

function payment_add_many(...$args)
{
    header('Content-Type: application/json');
    try {
        $pagos = [];
        for ($i = 0; $i < count($_POST['lista']); $i++) {
            $pago = new Pago();
            $pago->__construct(...$_POST['lista'][$i]);
            if (isset($_FILES['lista'])) {
                guardar_imagen_mult($i);
            }
            $id = $pago->agregar();
            array_push($pagos, $id);
        }
        echo json_encode(['success' => true, 'lista' => $pagos]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}


