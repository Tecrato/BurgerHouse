<?php
/**
 * Prueba Selenium para Categorías de Materia Prima
 */

require_once __DIR__ . '/../BaseTest.php';

use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;

class TestCategoriasMP extends BaseTest {
    
    private $testData;
    private $testDataEdit;
    
    public function __construct() {
        parent::__construct();
        $this->testData = ['nombre' => 'Categoria MP Test ' . date('His')];
        $this->testDataEdit = ['nombre' => 'Categoria MP Editada ' . date('His')];
    }
    
    public function run(): void {
        $this->log("=== PRUEBA CRUD CATEGORIAS MP ===");
        $this->testCreate();
        $this->testRead();
        $this->testUpdate();
        $this->testReadUpdated();
        $this->testDelete();
    }
    
    private function testCreate(): void {
        $this->log("1. CREATE...");
        $this->navigateTo('categoria-materia-prima');
        $this->wait(2);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('[data-bs-target="#registrar_categoria_materia_prima"]'))->click();
        } catch (NoSuchElementException $e) {
            $this->driver->findElement(WebDriverBy::cssSelector('.btn-add'))->click();
        }
        $this->wait(1);
        
        $this->fillForm($this->testData);
        $this->wait(1);
        
        try {
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_categoria_materia_prima'))->click();
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
            $this->driver->findElement(WebDriverBy::cssSelector('#enviar_categoria_materia_prima_editar'))->click();
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
    $test = new TestCategoriasMP();
    $test->execute();
}
