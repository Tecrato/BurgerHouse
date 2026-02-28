<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Venta;

function sale_view(...$args)
{
    view('sale');
}

function sale_get_all(...$args)
{
    get_all(new Venta(), ...$args);
}

function sale_add(...$args)
{
    add(new Venta(), $_POST);
}

function sale_update(...$args)
{
    update(new Venta(), $_POST);
}

function sale_delete(...$args)
{
    delete(new Venta(), $_POST['id']);
}


