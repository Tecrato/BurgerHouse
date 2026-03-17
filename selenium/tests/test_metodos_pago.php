<?php
/**
 * Prueba Selenium para Métodos de Pago
 */

require_once __DIR__ . '/../BaseTest.php';

use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;

class TestMetodosPago extends BaseTest {
    
    private $testData;
    private $testDataEdit;
    
    public function __construct() {
        parent::__construct();
        $this->testData = ['nombre' => 'Metodo Test ' . date('His')];
        $this->testDataEdit = ['nombre' => 'Metodo Editado ' . date('His')];
    }
    
    public function run(): void {
        $this->log("=== PRUEBA CRUD METODOS PAGO ===");
        $this->testCreate();
        $this->testRead();
        $this->testUpdate();
        $this->testReadUpdated();
        $this->testDelete();
    }
    
    private function testCreate(): void {
        $this->log("1. CREATE...");
        $this->navigateTo('metodos-pago');
        $this->wait(2);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('[data-bs-target="#registrar_metodo_pago"]'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->findElement(WebDriverBy::cssSelector('.btn-add'))->click();
        }
        $this->wait(1);
        
        $this->fillForm($this->testData);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_metodo_pago'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        $this->wait(3);
    }
    
    private function testRead(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        $this->log($this->existsInTable($this->testData['nombre']) ? "✓ Encontrado" : "✗ NO encontrado");
    }
    
    private function testUpdate(): void {
        $this->openEditModal($this->testData['nombre']);
        $this->wait(1);
        $this->fillForm($this->testDataEdit);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_metodo_pago_editar'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        $this->wait(3);
    }
    
    private function testReadUpdated(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        $this->log($this->existsInTable($this->testDataEdit['nombre']) ? "✓ Actualizado" : "✗ NO encontrado");
    }
    
    private function testDelete(): void {
        if ($this->deleteRecord($this->testDataEdit['nombre'])) {
            $this->confirmDelete();
            $this->wait(3);
            $this->log("✓ Eliminado");
        }
    }
}

if (php_sapi_name() === 'cli') {
    $test = new TestMetodosPago();
    $test->execute();
}
