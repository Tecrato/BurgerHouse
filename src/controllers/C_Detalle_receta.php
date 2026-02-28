<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

use Shtch\Burgerhouse\models\Detalle_receta;

function detalle_receta_view(...$args)
{
    view('detalle_receta');
}

function detalle_receta_get_all(...$args)
{
    get_all(new Detalle_receta(), ...$args);
}

function detalle_receta_add(...$args)
{
    add(new Detalle_receta(), $_POST);
}

function detalle_receta_update(...$args)
{
    update(new Detalle_receta(), $_POST);
}

function detalle_receta_delete(...$args)
{
    delete(new Detalle_receta(), $_POST['id']);
}
