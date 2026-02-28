<?php

namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;

class Entry_rawmaterial_detailsController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("Detalles_entradas_materia_prima");
        $this->db = new Detalle_entrada_materia_prima();
    }

}
