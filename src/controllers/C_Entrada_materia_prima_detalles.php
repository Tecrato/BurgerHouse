<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;

function detalle_entrada_materia_prima_view(...$args)
{
    view('detalle_entrada_materia_prima');
}

function detalle_entrada_materia_prima_get_all(...$args)
{
    get_all(new Detalle_entrada_materia_prima(), ...$args);
}

function detalle_entrada_materia_prima_add(...$args)
{
    add(new Detalle_entrada_materia_prima(), $_POST);
}

function detalle_entrada_materia_prima_update(...$args)
{
    update(new Detalle_entrada_materia_prima(), $_POST);
}

function detalle_entrada_materia_prima_delete(...$args)
{
    delete(new Detalle_entrada_materia_prima(), $_POST['id']);
}


