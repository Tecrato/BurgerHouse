<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Pago_entrada_producto_procesado;

function pago_producto_procesado_view(...$args)
{
    view('pay_entrys_product_process');
}

function pago_producto_procesado_get_all(...$args)
{
    get_all(new Pago_entrada_producto_procesado(), ...$args);
}

function pago_producto_procesado_add(...$args)
{
    add(new Pago_entrada_producto_procesado(), $_POST);
}

function pago_producto_procesado_update(...$args)
{
    update(new Pago_entrada_producto_procesado(), $_POST);
}

function pago_producto_procesado_delete(...$args)
{
    delete(new Pago_entrada_producto_procesado(), $_POST['id']);
}


