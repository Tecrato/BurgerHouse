<?php
require_once __DIR__ . '/Controller_base.php';

use Shtch\Burgerhouse\models\Estadisticas;

function estadisticas_conn()
{
    return new Estadisticas();
}

function statistics_gastoClienteSemana(...$args) { echo json_encode(estadisticas_conn()->GastoClienteSemana($_POST['anio'], $_POST['semana'])); }
function statistics_gastoClienteMes(...$args) { echo json_encode(estadisticas_conn()->gastoClienteMes($_POST['anio'], $_POST['mes'])); }
function statistics_gastoClienteAnual(...$args) { echo json_encode(estadisticas_conn()->gastoClienteAnio($_POST['anio'])); }
function statistics_productosMasVendidoSemana(...$args) { echo json_encode(estadisticas_conn()->productosMasVendidoSemana($_POST['anio'], $_POST['semana'])); }
function statistics_productosVendidosMes(...$args) { echo json_encode(estadisticas_conn()->productosMasVendidosMes($_POST['anio'], $_POST['mes'])); }
function statistics_productosVendidosAnual(...$args) { echo json_encode(estadisticas_conn()->productosMasVendidosAnio($_POST['anio'])); }
function statistics_productosMenosVendidosSemana(...$args) { echo json_encode(estadisticas_conn()->productosMenosVendidoSemana($_POST['anio'], $_POST['semana'])); }
function statistics_productosMenosVendidosMes(...$args) { echo json_encode(estadisticas_conn()->productosMenosVendidosMes($_POST['anio'], $_POST['mes'])); }
function statistics_productosMenosVendidosAnual(...$args) { echo json_encode(estadisticas_conn()->productosMenosVendidosAnio($_POST['anio'])); }
function statistics_totalVentaSemana(...$args) { echo json_encode(estadisticas_conn()->totalVentaSemana($_POST['anio'], $_POST['semana'])); }
function statistics_totalVentaMes(...$args) { echo json_encode(estadisticas_conn()->totalVentaMes($_POST['anio'], $_POST['mes'])); }
function statistics_totalVentaAnio(...$args) { echo json_encode(estadisticas_conn()->totalVentaAnio($_POST['anio'])); }
function statistics_utilidadNetaSemana(...$args) { echo json_encode(estadisticas_conn()->utilidadNetaSemana($_POST['anio'], $_POST['semana'])); }
function statistics_utilidadNetaMes(...$args) { echo json_encode(estadisticas_conn()->utilidadNetaMes($_POST['anio'], $_POST['mes'])); }
function statistics_utilidadNetaAnio(...$args) { echo json_encode(estadisticas_conn()->utilidadNetaAnio($_POST['anio'])); }
function statistics_ReservaHorarioSemana(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasSemana($_POST['anio'], $_POST['semana'])); }
function statistics_ReservaHorarioMes(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMes($_POST['anio'], $_POST['mes'])); }
function statistics_ReservaHorarioAnio(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasAnio($_POST['anio'])); }
function statistics_ReservasPorMetodoSemana(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMetodoSemana($_POST['anio'], $_POST['semana'])); }
function statistics_ReservasPorMetodoMes(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMetodoMes($_POST['anio'], $_POST['mes'])); }
function statistics_ReservasPorMetodoAnio(...$args) { echo json_encode(estadisticas_conn()->porcentajeReservasMetodoAnio($_POST['anio'])); }

// Compatibilidad con el nombre de módulo C_Estadisticas
function estadisticas_gastoClienteSemana(...$args) { return statistics_gastoClienteSemana(...$args); }
function estadisticas_gastoClienteMes(...$args) { return statistics_gastoClienteMes(...$args); }
function estadisticas_gastoClienteAnual(...$args) { return statistics_gastoClienteAnual(...$args); }
function estadisticas_productosMasVendidoSemana(...$args) { return statistics_productosMasVendidoSemana(...$args); }
function estadisticas_productosVendidosMes(...$args) { return statistics_productosVendidosMes(...$args); }
function estadisticas_productosVendidosAnual(...$args) { return statistics_productosVendidosAnual(...$args); }
function estadisticas_productosMenosVendidosSemana(...$args) { return statistics_productosMenosVendidosSemana(...$args); }
function estadisticas_productosMenosVendidosMes(...$args) { return statistics_productosMenosVendidosMes(...$args); }
function estadisticas_productosMenosVendidosAnual(...$args) { return statistics_productosMenosVendidosAnual(...$args); }
function estadisticas_totalVentaSemana(...$args) { return statistics_totalVentaSemana(...$args); }
function estadisticas_totalVentaMes(...$args) { return statistics_totalVentaMes(...$args); }
function estadisticas_totalVentaAnio(...$args) { return statistics_totalVentaAnio(...$args); }
function estadisticas_utilidadNetaSemana(...$args) { return statistics_utilidadNetaSemana(...$args); }
function estadisticas_utilidadNetaMes(...$args) { return statistics_utilidadNetaMes(...$args); }
function estadisticas_utilidadNetaAnio(...$args) { return statistics_utilidadNetaAnio(...$args); }
function estadisticas_ReservaHorarioSemana(...$args) { return statistics_ReservaHorarioSemana(...$args); }
function estadisticas_ReservaHorarioMes(...$args) { return statistics_ReservaHorarioMes(...$args); }
function estadisticas_ReservaHorarioAnio(...$args) { return statistics_ReservaHorarioAnio(...$args); }
function estadisticas_ReservasPorMetodoSemana(...$args) { return statistics_ReservasPorMetodoSemana(...$args); }
function estadisticas_ReservasPorMetodoMes(...$args) { return statistics_ReservasPorMetodoMes(...$args); }
function estadisticas_ReservasPorMetodoAnio(...$args) { return statistics_ReservasPorMetodoAnio(...$args); }
