<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Categoria_producto as CategoriaP;

function categoria_materia_prima_view(...$args)
{
    view('categoria');
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

