<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Cliente;


class ClientsController extends Controller_base {

    public function __construct(){
        parent::__construct('clients');
        $this->db = new Cliente();
    }
}