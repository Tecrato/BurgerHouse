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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "agregar")
    AuthSession-->>C_Producto_preparado: true/false
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(parametros)
    C_Producto_preparado->>ProductoPreparado: agregar()
    ProductoPreparado->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO productos_preparados
    Conexion-->>Db_base: lastInsertId
    Db_base-->>ProductoPreparado: lastInsertId
    ProductoPreparado-->>C_Producto_preparado: lastInsertId
    
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "consultar")
    AuthSession-->>C_Producto_preparado: true/false
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(filtros)
    ProductoPreparado->>Db_base: search()
    Db_base->>Conexion: SELECT with JOIN
    Conexion-->>Db_base: array de productos
    Db_base-->>ProductoPreparado: array de productos
    ProductoPreparado-->>C_Producto_preparado: array de productos
    
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "editar")
    AuthSession-->>C_Producto_preparado: true/false
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(parametros)
    ProductoPreparado->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE
    Conexion-->>Db_base: success
    Db_base-->>ProductoPreparado: success
    ProductoPreparado-->>C_Producto_preparado: success
    
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
    
    C_Producto_preparado->>AuthSession: has_permission("producto_preparado", "agregar")
    AuthSession-->>C_Producto_preparado: true/false
    
    alt Sin permiso
        C_Producto_preparado-->>C_Producto_preparado: Error 403
    end
    
    loop Por cada producto
        C_Producto_preparado->>ProductoPreparado: new ProductoPreparado(item)
        ProductoPreparado->>Db_base: agregar()
        Db_base->>Conexion: INSERT
        Conexion-->>Db_base: lastInsertId
        Db_base-->>ProductoPreparado: lastInsertId
        ProductoPreparado-->>C_Producto_preparado: lastInsertId
    end
    
    C_Producto_preparado-->>C_Producto_preparado: Exito
```
