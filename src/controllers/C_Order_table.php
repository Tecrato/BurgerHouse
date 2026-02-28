<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Orden_mesa;

function order_table_view(...$args)
{
    view('order');
}

function order_table_get_all(...$args)
{
    get_all(new Orden_mesa(), ...$args);
}

function order_table_add(...$args)
{
    add(new Orden_mesa(), $_POST);
}

function order_table_update(...$args)
{
    update(new Orden_mesa(), $_POST);
}

function order_table_delete(...$args)
{
    delete(new Orden_mesa(), $_POST['id']);
}


