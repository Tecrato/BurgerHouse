<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Vista;

function home_view(...$args)
{
    view('index');
}

function home_ClientesFrecuentes(...$args)
{
    header('Content-Type: application/json');
    try {
        $model = new Vista("vista_resumen_clientes");
        echo json_encode($model->search());
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}