# Módulo Reservaciones - Diagrama de Secuencia

## Agregar Reservación

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Reservacion as C_Reservacion.php
    participant Reservacion as Reservacion (Model)
    participant Paquetes_mesa as Paquetes_mesa (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Reservacion: fetch("reservacion/add", {POST, formData})
    
    alt Validación de permisos
        C_Reservacion->>C_Reservacion: has_permission('reservaciones', 'agregar')
    end
    
    alt Crear Orden primero
        C_Reservacion->>C_Reservacion: fetch("orden/add", {...})
    end
    
    C_Reservacion->>Reservacion: new Reservacion(
        id_orden, 
        id_paquete, 
        fecha_inicio, 
        fecha_final,
        descripcion
    )
    
    Reservacion->>DB: INSERT INTO reservaciones (...)
    DB-->>Reservacion: lastInsertId
    Reservacion-->>C_Reservacion: lastInsertId
    
    loop Por cada mesa en paquete
        C_Reservacion->>Paquetes_mesa: new Paquetes_mesa(id_paquete, id_mesa)
        Paquetes_mesa->>DB: INSERT INTO paquetes_mesas
        DB-->>Paquetes_mesa: lastInsertId
        Paquetes_mesa-->>C_Reservacion: lastInsertId
    end
    
    C_Reservacion-->>JS: {success: true, last_id: id}
```

## Consultar Reservaciones

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Reservacion as C_Reservacion.php
    participant Reservacion as Reservacion (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Reservacion: fetch("reservacion/get_all", {POST, page, limit, filtros})
    
    C_Reservacion->>C_Reservacion: has_permission('reservaciones', 'consultar')
    
    C_Reservacion->>Reservacion: new Reservacion(filtros)
    
    Note right of Reservacion: INNER JOIN paquetes_reservacion<br/>INNER JOIN orden<br/>INNER JOIN clientes
    
    Reservacion->>DB: Query SELECT con JOINS
    Note right of Reservacion: Devuelve: id, paquete, cliente,<br/>fechas, status, etc.
    DB-->>Reservacion: Array de reservaciones
    Reservacion-->>C_Reservacion: Array de reservaciones
    
    C_Reservacion-->>JS: {data: [...], recordsFiltered: n}
```

## Finalizar Reservación (al pagar)

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Reservacion as C_Reservacion.php
    participant Reservacion as Reservacion (Model)
    participant Orden as Orden (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Reservacion: fetch("calendario/update", {POST, id, status: 'finalizada'})
    
    C_Reservacion->>C_Reservacion: has_permission('reservaciones', 'editar')
    
    alt Actualizar reservación
        C_Reservacion->>Reservacion: new Reservacion(id, status: 'finalizada')
        Reservacion->>DB: UPDATE reservaciones SET status='finalizada'
        DB-->>Reservacion: {success: true}
        Reservacion-->>C_Reservacion: {success: true}
    end
    
    alt Registrar pago de reservación
        JS->>C_Reservacion: fetch("payment/add_many", {...})
        C_Reservacion->>C_Reservacion: Registrar pagos
    end
    
    alt Actualizar orden a pagada
        C_Reservacion->>Orden: new Orden(id, status: 'pagado')
        Orden->>DB: UPDATE orden SET status='pagado'
        DB-->>Orden: {success: true}
        Orden-->>C_Reservacion: {success: true}
    end
    
    C_Reservacion-->>JS: {success: true}
```

## Bloquear Fechas (No disponible)

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Reservacion as C_Reservacion.php
    participant Reservacion as Reservacion (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Reservacion: fetch("reservacion/add", {POST, fecha_bloqueo, ...})
    
    C_Reservacion->>C_Reservacion: has_permission('reservaciones', 'agregar')
    
    C_Reservacion->>Reservacion: new Reservacion(
        fecha_bloqueo, 
        status: 'bloqueado'
    )
    
    Reservacion->>DB: INSERT INTO reservaciones (...)
    DB-->>Reservacion: lastInsertId
    Reservacion-->>C_Reservacion: lastInsertId
    
    C_Reservacion-->>JS: {success: true, last_id: id}
```
