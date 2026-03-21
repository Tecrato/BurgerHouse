# Módulo Órdenes - Diagrama de Secuencia

## Agregar Orden Local

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Orden as C_Orden.php
    participant Orden as Orden (Model)
    participant C_Orden_mesa as C_Orden_mesa.php
    participant Orden_mesa as Orden_mesa (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Orden: fetch("orden/add", {POST formData})
    
    alt Validación de permisos
        C_Orden->>C_Orden: has_permission('ordenes', 'agregar')
        alt Sin permiso
            C_Orden-->>JS: Error 403
        end
    end
    
    C_Orden->>Orden: new Orden(...formData)
    Note right of Orden: Constructor recibe todos<br/>los parámetros del POST
    
    loop Por cada producto preparado
        C_Orden->>Orden: getMateriaPrima(id_producto)
        Orden->>DB: Query SQL
        Orden-->>C_Orden: existencia y materia prima
        Note over C_Orden: Valida stock disponible
    end
    
    loop Por cada producto procesado
        C_Orden->>Orden: getMateriaPrima(id_producto)
        Orden-->>C_Orden: existencia
    end
    
    alt Stock insuficiente
        C_Orden-->>JS: {success false message detalle_preparado/procesado}
    end
    
    alt Stock suficiente
        C_Orden->>Orden: agregar()
        Orden->>DB: INSERT INTO orden (...)
        DB-->>Orden: lastInsertId
        Orden-->>C_Orden: lastInsertId
        
        C_Orden->>C_Orden_mesa: fetch("orden_mesa/add_many", {POST})
        
        loop Por cada mesa seleccionada
            C_Orden_mesa->>Orden_mesa: new Orden_mesa(id_mesa, id_orden)
            Orden_mesa->>DB: INSERT INTO orden_mesa (...)
            DB-->>Orden_mesa: lastInsertId
            Orden_mesa-->>C_Orden_mesa: lastInsertId
        end
        
        C_Orden-->>JS: {success true last_id id}
    end
```

## Agregar Productos a Orden Existente

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Orden as C_Orden.php
    participant Orden as Orden (Model)
    participant DetallePrep as DetalleOrdenProductoPreparado
    participant DetalleProc as DetalleOrdenProductoProcesado
    participant DB as Conexion (DB)
    
    JS->>C_Orden: fetch("orden/add_process_and_prepared", {POST})
    
    alt Validación de permisos
        C_Orden->>C_Orden: has_permission('ordenes', 'agregar')
    end
    
    loop Por cada producto preparado
        C_Orden->>Orden: getMateriaPrima(id_producto)
        Orden->>DB: Query SQL (SELECT)
        DB-->>Orden: existencia y materia prima
        Orden-->>C_Orden: resultado
        
        alt Stock insuficiente
            C_Orden->>C_Orden: Registrar faltante
        end
        
        alt Stock suficiente
            C_Orden->>DetallePrep: new DetalleOrdenProductoPreparado(...)
            DetallePrep->>DB: INSERT INTO producto_preparado_detalle_orden
            DB-->>DetallePrep: lastInsertId
            DetallePrep-->>C_Orden: lastInsertId
            
            loop Por cada materia prima en receta
                C_Orden->>Orden: Actualizar existencia
                Orden->>DB: UPDATE existencia
                DB-->>Orden: success
            end
        end
    end
    
    loop Por cada producto procesado
        C_Orden->>Orden: getMateriaPrima(id_producto)
        Orden->>DB: Query SQL
        DB-->>Orden: existencia
        Orden-->>C_Orden: resultado
        
        alt Stock suficiente
            C_Orden->>DetalleProc: new DetalleOrdenProductoProcesado(...)
            DetalleProc->>DB: INSERT INTO producto_procesado_detalle_orden
            DB-->>DetalleProc: lastInsertId
            DetalleProc-->>C_Orden: lastInsertId
        end
    end
    
    C_Orden->>Orden: new Orden(id, status)
    Orden->>DB: UPDATE orden SET status='en cocina'
    DB-->>Orden: success
    Orden-->>C_Orden: {success: true}
    
    C_Orden-->>JS: {success: true}
```

## Consultar Órdenes

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Orden as C_Orden.php
    participant Orden as Orden (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Orden: fetch("orden/get_all", {POST page limit order})
    
    alt Validación de permisos
        C_Orden->>C_Orden: has_permission('ordenes', 'consultar')
        alt Sin permiso
            C_Orden-->>JS: Error 403
        end
    end
    
    C_Orden->>Orden: new Orden(filtros del POST)
    Orden->>DB: SELECT ... LEFT JOIN clientes LEFT JOIN ventas
    DB-->>Orden: Array de órdenes
    Orden-->>C_Orden: Array de órdenes
    
    C_Orden-->>JS: {data [...] total n}
```

## Actualizar Estado de Orden

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Orden as C_Orden.php
    participant Orden as Orden (Model)
    
    JS->>C_Orden: fetch("orden/update", {POST id status})
    
    alt Soft-delete (active = 0)
        C_Orden->>C_Orden: has_permission('ordenes', 'eliminar')
    end
    
    alt Restaurar (active = 1)
        C_Orden->>C_Orden: has_permission('Papelera', 'restaurar')
    end
    
    alt Edición normal
        C_Orden->>C_Orden: has_permission('ordenes', 'editar')
    end
    
    C_Orden->>Orden: new Orden(id, status, ...)
    Orden->>DB: UPDATE orden SET status=?, ...
    DB-->>Orden: success
    Orden-->>C_Orden: {success: true}
    
    C_Orden-->>JS: {success: true}
```

## Eliminar Orden

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Orden as C_Orden.php
    participant Orden as Orden (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Orden: fetch("orden/delete", {POST, id})
    
    C_Orden->>C_Orden: has_permission('ordenes', 'eliminar')
    alt Sin permiso
        C_Orden-->>JS: Error 403
    end
    
    C_Orden->>Orden: new Orden(id)
    Orden->>DB: DELETE FROM orden WHERE id=?
    DB-->>Orden: true/false
    Orden-->>C_Orden: true/false
    
    C_Orden-->>JS: {success: true/false}
```

## Enviar Factura por Email

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Orden as C_Orden.php
    participant Dropbox as Dropbox API
    participant Email as PHPMailer
    
    JS->>C_Orden: fetch("orden/sendInvoice", {POST pdf})
    
    C_Orden->>C_Orden: has_permission('ordenes', 'agregar')
    
    C_Orden->>Dropbox: Subir archivo PDF
    Dropbox-->>C_Orden: URL del archivo
    
    C_Orden->>Email: ConfigurarPHPMailer()
    C_Orden->>Email: $email->addAddress(cliente)
    C_Orden->>Email: $email->send()
    Email-->>C_Orden: true/false
    
    C_Orden-->>JS: {success true url dropbox_url}
```
