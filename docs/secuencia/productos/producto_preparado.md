# Módulo Productos Preparados - Diagrama de Secuencia

## Agregar Producto Preparado

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Producto_preparado as C_Producto_preparado.php
    participant ProductoPreparado as ProductoPreparado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Producto_preparado: fetch("producto_preparado/add", {POST formData})
    
    alt Validación de permisos
        C_Producto_preparado->>C_Producto_preparado: has_permission('producto_preparado', 'agregar')
        alt Sin permiso
            C_Producto_preparado-->>JS: Error 403
        end
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(...formData)
    Note right of ProductoPreparado: Constructor recibe<br/>nombre, precio, categoria,<br/>tipo, imagen, etc.
    
    C_Producto_preparado->>ProductoPreparado: agregar()
    ProductoPreparado->>DB: INSERT INTO productos_preparados (...)
    DB-->>ProductoPreparado: lastInsertId
    ProductoPreparado-->>C_Producto_preparado: lastInsertId
    
    alt Si hay imagen
        C_Producto_preparado->>C_Producto_preparado: move_uploaded_file(imagen)
    end
    
    C_Producto_preparado-->>JS: {success true last_id id}
```

## Consultar Productos Preparados

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Producto_preparado as C_Producto_preparado.php
    participant ProductoPreparado as ProductoPreparado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Producto_preparado: fetch("producto_preparado/get_all", {POST, page, limit})
    
    C_Producto_preparado->>C_Producto_preparado: has_permission('producto_preparado', 'consultar')
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(filtros)
    ProductoPreparado->>DB: Query SELECT con JOIN categorias
    Note right of ProductoPreparado: INNER JOIN categorias_productos<br/>ON categorias.id = producto.id_categoria
    DB-->>ProductoPreparado: Array de productos
    ProductoPreparado-->>C_Producto_preparado: Array de productos
    
    C_Producto_preparado-->>JS: {data: [...], recordsFiltered: n}
```

## Actualizar Producto Preparado

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Producto_preparado as C_Producto_preparado.php
    participant ProductoPreparado as ProductoPreparado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Producto_preparado: fetch("producto_preparado/update", {POST})
    
    alt Sin nueva imagen
        C_Producto_preparado->>C_Producto_preparado: $_POST['imagen'] = null
        Note right of C_Producto_preparado: Db_base ignora el campo
    end
    
    alt Con nueva imagen
        C_Producto_preparado->>C_Producto_preparado: move_uploaded_file()
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(...formData)
    ProductoPreparado->>DB: UPDATE productos_preparados SET...
    DB-->>ProductoPreparado: {success: true}
    ProductoPreparado-->>C_Producto_preparado: {success: true}
    
    C_Producto_preparado-->>JS: {success: true}
```

## Agregar Varios Productos (add_many)

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Producto_preparado as C_Producto_preparado.php
    participant ProductoPreparado as ProductoPreparado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Producto_preparado: fetch("producto_preparado/add_many", {POST lista [...]})
    
    C_Producto_preparado->>C_Producto_preparado: has_permission('producto_preparado', 'agregar')
    
    loop Por cada producto en lista
        C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(...item)
        ProductoPreparado->>DB: agregar()
        DB-->>ProductoPreparado: lastInsertId
        ProductoPreparado-->>C_Producto_preparado: lastInsertId
        C_Producto_preparado->>C_Producto_preparado: Agregar ID a array resultado
    end
    
    C_Producto_preparado-->>JS: {success true last_ids [1,2,3]}
```
