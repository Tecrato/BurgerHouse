<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Cliente;

function clientes_view(...$args)
{
    view('clientes');
}

function clientes_get_all(...$args)
{
    get_all(new Cliente(), ...$args);
}

function clientes_add(...$args)
{
    add(new Cliente(), $_POST);
}

function clientes_update(...$args)
{
    update(new Cliente(), $_POST);
}

function clientes_delete(...$args)
{
    delete(new Cliente(), $_POST['id']);
}

