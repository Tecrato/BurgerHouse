<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Categoria;

function categoria_view(...$args)
{
    view('categoria');
}

function categoria_get_all(...$args)
{
    get_all(new Categoria(), ...$args);
}

function categoria_add(...$args)
{
    add(new Categoria(), $_POST);
}

function categoria_update(...$args)
{
    update(new Categoria(), $_POST);
}

function categoria_delete(...$args)
{
    delete(new Categoria(), $_POST['id']);
}
