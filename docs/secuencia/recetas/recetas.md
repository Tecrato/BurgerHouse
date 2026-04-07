# Módulo Recetas - Diagrama de Secuencia

## Agregar Receta

```mermaid
sequenceDiagram
    autonumber
    participant C_Receta as C_Receta
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Receta as Receta
    participant Detalle_receta as Detalle_receta
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Receta->>AuthSession: new AuthSession()
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
    
    C_Receta->>AuthSession: has_permission("recetas", "agregar")
    AuthSession-->>C_Receta: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Receta-->>C_Receta: Error 403
    end
    
    C_Receta->>Receta: new Receta(id_producto)
    activate Receta
    Receta->>Db_base: add_variables([a.id_producto => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Receta: validated
    Receta-->>C_Receta: return
    C_Receta->>Receta: agregar()
    Receta->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO recetas
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Receta: lastInsertId
    Receta-->>C_Receta: id_receta
    
    loop Por cada ingrediente
        C_Receta->>Detalle_receta: new Detalle_receta(id_receta, id_materia_prima, cantidad)
        activate Detalle_receta
        Detalle_receta->>Db_base: add_variables([a.cantidad => ..., a.id_materia_prima => ...])
        activate Db_base
        Db_base-->>Db_base: preg_match validation
        Db_base-->>Detalle_receta: validated
        Detalle_receta-->>C_Receta: return
        Detalle_receta->>Db_base: agregar()
        Db_base->>Conexion: INSERT INTO detalles_receta
        activate Conexion
        Conexion-->>Db_base: lastInsertId
        Detalle_receta-->>C_Receta: lastInsertId
        deactivate Detalle_receta
        deactivate Conexion
        deactivate Db_base
    end
    
    C_Receta-->>C_Receta: JSON (success, id_receta)
    deactivate Receta
    deactivate Conexion
    deactivate Db_base
```

## Consultar Recetas

```mermaid
sequenceDiagram
    autonumber
    participant C_Receta as C_Receta
    participant AuthSession as AuthSession
    participant Receta as Receta
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Receta->>AuthSession: new AuthSession()
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
    
    C_Receta->>AuthSession: has_permission("recetas", "consultar")
    AuthSession-->>C_Receta: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Receta-->>C_Receta: Error 403
    end
    
    C_Receta->>Receta: new Receta(filtros)
    activate Receta
    Receta->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT with JOIN
    activate Conexion
    Conexion-->>Db_base: array de recetas
    Db_base-->>Receta: array de recetas
    Receta-->>C_Receta: array de recetas
    deactivate Receta
    deactivate Conexion
    deactivate Db_base
    
    C_Receta-->>C_Receta: JSON (data, recordsFiltered)
```

## Consultar Detalles de Receta

```mermaid
sequenceDiagram
    autonumber
    participant C_Detalle_receta as C_Detalle_receta
    participant AuthSession as AuthSession
    participant Detalle_receta as Detalle_receta
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Detalle_receta->>AuthSession: new AuthSession()
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
    
    C_Detalle_receta->>AuthSession: has_permission("recetas", "consultar")
    AuthSession-->>C_Detalle_receta: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Detalle_receta-->>C_Detalle_receta: Error 403
    end
    
    C_Detalle_receta->>Detalle_receta: new Detalle_receta(id_receta)
    activate Detalle_receta
    Detalle_receta->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT with JOIN
    activate Conexion
    Conexion-->>Db_base: array de ingredientes
    Db_base-->>Detalle_receta: array de ingredientes
    Detalle_receta-->>C_Detalle_receta: array de ingredientes
    deactivate Detalle_receta
    deactivate Conexion
    deactivate Db_base
    
    C_Detalle_receta-->>C_Detalle_receta: JSON (data)
```

## Actualizar Receta

```mermaid
sequenceDiagram
    autonumber
    participant C_Receta as C_Receta
    participant AuthSession as AuthSession
    participant Detalle_receta as Detalle_receta
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Receta->>AuthSession: new AuthSession()
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
    
    C_Receta->>AuthSession: has_permission("recetas", "editar")
    AuthSession-->>C_Receta: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Receta-->>C_Receta: Error 403
    end
    
    alt Agregar nuevos ingredientes
        loop Por cada ingrediente nuevo
            C_Receta->>Detalle_receta: new Detalle_receta(...)
            activate Detalle_receta
            Detalle_receta->>Db_base: add_variables([a.id_receta => ..., a.id_materia_prima => ..., a.cantidad => ...])
            activate Db_base
            Db_base-->>Db_base: preg_match validation
            Db_base-->>Detalle_receta: validated
            Detalle_receta-->>C_Receta: return
            Detalle_receta->>Db_base: agregar()
            Db_base->>Conexion: INSERT INTO detalles_receta
            activate Conexion
            Conexion-->>Db_base: lastInsertId
            Detalle_receta-->>C_Receta: lastInsertId
            deactivate Detalle_receta
            deactivate Conexion
            deactivate Db_base
        end
    end
    
    alt Eliminar ingredientes removidos
        C_Receta->>C_Receta: Comparar ingredientes actuales vs nuevos
        loop Por cada ingrediente a remover
            C_Receta->>Detalle_receta: new Detalle_receta(id)
            activate Detalle_receta
            Detalle_receta->>Db_base: add_variables([a.id => ...])
            activate Db_base
            Db_base-->>Db_base: preg_match validation
            Db_base-->>Detalle_receta: validated
            Detalle_receta-->>C_Receta: return
            Detalle_receta->>Db_base: borrar()
            Db_base->>Conexion: DELETE FROM detalles_receta
            activate Conexion
            Conexion-->>Db_base: success
            Detalle_receta-->>C_Receta: success
            deactivate Detalle_receta
            deactivate Conexion
            deactivate Db_base
        end
    end
    
    alt Actualizar cantidades
        loop Por cada ingrediente modificado
            C_Receta->>Detalle_receta: new Detalle_receta(id, cantidad)
            activate Detalle_receta
            Detalle_receta->>Db_base: add_variables([a.cantidad => ...])
            activate Db_base
            Db_base-->>Db_base: preg_match validation
            Db_base-->>Detalle_receta: validated
            Detalle_receta-->>C_Receta: return
            Detalle_receta->>Db_base: actualizar()
            Db_base->>Conexion: UPDATE detalles_receta
            activate Conexion
            Conexion-->>Db_base: success
            Detalle_receta-->>C_Receta: success
            deactivate Detalle_receta
            deactivate Conexion
            deactivate Db_base
        end
    end
    
    C_Receta-->>C_Receta: JSON (success)
```

## Eliminar Receta

```mermaid
sequenceDiagram
    autonumber
    participant C_Receta as C_Receta
    participant AuthSession as AuthSession
    participant Receta as Receta
    participant Detalle_receta as Detalle_receta
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Receta->>AuthSession: new AuthSession()
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
    
    C_Receta->>AuthSession: has_permission("recetas", "eliminar")
    AuthSession-->>C_Receta: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Receta-->>C_Receta: Error 403
    end
    
    C_Receta->>Detalle_receta: new Detalle_receta(id_receta)
    activate Detalle_receta
    Detalle_receta->>Db_base: add_variables([a.id_receta => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Detalle_receta: validated
    Detalle_receta-->>C_Receta: return
    Detalle_receta->>Db_base: borrar()
    Db_base->>Conexion: DELETE FROM detalles_receta
    activate Conexion
    Conexion-->>Db_base: success
    Detalle_receta-->>C_Receta: success
    deactivate Detalle_receta
    deactivate Conexion
    deactivate Db_base
    
    C_Receta->>Receta: new Receta(id)
    activate Receta
    Receta->>Db_base: add_variables([a.id => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>Receta: validated
    Receta-->>C_Receta: return
    Receta->>Db_base: borrar()
    Db_base->>Conexion: DELETE FROM recetas
    activate Conexion
    Conexion-->>Db_base: success
    Receta-->>C_Receta: success
    deactivate Receta
    deactivate Conexion
    deactivate Db_base
    
    C_Receta-->>C_Receta: JSON (success)
```
