# Módulo Productos Procesados - Diagrama de Secuencia

## Agregar Producto Procesado

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_PP as C_Producto_procesado.php
    participant ProductoProcesado as ProductoProcesado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_PP: fetch("producto_procesado/add", {POST formData})
    
    alt Validación de permisos
        C_PP->>C_PP: has_permission('producto_procesado', 'agregar')
    end
    
    alt Sin imagen
        C_PP->>C_PP: $_POST['imagen'] = "banner_productos.png"
    end
    
    C_PP->>ProductoProcesado: new ProductoProcesado(...formData)
    Note right of ProductoProcesado: Constructor recibe<br/>nombre, precio, stock_min/max,<br/>categoria, imagen
    
    C_PP->>ProductoProcesado: agregar()
    ProductoProcesado->>DB: INSERT INTO productos_procesados (...)
    DB-->>ProductoProcesado: lastInsertId
    ProductoProcesado-->>C_PP: lastInsertId
    
    C_PP-->>JS: {success true last_id id}
```

## Registrar Entrada de Producto Procesado

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Entrada_PP as C_Entrada_producto_procesado.php
    participant Entrada_PP as Entrada_producto_procesado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Entrada_PP: fetch("entrada_producto_procesado/add", {POST formData})
    
    C_Entrada_PP->>Entrada_PP: new Entrada_producto_procesado(...formData)
    Note right of Entrada_PP: Constructor recibe<br/>id_producto, id_proveedor,<br/>cantidad, precio_compra,<br/>fecha_vencimiento
    
    Entrada_PP->>DB: INSERT INTO entradas_producto_procesado
    DB-->>Entrada_PP: lastInsertId
    Entrada_PP-->>C_Entrada_PP: lastInsertId
    
    alt Actualizar existencia
        C_Entrada_PP->>C_Entrada_PP: UPDATE productos_procesados<br/>SET existencia = existencia + cantidad
    end
    
    C_Entrada_PP-->>JS: {success true last_id id}
```

## Consultar Entradas de Productos Procesados

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Entrada_PP as C_Entrada_producto_procesado.php
    participant Entrada_PP as Entrada_producto_procesado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Entrada_PP: fetch("entrada_producto_procesado/get_all", {POST})
    
    C_Entrada_PP->>Entrada_PP: new Entrada_producto_procesado(filtros)
    
    Note right of Entrada_PP: INNER JOIN productos_procesados<br/>INNER JOIN proveedores<br/>INNER JOIN unidades
    Entrada_PP->>DB: Query SELECT
    Note right of Entrada_PP: Devuelve: codigo, nombre_producto,<br/>nombre_proveedor, cantidad,<br/>fecha_vencimiento, existencia
    DB-->>Entrada_PP: Array de entradas
    Entrada_PP-->>C_Entrada_PP: Array de entradas
    
    C_Entrada_PP-->>JS: {data: [...], recordsFiltered: n}
```

## Entradas Por Vencer (10 días)

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Entrada_PP as C_Entrada_producto_procesado.php
    participant Entrada_PP as Entrada_producto_procesado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Entrada_PP: fetch("entrada_producto_procesado/get_all", {POST})
    
    C_Entrada_PP->>Entrada_PP: new Entrada_producto_procesado()
    Entrada_PP->>DB: Query SELECT
    
    Note over C_Entrada_PP: Filtrar en JS:<br/>fecha_vencimiento - hoy <= 10<br/>AND fecha_vencimiento > hoy<br/>AND existencia > 0
    
    DB-->>Entrada_PP: Todas las entradas
    Entrada_PP-->>C_Entrada_PP: Todas las entradas
    C_Entrada_PP-->>JS: {data: [...]}
```

## Entradas Vencidas

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Entrada_PP as C_Entrada_producto_procesado.php
    participant Entrada_PP as Entrada_producto_procesado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Entrada_PP: fetch("entrada_producto_procesado/get_all", {POST})
    
    C_Entrada_PP->>Entrada_PP: new Entrada_producto_procesado()
    Entrada_PP->>DB: Query SELECT
    
    Note over C_Entrada_PP: Filtrar en JS:<br/>fecha_vencimiento < hoy<br/>AND active = 1
    
    DB-->>Entrada_PP: Todas las entradas
    Entrada_PP-->>C_Entrada_PP: Todas las entradas
    C_Entrada_PP-->>JS: {data: [...]}
```

## Agregar Pago de Entrada Producto Procesado

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Pago_PP as C_Pago_entrada_producto_procesado.php
    participant Pago_PP as Pago_entrada_producto_procesado (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Pago_PP: fetch("pago_entrada_producto_procesado/add", {POST formData})
    
    C_Pago_PP->>Pago_PP: new Pago_entrada_producto_procesado(id_entrada, id_metodo_pago, precio_compra, tasa)
    
    Pago_PP->>DB: INSERT INTO pagos_entrada_producto_procesado
    DB-->>Pago_PP: lastInsertId
    Pago_PP-->>C_Pago_PP: lastInsertId
    
    C_Pago_PP-->>JS: {success true last_id id}
```
