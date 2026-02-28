<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Credito;

function credito_view(...$args)
{
    view('credito');
}

function credito_get_all(...$args)
{
    get_all(new Credito(), ...$args);
}

function credito_add(...$args)
{
    add(new Credito(), $_POST);
}

function credito_update(...$args)
{
    update(new Credito(), $_POST);
}

function credito_delete(...$args)
{
    delete(new Credito(), $_POST['id']);
}


