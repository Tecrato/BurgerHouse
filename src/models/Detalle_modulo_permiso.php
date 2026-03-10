<?php
namespace Shtch\Burgerhouse\models;

use Shtch\Burgerhouse\models\Db_base;

class Detalle_modulo_permiso extends Db_base {
    private $id;
    private $id_rol;
    private $id_modulo;
    private $id_permiso;

    public function __construct(
        $id = null,
        $id_rol = null,
        $id_modulo = null,
        $id_permiso = null
    ) {
        parent::__construct("credito");
        
        $this->id = $id;
        $this->id_rol = $id_rol;
        $this->id_modulo = $id_modulo;
        $this->id_permiso = $id_permiso;


        $this->add_variables([
            "a.id" => $this->id,
            "a.id_rol" => $this->id_rol,
            "a.id_modulo" => $this->id_modulo,
            "a.id_permiso" => $this->id_permiso
        ]);
        
        $this->select_query = "
            a.id,
            a.id_rol AS id_rol,
            r.nombre AS nombre_rol,
            a.id_modulo AS id_modulo,
            m.nombre AS nombre_modulo,
            a.id_permiso AS id_permiso,
            p.nombre AS nombre_permiso
        ";

        $this->joins = [
            "INNER JOIN roles AS r ON r.id = a.id_rol",
            "INNER JOIN modulos AS m ON m.id = a.id_modulo",
            "INNER JOIN permisos AS p ON p.id = a.id_permiso"
        ];
    }
}