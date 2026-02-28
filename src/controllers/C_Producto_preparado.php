<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\ProductoPreparado;

function producto_preparado_view(...$args)
{
    view('producto_preparado');
}

function producto_preparado_get_all(...$args)
{
    get_all(new ProductoPreparado(), ...$args);
}

function producto_preparado_add(...$args)
{
    add(new ProductoPreparado(), $_POST);
}

function producto_preparado_update(...$args)
{
    update(new ProductoPreparado(), $_POST);
}

function producto_preparado_delete(...$args)
{
    delete(new ProductoPreparado(), $_POST['id']);
}

