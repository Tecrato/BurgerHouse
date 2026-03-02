<?php

use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Vista;


function vistas_get_all(...$args)
{
    header('Content-Type: application/json');
    $_POST = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    // print_r($_POST);
    // print_r('------------------');
    $tabla = $_POST['nombre_vista'] ?? null;
    if (!$tabla) {
        echo json_encode(['error' => 'nombre_vista es requerido']);
        return;
    }
    $variables = (array)($_POST['variables'] ?? []);
    get_all(new Vista($tabla, $variables));
    
}

function vistas_check(...$args)
{
    check();
}