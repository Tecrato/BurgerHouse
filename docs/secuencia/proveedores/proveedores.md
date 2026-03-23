# Módulo Proveedores - Diagrama de Secuencia

## Agregar Proveedor

```mermaid
sequenceDiagram
    autonumber
    participant C_Proveedor as C_Proveedor
    participant AuthSession as AuthSession
    participant Usuario as Usuario
    participant Rol as Rol
    participant Proveedor as Proveedor
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Proveedor->>AuthSession: new AuthSession()
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
    
    C_Proveedor->>AuthSession: has_permission("proveedores", "agregar")
    AuthSession-->>C_Proveedor: true/false
    
    alt Sin permiso
        C_Proveedor-->>C_Proveedor: Error 403
    end
    
    C_Proveedor->>Proveedor: new Proveedor(nombre, razon_social, documento, telefono1, telefono2, direccion)
    C_Proveedor->>Proveedor: agregar()
    Proveedor->>Db_base: agregar()
    Db_base->>Conexion: INSERT INTO proveedores
    Conexion-->>Db_base: lastInsertId
    Db_base-->>Proveedor: lastInsertId
    Proveedor-->>C_Proveedor: id
    
    C_Proveedor-->>C_Proveedor: JSON (success, id)
```

## Consultar Proveedores

```mermaid
sequenceDiagram
    autonumber
    participant C_Proveedor as C_Proveedor
    participant AuthSession as AuthSession
    participant Proveedor as Proveedor
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Proveedor->>AuthSession: new AuthSession()
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
    
    C_Proveedor->>AuthSession: has_permission("proveedores", "consultar")
    AuthSession-->>C_Proveedor: true/false
    
    alt Sin permiso
        C_Proveedor-->>C_Proveedor: Error 403
    end
    
    C_Proveedor->>Proveedor: new Proveedor(search)
    Proveedor->>Db_base: search()
    Db_base->>Conexion: SELECT WHERE razon_social LIKE
    Conexion-->>Db_base: array de proveedores
    Db_base-->>Proveedor: array de proveedores
    Proveedor-->>C_Proveedor: array de proveedores
    
    C_Proveedor-->>C_Proveedor: JSON (data, recordsFiltered)
```

## Actualizar Proveedor

```mermaid
sequenceDiagram
    autonumber
    participant C_Proveedor as C_Proveedor
    participant AuthSession as AuthSession
    participant Proveedor as Proveedor
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Proveedor->>AuthSession: new AuthSession()
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
    
    C_Proveedor->>AuthSession: has_permission("proveedores", "editar")
    AuthSession-->>C_Proveedor: true/false
    
    alt Sin permiso
        C_Proveedor-->>C_Proveedor: Error 403
    end
    
    C_Proveedor->>Proveedor: new Proveedor(id, datos)
    Proveedor->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE proveedores
    Conexion-->>Db_base: success
    Db_base-->>Proveedor: success
    Proveedor-->>C_Proveedor: success
    
    C_Proveedor-->>C_Proveedor: JSON (success)
```

## Eliminar Proveedor (Soft-delete)

```mermaid
sequenceDiagram
    autonumber
    participant C_Proveedor as C_Proveedor
    participant AuthSession as AuthSession
    participant Proveedor as Proveedor
    participant Db_base as Db_base
    participant Conexion as Conexion
    
    C_Proveedor->>AuthSession: new AuthSession()
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
    
    C_Proveedor->>AuthSession: has_permission("proveedores", "eliminar")
    AuthSession-->>C_Proveedor: true/false
    
    alt Sin permiso
        C_Proveedor-->>C_Proveedor: Error 403
    end
    
    C_Proveedor->>Proveedor: new Proveedor(id, active)
    Proveedor->>Db_base: actualizar()
    Db_base->>Conexion: UPDATE proveedores SET active=0
    Conexion-->>Db_base: success
    Db_base-->>Proveedor: success
    Proveedor-->>C_Proveedor: success
    
    C_Proveedor-->>C_Proveedor: JSON (success)
```
