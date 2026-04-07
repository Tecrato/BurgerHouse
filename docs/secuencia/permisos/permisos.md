# Modulo Permisos - Diagrama de Secuencia

## Consultar Modulos

```mermaid
sequenceDiagram
    autonumber
    participant C_Permisos as C_Permisos
    participant AuthSession as AuthSession
    participant Modulo as Modulo
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Permisos->>AuthSession: new AuthSession()
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
    
    C_Permisos->>AuthSession: has_permission("permisos", "consultar")
    AuthSession-->>C_Permisos: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Permisos-->>C_Permisos: Error 403
    end
    
    C_Permisos->>Modulo: new Modulo()
    activate Modulo
    Modulo->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT modulos
    activate Conexion
    Conexion-->>Db_base: array de modulos
    Db_base-->>Modulo: array de modulos
    Modulo-->>C_Permisos: array de modulos
    deactivate Modulo
    deactivate Conexion
    deactivate Db_base
    
    C_Permisos-->>C_Permisos: JSON (data, total)
```

## Consultar Permisos Disponibles

```mermaid
sequenceDiagram
    autonumber
    participant C_Permisos as C_Permisos
    participant AuthSession as AuthSession
    participant Permiso as Permiso
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Permisos->>AuthSession: new AuthSession()
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
    
    C_Permisos->>AuthSession: has_permission("permisos", "consultar")
    AuthSession-->>C_Permisos: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Permisos-->>C_Permisos: Error 403
    end
    
    C_Permisos->>Permiso: new Permiso()
    activate Permiso
    Permiso->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT permisos
    activate Conexion
    Conexion-->>Db_base: array de permisos
    Db_base-->>Permiso: array de permisos
    Permiso-->>C_Permisos: array de permisos
    deactivate Permiso
    deactivate Conexion
    deactivate Db_base
    
    C_Permisos-->>C_Permisos: JSON (permisos, asignados)
```

## Toggle Permiso

```mermaid
sequenceDiagram
    autonumber
    participant C_Permisos as C_Permisos
    participant AuthSession as AuthSession
    participant Rol_modulo_permiso as Rol_modulo_permiso
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Permisos->>AuthSession: new AuthSession()
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
    
    C_Permisos->>AuthSession: has_permission("permisos", "editar")
    AuthSession-->>C_Permisos: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Permisos-->>C_Permisos: Error 403
    end
    
    C_Permisos->>Rol_modulo_permiso: new Rol_modulo_permiso(parametros)
    activate Rol_modulo_permiso
    Rol_modulo_permiso->>Db_base: add_variables([a.id_rol => ..., a.id_modulo => ..., a.id_permiso => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Rol_modulo_permiso: validated
    Rol_modulo_permiso-->>C_Permisos: return
    C_Permisos->>Rol_modulo_permiso: toggle()
    Rol_modulo_permiso->>Db_base: toggle()
    Db_base->>Conexion: INSERT/DELETE
    activate Conexion
    Conexion-->>Db_base: ok
    Db_base-->>Rol_modulo_permiso: ok
    Rol_modulo_permiso-->>C_Permisos: ok
    deactivate Rol_modulo_permiso
    deactivate Conexion
    deactivate Db_base
    
    C_Permisos-->>C_Permisos: JSON (success, action)
```

## Obtener Permisos de un Rol

```mermaid
sequenceDiagram
    autonumber
    participant C_Permisos as C_Permisos
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Permisos->>AuthSession: new AuthSession()
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
    
    C_Permisos->>AuthSession: has_permission("permisos", "consultar")
    AuthSession-->>C_Permisos: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Permisos-->>C_Permisos: Error 403
    end
    
    C_Permisos->>Rol: new Rol(id_rol)
    activate Rol
    Rol->>Db_base: obtener_permisos()
    activate Db_base
    Db_base->>Conexion: Query permisos
    activate Conexion
    Conexion-->>Db_base: array grouped
    Db_base-->>Rol: array grouped
    Rol-->>C_Permisos: array grouped
    deactivate Rol
    deactivate Conexion
    deactivate Db_base
    
    C_Permisos-->>C_Permisos: JSON (data)
```
