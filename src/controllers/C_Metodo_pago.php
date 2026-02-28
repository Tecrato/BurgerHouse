<?php
require_once __DIR__ . '/Controller_base.php';
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


