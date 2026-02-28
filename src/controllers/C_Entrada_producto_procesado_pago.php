<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Pago_entrada_producto_procesado;

function entrada_producto_procesado_pago_view(...$args)
{
    view('pay_entrys_product_process');
}

function entrada_producto_procesado_pago_get_all(...$args)
{
    get_all(new Pago_entrada_producto_procesado(), ...$args);
}

function entrada_producto_procesado_pago_add(...$args)
{
    add(new Pago_entrada_producto_procesado(), $_POST);
}

function entrada_producto_procesado_pago_update(...$args)
{
    update(new Pago_entrada_producto_procesado(), $_POST);
}

function entrada_producto_procesado_pago_delete(...$args)
{
    delete(new Pago_entrada_producto_procesado(), $_POST['id']);
}


