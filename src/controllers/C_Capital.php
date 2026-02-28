<?php
require_once __DIR__ . '/Controller_base.php';
use Shtch\Burgerhouse\models\Movimiento_capital;
use Exception;

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
        $model = new Movimiento_capital();
        echo json_encode($model->consultar_vista("vista_resumen_financiero"));
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}


function capital_GetCapital(...) {
    // converted from CapitalController.php::GetCapital - please implement logic
    // TODO: migrate code from class method
}

