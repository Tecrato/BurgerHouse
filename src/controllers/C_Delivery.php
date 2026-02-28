<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Delivery;

function delivery_view(...$args)
{
    view('delivery');
}

function delivery_get_all(...$args)
{
    get_all(new Delivery(), ...$args);
}

function delivery_add(...$args)
{
    add(new Delivery(), $_POST);
}

function delivery_update(...$args)
{
    update(new Delivery(), $_POST);
}

function delivery_delete(...$args)
{
    delete(new Delivery(), $_POST['id']);
}


