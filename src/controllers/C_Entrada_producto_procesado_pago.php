<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Pago_entrada_producto_procesado;


function entrada_producto_procesado_pago_get_all(...$args)
{
    get_all(new Pago_entrada_producto_procesado(), ...$args);
}

function entrada_producto_procesado_pago_add(...$args)
{
    add(new Pago_entrada_producto_procesado(), $_POST);
}

function entrada_producto_procesado_pago_add_many(...$args)
{
    add_many(new Pago_entrada_producto_procesado(), $_POST);
}

function entrada_producto_procesado_pago_update(...$args)
{
    update(new Pago_entrada_producto_procesado(), $_POST);
}

function entrada_producto_procesado_pago_delete(...$args)
{
    delete(new Pago_entrada_producto_procesado(), $_POST['id']);
}

function entrada_producto_procesado_pago_delete_many(...$args)
{
    delete_many(new Pago_entrada_producto_procesado(), $_POST['ids']);
}

function entrada_producto_procesado_pago_check(...$args)
{
    check(new Pago_entrada_producto_procesado(), $_POST['id']);
}

function entrada_producto_procesado_pago_total(...$args)
{
    total(new Pago_entrada_producto_procesado(), ...$args);
}

