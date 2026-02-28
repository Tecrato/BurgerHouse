<?php
namespace Shtch\Burgerhouse\controllers;
use Shtch\Burgerhouse\controllers\Controller_base;


class BrandController extends Controller_base {

    public function __construct(){
        parent::__construct(module_name: 'brand');
    }
}