# Módulo Materia Prima - Diagrama de Secuencia

## Agregar Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Materia_prima as C_Materia_prima.php
    participant Materia_prima as Materia_prima (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Materia_prima: fetch("materia_prima/add", {POST, formData})
    
    alt Validación de permisos
        C_Materia_prima->>C_Materia_prima: has_permission('materia_prima', 'agregar')
        alt Sin permiso
            C_Materia_prima-->>JS: Error 403
        end
    end
    
    C_Materia_prima->>Materia_prima: new Materia_prima(nombre, id_categoria, id_unidad, stock_min, stock_max)
    Note right of Materia_prima: Constructor recibe<br/>nombre, categoria, unidad,<br/>stock min/max
    
    C_Materia_prima->>Materia_prima: agregar()
    Materia_prima->>DB: INSERT INTO materia_prima (...)
    DB-->>Materia_prima: lastInsertId
    Materia_prima-->>C_Materia_prima: lastInsertId
    
    C_Materia_prima-->>JS: {success: true, last_id: id}
```

## Registrar Entrada de Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Entrada_mp as C_Entrada_materia_prima.php
    participant Entrada_mp as Entrada_materia_prima (Model)
    participant Detalle_mp as Detalle_entrada_materia_prima (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Entrada_mp: fetch("entrada_materia_prima/add", {POST, id_proveedor, fecha_compra})
    
    C_Entrada_mp->>Entrada_mp: new Entrada_materia_prima(id_proveedor, fecha_compra)
    Entrada_mp->>DB: INSERT INTO entradas_materia_prima (...)
    DB-->>Entrada_mp: id_entrada
    Entrada_mp-->>C_Entrada_mp: id_entrada
    
    loop Por cada item (materia prima)
        C_Entrada_mp->>Detalle_mp: new Detalle_entrada_materia_prima(
            id_entrada, 
            id_materia_prima, 
            cantidad, 
            fecha_vencimiento, 
            codigo
        )
        Detalle_mp->>DB: INSERT INTO detalles_entradas_materia_prima
        DB-->>Detalle_mp: lastInsertId
        Detalle_mp-->>C_Entrada_mp: lastInsertId
        
        C_Entrada_mp->>C_Entrada_mp: Actualizar existencia de materia_prima
    end
    
    C_Entrada_mp-->>JS: {success: true, last_id: id_entrada}
```

## Consultar Entradas de Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Entrada_mp_det as C_Entrada_materia_prima_detalles.php
    participant Detalle_mp as Detalle_entrada_materia_prima (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Entrada_mp_det: fetch("entrada_materia_prima_detalles/get_all", {POST})
    
    C_Entrada_mp_det->>Detalle_mp: new Detalle_entrada_materia_prima(filtros)
    
    loop Por cada detalle
        Note right of Detalle_mp: INNER JOIN materia_prima<br/>INNER JOIN proveedores<br/>INNER JOIN unidades
    end
    
    Detalle_mp->>DB: Query SELECT con JOINS
    Note right of Detalle_mp: Devuelve: codigo, nombre_materia_prima,<br/>nombre_proveedor, cantidad,<br/>fecha_vencimiento, existencia
    DB-->>Detalle_mp: Array de detalles
    Detalle_mp-->>C_Entrada_mp_det: Array de detalles
    
    C_Entrada_mp_det-->>JS: {data: [...], recordsFiltered: n}
```

## Agregar Pago de Entrada Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Pago_mp as C_Pago_entrada_materia_prima.php
    participant Pago_mp as Pago_entrada_materia_prima (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Pago_mp: fetch("pago_entrada_materia_prima/add", {POST, formData})
    
    C_Pago_mp->>Pago_mp: new Pago_entrada_materia_prima(
        id_entrada, 
        id_metodo_pago, 
        precio_compra, 
        tasa
    )
    
    Pago_mp->>DB: INSERT INTO pagos_entrada_materia_prima
    DB-->>Pago_mp: lastInsertId
    Pago_mp-->>C_Pago_mp: lastInsertId
    
    alt Si hay comprobante
        C_Pago_mp->>C_Pago_mp: move_uploaded_file(comprobante)
    end
    
    C_Pago_mp-->>JS: {success: true, last_id: id}
```

## Actualizar Existencia (Descontar Stock)

```mermaid
sequenceDiagram
    autonumber
    participant C_Orden as C_Orden.php
    participant Entrada_mp as Entrada_materia_prima (Model)
    participant DB as Conexion (DB)
    
    loop Por cada materia prima en receta
        C_Orden->>Entrada_mp: new Entrada_materia_prima(id)
        
        Note right of C_Orden: Buscar entradas con<br/>fecha_vencimiento > NOW()<br/>ORDER BY fecha_compra ASC
        
        Entrada_mp->>DB: Query SELECT entradas
        DB-->>Entrada_mp: Lista de entradas ordenadas
        Entrada_mp-->>C_Orden: Lista de entradas ordenadas
        
        loop Mientras haya cantidad por descontar
            C_Orden->>C_Orden: Calcular cantidad a descontar
            C_Orden->>Entrada_mp: UPDATE existencia
            C_Orden->>C_Orden: Continuar con siguiente entrada
        end
    end
```
