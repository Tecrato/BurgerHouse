# Módulo Recetas - Diagrama de Secuencia

## Agregar Receta

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Receta as C_Receta.php
    participant Receta as Receta (Model)
    participant Detalle_receta as Detalle_receta (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Receta: fetch("receta/add", {POST, id_producto})
    
    alt Validación de permisos
        C_Receta->>C_Receta: has_permission('recetas', 'agregar')
    end
    
    C_Receta->>Receta: new Receta(id_producto)
    
    C_Receta->>Receta: agregar()
    Receta->>DB: INSERT INTO recetas (id_producto)
    DB-->>Receta: id_receta
    Receta-->>C_Receta: id_receta
    
    loop Por cada ingrediente (materia prima)
        C_Receta->>Detalle_receta: new Detalle_receta(
            id_receta, 
            id_materia_prima, 
            cantidad
        )
        Detalle_receta->>DB: INSERT INTO detalles_receta
        DB-->>Detalle_receta: lastInsertId
        Detalle_receta-->>C_Receta: lastInsertId
    end
    
    C_Receta-->>JS: {success: true, last_id: id_receta}
```

## Consultar Recetas

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Receta as C_Receta.php
    participant Receta as Receta (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Receta: fetch("receta/get_all", {POST, page, limit})
    
    C_Receta->>C_Receta: has_permission('recetas', 'consultar')
    
    C_Receta->>Receta: new Receta(filtros)
    
    Note right of Receta: INNER JOIN productos_preparados
    Receta->>DB: Query SELECT
    Note right of Receta: Devuelve: id, id_producto,<br/>nombre_producto, tipo
    DB-->>Receta: Array de recetas
    Receta-->>C_Receta: Array de recetas
    
    C_Receta-->>JS: {data: [...], recordsFiltered: n}
```

## Consultar Detalles de Receta (Ingredientes)

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Detalle_receta as C_Detalle_receta.php
    participant Detalle_receta as Detalle_receta (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Detalle_receta: fetch("detalle_receta/get_all", {POST, id_receta})
    
    C_Detalle_receta->>Detalle_receta: new Detalle_receta(id_receta)
    
    Note right of Detalle_receta: INNER JOIN recetas<br/>INNER JOIN productos_preparados<br/>INNER JOIN materia_prima<br/>INNER JOIN unidades
    Detalle_receta->>DB: Query SELECT con JOINS
    Note right of Detalle_receta: Devuelve: ingrediente, cantidad,<br/>unidad (alias)
    DB-->>Detalle_receta: Array de ingredientes
    Detalle_receta-->>C_Detalle_receta: Array de ingredientes
    
    C_Detalle_receta-->>JS: {data: [...]}
```

## Actualizar Receta

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Receta as C_Receta.php
    participant Receta as Receta (Model)
    participant Detalle_receta as Detalle_receta (Model)
    participant DB as Conexion (DB)
    
    alt Agregar nuevos ingredientes
        loop Por cada ingrediente nuevo
            C_Receta->>Detalle_receta: new Detalle_receta(...)
            Detalle_receta->>DB: INSERT INTO detalles_receta
        end
    end
    
    alt Eliminar ingredientes removidos
        C_Receta->>C_Receta: Comparar ingredientes actuales vs nuevos
        loop Por cada ingrediente a remover
            C_Receta->>Detalle_receta: new Detalle_receta(id)
            Detalle_receta->>DB: DELETE FROM detalles_receta
        end
    end
    
    alt Actualizar cantidades
        loop Por cada ingrediente modificado
            C_Receta->>Detalle_receta: new Detalle_receta(id, cantidad)
            Detalle_receta->>DB: UPDATE detalles_receta SET cantidad=?
        end
    end
    
    C_Receta-->>JS: {success: true}
```

## Eliminar Receta

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Receta as C_Receta.php
    participant Receta as Receta (Model)
    participant Detalle_receta as Detalle_receta (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Receta: fetch("receta/delete", {POST, id})
    
    C_Receta->>C_Receta: has_permission('recetas', 'eliminar')
    
    alt Primero eliminar detalles
        C_Receta->>Detalle_receta: new Detalle_receta(id_receta: id)
        Detalle_receta->>DB: DELETE FROM detalles_receta WHERE id_receta=?
    end
    
    C_Receta->>Receta: new Receta(id)
    Receta->>DB: DELETE FROM recetas WHERE id=?
    DB-->>Receta: true/false
    Receta-->>C_Receta: true/false
    
    C_Receta-->>JS: {success: true/false}
```
