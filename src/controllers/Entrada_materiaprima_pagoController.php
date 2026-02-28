<?php

namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Pago_entrada_materia_prima ;

class Entry_rawmaterial_paymentController extends Controller_base
{
    public function __construct()
    {
        parent::__construct("pagos_entrada_materia_prima");
        $this->db = new Pago_entrada_materia_prima();
    }

}
