<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Pago_entrada_materia_prima;

function pago_materia_prima_view(...$args)
{
    view('pay_entrys_rawmaterial');
}

function pago_materia_prima_get_all(...$args)
{
    get_all(new Pago_entrada_materia_prima(), ...$args);
}

function pago_materia_prima_add(...$args)
{
    add(new Pago_entrada_materia_prima(), $_POST);
}

function pago_materia_prima_update(...$args)
{
    update(new Pago_entrada_materia_prima(), $_POST);
}

function pago_materia_prima_delete(...$args)
{
    delete(new Pago_entrada_materia_prima(), $_POST['id']);
}


