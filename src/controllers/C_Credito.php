<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Credito;

function credito_view(...$args)
{
    view('credito');
}

function credito_get_all(...$args)
{
    get_all(new Credito(), ...$args);
}

function credito_add(...$args)
{
    add(new Credito(), $_POST);
}

function credito_update(...$args)
{
    update(new Credito(), $_POST);
}

function credito_delete(...$args)
{
    delete(new Credito(), $_POST['id']);
}


