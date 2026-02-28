<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

use Shtch\Burgerhouse\models\DetalleOrdenProductoProcesado;

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
