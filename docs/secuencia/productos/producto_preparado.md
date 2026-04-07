# Modulo Productos Preparados - Diagrama de Secuencia

## Agregar Producto Preparado

```mermaid
sequenceDiagram
    autonumber
    participant C_Producto_preparado as C_Producto_preparado
    participant AuthSession as AuthSession
    participant ProductoPreparado as ProductoPreparado
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Producto_preparado->>AuthSession: new AuthSession()
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "agregar")
    AuthSession-->>C_Producto_preparado: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(parametros)
    activate ProductoPreparado
    ProductoPreparado->>Db_base: add_variables([a.nombre => ..., a.precio => ..., a.descripcion => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>ProductoPreparado: validated
    ProductoPreparado-->>C_Producto_preparado: return
    C_Producto_preparado->>ProductoPreparado: agregar()
    ProductoPreparado->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO productos_preparados
    activate Conexion
    Conexion-->>Db_base: lastInsertId
    Db_base-->>ProductoPreparado: lastInsertId
    ProductoPreparado-->>C_Producto_preparado: lastInsertId
    deactivate ProductoPreparado
    deactivate Conexion
    deactivate Db_base
    
    C_Producto_preparado-->>C_Producto_preparado: Exito
```

## Consultar Productos Preparados

```mermaid
sequenceDiagram
    autonumber
    participant C_Producto_preparado as C_Producto_preparado
    participant AuthSession as AuthSession
    participant ProductoPreparado as ProductoPreparado
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Producto_preparado->>AuthSession: new AuthSession()
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "consultar")
    AuthSession-->>C_Producto_preparado: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(filtros)
    activate ProductoPreparado
    ProductoPreparado->>Db_base: search()
    activate Db_base
    Db_base->>Conexion: SELECT with JOIN
    activate Conexion
    Conexion-->>Db_base: array de productos
    Db_base-->>ProductoPreparado: array de productos
    ProductoPreparado-->>C_Producto_preparado: array de productos
    deactivate ProductoPreparado
    deactivate Conexion
    deactivate Db_base
    
    C_Producto_preparado-->>C_Producto_preparado: JSON (data, total)
```

## Actualizar Producto Preparado

```mermaid
sequenceDiagram
    autonumber
    participant C_Producto_preparado as C_Producto_preparado
    participant AuthSession as AuthSession
    participant ProductoPreparado as ProductoPreparado
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Producto_preparado->>AuthSession: new AuthSession()
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "editar")
    AuthSession-->>C_Producto_preparado: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(parametros)
    activate ProductoPreparado
    ProductoPreparado->>Db_base: add_variables([a.nombre => ..., a.precio => ...])
    activate Db_base
    Db_base-->>Db_base: preg_match validation
    Db_base-->>ProductoPreparado: validated
    ProductoPreparado-->>C_Producto_preparado: return
    ProductoPreparado->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE
    activate Conexion
    Conexion-->>Db_base: success
    Db_base-->>ProductoPreparado: success
    ProductoPreparado-->>C_Producto_preparado: success
    deactivate ProductoPreparado
    deactivate Conexion
    deactivate Db_base
    
    C_Producto_preparado-->>C_Producto_preparado: JSON (success)
```

## Agregar Varios Productos

```mermaid
sequenceDiagram
    autonumber
    participant C_Producto_preparado as C_Producto_preparado
    participant AuthSession as AuthSession
    participant ProductoPreparado as ProductoPreparado
    participant Usuario as Usuario
    participant Rol as Rol
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Producto_preparado->>AuthSession: new AuthSession()
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "agregar")
    AuthSession-->>C_Producto_preparado: true/false
    deactivate AuthSession
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    loop Por cada producto
        C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(item)
        activate ProductoPreparado
        ProductoPreparado->>Db_base: add_variables([a.nombre => ..., a.precio => ...])
        activate Db_base
        Db_base-->>Db_base: preg_match validation
        Db_base-->>ProductoPreparado: validated
        ProductoPreparado-->>C_Producto_preparado: return
        ProductoPreparado->>Db_base: agregar()
        Db_base->>Conexion: INSERT
        activate Conexion
        Conexion-->>Db_base: lastInsertId
        Db_base-->>ProductoPreparado: lastInsertId
        ProductoPreparado-->>C_Producto_preparado: lastInsertId
        deactivate ProductoPreparado
        deactivate Conexion
        deactivate Db_base
    end
    
    C_Producto_preparado-->>C_Producto_preparado: Exito
```
