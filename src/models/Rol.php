<?php
namespace Shtch\Burgerhouse\models;

use Shtch\Burgerhouse\models\Db_base;

class Rol extends Db_base {
    private $id;
    private $nombre;
    private $descripcion;
    private $nombre_like;
    private $active;

    public function __construct($id = null, $nombre = null, $descripcion = null, $nombre_like=null, $active=null) {
        parent::__construct("roles",2);
        
        $this->id = $id;
        $this->nombre = $nombre;
        $this->descripcion = $descripcion;
        $this->nombre_like = $nombre_like;
        $this->active = $active;

        $this->add_variables([
            "a.id" => $this->id,
            "a.nombre" => $this->nombre,
            "a.descripcion" => $this->descripcion,
            "a.active" => $this->active
        ]);

        $this->add_variables_like([
            "a.nombre" => $this->nombre_like
        ]);
        
        $this->select_query = "
            a.id,
            a.nombre,
            a.descripcion,
            a.active
        ";
    }

    public function obtener_permisos() {
        $query = "SELECT
        roles.nombre AS rol,
        modulos.nombre AS modulo,
        GROUP_CONCAT(permisos.nombre ORDER BY permisos.nombre SEPARATOR ', ') AS permisos
        FROM roles_modulos_permisos AS relaciones
        INNER JOIN roles ON roles.id = relaciones.id_rol
        INNER JOIN modulos ON modulos.id = relaciones.id_modulo
        INNER JOIN permisos ON permisos.id = relaciones.id_permiso
        WHERE relaciones.id_rol = :id_rol
        GROUP BY modulos.id
        ORDER BY modulos.nombre";
        // $query = "SELECT
        // roles.nombre AS rol,
        // modulos.nombre AS modulo
        // -- permiso.nombre AS permisos
        // FROM roles_modulos_permisos AS permiso
        // INNER JOIN roles ON roles.id = permiso.id_rol
        // INNER JOIN modulos ON modulos.id = permiso.id_modulo
        // WHERE permiso.id_rol = 11";
        
        $query = $this->conn->prepare($query);
        $query->bindValue(':id_rol', $this->id);
        $query->execute();
        return $query->fetchAll();
    }
}
