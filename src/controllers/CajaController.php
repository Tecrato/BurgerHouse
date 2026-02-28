<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Caja;
use Exception;


class CashController extends Controller_base {
    public function __construct() {
        $this->db = new Caja();
    }

    public function detailCash() {
        try {
            $id = $_POST['id'];
            $cashDetails = $this->db->cajaDetails($id);
            echo json_encode($cashDetails);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function closeCash() {
        try {
            $id = $_POST['id'];
            $this->db->closeCash($id);
            echo json_encode(['success' => true]);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}