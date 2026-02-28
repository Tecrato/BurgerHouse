<?php
namespace Shtch\Burgerhouse\models;

class Permiso extends Db_base {
    private $id;
    private $nombre;
    private $descripcion;
    private $active;

    public function __construct(
        $id = null,
        $nombre = null,
        $descripcion = null,
        $active = null
    ) {
        parent::__construct("permisos",2);
        
        $this->id = $id;
        $this->nombre = $nombre;
        $this->descripcion = $descripcion;
        $this->active = $active;

        $this->add_variables([
            "a.id" => $this->id,
            "a.nombre" => $this->nombre,
            "a.descripcion" => $this->descripcion,
            "a.active" => $this->active
        ]);
    }
}