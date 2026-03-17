<?php
/**
 * Runner para ejecutar todas las pruebas Selenium
 * Uso: php run_all_tests.php
 */

require_once __DIR__ . '/vendor/autoload.php';

require_once __DIR__ . '/BaseTest.php';

$tests = [
    'test_adicionales.php',
    'test_mesas.php',
    'test_productos_preparados.php',
    'test_productos_procesados.php',
    'test_categorias_producto.php',
    'test_categorias_mp.php',
    'test_unidades.php',
    'test_metodos_pago.php',
    'test_clientes.php',
    'test_usuarios.php',
    'test_roles.php',
    'test_proveedores.php',
    'test_materia_prima.php'
];

$passed = 0;
$failed = 0;

echo "============================================\n";
echo "  EJECUTANDO PRUEBAS SELENIUM - BURGERHOUSE\n";
echo "============================================\n\n";

foreach ($tests as $testFile) {
    $testPath = __DIR__ . '/tests/' . $testFile;
    
    if (!file_exists($testPath)) {
        echo "⚠️  Test no encontrado: {$testFile}\n";
        continue;
    }
    
    echo "▶ Ejecutando: {$testFile}\n";
    echo str_repeat('-', 50) . "\n";
    
    require_once $testPath;
    
    $className = str_replace('.php', '', $testFile);
    $className = str_replace('_', '', $className);
    $className = ucwords($className);
    
    // Convertir a nombre de clase
    $className = str_replace(
        ['testadicionales', 'testmesas', 'testproductospreparados', 'testproductosprocesados', 
         'testcategoriasproducto', 'testcategoriasmp', 'testunidades', 'testmetodospago',
         'testclientes', 'testusuarios', 'testroles', 'testproveedores', 'testmateriaprima'],
        ['TestAdicionales', 'TestMesas', 'TestProductosPreparados', 'TestProductosProcesados',
         'TestCategoriasProducto', 'TestCategoriasMP', 'TestUnidades', 'TestMetodosPago',
         'TestClientes', 'TestUsuarios', 'TestRoles', 'TestProveedores', 'TestMateriaPrima'],
        strtolower($className)
    );
    
    // Nombre de clase correcto
    $classNames = [
        'testadicionales' => 'TestAdicionales',
        'testmesas' => 'TestMesas',
        'testproductospreparados' => 'TestProductosPreparados',
        'testproductosprocesados' => 'TestProductosProcesados',
        'testcategoriasproducto' => 'TestCategoriasProducto',
        'testcategoriasmp' => 'TestCategoriasMP',
        'testunidades' => 'TestUnidades',
        'testmetodospago' => 'TestMetodosPago',
        'testclientes' => 'TestClientes',
        'testusuarios' => 'TestUsuarios',
        'testroles' => 'TestRoles',
        'testproveedores' => 'TestProveedores',
        'testmateriaprima' => 'TestMateriaPrima'
    ];
    
    $key = strtolower(str_replace('.php', '', $testFile));
    $className = $classNames[$key] ?? null;
    
    if (!$className || !class_exists($className)) {
        echo "⚠️  Clase no encontrada para: {$testFile}\n";
        continue;
    }
    
    try {
        $test = new $className();
        $test->execute();
        echo "✅ {$testFile} - PASSED\n";
        $passed++;
    } catch (Exception $e) {
        echo "❌ {$testFile} - FAILED: " . $e->getMessage() . "\n";
        $failed++;
    }
    
    echo "\n";
}

echo "============================================\n";
echo "  RESUMEN DE PRUEBAS\n";
echo "============================================\n";
echo "Total: " . count($tests) . "\n";
echo "Pasadas: {$passed}\n";
echo "Fallidas: {$failed}\n";
echo "============================================\n";
