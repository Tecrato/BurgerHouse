<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
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


