<?php
/**
 * Prueba Selenium para Proveedores
 */

require_once __DIR__ . '/../BaseTest.php';

use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;

class TestProveedores extends BaseTest {
    
    private $testData;
    private $testDataEdit;
    
    public function __construct() {
        parent::__construct();
        $this->testData = [
            'razon_social' => 'Proveedor Test ' . date('His'),
            'telefono' => '04141234567'
        ];
        $this->testDataEdit = [
            'razon_social' => 'Proveedor Editado ' . date('His')
        ];
    }
    
    public function run(): void {
        $this->log("=== PRUEBA CRUD PROVEEDORES ===");
        $this->testCreate();
        $this->testRead();
        $this->testUpdate();
        $this->testReadUpdated();
        $this->testDelete();
    }
    
    private function testCreate(): void {
        $this->log("1. CREATE...");
        $this->navigateTo('proveedores');
        $this->wait(2);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('[data-bs-target="#registrar_proveedor"]'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->findElement(WebDriverBy::cssSelector('.btn-add'))->click();
        }
        $this->wait(1);
        
        $this->fillForm($this->testData);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_proveedor'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        $this->wait(3);
    }
    
    private function testRead(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        $this->log($this->existsInTable($this->testData['razon_social']) ? "✓ Encontrado" : "✗ NO encontrado");
    }
    
    private function testUpdate(): void {
        $this->openEditModal($this->testData['razon_social']);
        $this->wait(1);
        $this->fillForm($this->testDataEdit);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_proveedor_editar'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        $this->wait(3);
    }
    
    private function testReadUpdated(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        $this->log($this->existsInTable($this->testDataEdit['razon_social']) ? "✓ Actualizado" : "✗ NO encontrado");
    }
    
    private function testDelete(): void {
        if ($this->deleteRecord($this->testDataEdit['razon_social'])) {
            $this->confirmDelete();
            $this->wait(3);
            $this->log("✓ Eliminado");
        }
    }
}

if (php_sapi_name() === 'cli') {
    $test = new TestProveedores();
    $test->execute();
}
