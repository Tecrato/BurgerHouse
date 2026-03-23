# Modulo Mesas - Diagrama de Secuencia

## Agregar Mesa

```mermaid
sequenceDiagram
    autonumber
    participant C_Mesas as C_Mesas
    participant AuthSession as AuthSession
    participant Mesa as Mesa
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Mesas->>AuthSession: new AuthSession()
    AuthSession->>Usuario: new Usuario(id_session)
    Usuario->>Db_base: search()
    Db_base->>Conexion: Query usuario
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    Usuario-->>AuthSession: usuario
    
    AuthSession->>Rol: new Rol(id_rol)
    Rol->>Db_base: obtener_permisos()
    Db_base->>Conexion: Query permisos
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    Rol-->>AuthSession: permisos
    
    C_Mesas->>AuthSession: has_permission("mesas", "agregar")
    AuthSession-->>C_Mesas: true/false
    
    alt Sin permiso
        C_Mesas-->>C_Mesas: Error 403
    end
    
    C_Mesas->>Mesa: new Mesa(parametros)
    C_Mesas->>Mesa: agregar()
    Mesa->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO mesas
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Mesa: lastInsertId
    Mesa-->>C_Mesas: lastInsertId
    
    C_Mesas-->>C_Mesas: Exito
```

## Consultar Mesas

```mermaid
sequenceDiagram
    autonumber
    participant C_Mesas as C_Mesas
    participant AuthSession as AuthSession
    participant Mesa as Mesa
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Mesas->>AuthSession: new AuthSession()
    AuthSession->>Usuario: new Usuario(id_session)
    Usuario->>Db_base: search()
    Db_base->>Conexion: Query usuario
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    Usuario-->>AuthSession: usuario
    
    AuthSession->>Rol: new Rol(id_rol)
    Rol->>Db_base: obtener_permisos()
    Db_base->>Conexion: Query permisos
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    Rol-->>AuthSession: permisos
    
    C_Mesas->>AuthSession: has_permission("mesas", "consultar")
    AuthSession-->>C_Mesas: true/false
    
    alt Sin permiso
        C_Mesas-->>C_Mesas: Error 403
    end
    
    C_Mesas->>Mesa: new Mesa(filtros)
    Mesa->>Db_base: search()
    Db_base->>Conexion: SELECT
    Conexion-->>Db_base: array de mesas
    Db_base-->>Mesa: array de mesas
    Mesa-->>C_Mesas: array de mesas
    
    C_Mesas-->>C_Mesas: JSON (data, total)
```

## Actualizar Mesa

```mermaid
sequenceDiagram
    autonumber
    participant C_Mesas as C_Mesas
    participant AuthSession as AuthSession
    participant Mesa as Mesa
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Mesas->>AuthSession: new AuthSession()
    AuthSession->>Usuario: new Usuario(id_session)
    Usuario->>Db_base: search()
    Db_base->>Conexion: Query usuario
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    Usuario-->>AuthSession: usuario
    
    AuthSession->>Rol: new Rol(id_rol)
    Rol->>Db_base: obtener_permisos()
    Db_base->>Conexion: Query permisos
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    Rol-->>AuthSession: permisos
    
    C_Mesas->>AuthSession: has_permission("mesas", "editar")
    AuthSession-->>C_Mesas: true/false
    
    alt Sin permiso
        C_Mesas-->>C_Mesas: Error 403
    end
    
    C_Mesas->>Mesa: new Mesa(id, datos)
    Mesa->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE
    Conexion-->>Db_base: success
    Db_base-->>Mesa: success
    Mesa-->>C_Mesas: success
    
    C_Mesas-->>C_Mesas: JSON (success)
```

## Bloquear Mesa

```mermaid
sequenceDiagram
    autonumber
    participant C_Orden_mesa as C_Orden_mesa
    participant AuthSession as AuthSession
    participant Orden_mesa as Orden_mesa
    participant Mesa as Mesa
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Orden_mesa->>AuthSession: new AuthSession()
    AuthSession->>Usuario: new Usuario(id_session)
    Usuario->>Db_base: search()
    Db_base->>Conexion: Query usuario
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    Usuario-->>AuthSession: usuario
    
    AuthSession->>Rol: new Rol(id_rol)
    Rol->>Db_base: obtener_permisos()
    Db_base->>Conexion: Query permisos
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    Rol-->>AuthSession: permisos
    
    C_Orden_mesa->>AuthSession: has_permission("ordenes_mesa", "agregar")
    AuthSession-->>C_Orden_mesa: true/false
    
    alt Sin permiso
        C_Orden_mesa-->>C_Orden_mesa: Error 403
    end
    
    loop Por cada mesa-orden
        C_Orden_mesa->>Orden_mesa: new Orden_mesa(id_mesa, id_orden)
        Orden_mesa->>Db_base: agregar()
        Db_base->>Conexion: INSERT INTO orden_mesa
        Conexion-->>Db_base: lastInsertId
        Db_base-->>Orden_mesa: lastInsertId
        Orden_mesa-->>C_Orden_mesa: ok
    end
    
    C_Orden_mesa->>Mesa: new Mesa(id, estado)
    Mesa->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE estado
    Conexion-->>Db_base: ok
    Mesa-->>C_Orden_mesa: ok
    
    C_Orden_mesa-->>C_Orden_mesa: Exito
```

## Liberar Mesa

```mermaid
sequenceDiagram
    autonumber
    participant C_Orden_mesa as C_Orden_mesa
    participant AuthSession as AuthSession
    participant Orden_mesa as Orden_mesa
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Orden_mesa->>AuthSession: new AuthSession()
    AuthSession->>Usuario: new Usuario(id_session)
    Usuario->>Db_base: search()
    Db_base->>Conexion: Query usuario
    Conexion-->>Db_base: datos usuario
    Db_base-->>Usuario: datos usuario
    Usuario-->>AuthSession: usuario
    
    AuthSession->>Rol: new Rol(id_rol)
    Rol->>Db_base: obtener_permisos()
    Db_base->>Conexion: Query permisos
    Conexion-->>Db_base: lista permisos
    Db_base-->>Rol: lista permisos
    Rol-->>AuthSession: permisos
    
    C_Orden_mesa->>AuthSession: has_permission("ordenes_mesa", "eliminar")
    AuthSession-->>C_Orden_mesa: true/false
    
    alt Sin permiso
        C_Orden_mesa-->>C_Orden_mesa: Error 403
    end
    
    C_Orden_mesa->>Orden_mesa: new Orden_mesa(id)
    Orden_mesa->>Db_base: borrar()
    Db_base->>Conexion: DELETE
    Conexion-->>Db_base: true/false
    Db_base-->>Orden_mesa: true/false
    Orden_mesa-->>C_Orden_mesa: true/false
    
    C_Orden_mesa-->>C_Orden_mesa: JSON (success)
```
