<?php
// Cargar las dependencias instaladas con Composer
require_once 'vendor/autoload.php';

// Usar las clases necesarias
use Facebook\WebDriver\Remote\RemoteWebDriver;
use Facebook\WebDriver\Remote\DesiredCapabilities;
use Facebook\WebDriver\WebDriverBy;
use Facebook\WebDriver\WebDriverExpectedCondition;

// Configuración: la URL del servidor Selenium
$serverUrl = 'http://localhost:4444';

// Configurar el navegador (Firefox en este caso)
$capabilities = DesiredCapabilities::firefox();
$capabilities->setCapability('acceptInsecureCerts', true);

// Crear una instancia del driver
$driver = RemoteWebDriver::create($serverUrl, $capabilities);

try {
    // 1. Navegar a una página pública primero (home o login)
    echo "Navegando a página pública para establecer cookie...\n";
    $driver->get('https://localhost/BurgerHouse');
    
    // 2. Esperar a que cargue cualquier página (no esperamos título específico)
    echo "Esperando 3 segundos para que cargue...\n";
    sleep(3);
    
    // 3. Agregar la cookie de sesión de PHP (con configuración más compatible)
    echo "Estableciendo cookie de sesión...\n";
    try {
        $driver->manage()->deleteAllCookies(); // Limpiar cookies primero
        
        $cookie = [
            'name' => 'PHPSESSID',
            'value' => 'pfvju7ktjo2otal9aod36qog3d',
            'domain' => 'localhost',
            'path' => '/',
            'httpOnly' => false,  // Cambiado a false para localhost
            'secure' => false   // Mantenido en false para HTTP
        ];
        
        // Omitir domain para localhost y usar configuración mínima
        unset($cookie['domain']);
        $driver->manage()->addCookie($cookie);
        
        echo "Cookie agregada exitosamente\n";
    } catch (Exception $e) {
        echo "Error al agregar cookie: " . $e->getMessage() . "\n";
        echo "Intentando método alternativo...\n";
        
        // Método alternativo: usar JavaScript injection
        try {
            $driver->executeScript("document.cookie = 'PHPSESSID=pfvju7ktjo2otal9aod36qog3d; path=/;'");
            echo "Cookie establecida via JavaScript\n";
        } catch (Exception $jsEx) {
            echo "Error también con JavaScript: " . $jsEx->getMessage() . "\n";
        }
    }
    
    // 4. Refrescar la página para aplicar la cookie
    echo "Refrescando página para aplicar cookie...\n";
    $driver->navigate()->refresh();
    
    // 5. Esperar a que se aplique la cookie
    echo "Esperando 2 segundos para que aplique la cookie...\n";
    sleep(2);
    
    // 6. Ahora navegar a adicionales
    echo "Navegando a Adicionales...\n";
    $driver->get('https://localhost/BurgerHouse/adicionales');

    // 7. Esperar a que cargue la página de adicionales
    $driver->wait(10,5000)->until(
        WebDriverExpectedCondition::titleContains('Adicionales'),
        'No se cargó la página de adicionales'
    );
    
    // 8. Verificar el estado final
    $title = $driver->getTitle();
    echo "Título de la página: " . $title . "\n";
    
    if (strpos($title, 'Adicionales') !== false) {
        echo "✅ Página de adicionales cargada exitosamente!\n";
    } else {
        echo "❌ La página no se cargó correctamente. Título: " . $title . "\n";
    }

    // 7. Tomar una captura de pantalla (opcional, pero queda bonito)
    echo "Captura guardada como resultado_google.png\n";

} catch (Exception $e) {
    echo "Error durante la prueba: " . $e->getMessage() . "\n";
} finally {
    // 8. Cerrar el navegador SIEMPRE
    $driver->wait(10);
    $driver->quit();
}
?>