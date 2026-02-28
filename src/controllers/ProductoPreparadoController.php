<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\ProductoPreparado;

class ProductPreparedController extends Controller_base {
    public function __construct() {
        parent::__construct(module_name: "productPrepared");
        $this->db = new ProductoPreparado();
    }
}