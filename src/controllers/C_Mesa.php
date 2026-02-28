<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Mesa;

function mesa_view(...$args)
{
    view('mesa');
}

function mesa_get_all(...$args)
{
    get_all(new Mesa(), ...$args);
}

function mesa_add(...$args)
{
    add(new Mesa(), $_POST);
}

function mesa_update(...$args)
{
    update(new Mesa(), $_POST);
}

function mesa_delete(...$args)
{
    delete(new Mesa(), $_POST['id']);
}


