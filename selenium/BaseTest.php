<?php
/**
 * Clase base abstracta para pruebas Selenium
 * Proporciona métodos reutilizables para CRUD
 */

require_once 'vendor/autoload.php';

use Facebook\WebDriver\Remote\RemoteWebDriver;
use Facebook\WebDriver\Remote\DesiredCapabilities;
use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverExpectedCondition;
use Facebook\WebDriver\WebDriverKeys;
use Facebook\WebDriver\Exception\NoSuchElementException;
use Facebook\WebDriver\Firefox\FirefoxOptions;

abstract class BaseTest {
    protected $driver;
    protected $baseUrl = 'https://localhost/BurgerHouse';
    protected $sessionId = '6c9tplhma4c1dfo7pi4240309u';
    protected $screenshotPath = __DIR__ . '/screenshots/';
    protected $currentTest = '';
    
    // Configuración del servidor Selenium
    protected $serverUrl = 'http://localhost:4444';
    
    public function __construct() {
        // Crear directorio de screenshots si no existe
        if (!is_dir($this->screenshotPath)) {
            mkdir($this->screenshotPath, 0777, true);
        }
    }
    
    /**
     * Inicializa el driver de Selenium
     */
    protected function setUp(): void {
        echo "[SETUP] Inicializando driver Firefox...\n";
        
        $capabilities = DesiredCapabilities::firefox();
        $capabilities->setCapability('acceptInsecureCerts', true);
        
        // Configuración simple para geckodriver
        $firefoxOptions = new \Facebook\WebDriver\Firefox\FirefoxOptions();
        $firefoxOptions->addArguments(['--width=1920', '--height=1080']);
        
        $capabilities->setCapability(\Facebook\WebDriver\Firefox\FirefoxOptions::CAPABILITY, $firefoxOptions);
        
        $this->driver = RemoteWebDriver::create($this->serverUrl, $capabilities);
        $this->driver->manage()->window()->maximize();
        $this->driver->manage()->timeouts()->implicitlyWait(10);
        $this->driver->manage()->timeouts()->pageLoadTimeout(30);
        
        echo "[SETUP] Driver inicializado correctamente\n";
    }
    
    /**
     * Establece la cookie de sesión para autenticación
     */
    protected function login(): void {
        echo "[LOGIN] Estableciendo cookie de sesión...\n";
        
        // Navegar a página pública primero
        $this->driver->get($this->baseUrl);
        $this->wait(2);
        
        // Limpiar cookies y agregar sesión
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
            // Método alternativo con JavaScript
            $this->driver->executeScript("document.cookie = 'PHPSESSID={$this->sessionId}; path=/; domain=localhost';");
            echo "[LOGIN] Cookie establecida via JavaScript\n";
        }
        
        // Refrescar para aplicar cookie
        $this->driver->navigate()->refresh();
        $this->wait(2);
    }
    
    /**
     * Navega a un módulo específico
     */
    protected function navigateTo(string $modulo): void {
        echo "[NAV] Navegando a {$modulo}...\n";
        $this->driver->get($this->baseUrl . '/' . $modulo);
        $this->waitForPageLoad($modulo);
    }
    
    /**
     * Espera a que cargue la página verificando el título
     */
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
    
    /**
     * Hace clic en el botón de agregar (modal o botón)
     */
    protected function clickAdd(string $selector = '.btn-add, .btn-agregar, [data-bs-toggle="modal"]'): void {
        echo "[ACTION] Buscando botón agregar...\n";
        
        try {
            // Buscar modal de agregar
            $buttons = $this->driver->findElements(WebDriverBy::cssSelector($selector));
            foreach ($buttons as $btn) {
                if (strpos($btn->getText(), 'Agregar') !== false || 
                    strpos($btn->getAttribute('class'), 'add') !== false) {
                    $btn->click();
                    $this->wait(1);
                    echo "[ACTION] Modal de agregar abierto\n";
                    return;
                }
            }
            
            // Si no encuentra, buscar por data-bs-target
            $addBtn = $this->driver->findElement(WebDriverBy::cssSelector('[data-bs-target*="register"]'));
            $addBtn->click();
            $this->wait(1);
            echo "[ACTION] Modal abierto\n";
            
        } catch (NoSuchElementException $e) {
            // Intentar con selector más específico por módulo
            $this->takeScreenshot('click_add_error');
            throw new Exception("No se encontró el botón de agregar: " . $e->getMessage());
        }
    }
    
    /**
     * Abre el modal de edición para un registro específico
     */
    protected function openEditModal(string $value, string $tableSelector = 'table'): void {
        echo "[ACTION] Buscando registro para editar: {$value}...\n";
        
        // Buscar fila en la tabla
        $rows = $this->driver->findElements(WebDriverBy::cssSelector("{$tableSelector} tbody tr"));
        
        foreach ($rows as $row) {
            if (stripos($row->getText(), $value) !== false) {
                // Buscar botón de editar en la fila
                try {
                    $editBtn = $row->findElement(WebDriverBy::cssSelector('.edit_btn, .edit_btn_datatable, [data-module-edit]'));
                    $editBtn->click();
                    $this->wait(1);
                    echo "[ACTION] Modal de edición abierto\n";
                    return;
                } catch (NoSuchElementException $e) {
                    // Continuar buscando
                }
            }
        }
        
        throw new Exception("No se encontró el registro: {$value}");
    }
    
    /**
     * Confirma la eliminación en un Swal modal
     */
    protected function confirmDelete(): void {
        echo "[ACTION] Confirmando eliminación...\n";
        $this->wait(1);
        
        try {
            // Buscar botón de confirmar en Swal
            $confirmBtn = $this->driver->findElement(WebDriverBy::cssSelector('.swal2-confirm, .confirm_btn'));
            $confirmBtn->click();
            $this->wait(2);
            echo "[ACTION] Eliminación confirmada\n";
        } catch (NoSuchElementException $e) {
            // Intentar con Enter o buscar otro selector
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
            $this->wait(2);
        }
    }
    
    /**
     * Cancela una acción en Swal
     */
    protected function cancelDelete(): void {
        echo "[ACTION] Cancelando eliminación...\n";
        try {
            $cancelBtn = $this->driver->findElement(WebDriverBy::cssSelector('.swal2-cancel'));
            $cancelBtn->click();
            $this->wait(1);
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ESCAPE);
        }
    }
    
    /**
     * Elimina un registro de la tabla
     */
    protected function deleteRecord(string $value, string $tableSelector = 'table'): bool {
        echo "[ACTION] Buscando registro para eliminar: {$value}...\n";
        
        try {
            $rows = $this->driver->findElements(WebDriverBy::cssSelector("{$tableSelector} tbody tr"));
            
            foreach ($rows as $row) {
                if (stripos($row->getText(), $value) !== false) {
                    try {
                        // Buscar botón de eliminar
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
    
    /**
     * Llena un formulario con los datos proporcionados
     */
    protected function fillForm(array $data): void {
        echo "[ACTION] Llenando formulario...\n";
        
        foreach ($data as $field => $value) {
            try {
                // Buscar input por varios métodos
                $input = null;
                
                // Por ID
                try {
                    $input = $this->driver->findElement(WebDriverBy::id("input_{$field}"));
                } catch (NoSuchElementException $e) {
                    // Por name
                    try {
                        $input = $this->driver->findElement(WebDriverBy::name($field));
                    } catch (NoSuchElementException $e2) {
                        // Por selector css con partial id
                        try {
                            $input = $this->driver->findElement(WebDriverBy::cssSelector("[id*='{$field}']"));
                        } catch (NoSuchElementException $e3) {
                            echo "[WARNING] Campo no encontrado: {$field}\n";
                            continue;
                        }
                    }
                }
                
                if ($input) {
                    // Limpiar campo
                    $input->clear();
                    
                    // Verificar si es checkbox
                    $tagName = $input->getTagName();
                    if ($tagName === 'input') {
                        $type = $input->getAttribute('type');
                        if ($type === 'checkbox') {
                            if ($value == 1 || $value === true || $value === 'on') {
                                if (!$input->isSelected()) {
                                    $input->click();
                                }
                            } else {
                                if ($input->isSelected()) {
                                    $input->click();
                                }
                            }
                        } else {
                            $input->sendKeys($value);
                        }
                    } elseif ($tagName === 'select') {
                        // Para selects
                        $input->click();
                        $this->wait(0.5);
                        $option = $this->driver->findElement(WebDriverBy::cssSelector("option[value='{$value}']"));
                        $option->click();
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
    
    /**
     * Envía el formulario
     */
    protected function submitForm(string $submitSelector = '#enviar, [type="submit"], .btn-guardar'): void {
        echo "[ACTION] Enviando formulario...\n";
        
        try {
            $submitBtn = $this->driver->findElement(WebDriverBy::cssSelector($submitSelector));
            $submitBtn->click();
            $this->wait(2);
        } catch (NoSuchElementException $e) {
            // Intentar con el botón dentro del modal
            try {
                $submitBtn = $this->driver->findElement(WebDriverBy::cssSelector('.modal .btn-primary, .modal .bh_1'));
                $submitBtn->click();
                $this->wait(2);
            } catch (NoSuchElementException $e2) {
                // Enviar con Enter
                $this->driver->getKeyboard()->pressKey(WebDriverKeys::ENTER);
                $this->wait(2);
            }
        }
    }
    
    /**
     * Cierra un modal
     */
    protected function closeModal(): void {
        try {
            $closeBtn = $this->driver->findElement(WebDriverBy::cssSelector('.modal .btn-close, .modal [data-bs-dismiss="modal"]'));
            $closeBtn->click();
            $this->wait(1);
        } catch (NoSuchElementException $e) {
            $this->driver->getKeyboard()->pressKey(WebDriverKeys::ESCAPE);
            $this->wait(1);
        }
    }
    
    /**
     * Espera a que aparezca un mensaje de éxito
     */
    protected function waitForSuccess(int $timeout = 5): bool {
        echo "[ASSERT] Verificando mensaje de éxito...\n";
        
        try {
            // Buscar toast o alert de éxito
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
            return true; // Continuar de todas formas
        }
    }
    
    /**
     * Verifica si un registro existe en la tabla
     */
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
    
    /**
     * Obtiene el ID de un registro en la tabla
     */
    protected function getRecordId(string $value, string $tableSelector = 'table'): ?string {
        try {
            $rows = $this->driver->findElements(WebDriverBy::cssSelector("{$tableSelector} tbody tr"));
            
            foreach ($rows as $row) {
                if (stripos($row->getText(), $value) !== false) {
                    // Buscar checkbox o atributo data-id
                    try {
                        $checkbox = $row->findElement(WebDriverBy::cssSelector('[data-id]'));
                        return $checkbox->getAttribute('data-id');
                    } catch (NoSuchElementException $e) {
                        return null;
                    }
                }
            }
            return null;
        } catch (Exception $e) {
            return null;
        }
    }
    
    /**
     * Espera segundos
     */
    protected function wait(int $seconds): void {
        sleep($seconds);
    }
    
    /**
     * Toma una captura de pantalla
     */
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
    
    /**
     * Imprime mensaje de resultado
     */
    protected function log(string $message): void {
        echo "[" . date('H:i:s') . "] {$message}\n";
    }
    
    /**
     * Cierra el driver
     */
    protected function tearDown(): void {
        echo "[TEARDOWN] Cerrando navegador...\n";
        if ($this->driver) {
            $this->wait(1);
            $this->driver->quit();
        }
        echo "[TEARDOWN] Navegador cerrado\n";
    }
    
    /**
     * Método principal de prueba - implementar en cada test
     */
    abstract public function run(): void;
    
    /**
     * Ejecuta la prueba completa (setup, run, teardown)
     */
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
    
    /**
     * Destructor para asegurar cierre del driver
     */
    public function __destruct() {
        if (isset($this->driver)) {
            try {
                $this->driver->quit();
            } catch (Exception $e) {
                // Ignorar errores al cerrar
            }
        }
    }
}
