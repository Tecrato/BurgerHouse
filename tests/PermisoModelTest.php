<?php
require_once __DIR__ . '/../src/config/config.php';
use PHPUnit\Framework\TestCase;

class PermisoModelTest extends TestCase{
    public function setUp(): void
    {
        if (!isset($_SESSION)) {
            $_SESSION = [];
        }
        $_SESSION['id_rol'] = 1;
    }

    public function testAgregarPermiso()
    {
        $permiso = new \Shtch\Burgerhouse\models\Permiso(
            null,
            'Permiso Test',
            'Descripcion test de permiso',
            1
        );
        $permiso->conn->beginTransaction();
        $id = $permiso->agregar();
        $permiso->conn->rollBack();
        $this->assertIsInt($id);
        $this->assertGreaterThan(0, $id);
    }

    public function testActualizarPermiso()
    {
        $c4 = new \Shtch\Burgerhouse\models\Permiso();
        $id_ultimo_permiso = $c4->search(order_type: 'DESC')[0]['id'];
        $permiso = new \Shtch\Burgerhouse\models\Permiso(
            $id_ultimo_permiso,
            'Permiso Actualizado Test',
            'Descripcion actualizada',
            1
        );
        $permiso->conn->beginTransaction();
        $result = $permiso->actualizar();
        $permiso->conn->rollBack();
        $this->assertIsArray($result);
        $this->assertTrue($result['success'], $result['message']);
    }

    public function testBorrarPermiso()
    {
        $c4 = new \Shtch\Burgerhouse\models\Permiso();
        $id_ultimo_permiso = $c4->search(order_type: 'DESC')[0]['id'];
        $permiso = new \Shtch\Burgerhouse\models\Permiso($id_ultimo_permiso);
        $permiso->conn->beginTransaction();
        $result = $permiso->borrar();
        $permiso->conn->rollBack();
        $this->assertIsBool($result);
    }
}
