<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\ProductoProcesado;

function producto_procesado_view(...$args)
{
    view('producto_procesado');
}

function producto_procesado_get_all(...$args)
{
    get_all(new ProductoProcesado(), ...$args);
}

function producto_procesado_add(...$args)
{
    add(new ProductoProcesado(), $_POST);
}

function producto_procesado_update(...$args)
{
    update(new ProductoProcesado(), $_POST);
}

function producto_procesado_delete(...$args)
{
    delete(new ProductoProcesado(), $_POST['id']);
}

