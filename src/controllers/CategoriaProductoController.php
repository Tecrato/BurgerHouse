<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Categoria_producto;


class CategoryProductoController extends Controller_base {
    public function __construct() {
        parent::__construct("categorias_productos");
        $this->db = new Categoria_producto();
    }
    
}