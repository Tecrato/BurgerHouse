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



function unidades_view(...$args) { return unidad_view(...$args); }
function unidades_get_all(...$args) { return unidad_get_all(...$args); }
function unidades_add(...$args) { return unidad_add(...$args); }
function unidades_update(...$args) { return unidad_update(...$args); }
function unidades_delete(...$args) { return unidad_delete(...$args); }
