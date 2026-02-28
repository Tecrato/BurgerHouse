<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Delivery;

function delivery_view(...$args)
{
    view('delivery');
}

function delivery_get_all(...$args)
{
    get_all(new Delivery(), ...$args);
}

function delivery_add(...$args)
{
    add(new Delivery(), $_POST);
}

function delivery_update(...$args)
{
    update(new Delivery(), $_POST);
}

function delivery_delete(...$args)
{
    delete(new Delivery(), $_POST['id']);
}


