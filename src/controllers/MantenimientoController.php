<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Backup;
use Shtch\Burgerhouse\models\Usuario;
use Exception;

class MaintenanceController extends Controller_base
{
    private $conn;
    public function __construct()
    {
        parent::__construct("maintenance");
        $this->conn = new Backup();
        $this->db = new Usuario();
    }

    public function export()
    {
        try {
            $db = $_POST['db'];
            $route = $_POST['route'];
            $this->conn->respaldo($db, $route);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }
    public function import()
    {
        try {
            $this->db->clear();
            $this->db->__construct(id: $_POST['id']);
            $result = $this->db->search();
            if ($result[0]["hash"] == $_POST['password']) {
                $db = $_POST['db'];
                $route = $_POST['route'];
                $archive = $_POST['archive'];
                $this->conn->restaurar($db, $route, $archive);
            } else {
                echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
            }
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }
    public function search()
    {
        try {
            $route = $_POST['route'];
            $result = $this->conn->search($route);
            echo json_encode($result);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }
    public function delete()
    {
        try {
            $this->db->clear();
            $this->db->__construct(id: $_POST['id']);
            $result = $this->db->search();
            if ($result[0]["hash"] == $_POST['password']) {
                $route = $_POST['route'];
                $archive = $_POST['archive'];
                $this->conn->delete($route, $archive);
            } else {
                echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
            }
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }
}
