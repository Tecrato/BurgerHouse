<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\ProductoProcesado as Adicionales;

function bebidas_view(...$args)
{
    view('bebidas');
}

function bebidas_add(...$args)
{
    add(new Adicionales(), $_POST);
}

function bebidas_delete(...$args)
{
    delete(new Adicionales());
}

function bebidas_delete_many(...$args)
{
    delete_many(new Adicionales());
}

function bebidas_add_many(...$args)
{
    add_many(new Adicionales());
}

function bebidas_update(...$args)
{
    update(new Adicionales(), $_POST);
}
function bebidas_update_many(...$args)
{
    update_many(new Adicionales());
}

function bebidas_get_all(...$args)
{
    get_all(new Adicionales(), ...$args);
}

function bebidas_check(...$args)
{
    check();
}

function bebidas_total(...$args)
{
    total(new Adicionales(), ...$args);
}