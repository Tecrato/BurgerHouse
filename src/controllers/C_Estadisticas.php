<?php
use function Shtch\Burgerhouse\controllers\{view, add, add_many, get_all, update, update_many, delete, delete_many, check, guardar_imagen_mult, guardar_imagen_single, total};

use Shtch\Burgerhouse\models\Estadisticas;

function estadisticas_view(...$args)
{
    view('estadisticas');
}

function estadisticas_conn()
{
    return new Estadisticas();
}

function estadisticas_gastoClienteSemana(...$args) { echo json_encode(estadisticas_conn()->GastoClienteSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_gastoClienteMes(...$args) { echo json_encode(estadisticas_conn()->gastoClienteMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_gastoClienteAnual(...$args) { echo json_encode(estadisticas_conn()->gastoClienteAnio($_POST['anio'])); }
function estadisticas_productosMasVendidoSemana(...$args) { echo json_encode(estadisticas_conn()->productosMasVendidoSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_productosVendidosMes(...$args) { echo json_encode(estadisticas_conn()->productosMasVendidosMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_productosVendidosAnual(...$args) { echo json_encode(estadisticas_conn()->productosMasVendidosAnio($_POST['anio'])); }
function estadisticas_productosMenosVendidosSemana(...$args) { echo json_encode(estadisticas_conn()->productosMenosVendidoSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_productosMenosVendidosMes(...$args) { echo json_encode(estadisticas_conn()->productosMenosVendidosMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_productosMenosVendidosAnual(...$args) { echo json_encode(estadisticas_conn()->productosMenosVendidosAnio($_POST['anio'])); }
function estadisticas_totalVentaSemana(...$args) { echo json_encode(estadisticas_conn()->totalVentaSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_totalVentaMes(...$args) { echo json_encode(estadisticas_conn()->totalVentaMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_totalVentaAnio(...$args) { echo json_encode(estadisticas_conn()->totalVentaAnio($_POST['anio'])); }
function estadisticas_utilidadNetaSemana(...$args) { echo json_encode(estadisticas_conn()->utilidadNetaSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_utilidadNetaMes(...$args) { echo json_encode(estadisticas_conn()->utilidadNetaMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_utilidadNetaAnio(...$args) { echo json_encode(estadisticas_conn()->utilidadNetaAnio($_POST['anio'])); }
function estadisticas_ReservaHorarioSemana(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_ReservaHorarioMes(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_ReservaHorarioAnio(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasAnio($_POST['anio'])); }
function estadisticas_ReservasPorMetodoSemana(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMetodoSemana($_POST['anio'], $_POST['semana'])); }
function estadisticas_ReservasPorMetodoMes(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMetodoMes($_POST['anio'], $_POST['mes'])); }
function estadisticas_ReservasPorMetodoAnio(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMetodoAnio($_POST['anio'])); }

// Compatibilidad con el nombre de módulo C_Estadisticas

