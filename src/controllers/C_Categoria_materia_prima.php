<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Categoria_materia_prima as CategoriaMP;

function categoria_materia_prima_view(...$args)
{
    view('categoria_materia_prima');
}

function categoria_materia_prima_get_all(...$args)
{
    get_all(new CategoriaMP(), ...$args);
}

function categoria_materia_prima_add(...$args)
{
    add(new CategoriaMP(), $_POST);
}

function categoria_materia_prima_update(...$args)
{
    update(new CategoriaMP(), $_POST);
}

function categoria_materia_prima_delete(...$args)
{
    delete(new CategoriaMP(), $_POST['id']);
}

