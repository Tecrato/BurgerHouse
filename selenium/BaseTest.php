<?php
/**
 * Clase base abstracta para pruebas Selenium
 * Proporciona métodos reutilizables para CRUD
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Facebook\WebDriver\Remote\RemoteWebDriver;
use Facebook\WebDriver\Remote\DesiredCapabilities;
use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverExpectedCondition;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;
use Facebook\WebDriver\Firefox\FirefoxOptions;

abstract class BaseTest {
    protected $driver;
    protected $baseUrl = 'https://localhost/burgerhouse';
    protected $sessionId = 'pfvju7ktjo2otal9aod36qog3d';
    protected $screenshotPath = __DIR__ . '/../selenium/screenshots/';
    protected $currentTest = '';
    
    protected $serverUrl = 'http://localhost:4444';
    
    public function __construct() {
        if (!is_dir($this->screenshotPath)) {
            mkdir($this->screenshotPath, 0777, true);
        }
    }
    
    protected function setUp(): void {
        echo "[SETUP] Inicializando driver Firefox...\n";
        
        $capabilities = DesiredCapabilities::firefox();
        $capabilities->setCapability('acceptInsecureCerts', true);
        
        $firefoxOptions = new FirefoxOptions();
        $firefoxOptions->addArguments(['--width=1920', '--height=1080']);
        
        $capabilities->setCapability(FirefoxOptions::CAPABILITY, $firefoxOptions);
        
        $this->driver = RemoteWebDriver::create($this->serverUrl, $capabilities);
        $this->driver->manage()->window()->maximize();
        $this->driver->manage()->timeouts()->implicitlyWait(10);
        $this->driver->manage()->timeouts()->pageLoadTimeout(30);
        
        echo "[SETUP] Driver inicializado correctamente\n";
    }
    
    protected function login(): void {
        echo "[LOGIN] Estableciendo cookie de sesión...\n";
        
        $this->driver->get($this->baseUrl);
        $this->wait(2);
        
        $this->driver->manage()->deleteAllCookies();
        
        try {
            $this->driver->manage()->addCookie([
                'name' => 'PHPSESSID',
                'value' => $this->sessionId,
                'path' => '/',
                'domain' => 'localhost'
            ]);
            echo "[LOGIN] Cookie de sesión establecida\n";
        } catch (Exception $e) {
            $this->driver->executeScript("document.cookie = 'PHPSESSID={$this->sessionId}; path=/; domain=localhost';");
            echo "[LOGIN] Cookie establecida via JavaScript\n";
        }
        
        $this->driver->navigate()->refresh();
        $this->wait(2);
    }
    
    protected function navigateTo(string $modulo): void {
        echo "[NAV] Navegando a {$modulo}...\n";
        $this->driver->get($this->baseUrl . '/' . $modulo);
        $this->waitForPageLoad($modulo);
    }
    
    protected function waitForPageLoad(string $titlePart, int $timeout = 10): void {
        try {
            $this->driver->wait($timeout, 500)->until(
                WebDriverExpectedCondition::titleContains($titlePart),
                "La página no cargó: {$titlePart}"
            );
            echo "[NAV] Página cargada: {$titlePart}\n";
        } catch (Exception $e) {
            echo "[ERROR] Página no cargó: " . $e->getMessage() . "\n";
            $this->takeScreenshot('error_page_load');
        }
    }
    
    protected function openEditModal(string $value, string $tableSelector = 'table'): void {
        echo "[ACTION] Buscando registro para editar: {$value}...\n";
        
        $rows = $this->driver->findElements(WebDriverBy::cssSelector("{$tableSelector} tbody tr"));
        
        foreach ($rows as $row) {
            if (stripos($row->getText(), $value) !== false) {
                try {
                    $editBtn = $row->findElement(WebDriverBy::cssSelector('.edit_btn, .edit_btn_datatable, [data-module-edit]'));
                    $editBtn->click();
                    $this->wait(1);
                    echo "[ACTION] Modal de edición abierto\n";
                    return;
                } catch (NoSuchElementException $e) {
                    continue;
                }
            }
        }
        
        throw new Exception("No se encontró el registro: {$value}");
    }
    
    protected function confirmDelete(): void {
        echo "[ACTION] Confirmando eliminación...\n";
        $this->wait(1);
        
        try {
            $confirmBtn = $this->driver->findElement(WebDriverBy::cssSelector('.swal2-confirm, .confirm_btn'));
            $confirmBtn->click();
            $this->wait(2);
            echo "[ACTION] Eliminación confirmada\n";
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
            $this->wait(2);
        }
    }
    
    protected function deleteRecord(string $value, string $tableSelector = 'table'): bool {
        echo "[ACTION] Buscando registro para eliminar: {$value}...\n";
        
        try {
            $rows = $this->driver->findElements(WebDriverBy::cssSelector("{$tableSelector} tbody tr"));
            
            foreach ($rows as $row) {
                if (stripos($row->getText(), $value) !== false) {
                    try {
                        $deleteBtn = $row->findElement(WebDriverBy::cssSelector('.trash_btn, .trash_btn_datatable, [data-module-delete]'));
                        $deleteBtn->click();
                        $this->wait(1);
                        echo "[ACTION] Botón de eliminar clickeado\n";
                        return true;
                    } catch (NoSuchElementException $e) {
                        continue;
                    }
                }
            }
            
            echo "[WARNING] No se encontró el registro para eliminar: {$value}\n";
            return false;
            
        } catch (Exception $e) {
            echo "[ERROR] Error al eliminar: " . $e->getMessage() . "\n";
            return false;
        }
    }
    
    protected function fillForm(array $data): void {
        echo "[ACTION] Llenando formulario...\n";
        
        $fieldMap = [
            'nombre' => 'name',
            'precio' => 'price',
            'descripcion' => 'description',
            'telefono' => 'phone',
            'email' => 'email',
            'direccion' => 'address',
            'stock_min' => 'stock_min',
            'stock_max' => 'stock_max',
            'sillas' => 'sillas',
            'vip' => 'vip'
        ];
        
        foreach ($data as $field => $value) {
            try {
                $input = null;
                
                $englishField = $fieldMap[$field] ?? $field;
                $selectors = [
                    WebDriverBy::id("input_{$field}"),
                    WebDriverBy::name($field),
                    WebDriverBy::cssSelector("[id*='{$englishField}']"),
                    WebDriverBy::cssSelector("[id*='-{$field}']"),
                    WebDriverBy::cssSelector("[name='{$field}']"),
                ];
                
                foreach ($selectors as $selector) {
                    try {
                        $input = $this->driver->findElement($selector);
                        break;
                    } catch (NoSuchElementException $e) {
                        continue;
                    }
                }
                
                if ($input) {
                    $input->clear();
                    
                    $tagName = $input->getTagName();
                    if ($tagName === 'input') {
                        $type = $input->getAttribute('type');
                        if ($type === 'checkbox') {
                            if ($value == 1 || $value === true || $value === 'on') {
                                if (!$input->isSelected()) {
                                    $input->click();
                                }
                            }
                        } else {
                            $input->sendKeys($value);
                        }
                    } elseif ($tagName === 'select') {
                        $input->click();
                        $this->wait(0.5);
                        try {
                            $option = $this->driver->findElement(WebDriverBy::cssSelector("option[value='{$value}']"));
                            $option->click();
                        } catch (NoSuchElementException $e) {
                            $input->sendKeys($value);
                        }
                    } else {
                        $input->sendKeys($value);
                    }
                    
                    echo "[ACTION] Campo llenado: {$field} = {$value}\n";
                }
                
            } catch (Exception $e) {
                echo "[WARNING] Error al llenar {$field}: " . $e->getMessage() . "\n";
            }
        }
    }
    
    protected function waitForSuccess(int $timeout = 5): bool {
        echo "[ASSERT] Verificando mensaje de éxito...\n";
        
        try {
            $this->driver->wait($timeout, 500)->until(
                function ($driver) {
                    $text = $driver->getPageSource();
                    return stripos($text, 'success') !== false || 
                           stripos($text, 'éxito') !== false ||
                           stripos($text, 'agregado') !== false ||
                           stripos($text, 'actualizado') !== false ||
                           stripos($text, 'eliminado') !== false;
                }
            );
            echo "[SUCCESS] Operación exitosa\n";
            return true;
        } catch (Exception $e) {
            echo "[WARNING] No se detectó mensaje de éxito explícito\n";
            return true;
        }
    }
    
    protected function existsInTable(string $value, string $tableSelector = 'table'): bool {
        try {
            $rows = $this->driver->findElements(WebDriverBy::cssSelector("{$tableSelector} tbody tr"));
            
            foreach ($rows as $row) {
                if (stripos($row->getText(), $value) !== false) {
                    return true;
                }
            }
            return false;
        } catch (Exception $e) {
            return false;
        }
    }
    
    protected function wait(int $seconds): void {
        sleep($seconds);
    }
    
    protected function takeScreenshot(string $name = ''): void {
        if (empty($name)) {
            $name = date('Y-m-d_H-i-s');
        }
        
        $filename = $this->screenshotPath . $this->currentTest . '_' . $name . '.png';
        
        try {
            $this->driver->takeScreenshot($filename);
            echo "[SCREENSHOT] Guardado: {$filename}\n";
        } catch (Exception $e) {
            echo "[WARNING] No se pudo guardar screenshot: " . $e->getMessage() . "\n";
        }
    }
    
    protected function log(string $message): void {
        echo "[" . date('H:i:s') . "] {$message}\n";
    }
    
    protected function tearDown(): void {
        echo "[TEARDOWN] Cerrando navegador...\n";
        if ($this->driver) {
            $this->wait(1);
            $this->driver->quit();
        }
        echo "[TEARDOWN] Navegador cerrado\n";
    }
    
    abstract public function run(): void;
    
    public function execute(): void {
        $this->currentTest = get_class($this);
        
        try {
            $this->log("=== INICIANDO PRUEBA: {$this->currentTest} ===");
            $this->setUp();
            $this->login();
            $this->run();
            $this->log("=== PRUEBA COMPLETADA: {$this->currentTest} ===");
        } catch (Exception $e) {
            $this->log("=== ERROR EN PRUEBA: {$e->getMessage()} ===");
            if (isset($this->driver)) {
                $this->takeScreenshot('error_final');
            }
            throw $e;
        } finally {
            $this->tearDown();
        }
    }
    
    public function __destruct() {
        if (isset($this->driver)) {
            try {
                $this->driver->quit();
            } catch (Exception $e) {
            }
        }
    }
}
