<?php

namespace Shtch\Burgerhouse\controllers;

use Shtch\Burgerhouse\controllers\Controller_base;
use Shtch\Burgerhouse\models\Estadisticas;
use Exception;

class StatisticsController extends Controller_base
{
    private $conn;
    public function __construct()
    {
        parent::__construct("statistics");
        $this->conn = new Estadisticas();
    }
    public function gastoClienteSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->GastoClienteSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function gastoClienteMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->gastoClienteMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function gastoClienteAnual()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->gastoClienteAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMasVendidoSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->productosMasVendidoSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosVendidosMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->productosMasVendidosMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosVendidosAnual()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->productosMasVendidosAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }


    public function productosMenosVendidosSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->productosMenosVendidoSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMenosVendidosMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->productosMenosVendidosMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMenosVendidosAnual()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->productosMenosVendidosAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }


    public function totalVentaSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->totalVentaSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function totalVentaMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->totalVentaMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function totalVentaAnio()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->totalVentaAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function utilidadNetaSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->utilidadNetaSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function utilidadNetaMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->utilidadNetaMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function utilidadNetaAnio()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->utilidadNetaAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }


    public function ReservaHorarioSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->porcentajeReservasSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function ReservaHorarioMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->porcentajeReservasMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function ReservaHorarioAnio()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->porcentajeReservasAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }

    public function ReservasPorMetodoSemana()
    {
        try {
            $anio = $_POST['anio'];
            $semana = $_POST['semana'];
            echo json_encode($this->conn->porcentajeReservasMetodoSemana($anio, $semana));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function ReservasPorMetodoMes()
    {
        try {
            $anio = $_POST['anio'];
            $mes = $_POST['mes'];
            echo json_encode($this->conn->porcentajeReservasMetodoMes($anio, $mes));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function ReservasPorMetodoAnio()
    {
        try {
            $anio = $_POST['anio'];
            echo json_encode($this->conn->porcentajeReservasMetodoAnio($anio));
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}
