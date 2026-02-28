<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Categoria_producto as CategoriaP;

function categoria_producto_view(...$args)
{
    view('categoria_producto');
}

function categoria_producto_get_all(...$args)
{
    get_all(new CategoriaP(), ...$args);
}

function categoria_producto_add(...$args)
{
    add(new CategoriaP(), $_POST);
}

function categoria_producto_update(...$args)
{
    update(new CategoriaP(), $_POST);
}

function categoria_producto_delete(...$args)
{
    delete(new CategoriaP(), $_POST['id']);
}

