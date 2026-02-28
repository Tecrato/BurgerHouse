<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Unidad;

function unidad_view(...$args)
{
    view('unidad');
}

function unidad_get_all(...$args)
{
    get_all(new Unidad(), ...$args);
}

function unidad_add(...$args)
{
    add(new Unidad(), $_POST);
}

function unidad_update(...$args)
{
    update(new Unidad(), $_POST);
}

function unidad_delete(...$args)
{
    delete(new Unidad(), $_POST['id']);
}


