<?php

namespace Shtch\Burgerhouse\models;

use Shtch\Burgerhouse\models\Conexion;
use Exception;
use PDO;

abstract class Db_base extends Conexion
{
    // Ejemplo
    // $this->add_variables([
    //      "id" => $this->id,
    //      "nombre"=> $this->nombre,
    //      ...
    // ]);
    // $this->add_variables_like([
    //     "nombre" => $this->like
    // ]);
    // $this->add_variables_interval([
    //     "a.fecha" => $this->between_fecha
    // ]);
    // $this->tabla = 'productos';
    // $this->select_query = "
    //     a.id,
    //     a.id_categoria,
    //     b.nombre categoria,
    //     a.id_unidad,
    //     c.nombre unidad,
    //     a.nombre,
    //     a.id_marca,
    //     m.nombre marca,
    //     a.valor_unidad,
    //     a.imagen,
    //     (SELECT SUM(entradas_2.existencia) FROM entradas_2 Where id_producto = a.id AND entradas_2.fecha_vencimiento > NOW()) as stock,
    //     a.stock_min,
    //     a.stock_max,
    //     a.precio_venta,
    //     a.IVA,
    //     a.codigo
    // ";
    // $this->joins = '
    //     INNER JOIN categoria b ON b.id = a.id_categoria 
    //     INNER JOIN unidades c ON c.id = a.id_unidad
    //     INNER JOIN marcas m ON m.id = a.id_marca 
    // ';
    public $variables;
    public $variables_like;
    public $variables_interval;
    public $tabla;
    public $joins;
    public $select_query;
    public $validaciones;
    public function __construct($tabla = "", $db_n = 1)
    {
        $this->variables = array();
        $this->tabla = $tabla;
        $this->variables_like = array();
        $this->joins = "";
        $this->select_query = " a.* ";
        $this->variables_interval = array();
        Conexion::__construct($db_n);
    }
    public function add_variables(array $variables): void
    {
        foreach ($variables as $key => $value) {
            $fieldName = trim((string)$key);
            if (str_contains($fieldName, '.')) {
                $parts = explode('.', $fieldName);
                $fieldName = trim((string)end($parts));
            }

            if ($fieldName === '') {
                throw new Exception("Clave de variable invalida");
            }

            if ($value == null) {
                unset($this->variables[$key]);
                continue;
            }
            
            $regex = $GLOBALS['expresiones_regulares'][$fieldName] ?? null;
            
            if ($fieldName === 'imagen' && is_array($value)) {
                $permitidos = ["image/jpeg", "image/jpg", "image/png", "image/gif"];
                if (in_array($value["type"], $permitidos)) {
                    $this->variables[$key] = $value;
                } else {
                    throw new Exception("Error al validar imagen");
                }
            } elseif ($regex) {
                if (preg_match($regex, $value)) {
                    $this->variables[$key] = $value;
                } else {
                    throw new Exception("Error al validar $key($value)");
                }
            } else {
                $this->variables[$key] = $value;
            }
        }
    }
    public function add_variables_like(array $variables): void
    {
        $this->variables_like = array_filter($variables, fn($value) => (!is_null($value) and !is_array($value)));
    }
    public function add_variables_interval(array $variables): void
    {
        $this->variables_interval = array_filter($variables, fn($value) => (!is_null($value) and is_array($value)));
    }

    public function clear(): void
    {
        $this->variables = array();
        $this->variables_like = array();
        $this->variables_interval = array();
    }

    private function normalizeKey($key)
    {
        if (str_contains($key, '.')) {
            // return explode(".", $key)[1];
            return implode("", explode(".", $key));
        }
        return $key;
    }
    private function normalizeKey2($key)
    {
        if (str_contains($key, '.')) {
            return explode(".", $key)[1];
            // return implode("",explode(".", $key));
        }
        return $key;
    }
    public function agregar(): int
    {
        $lista_vars = array();
        foreach ($this->variables as $key => $value) {
            $lista_vars[$this->normalizeKey2($key)] = $value;
        }
        $sql = "INSERT INTO " . $this->tabla . "(";
        $sql .= implode(",", array_keys($lista_vars));
        $sql .= ") VALUES(:";
        $sql .= implode(",:", array_keys($lista_vars));
        $sql .= ") ";

        // echo "\n";
        // echo "linea 100";
        // echo "Consulta SQL: " . $sql . "\n";
        // print_r($lista_vars);
        // print_r($_POST);
        // $sql = str_replace("a.", "", $sql);
        // print_r($sql);
        $query = $this->conn->prepare($sql);
        $query->execute($lista_vars);
        return $this->conn->lastInsertId();
    }
    public function actualizar(): array
    {
        if ((!isset($this->variables['a.id']) or $this->variables['a.id'] == null) and
            (!isset($this->variables['id']) or $this->variables['id'] == null)
        ) {
            return ['success' => false, 'message' => 'No se pudo actualizar el registro, falta el id'];
        }
        $lista_vars = array();
        foreach ($this->variables as $key => $value) {
            $lista_vars[$this->normalizeKey2($key)] = $value;
        }
        $sql = "UPDATE $this->tabla SET ";
        foreach ($lista_vars as $key => $value) {
            if ($key == 'id') {
                continue;
            }
            $sql .= "$key=:$key, ";
        }
        $sql = substr($sql, 0, -2);
        $sql .= " WHERE id=:id";
        $query = $this->conn->prepare($sql);
        try {
            return ['success' => true, 'message' => $query->execute($lista_vars)];
        } catch (Exception $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }
    public function borrar(): bool
    {
        try {
            $query = $this->conn->prepare("DELETE FROM $this->tabla WHERE id=:id");
            if (!isset($this->variables['a.id'])) {
                return false;
            }
            $query->bindValue(':id', $this->variables['a.id'], PDO::PARAM_INT);
            return $query->execute();
        } catch (Exception $e) {
            return 0;
        }
    }
    public function search( int $n = 0, int $limite = 9, string $order_by = 'a.id', string $order_type = 'ASC'): array
    {
        $query = "SELECT $this->select_query FROM $this->tabla AS a $this->joins WHERE 1";

        $first_like = true;
        foreach ($this->variables_like as $key => $value) {
            if ($first_like) {
                $query .= ' AND (';
                $first_like = false;
            } else {
                $query .= ' OR ';
            }
            $query .= $key . ' LIKE :like' . $this->normalizeKey($key);
        }
        if (!$first_like) {
            $query .= ')';
        }
        foreach ($this->variables as $key => $value) {
            $query .= ' AND ' . $key . ' = :' . $this->normalizeKey($key);
        }
        foreach ($this->variables_interval as $key => $value) {
            $query .= ' AND ' . $key . ' BETWEEN :' . $this->normalizeKey($key) . ' AND :' . $this->normalizeKey($key) . '2';
        }

        // Validación genérica para order_by
        $order_by_clean = str_replace('a.', '', $order_by);
        
        // Verificar si la columna existe en la tabla (método más seguro)
        try {
            $columns_query = $this->conn->prepare("DESCRIBE $this->tabla");
            $columns_query->execute();
            $table_columns = $columns_query->fetchAll(PDO::FETCH_COLUMN);
            
            if (in_array($order_by_clean, $table_columns) && in_array(strtoupper($order_type), ['ASC', 'DESC'])) {
                // Usar alias 'a' si existe en la consulta, sino usar nombre directo
                if (str_contains($query, 'FROM ' . $this->tabla . ' AS a')) {
                    $query .= " ORDER BY a.$order_by_clean $order_type";
                } else {
                    $query .= " ORDER BY $order_by_clean $order_type";
                }
            }
        } catch (Exception $e) {
            // Si falla la consulta DESCRIBE, usar fallback simple
            if (in_array(strtoupper($order_type), ['ASC', 'DESC'])) {
                if (str_contains($query, 'FROM ' . $this->tabla . ' AS a')) {
                    $query .= " ORDER BY a.$order_by_clean $order_type";
                } else {
                    $query .= " ORDER BY $order_by_clean $order_type";
                }
            }
        }

        $query .= " LIMIT :l OFFSET :n ";

        // print_r("\n");
        // print_r($order_by);
        // print_r("\n");
        // print_r($order_type);
        // print_r("\n");
        // print_r($query);
        // Creamos la consulta
        $consulta = $this->conn->prepare($query);
        // Asignamos los parametros   
        // print_r($this->variables);
        foreach ($this->variables as $key => $value) {
            $consulta->bindValue(':' . $this->normalizeKey($key), $value);
        }
        foreach ($this->variables_like as $key => $value) {
            $value2 = '%' . $value . '%';
            $consulta->bindValue(':like' . $this->normalizeKey($key), $value2, PDO::PARAM_STR);
        }
        foreach ($this->variables_interval as $key => $value) {
            $consulta->bindValue(':' . $this->normalizeKey($key), $value["inicio"]);
            $consulta->bindValue(':' . $this->normalizeKey($key) . '2', $value["fin"]);
        }
        $n = $n * $limite;
        $consulta->bindValue(':l', $limite, PDO::PARAM_INT);
        $consulta->bindValue(':n', $n, PDO::PARAM_INT);
        $consulta->execute();
        return $consulta->fetchAll();
    }
    public function COUNT(): int
    {
        $query = "SELECT COUNT(*) as 'total' FROM $this->tabla AS a $this->joins WHERE 1";

        foreach ($this->variables as $key => $value) {
            $query .= ' AND ' . $key . '=:a' . $this->normalizeKey($key);
        }
        foreach ($this->variables_like as $key => $value) {
            $query .= ' AND ' . $key . ' LIKE :alike' . $this->normalizeKey($key);
        }
        foreach ($this->variables_interval as $key => $value) {
            $query .= ' AND ' . $key . ' BETWEEN :' . $this->normalizeKey($key) . ' AND :' . $this->normalizeKey($key) . '2';
        }

        // Creamos la consulta
        $consulta = $this->conn->prepare($query);

        // Asignamos los parametros   
        foreach ($this->variables as $key => $value) {
            $consulta->bindValue(':a' . $this->normalizeKey($key), $value);
        }
        foreach ($this->variables_like as $key => $value) {
            $value2 = '%' . $value . '%';
            $consulta->bindValue(':alike' . $this->normalizeKey($key), $value2);
        }
        foreach ($this->variables_interval as $key => $value) {
            $consulta->bindValue(':' . $this->normalizeKey($key), $value["inicio"]);
            $consulta->bindValue(':' . $this->normalizeKey($key) . '2', $value["fin"]);
        }
        $consulta->execute();
        return $consulta->fetch()['total'];
    }
    public function get($key)
    {
        return $this->variables[$key];
    }
    public function set($key, $value)
    {
        return $this->variables[$key] = $value;
    }
    public function __toString()
    {
        return json_encode($this->variables);
    }
}
