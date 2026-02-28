<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Metodo_pago;

class PaymentMethodController extends Controller_base {
    public function __construct() {
        parent::__construct("paymentMethod");
        $this->db = new Metodo_pago();
    }
}