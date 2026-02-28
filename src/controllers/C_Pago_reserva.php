<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Pago_reserva;

function pago_reserva_view(...$args)
{
    view('pay');
}

function pago_reserva_get_all(...$args)
{
    get_all(new Pago_reserva(), ...$args);
}

function pago_reserva_add(...$args)
{
    add(new Pago_reserva(), $_POST);
}

function pago_reserva_update(...$args)
{
    update(new Pago_reserva(), $_POST);
}

function pago_reserva_delete(...$args)
{
    delete(new Pago_reserva(), $_POST['id']);
}


