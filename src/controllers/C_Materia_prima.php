<?php
use Shtch\Burgerhouse\models\Materia_prima;
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

function materia_prima_view(...$args)
{
    view('materia_prima');
}

function materia_prima_get_all(...$args)
{
    get_all(new Materia_prima(), ...$args);
}

function materia_prima_add(...$args)
{
    add(new Materia_prima(), $_POST);
}

function materia_prima_update(...$args)
{
    update(new Materia_prima(), $_POST);
}

function materia_prima_delete(...$args)
{
    delete(new Materia_prima(), $_POST['id']);
}


