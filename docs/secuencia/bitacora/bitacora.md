# Modulo Bitacora - Diagrama de Secuencia

## Consultar Bitacora

```mermaid
sequenceDiagram
    autonumber
    participant C_Bitacora as C_Bitacora
    participant AuthSession as AuthSession
    participant Bitacora as Bitacora
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Bitacora->>AuthSession: new AuthSession()
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
    
    C_Bitacora->>AuthSession: has_permission("bitacora", "consultar")
    AuthSession-->>C_Bitacora: true/false
    
    alt Sin permiso
        C_Bitacora-->>C_Bitacora: Error 403
    end
    
    C_Bitacora->>Bitacora: new Bitacora(filtros)
    Bitacora->>Db_base: search()
    Db_base->>Conexion: SELECT with JOIN
    Conexion-->>Db_base: array de bitacora
    Db_base-->>Bitacora: array de bitacora
    Bitacora-->>C_Bitacora: array de bitacora
    
    C_Bitacora-->>C_Bitacora: JSON (data, total)
```

## Filtrar por Usuario

```mermaid
sequenceDiagram
    autonumber
    participant C_Bitacora as C_Bitacora
    participant AuthSession as AuthSession
    participant Bitacora as Bitacora
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Bitacora->>AuthSession: new AuthSession()
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
    
    C_Bitacora->>AuthSession: has_permission("bitacora", "consultar")
    AuthSession-->>C_Bitacora: true/false
    
    alt Sin permiso
        C_Bitacora-->>C_Bitacora: Error 403
    end
    
    C_Bitacora->>Bitacora: new Bitacora(id_usuario)
    Bitacora->>Db_base: search()
    Db_base->>Conexion: Query WHERE id_usuario
    Conexion-->>Db_base: array filtrado
    Db_base-->>Bitacora: array filtrado
    Bitacora-->>C_Bitacora: array filtrado
    
    C_Bitacora-->>C_Bitacora: JSON (data)
```

## Filtrar por Tabla

```mermaid
sequenceDiagram
    autonumber
    participant C_Bitacora as C_Bitacora
    participant AuthSession as AuthSession
    participant Bitacora as Bitacora
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Bitacora->>AuthSession: new AuthSession()
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
    
    C_Bitacora->>AuthSession: has_permission("bitacora", "consultar")
    AuthSession-->>C_Bitacora: true/false
    
    alt Sin permiso
        C_Bitacora-->>C_Bitacora: Error 403
    end
    
    C_Bitacora->>Bitacora: new Bitacora(tabla)
    Bitacora->>Db_base: search()
    Db_base->>Conexion: Query WHERE tabla
    Conexion-->>Db_base: array filtrado
    Db_base-->>Bitacora: array filtrado
    Bitacora-->>C_Bitacora: array filtrado
    
    C_Bitacora-->>C_Bitacora: JSON (data)
```
