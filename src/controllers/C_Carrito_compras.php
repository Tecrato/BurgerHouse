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



function carrito_compras_view(...$args) { return shoppingcart_view(...$args); }
function carrito_compras_get_all(...$args) { return shoppingcart_get_all(...$args); }
function carrito_compras_add(...$args) { return shoppingcart_add(...$args); }
function carrito_compras_update(...$args) { return shoppingcart_update(...$args); }
function carrito_compras_delete(...$args) { return shoppingcart_delete(...$args); }
