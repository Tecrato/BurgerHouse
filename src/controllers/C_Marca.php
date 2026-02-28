<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Marca;

function marca_view(...$args)
{
    view('brand');
}

function marca_get_all(...$args)
{
    get_all(new Marca(), ...$args);
}

function marca_add(...$args)
{
    add(new Marca(), $_POST);
}

function marca_update(...$args)
{
    update(new Marca(), $_POST);
}

function marca_delete(...$args)
{
    delete(new Marca(), $_POST['id']);
}


