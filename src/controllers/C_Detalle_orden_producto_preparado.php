<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

use Shtch\Burgerhouse\models\DetalleOrdenProductoPreparado;

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
