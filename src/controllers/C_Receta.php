<?php
require_once __DIR__ . '/Controller_base.php';

use Shtch\Burgerhouse\models\Detalle_receta;
use Shtch\Burgerhouse\models\Receta;

function recipe_add(...$args)
{
    header('Content-Type: application/json');
    $receta = new Receta();

    try {
        $receta->clear();
        $receta->__construct(id_producto: $_POST['id_producto']);
        $last_id = $receta->agregar();

        for ($i = 0; $i < count($_POST['lista']); $i++) {
            $detalle = new Detalle_receta(...['id_receta' => $last_id, ...$_POST['lista'][$i]]);
            $detalle->agregar();
        }

        echo json_encode(['success' => true, 'last_id' => $last_id]);
    } catch (Exception $e) {
        try {
            if ($receta->conn->inTransaction()) {
                $receta->conn->rollBack();
            }
        } catch (Throwable $th) {
        }

        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function receta_add(...$args)
{
    return recipe_add(...$args);
}
