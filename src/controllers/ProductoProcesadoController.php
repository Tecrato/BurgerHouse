<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\ProductoProcesado;

class ProductProcessController extends Controller_base {

    public function __construct() {
        parent::__construct(module_name: "productProcess");
        $this->db = new ProductoProcesado();
    }
}