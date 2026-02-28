<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Movimiento_capital;
use Shtch\Burgerhouse\models\Vista;


function capital_view(...$args)
{
    view('capital');
}

function capital_get_all(...$args)
{
    get_all(new Movimiento_capital(), ...$args);
}

function capital_add(...$args)
{
    add(new Movimiento_capital(), $_POST);
}

function capital_update(...$args)
{
    update(new Movimiento_capital(), $_POST);
}

function capital_delete(...$args)
{
    delete(new Movimiento_capital(), $_POST['id']);
}

function capital_getCapital(...$args)
{
    header('Content-Type: application/json');
    try {
        $model = new Vista("vista_resumen_financiero");
        echo json_encode($model->search());
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}
