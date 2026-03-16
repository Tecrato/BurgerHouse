<?php
namespace Shtch\Burgerhouse\models;

class Rol_modulo_permiso extends Db_base {
    private $id;
    private $id_rol;
    private $id_modulo;
    private $id_permiso;

    public function __construct(
        $id = null,
        $id_rol = null,
        $id_modulo = null,
        $id_permiso = null
    ) {
        parent::__construct("roles_modulos_permisos", 2);
        
        $this->id = $id;
        $this->id_rol = $id_rol;
        $this->id_modulo = $id_modulo;
        $this->id_permiso = $id_permiso;

        $this->add_variables([
            "a.id" => $this->id,
            "a.id_rol" => $this->id_rol,
            "a.id_modulo" => $this->id_modulo,
            "a.id_permiso" => $this->id_permiso
        ]);
    }

    public function toggle(): array {
        $existente = $this->search();

        if (!empty($existente) && count($existente) > 0) {
            return $this->eliminar_relacion();
        } else {
            $id = $this->agregar();
            return ['success' => true, 'action' => 'added', 'message' => 'Permiso agregado', 'last_id' => $id];
        }
    }

    private function eliminar_relacion(): array {
        $query = $this->conn->prepare("DELETE FROM roles_modulos_permisos WHERE id_rol = :id_rol AND id_modulo = :id_modulo AND id_permiso = :id_permiso");
        $query->bindValue(':id_rol', $this->id_rol, \PDO::PARAM_INT);
        $query->bindValue(':id_modulo', $this->id_modulo, \PDO::PARAM_INT);
        $query->bindValue(':id_permiso', $this->id_permiso, \PDO::PARAM_INT);
        $query->execute();
        return ['success' => true, 'action' => 'removed', 'message' => 'Permiso eliminado'];
    }
}
