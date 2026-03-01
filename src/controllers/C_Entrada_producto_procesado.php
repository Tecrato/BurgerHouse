<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};
use Shtch\Burgerhouse\models\Entrada_producto_procesado;
use Shtch\Burgerhouse\models\Pago_entrada_producto_procesado;
use Shtch\Burgerhouse\models\Vista;

function entrada_producto_procesado_add_many(...$args)
{
    try {
        $pago_producto_procesado = new Pago_entrada_producto_procesado();
        $lista_entrada = $_POST['lista']["detalles_entrada"];

        for ($i = 0; $i < count($lista_entrada); $i++) {
            $db = new Entrada_producto_procesado();
            $db->clear();
            $db->__construct(
                id_proveedor: $lista_entrada[$i]["id_proveedor"],
                id_producto: $lista_entrada[$i]["id_producto"],
                id_unidad: $lista_entrada[$i]["id_unidad"],
                cantidad: $lista_entrada[$i]["cantidad"],
                existencia: $lista_entrada[$i]["existencia"],
                codigo: $lista_entrada[$i]["codigo"],
                fecha_vencimiento: $lista_entrada[$i]["fecha_vencimiento"]
            );
            $last_id = $db->agregar();
            for ($j = 0; $j < count($lista_entrada[$i]["payment"]); $j++) {
                $pago_producto_procesado->clear();
                $pago_producto_procesado->__construct(...["id_entrada" => $last_id, ...$lista_entrada[$i]["payment"][$j]]);
                is_dir("../src/media/pay_entrys_product_process") or mkdir("../src/media/pay_entrys_product_process");
                $imagen = $_FILES["lista"];
                move_uploaded_file($imagen['tmp_name']["detalles_entrada"][$i]["payment"][$j]["imagen"], "../src/media/pay_entrys_product_process" . '/' . $imagen['name']["detalles_entrada"][$i]["payment"][$j]["imagen"]);
                $pago_producto_procesado->agregar();
            }
        }
        echo json_encode(['success' => true]);
    } catch (Exception $th) {
        echo json_encode(['success' => false, 'message' => $th->getMessage()]);
    }
}

function entrada_producto_procesado_inventario(...$args)
{
    try {
        $db = new Vista("vista_inventario_productos_procesados");
        $db->clear();
        $db->__construct();
        echo json_encode($db->search());
    } catch (Exception $th) {
        echo json_encode(['success' => false, 'message' => $th->getMessage()]);
    }
}
