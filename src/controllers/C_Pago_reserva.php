<?php
require_once __DIR__ . '/Controller_base.php';
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


