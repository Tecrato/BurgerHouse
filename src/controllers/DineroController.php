<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;

class MoneyController extends Controller_base{

    public function __construct(){
        parent::__construct(module_name: 'money');
    }
}