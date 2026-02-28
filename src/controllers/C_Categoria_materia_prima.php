<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Categoria_materia_prima as CategoriaMP;

function categoria_materia_prima_view(...$args)
{
    view('categoria');
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

