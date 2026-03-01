<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Usuario;


function users_view(...$args)
{
    view('users');
}

function users_get_all(...$args)
{
    get_all(new Usuario(), ...$args);
}

function users_count(...$args)
{
    total(new Usuario(), ...$args);
}

function users_add(...$args)
{
    add(new Usuario(), $_POST);
}

function users_update(...$args)
{
    update(new Usuario(), $_POST);
}

function users_delete(...$args)
{
    delete(new Usuario(), $_POST['id']);
}

