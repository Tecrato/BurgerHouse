<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Paquetes_mesa;

class Package_tableController extends Controller_base {
    public function __construct() {
        parent::__construct("package_reservation");
        $this->db = new Paquetes_mesa();
    }
}