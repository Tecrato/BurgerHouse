<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\ProductoPreparado;

function productprepared_view(...$args)
{
    view('productPrepared');
}

function productprepared_get_all(...$args)
{
    get_all(new ProductoPreparado(), ...$args);
}

function productprepared_add(...$args)
{
    add(new ProductoPreparado(), $_POST);
}

function productprepared_update(...$args)
{
    update(new ProductoPreparado(), $_POST);
}

function productprepared_delete(...$args)
{
    delete(new ProductoPreparado(), $_POST['id']);
}


