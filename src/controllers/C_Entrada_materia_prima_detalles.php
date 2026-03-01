<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;


function entrada_materia_prima_detalles_get_all(...$args)
{
    get_all(new Detalle_entrada_materia_prima(), ...$args);
}

function entrada_materia_prima_detalles_add(...$args)
{
    add(new Detalle_entrada_materia_prima(), $_POST);
}

function entrada_materia_prima_detalles_add_many(...$args)
{
    add_many(new Detalle_entrada_materia_prima(), $_POST);
}

function entrada_materia_prima_detalles_update(...$args)
{
    update(new Detalle_entrada_materia_prima(), $_POST);
}

function entrada_materia_prima_detalles_delete(...$args)
{
    delete(new Detalle_entrada_materia_prima(), $_POST['id']);
}


function entrada_materia_prima_detalles_delete_many(...$args)
{
    delete_many(new Detalle_entrada_materia_prima(), $_POST['ids']);
}

function entrada_materia_prima_detalles_check(...$args)
{
    check(new Detalle_entrada_materia_prima(), $_POST['id']);
}

function entrada_materia_prima_detalles_total(...$args)
{
    total(new Detalle_entrada_materia_prima(), ...$args);
}