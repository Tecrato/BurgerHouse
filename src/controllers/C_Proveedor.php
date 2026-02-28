<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
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


