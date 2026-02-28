<?php


require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Usuario;


function login_view(...$args)
{
    view('login');
}

function login_get_all(...$args)
{
    $modelo = new Usuario();
    get_all($modelo, ...$args);
}

function login_sessionInfo(...$args) {
    echo json_encode([
        "success" => true,
        "message" => [
            "id" => $_SESSION['id'] ?? null,
            "nombre" => $_SESSION['nombre'] ?? null,
            "apellido" => $_SESSION['apellido'] ?? null,
            "correo" => $_SESSION['correo'] ?? null,
            "rol" => $_SESSION['rol'] ?? null,
            "permisos" => $_SESSION['permisos'] ?? []
        ]
    ]);
}
