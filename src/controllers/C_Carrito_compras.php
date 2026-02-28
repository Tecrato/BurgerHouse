<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\ShoppingCart;

function shoppingcart_view(...$args)
{
    view('ShoppingCart');
}

function shoppingcart_get_all(...$args)
{
    get_all(new ShoppingCart(), ...$args);
}

function shoppingcart_add(...$args)
{
    add(new ShoppingCart(), $_POST);
}

function shoppingcart_update(...$args)
{
    update(new ShoppingCart(), $_POST);
}

function shoppingcart_delete(...$args)
{
    delete(new ShoppingCart(), $_POST['id']);
}


