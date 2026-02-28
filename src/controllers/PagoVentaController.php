<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Pago_venta;

class PaymentSaleController extends Controller_base{

    public function __construct(){
        parent::__construct(module_name: 'pay');
        $this->db = new Pago_venta();
    }

}