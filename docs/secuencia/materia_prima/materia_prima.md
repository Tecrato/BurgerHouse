# Modulo Materia Prima - Diagrama de Secuencia

## Agregar Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant C_Materia_prima as C_Materia_prima
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Materia_prima as Materia_prima
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Materia_prima->>AuthSession: new AuthSession()
    activate AuthSession
    AuthSession->>Usuario: new Usuario(id_session)
    activate Usuario
    Usuario->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: Query usuario
    activate Conexion
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    deactivate Conexion
    Usuario-->>AuthSession: usuario
    deactivate Usuario
    deactivate Db_base
    
    AuthSession->>Rol: new Rol(id_rol)
    activate Rol
    Rol->>Db_base: obtener_permisos()
    activate Db_base
    Db_base->>Conexion: Query permisos
    activate Conexion
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    deactivate Conexion
    Rol-->>AuthSession: permisos
    deactivate Rol
    deactivate Db_base
    
    C_Materia_prima->>AuthSession: has_permission("materia_prima", "agregar")
    AuthSession-->>C_Materia_prima: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Materia_prima-->>C_Materia_prima: Error 403
    end
    
    C_Materia_prima->>Materia_prima: new Materia_prima(parametros)
    activate Materia_prima
    Materia_prima->>Db_base: add_variables([a.nombre => ..., a.unidad => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Materia_prima: validated
    Materia_prima-->>C_Materia_prima: return
    C_Materia_prima->>Materia_prima: agregar()
    Materia_prima->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO materia_prima
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Materia_prima: lastInsertId
    Materia_prima-->>C_Materia_prima: lastInsertId
    deactivate Materia_prima
    deactivate Conexion
    deactivate Db_base
    
    C_Materia_prima-->>C_Materia_prima: Exito
```

## Registrar Entrada de Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant C_Entrada_mp as C_Entrada_materia_prima
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Entrada_mp as Entrada_materia_prima
    participant Detalle_mp as Detalle_entrada_materia_prima
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Entrada_mp->>AuthSession: new AuthSession()
    activate AuthSession
    AuthSession->>Usuario: new Usuario(id_session)
    activate Usuario
    Usuario->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: Query usuario
    activate Conexion
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    deactivate Conexion
    Usuario-->>AuthSession: usuario
    deactivate Usuario
    deactivate Db_base
    
    AuthSession->>Rol: new Rol(id_rol)
    activate Rol
    Rol->>Db_base: obtener_permisos()
    activate Db_base
    Db_base->>Conexion: Query permisos
    activate Conexion
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    deactivate Conexion
    Rol-->>AuthSession: permisos
    deactivate Rol
    deactivate Db_base
    
    C_Entrada_mp->>AuthSession: has_permission("materia_prima", "agregar")
    AuthSession-->>C_Entrada_mp: true/false
    deactivate AuthSession
    
    C_Entrada_mp->>Entrada_mp: new Entrada_materia_prima(parametros)
    activate Entrada_mp
    Entrada_mp->>Db_base: add_variables([a.fecha => ..., a.id_proveedor => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Entrada_mp: validated
    Entrada_mp-->>C_Entrada_mp: return
    C_Entrada_mp->>Entrada_mp: agregar()
    Entrada_mp->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO entradas_materia_prima
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Entrada_mp: lastInsertId
    Entrada_mp-->>C_Entrada_mp: lastInsertId
    
    loop Por cada item
        C_Entrada_mp->>Detalle_mp: new Detalle_entrada_materia_prima(parametros)
        activate Detalle_mp
        Detalle_mp->>Db_base: add_variables([a.cantidad => ..., a.id_materia_prima => ...])
        activate Db_base
        Db_base-->>Db_base: preg_match validation
        Db_base-->>Detalle_mp: validated
        Detalle_mp-->>C_Entrada_mp: return
        Detalle_mp->>Db_base: agregar()
        Db_base->>Conexion: INSERT INTO detalles_entradas_materia_prima
        activate Conexion
        Conexion-->>Db_base: lastInsertId
        Detalle_mp-->>C_Entrada_mp: lastInsertId
        deactivate Detalle_mp
        deactivate Conexion
        deactivate Db_base
    end
    
    C_Entrada_mp-->>C_Entrada_mp: Exito
    deactivate Entrada_mp
    deactivate Conexion
    deactivate Db_base
```

## Consultar Entradas de Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant C_Entrada_mp_det as C_Entrada_materia_prima_detalles
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Detalle_mp as Detalle_entrada_materia_prima
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Entrada_mp_det->>AuthSession: new AuthSession()
    activate AuthSession
    AuthSession->>Usuario: new Usuario(id_session)
    activate Usuario
    Usuario->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: Query usuario
    activate Conexion
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    deactivate Conexion
    Usuario-->>AuthSession: usuario
    deactivate Usuario
    deactivate Db_base
    
    AuthSession->>Rol: new Rol(id_rol)
    activate Rol
    Rol->>Db_base: obtener_permisos()
    activate Db_base
    Db_base->>Conexion: Query permisos
    activate Conexion
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    deactivate Conexion
    Rol-->>AuthSession: permisos
    deactivate Rol
    deactivate Db_base
    
    C_Entrada_mp_det->>AuthSession: has_permission("materia_prima", "consultar")
    AuthSession-->>C_Entrada_mp_det: true/false
    deactivate AuthSession
    
    C_Entrada_mp_det->>Detalle_mp: new Detalle_entrada_materia_prima(filtros)
    activate Detalle_mp
    Detalle_mp->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT with JOIN
    activate Conexion
    Conexion-->>Db_base: array de detalles
    Db_base-->>Detalle_mp: array de detalles
    Detalle_mp-->>C_Entrada_mp_det: array de detalles
    deactivate Detalle_mp
    deactivate Conexion
    deactivate Db_base
    
    C_Entrada_mp_det-->>C_Entrada_mp_det: JSON (data, total)
```

## Agregar Pago de Entrada Materia Prima

```mermaid
sequenceDiagram
    autonumber
    participant C_Pago_mp as C_Pago_entrada_materia_prima
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Pago_mp as Pago_entrada_materia_prima
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Pago_mp->>AuthSession: new AuthSession()
    activate AuthSession
    AuthSession->>Usuario: new Usuario(id_session)
    activate Usuario
    Usuario->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: Query usuario
    activate Conexion
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    deactivate Conexion
    Usuario-->>AuthSession: usuario
    deactivate Usuario
    deactivate Db_base
    
    AuthSession->>Rol: new Rol(id_rol)
    activate Rol
    Rol->>Db_base: obtener_permisos()
    activate Db_base
    Db_base->>Conexion: Query permisos
    activate Conexion
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    deactivate Conexion
    Rol-->>AuthSession: permisos
    deactivate Rol
    deactivate Db_base
    
    C_Pago_mp->>AuthSession: has_permission("materia_prima", "agregar")
    AuthSession-->>C_Pago_mp: true/false
    deactivate AuthSession
    
    C_Pago_mp->>Pago_mp: new Pago_entrada_materia_prima(parametros)
    activate Pago_mp
    Pago_mp->>Db_base: add_variables([a.monto => ..., a.id_entrada => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Pago_mp: validated
    Pago_mp-->>C_Pago_mp: return
    C_Pago_mp->>Pago_mp: agregar()
    Pago_mp->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO pagos_entrada_materia_prima
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Pago_mp: lastInsertId
    Pago_mp-->>C_Pago_mp: lastInsertId
    deactivate Pago_mp
    deactivate Conexion
    deactivate Db_base
    
    C_Pago_mp-->>C_Pago_mp: Exito
```

## Actualizar Existencia (Descontar Stock)

```mermaid
sequenceDiagram
    autonumber
    participant C_Orden as C_Orden
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Entrada_mp as Entrada_materia_prima
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Orden->>AuthSession: new AuthSession()
    activate AuthSession
    AuthSession->>Usuario: new Usuario(id_session)
    activate Usuario
    Usuario->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: Query usuario
    activate Conexion
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    deactivate Conexion
    Usuario-->>AuthSession: usuario
    deactivate Usuario
    deactivate Db_base
    
    AuthSession->>Rol: new Rol(id_rol)
    activate Rol
    Rol->>Db_base: obtener_permisos()
    activate Db_base
    Db_base->>Conexion: Query permisos
    activate Conexion
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    deactivate Conexion
    Rol-->>AuthSession: permisos
    deactivate Rol
    deactivate Db_base
    
    C_Orden->>AuthSession: has_permission("ordenes", "agregar")
    AuthSession-->>C_Orden: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Orden-->>C_Orden: Error 403
    end
    
    loop Por cada materia prima
        C_Orden->>Entrada_mp: new Entrada_materia_prima(id)
        activate Entrada_mp
        C_Orden->>Entrada_mp: search()
        Entrada_mp->>Db_base: search()
        activate Db_base
        Db_base->>Conexion: Query entradas FIFO
        activate Conexion
        Conexion-->>Db_base: lista ordenada
        Db_base-->>Entrada_mp: lista
        Entrada_mp-->>C_Orden: lista
        
        loop Mientras haya cantidad
            C_Orden->>Entrada_mp: actualizar()
            Entrada_mp->>Db_base: actualizar()
            activate Db_base
            Db_base->>Conexion: UPDATE existencia
            activate Conexion
            Conexion-->>Db_base: ok
            deactivate Conexion
            deactivate Db_base
        end
        deactivate Entrada_mp
    end
```
