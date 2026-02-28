<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Mesa;

function mesa_view(...$args)
{
    view('mesa');
}

function mesa_get_all(...$args)
{
    get_all(new Mesa(), ...$args);
}

function mesa_add(...$args)
{
    add(new Mesa(), $_POST);
}

function mesa_update(...$args)
{
    update(new Mesa(), $_POST);
}

function mesa_delete(...$args)
{
    delete(new Mesa(), $_POST['id']);
}


