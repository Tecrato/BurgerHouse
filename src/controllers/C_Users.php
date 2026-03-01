<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Usuario;


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
    total(new Usuario(), ...$args);
}

function users_add(...$args)
{
    if (!empty($_POST['hash'])) {
        $_POST['hash'] = password_hash($_POST['hash'], PASSWORD_DEFAULT);
    }
    add(new Usuario(), $_POST);
}

function users_add_many(...$args)
{
    if (!isset($_POST['lista']) || !is_array($_POST['lista'])) {
        echo json_encode(['success' => false, 'message' => 'Lista de usuarios inválida']);
        return;
    }

    foreach ($_POST['lista'] as $index => $user) {
        if (empty($user['hash'])) {
            echo json_encode(['success' => false, 'message' => "La contraseña del usuario #{$index} es requerida"]);
            return;
        }
        $_POST['lista'][$index]['hash'] = password_hash($user['hash'], PASSWORD_DEFAULT);
    }

    add_many(new Usuario(), $_POST);
}

function users_update(...$args)
{
    if (array_key_exists('hash', $_POST)) {
        if (trim((string)$_POST['hash']) === '') {
            unset($_POST['hash']);
        } else {
            $_POST['hash'] = password_hash($_POST['hash'], PASSWORD_DEFAULT);
        }
    }
    update(new Usuario(), $_POST);
}

function users_delete(...$args)
{
    delete(new Usuario(), $_POST['id']);
}

