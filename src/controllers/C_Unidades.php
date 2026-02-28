<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Unidad;

function unidades_view(...$args)
{
    view('unidades');
}

function unidades_get_all(...$args)
{
    get_all(new Unidad(), ...$args);
}

function unidades_add(...$args)
{
    add(new Unidad(), $_POST);
}

function unidades_update(...$args)
{
    update(new Unidad(), $_POST);
}

function unidades_delete(...$args)
{
    delete(new Unidad(), $_POST['id']);
}

