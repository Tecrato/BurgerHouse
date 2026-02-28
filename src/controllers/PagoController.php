<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Pago;
use Shtch\Burgerhouse\models\Pago_venta;
use Shtch\Burgerhouse\models\Pago_reserva;

use Exception;
class PaymentController extends Controller_base{

    public function __construct(){
        parent::__construct(module_name: 'pay');
        $this->db = new Pago();
    }
    public function add_many(){
        $pagos = [];
        try {
            for ($i = 0; $i < count($_POST['lista']); $i++) {
                $this->db->__construct(...$_POST['lista'][$i]);
                if (isset($_FILES['lista'])) {
                    $this->guardar_imagen_mult($i);
                }
                $id = $this->db->agregar();
                array_push($pagos, $id);
            }
            echo json_encode(['success' => true, 'lista' => $pagos]);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }

}