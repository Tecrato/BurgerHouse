<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Orden_mesa;

class Order_tableController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("order");
        $this->db = new Orden_mesa();
    }
}
