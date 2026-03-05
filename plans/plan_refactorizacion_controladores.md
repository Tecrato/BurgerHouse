# Plan de Refactorización de Controladores - BurgerHouse

## Resumen del Análisis

He analizado el proyecto y encontrado **3 patrones diferentes** de controladores:

### Patrón 1: Estilo Manual Completo (Antiguo)
Controladores que manejan todo manualmente sin usar helpers.

### Patrón 2: Funciones Helper
Controladores que usan funciones helper externas (`view`, `add`, `get_all`, etc.).

### Patrón 3: Nuevo Estándar (C_Bitacora.php) ✅
El patrón que deseas implementar como estándar.

---

## Características del Nuevo Patrón (C_Bitacora.php)

```php
// 1. Imports
use Shtch\Burgerhouse\function\AuthSession;
use Shtch\Burgerhouse\models\NombreModelo;

// 2. Inicialización de sesión
$session = new AuthSession();
$resultado_final = '';

// 3. Verificación de autenticación
if (!$session->usuario) {
    make_url_error("No estas autenticado...", 401, ajax: $ajax);
}

// 4. Manejo de vista (view)
if (count($url) < 2 || $url[1] === 'view') {
    // include_once vista
    exit;
}

// 5. Acciones con switch/if-else
if ($url[1] === 'get_all') {
    // Con permisos
    // Con try-catch
    $modelo = new Modelo(...$_POST);
    $resultado_final = $modelo->search(...$parametros_paginacion);
    $ajax = true;
} else if ($url[1] === 'add') {
    // Con permisos
    // Con try-catch
    $_POST['id_usuario'] = $session->usuario['id']; // usuario actual
    $modelo = new Modelo(...$_POST);
    $id = $modelo->agregar();
    $resultado_final = ['success' => true, 'last_id' => $id];
    $ajax = true;
} else if ($url[1] === 'count' || $url[1] === 'total') {
    // Con permisos
    $modelo = new Modelo(...$_POST);
    $resultado_final = $modelo->count();
    $ajax = true;
} else {
    make_url_error("Accion no valida...", 404, ajax: true);
}

// 6. Respuesta JSON
if ($ajax) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($resultado_final);
    exit;
}

print_r($resultado_final);
```

---

## Clasificación de Controladores

### Controladores que YA usan el Patrón Nuevo (o similar)
| Archivo | Estado | Notas |
|---------|--------|-------|
| C_Bitacora.php | ✅listo | Patrón de referencia |
| C_Clientes.php | ⚠️parcial | Ya tiene estructura similar, revisar permisos |
| C_Unidades.php | ⚠️parcial | Ya tiene estructura similar |
| C_Home.php | ⚠️simple | Estructura básica correcta |

### Controladores que usan Funciones Helper
| Archivo | Estado | Acción |
|---------|--------|--------|
| C_Venta.php | 🔄revisar | ¿Migrar al nuevo patrón? |
| C_Vistas.php | 🔄revisar | ¿Migrar al nuevo patrón? |
| C_Categoria_producto.php | 🔄revisar | ¿Migrar al nuevo patrón? |
| C_Users.php | 🔄revisar | ¿Migrar al nuevo patrón? |

### Controladores con Estilo Manual (Necesitan Actualización)
| Archivo | Complejidad | Prioridad |
|---------|-------------|-----------|
| C_Adicionales.php | Baja | Alta |
| C_Caja.php | Media | Alta |
| C_Materia_prima.php | Alta | Media |
| C_Proveedor.php | Baja | Alta |
| C_Producto_preparado.php | Baja | Alta |
| C_Orden.php | Muy Alta | Baja (compleja) |
| C_Categoria_materia_prima.php | Media | Media |
| C_Entrada_materia_prima.php | Alta | Baja |
| C_Entrada_producto_procesado.php | Alta | Baja |
| C_Recetas.php | Media | Media |
| C_Mesa.php | Baja | Alta |
| C_Metodo_pago.php | Baja | Alta |
| C_Delivery.php | Media | Media |
| C_Estadisticas.php | Media | Baja |
| C_Roles.php | Baja | Media |
| C_Permisos.php | Baja | Media |

---

## Propuesta de Ejecución

### Fase 1: Controladores Simples (Baja Complejidad)
1. C_Adicionales.php
2. C_Proveedor.php
3. C_Producto_preparado.php
4. C_Mesa.php
5. C_Metodo_pago.php
6. C_Delivery.php

### Fase 2: Controladores Medianos
1. C_Caja.php
2. C_Unidades.php
3. C_Clientes.php
4. C_Roles.php
5. C_Permisos.php

### Fase 3: Controladores con Funciones Helper
1. C_Venta.php
2. C_Vistas.php
3. C_Categoria_producto.php
4. C_Users.php

### Fase 4: Controladores Complejos (Último)
1. C_Materia_prima.php
2. C_Recetas.php
3. C_Orden.php

---

## Pendiente por Confirmar

- ¿Quieres migrar también los controladores que usan funciones helper al nuevo patrón?
- ¿C_Orden.php debe mantenerse como está (lógica muy compleja)?
