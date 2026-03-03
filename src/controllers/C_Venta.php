<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Venta;

function venta_get_all(...$args)
{
    get_all(new Venta(), ...$args);
}

function venta_add(...$args)
{
    add(new Venta(), $_POST);
}

function venta_update(...$args)
{
    update(new Venta(), $_POST);
}

function venta_delete(...$args)
{
    delete(new Venta(), $_POST['id']);
}


