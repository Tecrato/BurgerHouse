<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

use Shtch\Burgerhouse\models\Detalle_receta;
use Shtch\Burgerhouse\models\Receta;

function recetas_view(...$args)
{
    view('recetas');
}
function recetas_add(...$args)
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

function recetas_get_all(...$args)
{
    get_all(new Receta(), ...$args);
}

