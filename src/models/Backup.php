<?php

namespace Shtch\Burgerhouse\models;
use Exception;
class Backup
{
    public function respaldo($db, $route)
    {
        try {
            date_default_timezone_set('America/Caracas');
            $host = $GLOBALS['db1']['host'];
            $user = $GLOBALS['db1']['user'];
            $pass = $GLOBALS['db1']['pass'];
            $__dump_file_path = $GLOBALS['__mysql_path']."mysqldump";
            $fecha = date('Y-m-d');
            $hora = date('h-i');
            $nombreArchivo = "F{$fecha}_H{$hora}-{$route}.sql";
            $ruta = "../src/backups/{$route}/{$nombreArchivo}";
            $command = "$__dump_file_path --host={$host} --user={$user} --password={$pass} --routines --events --triggers --add-drop-table {$db} > \"$ruta\" 2>nul";
            $result = shell_exec($command);
            // echo json_encode(["success" => true, "message" => $nombreArchivo]);
            return $nombreArchivo;
        } catch (Exception $e) {
            // echo json_encode(["success" => false, "message" => $e->getMessage()]);
            return $e->getMessage();
        }
    }
    public function restaurar($db, $route, $id)
    {
        try {
            $host = $GLOBALS['db1']['host'];
            $user = $GLOBALS['db1']['user'];
            $pass = $GLOBALS['db1']['pass'];
            $__mysql_path = $GLOBALS['__mysql_path']."mysql";
            $rutaBackup = realpath("../src/backups/{$route}/{$id}");
            $dropCreate = "$__mysql_path -h $host -u $user --password$pass -e \"DROP DATABASE IF EXISTS `$db`; CREATE DATABASE `$db`;\"";
            shell_exec($dropCreate);
            $command = "$__mysql_path -h {$host} -u {$user} --password{$pass} {$db} < {$rutaBackup}";
            shell_exec($command . " 2>&1");
            // echo json_encode(["success" => true]);
            return true;
        } catch (Exception $e) {
            // echo json_encode(["success" => false, "message" => $e->getMessage()]);
            return $e->getMessage();
        }
    }
    public function config($db, $route)
    {
        $configFile = __DIR__ . '../../../db.config.json';
        date_default_timezone_set('America/Caracas');
        if (!file_exists($configFile)) {
            file_put_contents($configFile, json_encode([
                'interval_minutes' => 1440,
                'last_backup' => date('c')
            ], JSON_PRETTY_PRINT));
            exit;
        }

        $config = json_decode(file_get_contents($configFile), true);
        $lastRun = strtotime($config["last_backup"]);
        $interval = $config["interval_minutes"] * 60;

        if (time() - $lastRun >= $interval) {
            Backup::respaldo($db, $route);
            $config["last_backup"] = date("c");
            file_put_contents($configFile, json_encode($config, JSON_PRETTY_PRINT));
        }
    }
    function search($route)
    {
        $archivos = scandir("../src/backups/" . $route);
        $archivos = array_diff($archivos, array('.', '..'));

        $result = [];
        $id = 1;

        foreach ($archivos as $archivo) {
            $result[] = [
                'id' => $id++,
                'name' => $archivo
            ];
        }

        return json_encode($result);
    }
    function delete($route, $id)
    {
        $rutaArchivo = '../src/backups/' . $route . '/' . $id;
        if (!file_exists($rutaArchivo)) {
            echo json_encode(["success" => false, "message" => "El archivo no existe"]);
        }
        if (!is_file($rutaArchivo)) {
            echo json_encode(["success" => false, "message" => "El archivo no es un archivo"]);
        }
        if (unlink($rutaArchivo)) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al eliminar el archivo"]);
        }
    }
}