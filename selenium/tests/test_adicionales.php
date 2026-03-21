<?php
/**
 * Prueba Selenium para el módulo de Adicionales
 */

require_once __DIR__ . '/../BaseTest.php';

use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;

class TestAdicionales extends BaseTest {
    
    private $testData;
    private $testDataEdit;
    
    public function __construct() {
        parent::__construct();
        $this->testData = [
            'nombre' => 'Test Adicional ' . date('His'),
            'precio' => '2.50'
        ];
        
        $this->testDataEdit = [
            'nombre' => 'Test Adicional Editado ' . date('His'),
            'precio' => '3.00'
        ];
    }
    
    public function run(): void {
        $this->log("=== INICIO PRUEBA CRUD ADICIONALES ===");
        
        $this->testCreate();
        $this->testRead();
        $this->testUpdate();
        $this->testReadUpdated();
        $this->testDelete();
        
        $this->log("=== FIN PRUEBA CRUD ADICIONALES ===");
    }
    
    private function testCreate(): void {
        $this->log("1. CREATE: Agregando nuevo adicional...");
        $this->navigateTo('adicionales');
        $this->wait(2);
        
        try {
            $addBtn = $this->driver->findElement(WebDriverBy::cssSelector('[data-bs-target="#register-additional"]'));
            $addBtn->click();
        } catch (NoSuchElementException $e) {
            $addBtn = $this->driver->findElement(WebDriverBy::cssSelector('[data-module-add="Adicionales"]'));
            $addBtn->click();
        }
        $this->wait(1);
        
        $this->fillForm([
            'nombre' => $this->testData['nombre'],
            'precio' => $this->testData['precio']
        ]);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#submit-additional'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        
        $this->wait(3);
        $this->takeScreenshot('adicionales_create');
    }
    
    private function testRead(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        
        $exists = $this->existsInTable($this->testData['nombre']);
        $this->log($exists ? "✓ Encontrado" : "✗ NO encontrado");
    }
    
    private function testUpdate(): void {
        $this->openEditModal($this->testData['nombre']);
        $this->wait(1);
        
        $this->fillForm([
            'nombre' => $this->testDataEdit['nombre'],
            'precio' => $this->testDataEdit['precio']
        ]);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#submit-edit-additional'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        $this->wait(3);
    }
    
    private function testReadUpdated(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        
        $exists = $this->existsInTable($this->testDataEdit['nombre']);
        $this->log($exists ? "✓ Actualizado encontrado" : "✗ NO encontrado");
    }
    
    private function testDelete(): void {
        $deleted = $this->deleteRecord($this->testDataEdit['nombre']);
        
        if ($deleted) {
            $this->confirmDelete();
            $this->wait(3);
            $this->takeScreenshot('adicionales_delete');
            $this->log("✓ Eliminado");
        }
    }
}

if (php_sapi_name() === 'cli') {
    $test = new TestAdicionales();
    $test->execute();
}
