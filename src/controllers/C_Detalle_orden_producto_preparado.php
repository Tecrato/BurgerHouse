<?php
require_once __DIR__ . '/Controller_base.php';

use Shtch\Burgerhouse\models\DetalleOrdenProductoPreparado;

function detalle_orden_producto_preparado_view(...$args)
{
    view('detalle_orden_producto_preparado');
}

function detalle_orden_producto_preparado_get_all(...$args)
{
    get_all(new DetalleOrdenProductoPreparado(), ...$args);
}

function detalle_orden_producto_preparado_add(...$args)
{
    add(new DetalleOrdenProductoPreparado(), $_POST);
}

function detalle_orden_producto_preparado_update(...$args)
{
    update(new DetalleOrdenProductoPreparado(), $_POST);
}

function detalle_orden_producto_preparado_delete(...$args)
{
    delete(new DetalleOrdenProductoPreparado(), $_POST['id']);
}
