<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Proveedor;

function proveedor_view(...$args)
{
    view('supplier');
}

function proveedor_get_all(...$args)
{
    get_all(new Proveedor(), ...$args);
}

function proveedor_add(...$args)
{
    add(new Proveedor(), $_POST);
}

function proveedor_update(...$args)
{
    update(new Proveedor(), $_POST);
}

function proveedor_delete(...$args)
{
    delete(new Proveedor(), $_POST['id']);
}


