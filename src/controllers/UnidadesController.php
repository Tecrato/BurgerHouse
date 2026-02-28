<?php
namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Unidad;

class UnitsController extends Controller_base {
    public function __construct(){
        parent::__construct(module_name: 'units');
        
        $this->db = new Unidad();
    }
}