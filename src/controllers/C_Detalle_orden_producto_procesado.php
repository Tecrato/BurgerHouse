<?php
require_once __DIR__ . '/Controller_base.php';

use Shtch\Burgerhouse\models\DetalleOrdenProductoProcesado;

function detalle_orden_producto_procesado_view(...$args)
{
    view('detalle_orden_producto_procesado');
}

function detalle_orden_producto_procesado_get_all(...$args)
{
    get_all(new DetalleOrdenProductoProcesado(), ...$args);
}

function detalle_orden_producto_procesado_add(...$args)
{
    add(new DetalleOrdenProductoProcesado(), $_POST);
}

function detalle_orden_producto_procesado_update(...$args)
{
    update(new DetalleOrdenProductoProcesado(), $_POST);
}

function detalle_orden_producto_procesado_delete(...$args)
{
    delete(new DetalleOrdenProductoProcesado(), $_POST['id']);
}
