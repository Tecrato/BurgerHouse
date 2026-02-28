<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;

use Shtch\Burgerhouse\models\Receta;
use Shtch\Burgerhouse\models\Detalle_receta;
use Exception;

class RecipeController extends Controller_base {
    public function __construct() {
        parent::__construct('recipe');
        $this->db = new Receta();
    }
    public function add() {
        header('Content-Type: application/json');
        try {
            // $this->db->conn->beginTransaction();
            $this->db->clear();

            $this->db->__construct(id_producto: $_POST['id_producto']);
            $last_id = $this->db->agregar();

            for ($i = 0; $i < count($_POST['lista']); $i++) {
                $otra_clase = new Detalle_receta(...['id_receta' => $last_id,...$_POST['lista'][$i]]);
                $otra_clase->agregar();
            }
            // $this->db->conn->commit();
            echo json_encode(['success' => true, 'last_id' => $last_id]);
            
        } catch (Exception $e) {
            try {
                if ($this->db->conn->inTransaction()){
                    $this->db->conn->rollBack();
                }
            } catch (\Throwable $th) {
                //throw $th;
            }
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}