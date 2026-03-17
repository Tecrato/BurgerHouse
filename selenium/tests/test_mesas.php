<?php
/**
 * Prueba Selenium para el módulo de Mesas
 * Test CRUD completo
 */

require_once __DIR__ . '/../BaseTest.php';

use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;

class TestMesas extends BaseTest {
    
    private $testData;
    private $testDataEdit;
    
    public function __construct() {
        parent::__construct();
        $this->testData = [
            'nombre' => 'Mesa Test ' . date('His'),
            'sillas' => '4',
            'vip' => 0
        ];
        
        $this->testDataEdit = [
            'nombre' => 'Mesa Test Editada ' . date('His'),
            'sillas' => '6',
            'vip' => 1
        ];
    }
    
    public function run(): void {
        $this->log("=== INICIO PRUEBA CRUD MESAS ===");
        
        $this->testCreate();
        $this->testRead();
        $this->testUpdate();
        $this->testReadUpdated();
        $this->testDelete();
        
        $this->log("=== FIN PRUEBA CRUD MESAS ===");
    }
    
    private function testCreate(): void {
        $this->log("1. CREATE: Agregando nueva mesa...");
        $this->navigateTo('mesas');
        $this->wait(2);
        
        try {
            $addBtn = $this->driver->findElement(WebDriverBy::cssSelector('[data-bs-target="#registrar_mesa"]'));
            $addBtn->click();
        } catch (NoSuchElementException $e) {
            $addBtn = $this->driver->findElement(WebDriverBy::cssSelector('.btn-add'));
            $addBtn->click();
        }
        $this->wait(1);
        
        $this->fillForm($this->testData);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_mesa'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        
        $this->wait(3);
        $this->takeScreenshot('mesas_create');
        $this->log("Mesa creada: {$this->testData['nombre']}");
    }
    
    private function testRead(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        
        $exists = $this->existsInTable($this->testData['nombre']);
        $this->log($exists ? "✓ La mesa aparece en la lista" : "✗ ERROR: La mesa NO aparece");
    }
    
    private function testUpdate(): void {
        $this->log("3. UPDATE: Editando registro...");
        $this->openEditModal($this->testData['nombre']);
        $this->wait(1);
        
        $this->fillForm($this->testDataEdit);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_mesa_editar'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
        }
        
        $this->wait(3);
        $this->takeScreenshot('mesas_update');
    }
    
    private function testReadUpdated(): void {
        $this->driver->navigate()->refresh();
        $this->wait(3);
        
        $exists = $this->existsInTable($this->testDataEdit['nombre']);
        $this->log($exists ? "✓ La mesa actualizada aparece" : "✗ ERROR: No aparece");
    }
    
    private function testDelete(): void {
        $deleted = $this->deleteRecord($this->testDataEdit['nombre']);
        
        if ($deleted) {
            $this->confirmDelete();
            $this->wait(3);
            $this->takeScreenshot('mesas_delete');
            $this->log("✓ Mesa eliminada");
        }
    }
}

if (php_sapi_name() === 'cli') {
    $test = new TestMesas();
    $test->execute();
}
