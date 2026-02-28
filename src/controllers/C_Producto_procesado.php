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



function producto_procesado_view(...$args) { return productprocesado_view(...$args); }
function producto_procesado_get_all(...$args) { return productprocesado_get_all(...$args); }
function producto_procesado_add(...$args) { return productprocesado_add(...$args); }
function producto_procesado_update(...$args) { return productprocesado_update(...$args); }
function producto_procesado_delete(...$args) { return productprocesado_delete(...$args); }
