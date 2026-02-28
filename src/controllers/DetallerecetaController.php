<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;

use Shtch\Burgerhouse\models\Detalle_receta;

class DetallerecipeController extends Controller_base {
    public function __construct() {
        parent::__construct('recipe');
        $this->db = new Detalle_receta();
    }
}