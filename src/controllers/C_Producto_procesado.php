<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\ProductoProcesado;

function productprocesado_view(...$args)
{
    view('productProcess');
}

function productprocesado_get_all(...$args)
{
    get_all(new ProductoProcesado(), ...$args);
}

function productprocesado_add(...$args)
{
    add(new ProductoProcesado(), $_POST);
}

function productprocesado_update(...$args)
{
    update(new ProductoProcesado(), $_POST);
}

function productprocesado_delete(...$args)
{
    delete(new ProductoProcesado(), $_POST['id']);
}


