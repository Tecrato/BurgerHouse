<?php

namespace Shtch\Burgerhouse\models;

use Shtch\Burgerhouse\models\Db_base;
use PDO;
use Exception;

class Estadisticas extends Db_base
{
    public function __construct()
    {
        parent::__construct("vista_estadisticas");
    }
    public function GastoClienteSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL GastoClienteSemana(:anio, :semana)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function GastoClienteMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL gastoClienteMes(:anio, :mes)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function GastoClienteAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL gastoClienteAnual(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMasVendidoSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL productosMasVendidoSemana(:anio, :semana)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMasVendidosMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL productosMasVendidoMes(:anio, :mes)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMasVendidosAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL productosMasVendidoAnio(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }


    public function productosMenosVendidoSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL productosMenosVendidoSemana(:anio, :semana)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMenosVendidosMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL productosMenosVendidoMes(:anio, :mes)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function productosMenosVendidosAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL productosMenosVendidoAnio(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }


    public function totalVentaSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL TotalVentasSemana(:anio, :semana)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function totalVentaMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL TotalVentasMes(:anio, :mes)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function totalVentaAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL TotalVentasAnio(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function utilidadNetaSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL utilidadNetaSemana(:anio, :semana)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function utilidadNetaMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL utilidadNetaMes(:anio, :mes)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function utilidadNetaAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL utilidadNetaAnual(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }


    public function porcentajeReservasSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL porcentaje_reservaciones_semana(:semana, :anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function porcentajeReservasMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL porcentaje_reservaciones_mes(:mes, :anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function porcentajeReservasAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL porcentaje_reservaciones_anio(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }

    public function porcentajeReservasMetodoSemana(int $anio, int $semana)
    {
        try {
            $query = $this->conn->prepare("CALL ReservasPorMetodoSemana(:anio, :semana)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':semana', $semana, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function porcentajeReservasMetodoMes(int $anio, int $mes)
    {
        try {
            $query = $this->conn->prepare("CALL ReservasPorMetodoMes(:anio, :mes)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->bindValue(':mes', $mes, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
    public function porcentajeReservasMetodoAnio(int $anio)
    {
        try {
            $query = $this->conn->prepare("CALL ReservasPorMetodoAnual(:anio)");
            $query->bindValue(':anio', $anio, PDO::PARAM_INT);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }

    public function stats_ordenes(string $tipo)
    {
        try {
            $query = $this->conn->prepare("select count(`burgerhouse`.`orden`.`id`) AS `total`,sum((`burgerhouse`.`orden`.`status` = 'por verificar')) AS `por verificar`,sum((`burgerhouse`.`orden`.`status` = 'en cocina')) AS `en cocina`,sum((`burgerhouse`.`orden`.`status` = 'para despachar')) AS `para despachar`,sum((`burgerhouse`.`orden`.`status` = 'en camino')) AS `en camino`,sum((`burgerhouse`.`orden`.`status` = 'entregada')) AS `entregada`,sum((`burgerhouse`.`orden`.`status` = 'pagado')) AS `pagado`,sum((`burgerhouse`.`orden`.`status` = 'en mesa')) AS `en mesa`,sum((`burgerhouse`.`orden`.`status` = 'anulada')) AS `anulada`,sum((`burgerhouse`.`orden`.`status` = '1')) AS `terminada` from `burgerhouse`.`orden` where `burgerhouse`.`orden`.`tipo` = :tipo");
            $query->bindValue(':tipo', $tipo, PDO::PARAM_STR);
            $query->execute();
            return $query->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}
