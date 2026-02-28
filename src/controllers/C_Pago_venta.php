<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Pago_venta;

function pago_venta_view(...$args)
{
    view('pay');
}

function pago_venta_get_all(...$args)
{
    get_all(new Pago_venta(), ...$args);
}

function pago_venta_add(...$args)
{
    add(new Pago_venta(), $_POST);
}

function pago_venta_update(...$args)
{
    update(new Pago_venta(), $_POST);
}

function pago_venta_delete(...$args)
{
    delete(new Pago_venta(), $_POST['id']);
}


