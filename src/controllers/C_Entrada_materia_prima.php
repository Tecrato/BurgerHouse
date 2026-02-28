<?php
use function Shtch\Burgerhouse\controllers\{add, add_many, get_all, update, view};
use Shtch\Burgerhouse\models\Entrada_materia_prima;
use Shtch\Burgerhouse\models\Detalle_entrada_materia_prima;
use Shtch\Burgerhouse\models\Pago_entrada_materia_prima;
use Shtch\Burgerhouse\models\Vista;


function entrada_materia_prima_brokenear_materia(...$args)
{
    $db = new Entrada_materia_prima(id: $_POST['id']);
    $r = $db->search()[0];
    $existencia = $r['existencia'] - $_POST['cantidad'];
    $broken = $r['broken'] + $_POST['cantidad'];
    $db->clear();
    $db->__construct(id: $_POST['id'], existencia: $existencia, broken: $broken);
    $result = $db->actualizar();
    if ($result['success'] == false) {
        echo json_encode(['success' => false, 'message' => $result['message']]);
        return;
    }

    echo json_encode(['success' => true]);
}

function entrada_materia_prima_add_many(...$args)
{
    try {
        $pago_materia_prima = new Pago_entrada_materia_prima();
        $detalle_entrada = new Detalle_entrada_materia_prima();
        $lista_entrada = $_POST['lista']["info_entrada"];

        foreach ($lista_entrada as $key => $value) {
            $db = new Entrada_materia_prima(id_proveedor: $value["id_proveedor"]);
            $last_id = $db->agregar();
            $pago_materia_prima->clear();

            foreach ($value["payment"] as $key2 => $value2) {
                $pago_materia_prima->__construct(...["id_entrada" => $last_id, ...$value["payment"][$key2]]);
                $pago_materia_prima->agregar();
            }

            $imagen = $_FILES["lista"];
            foreach ($imagen['tmp_name']['info_entrada'][$key]["payment"] as $key3 => $value3) {
                move_uploaded_file($value3["imagen"], "../src/media/pay_entrys_rawmaterial" . '/' . $imagen['name']['info_entrada'][$key]["payment"][$key3]["imagen"]);
            }

            foreach ($value["detalles_entrada"] as $value2) {
                $detalle_entrada->clear();
                $detalle_entrada->__construct(
                    id_materia_prima: $value2["id_materia_prima"],
                    id_entrada: $last_id,
                    cantidad: $value2["cantidad"],
                    codigo: $value2["codigo"],
                    fecha_vencimiento: $value2["fecha_vencimiento"],
                    existencia: $value2["existencia"],
                );
                $detalle_entrada->agregar();
            }
        }

        echo json_encode(['success' => true]);
    } catch (Exception $th) {
        echo json_encode(['success' => false, 'message' => $th->getMessage()]);
    }
}

function entrada_materia_prima_inventario(...$args)
{
    try {
        $db = new Vista("vista_inventario_materia_prima");
        $db->clear();
        $db->__construct();
        echo json_encode($db->search());
    } catch (Exception $th) {
        echo json_encode(['success' => false, 'message' => $th->getMessage()]);
    }
}
