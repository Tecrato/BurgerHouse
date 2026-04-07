# Modulo Caja - Diagrama de Secuencia

## Abrir Caja

```mermaid
sequenceDiagram
    autonumber
    participant C_Caja as C_Caja
    participant AuthSession as AuthSession
    participant Caja as Caja
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Caja->>AuthSession: new AuthSession()
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
    
    C_Caja->>AuthSession: has_permission("caja", "agregar")
    AuthSession-->>C_Caja: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Caja-->>C_Caja: Error 403
    end
    
    C_Caja->>Caja: new Caja(parametros)
    activate Caja
    Caja->>Db_base: add_variables([a.monto_inicial => ..., a.id_usuario => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Caja: validated
    Caja-->>C_Caja: return
    C_Caja->>Caja: agregar()
    Caja->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO caja
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Caja: lastInsertId
    Caja-->>C_Caja: lastInsertId
    deactivate Caja
    deactivate Conexion
    deactivate Db_base
    
    C_Caja-->>C_Caja: Exito
```

## Consultar Cajas

```mermaid
sequenceDiagram
    autonumber
    participant C_Caja as C_Caja
    participant AuthSession as AuthSession
    participant Caja as Caja
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Caja->>AuthSession: new AuthSession()
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
    
    C_Caja->>AuthSession: has_permission("caja", "consultar")
    AuthSession-->>C_Caja: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Caja-->>C_Caja: Error 403
    end
    
    C_Caja->>Caja: new Caja(filtros)
    activate Caja
    Caja->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT
    activate Conexion
    Conexion-->>Db_base: array de cajas
    Db_base-->>Caja: array de cajas
    Caja-->>C_Caja: array de cajas
    deactivate Caja
    deactivate Conexion
    deactivate Db_base
    
    C_Caja-->>C_Caja: JSON (data, total)
```

## Realizar Venta

```mermaid
sequenceDiagram
    autonumber
    participant C_Venta as C_Venta
    participant AuthSession as AuthSession
    participant Venta as Venta
    participant Pago as Pago
    participant Pago_venta as Pago_venta
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Venta->>AuthSession: new AuthSession()
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
    
    C_Venta->>AuthSession: has_permission("ventas", "agregar")
    AuthSession-->>C_Venta: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Venta-->>C_Venta: Error 403
    end
    
    C_Venta->>Venta: new Venta(parametros)
    activate Venta
    Venta->>Db_base: add_variables([a.total => ..., a.id_caja => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Venta: validated
    Venta-->>C_Venta: return
    Venta->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO ventas
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Venta: lastInsertId
    Venta-->>C_Venta: lastInsertId
    
    loop Por cada metodo de pago
        C_Venta->>Pago: new Pago(parametros)
        activate Pago
        Pago->>Db_base: add_variables([a.monto => ..., a.metodo => ...])
        activate Db_base
        Db_base-->>Db_base: preg_match validation
        Db_base-->>Pago: validated
        Pago-->>C_Venta: return
        Pago->>Db_base: agregar()
        Db_base->>Conexion: INSERT INTO pagos
        activate Conexion
        Conexion-->>Db_base: id_pago
        Db_base-->>Pago: id_pago
        Pago-->>C_Venta: id_pago
        deactivate Pago
        deactivate Conexion
        deactivate Db_base
    end
    
    loop Por cada pago
        C_Venta->>Pago_venta: new Pago_venta(id_venta, id_pago)
        activate Pago_venta
        Pago_venta->>Db_base: add_variables([a.id_venta => ..., a.id_pago => ...])
        activate Db_base
        Db_base-->>Db_base: preg_match validation
        Db_base-->>Pago_venta: validated
        Pago_venta-->>C_Venta: return
        Pago_venta->>Db_base: agregar()
        Db_base->>Conexion: INSERT INTO pago_venta
        activate Conexion
        deactivate Pago_venta
        deactivate Conexion
        deactivate Db_base
    end
    
    C_Venta-->>C_Venta: Exito
    deactivate Venta
    deactivate Conexion
    deactivate Db_base
```

## Cerrar Caja

```mermaid
sequenceDiagram
    autonumber
    participant C_Caja as C_Caja
    participant AuthSession as AuthSession
    participant Caja as Caja
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Caja->>AuthSession: new AuthSession()
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
    
    C_Caja->>AuthSession: has_permission("caja", "editar")
    AuthSession-->>C_Caja: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Caja-->>C_Caja: Error 403
    end
    
    C_Caja->>Caja: new Caja(id, estado)
    activate Caja
    Caja->>Db_base: add_variables([a.estado => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Caja: validated
    Caja-->>C_Caja: return
    Caja->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE estado
    activate Conexion
    Conexion-->>Db_base: ok
    Caja-->>C_Caja: ok
    deactivate Caja
    deactivate Conexion
    deactivate Db_base
    
    C_Caja->>Caja: closeCash(id)
    activate Caja
    Caja->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: CALL CerrarCaja
    activate Conexion
    Conexion-->>Db_base: summary
    Db_base-->>Caja: summary
    Caja-->>C_Caja: summary
    deactivate Caja
    deactivate Conexion
    deactivate Db_base
    
    C_Caja-->>C_Caja: JSON (success, summary)
```

## Ver Detalles de Caja

```mermaid
sequenceDiagram
    autonumber
    participant C_Caja as C_Caja
    participant AuthSession as AuthSession
    participant Caja as Caja
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Caja->>AuthSession: new AuthSession()
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
    
    C_Caja->>AuthSession: has_permission("caja", "consultar")
    AuthSession-->>C_Caja: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Caja-->>C_Caja: Error 403
    end
    
    C_Caja->>Caja: new Caja(id)
    activate Caja
    Caja->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: CALL Caja
    activate Conexion
    Conexion-->>Db_base: detalles
    Db_base-->>Caja: detalles
    Caja-->>C_Caja: detalles
    deactivate Caja
    deactivate Conexion
    deactivate Db_base
    
    C_Caja-->>C_Caja: JSON (data)
```
