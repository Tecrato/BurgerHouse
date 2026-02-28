<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Permiso;
use Shtch\Burgerhouse\models\Rol;

use function PHPSTORM_META\type;

class RolController extends Controller_base
{

    public function __construct()
    {
        parent::__construct("roles");
        $this->db = new Rol();
    }

    public function obtener_permisos($id) {
        $id_rol = intval($id) ?? null;
        if ($id_rol) {
            $rol = new Rol(id: $id_rol);
            $permisos = $rol->obtener_permisos();
            header('Content-Type: application/json');
            echo json_encode($permisos);
        } else {
            header('Content-Type: application/json');
            echo json_encode(['error' => 'ID de rol no proporcionado']);
        }
    }


    // public function agregar_rol(){
    //     $data = json_decode($_POST['nose'], true)[0];
    //     $nombre = $data['detalles']['nombre'];
    //     $descripcion = $data['detalles']['descripcion'];
    //     $db = new Rol(nombre: $nombre, descripcion: $descripcion);
    //     $last_id = $db->agregar();

    //     $lista_permisos = $data['permisos'];

    //     for ($i = 0; $i < count($lista_permisos); $i++) {
    //         $db= new Permiso(id_rol: $last_id, modulo: $lista_permisos[$i]['modulo'], permisos: $lista_permisos[$i]['permisos']);
    //         $db->agregar();
    //     }
    // }

}
