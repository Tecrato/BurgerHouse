<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Materia_prima;

class RawmaterialController extends Controller_base {

    public function __construct() {
        parent::__construct("raw-material");
        $this->db = new Materia_prima();
    }
}