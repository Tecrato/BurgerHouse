<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Usuario;

// generated procedural controller for users.  original class only set up the
// model; we now provide the usual set of actions that the frontend expects.

function users_view(...$args)
{
    view('users');
}

function users_get_all(...$args)
{
    get_all(new Usuario(), ...$args);
}

function users_count(...$args)
{
    header('Content-Type: application/json');
    try {
        $model = new Usuario();
        $model->clear();
        $model->__construct(...$_POST);
        echo json_encode($model->count());
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function users_add(...$args)
{
    add(new Usuario(), $_POST);
}

function users_update(...$args)
{
    update(new Usuario(), $_POST);
}

function users_delete(...$args)
{
    delete(new Usuario(), $_POST['id']);
}

