# Documentación de Diagramas de Secuencia

Este directorio contiene los diagramas de secuencia organizados por módulo del sistema BurgerHouse.

## Estructura de Carpetas

```
secuencia/
├── ordenes/
│   └── agregar_orden.md
├── usuarios/
│   └── usuarios.md
├── clientes/
│   └── clientes.md
├── mesas/
│   └── mesas.md
├── productos/
│   ├── producto_preparado.md
│   └── producto_procesado.md
├── recetas/
│   └── recetas.md
├── materia_prima/
│   └── materia_prima.md
├── proveedores/
│   └── proveedores.md
├── ventas/
│   └── ventas.md
├── caja/
│   └── caja.md
├── reservaciones/
│   └── reservaciones.md
├── permisos/
│   └── permisos.md
├── bitacora/
│   └── bitacora.md
└── README.md (este archivo)
```

## Convenciones

### Nomenclatura de Participantes
- `JS` → JavaScript (Frontend)
- `C_Controller` → Controlador PHP
- `Model` → Modelo PHP
- `DB` → Base de datos

### Simbología Mermaid
```mermaid
sequenceDiagram
    participant Alias as Descripción
    Actor->>Receptor: mensaje
    Receptor-->>Actor: respuesta
```

### Leyenda de Flechas
- `->>` : Llamada síncrona
- `-->>` : Respuesta
- `-)` : Llamada asíncrona
- `--)` : Respuesta asíncrona
- `loop` : Bucle/Iteración
- `alt/else` : Condicional if/else
- `Note` : Nota explicativa

## Módulos Documentados

| Módulo | Archivo | Estado |
|--------|---------|--------|
| Órdenes | `ordenes/agregar_orden.md` | ✅ Completo |
| Usuarios | `usuarios/usuarios.md` | ✅ Completo |
| Clientes | `clientes/clientes.md` | ✅ Completo |
| Mesas | `mesas/mesas.md` | ✅ Completo |
| Productos Preparados | `productos/producto_preparado.md` | ✅ Completo |
| Productos Procesados | `productos/producto_procesado.md` | ✅ Completo |
| Recetas | `recetas/recetas.md` | ✅ Completo |
| Materia Prima | `materia_prima/materia_prima.md` | ✅ Completo |
| Proveedores | `proveedores/proveedores.md` | ✅ Completo |
| Caja | `caja/caja.md` | ✅ Completo |
| Permisos | `permisos/permisos.md` | ✅ Completo |
| Reservaciones | `reservaciones/reservaciones.md` | ✅ Completo |
| Bitácora | `bitacora/bitacora.md` | ✅ Completo |

## Operaciones Cubiertas

| Operación | Descripción |
|-----------|-------------|
| `add` / `agregar` | Crear nuevo registro |
| `add_many` | Crear varios registros |
| `get_all` / `consultar` | Leer/listar registros |
| `update` / `actualizar` | Modificar registro |
| `delete` / `eliminar` | Eliminar registro |
| `count` / `total` | Contar registros |
| `toggle` | Alternar estado (permisos) |

## Flujo Típico de una Operación

```
1. JavaScript (Frontend)
   └── fetch() → Controlador PHP
                   └── new Model(...) → Constructor
                   └── Método (agregar/actualizar/borrar)
                   └── Query SQL
                   └── Response JSON
```
