<?php

namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Pago_entrada_producto_procesado;

class Entry_product_process_paymentController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("pagos_entrada_producto_procesado");
        $this->db = new Pago_entrada_producto_procesado();
    }

}
