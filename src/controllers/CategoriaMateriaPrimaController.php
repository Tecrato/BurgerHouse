<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Categoria_materia_prima;


class CategoryMateriaPrimaController extends Controller_base {
    public function __construct() {
        parent::__construct("category");
        $this->db = new Categoria_materia_prima();
    }
}