<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;  
use Shtch\Burgerhouse\models\Proveedor;

class SupplierController extends Controller_base {

    public function __construct() {
        parent::__construct("supplier");
        $this->db = new Proveedor();
    }
    
}