# Módulo Proveedores - Diagrama de Secuencia

## Agregar Proveedor

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Proveedor as C_Proveedor.php
    participant Proveedor as Proveedor (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Proveedor: fetch("proveedor/add", {POST, formData})
    
    alt Validación de permisos
        C_Proveedor->>C_Proveedor: has_permission('proveedores', 'agregar')
    end
    
    C_Proveedor->>Proveedor: new Proveedor(
        nombre, 
        razon_social, 
        documento,
        n_telefono1,
        n_telefono2,
        direccion
    )
    
    C_Proveedor->>Proveedor: agregar()
    Proveedor->>DB: INSERT INTO proveedores (...)
    DB-->>Proveedor: lastInsertId
    Proveedor-->>C_Proveedor: lastInsertId
    
    C_Proveedor-->>JS: {success: true, last_id: id}
```

## Consultar Proveedores

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Proveedor as C_Proveedor.php
    participant Proveedor as Proveedor (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Proveedor: fetch("proveedor/get_all", {POST, page, limit, search})
    
    C_Proveedor->>C_Proveedor: has_permission('proveedores', 'consultar')
    
    C_Proveedor->>Proveedor: new Proveedor(razon_social_like: search)
    Proveedor->>DB: Query SELECT WHERE razon_social LIKE '%...%'
    DB-->>Proveedor: Array de proveedores
    Proveedor-->>C_Proveedor: Array de proveedores
    
    C_Proveedor-->>JS: {data: [...], recordsFiltered: n}
```

## Actualizar Proveedor

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Proveedor as C_Proveedor.php
    participant Proveedor as Proveedor (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Proveedor: fetch("proveedor/update", {POST, id, datos})
    
    alt Sin permiso
        C_Proveedor->>C_Proveedor: has_permission('proveedores', 'eliminar')
    end
    
    alt Normal
        C_Proveedor->>C_Proveedor: has_permission('proveedores', 'editar')
    end
    
    C_Proveedor->>Proveedor: new Proveedor(id, ...)
    Proveedor->>DB: UPDATE proveedores SET...
    DB-->>Proveedor: {success: true}
    Proveedor-->>C_Proveedor: {success: true}
    
    C_Proveedor-->>JS: {success: true}
```

## Eliminar Proveedor (Soft-delete)

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Proveedor as C_Proveedor.php
    participant Proveedor as Proveedor (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Proveedor: fetch("proveedor/update", {POST, id, active: 0})
    
    C_Proveedor->>C_Proveedor: has_permission('proveedores', 'eliminar')
    
    C_Proveedor->>Proveedor: new Proveedor(id, active: 0)
    Proveedor->>DB: UPDATE proveedores SET active=0 WHERE id=?
    DB-->>Proveedor: {success: true}
    Proveedor-->>C_Proveedor: {success: true}
    
    C_Proveedor-->>JS: {success: true}
```
