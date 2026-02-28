<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Metodo_pago;

function metodo_pago_view(...$args)
{
    view('metodo_pago');
}

function metodo_pago_get_all(...$args)
{
    get_all(new Metodo_pago(), ...$args);
}

function metodo_pago_add(...$args)
{
    add(new Metodo_pago(), $_POST);
}

function metodo_pago_update(...$args)
{
    update(new Metodo_pago(), $_POST);
}

function metodo_pago_delete(...$args)
{
    delete(new Metodo_pago(), $_POST['id']);
}


