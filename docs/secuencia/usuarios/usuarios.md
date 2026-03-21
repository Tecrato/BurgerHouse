# Módulo Usuarios - Diagrama de Secuencia

## Agregar Usuario

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Users as C_Users.php
    participant Usuario as Usuario (Model)
    
    JS->>C_Users: fetch("users/add", {POST formData})
    
    alt Validación de permisos
        C_Users->>C_Users: has_permission('usuarios', 'agregar')
        alt Sin permiso
            C_Users-->>JS: Error 403
        end
    end
    
    C_Users->>Usuario: new Usuario(nombre, hash, id_rol, ...)
    Note right of Usuario: Constructor recibe<br/>todos los parámetros
    
    C_Users->>Usuario: agregar()
    Usuario->>DB: INSERT INTO usuario (...)
    DB-->>Usuario: lastInsertId
    Usuario-->>C_Users: lastInsertId
    
    alt Si hay imagen
        C_Users->>C_Users: move_uploaded_file(imagen)
    end
    
    C_Users-->>JS: {success true last_id id}
```

## Consultar Usuarios

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Users as C_Users.php
    participant Usuario as Usuario (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Users: fetch("users/get_all", {POST page limit order})
    
    C_Users->>C_Users: has_permission('usuarios', 'consultar')
    
    C_Users->>Usuario: new Usuario(filtros)
    Usuario->>DB: SELECT ... INNER JOIN roles ON...
    DB-->>Usuario: Array de usuarios
    Usuario-->>C_Users: Array de usuarios
    
    C_Users-->>JS: {data: [...], recordsFiltered: n}
```

## Actualizar Usuario

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Users as C_Users.php
    participant Usuario as Usuario (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Users: fetch("users/update", {POST id datos})
    
    alt Soft-delete
        C_Users->>C_Users: has_permission('usuarios', 'eliminar')
    end
    
    alt Edición normal
        C_Users->>C_Users: has_permission('usuarios', 'editar')
    end
    
    C_Users->>Usuario: new Usuario(id, ...)
    Usuario->>DB: UPDATE usuario SET ...
    DB-->>Usuario: success
    Usuario-->>C_Users: {success: true}
    
    C_Users-->>JS: {success: true}
```

## Eliminar Usuario

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Users as C_Users.php
    participant Usuario as Usuario (Model)
    participant DB as Conexion (DB)
    
    JS->>C_Users: fetch("users/delete", {POST id})
    
    C_Users->>C_Users: has_permission('usuarios', 'eliminar')
    
    C_Users->>Usuario: new Usuario(id)
    Usuario->>DB: DELETE FROM usuario WHERE id=?
    DB-->>Usuario: true/false
    Usuario-->>C_Users: true/false
    
    C_Users-->>JS: {success: true/false}
```

## Login

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Login as C_Login.php
    participant Usuario as Usuario (Model)
    participant Auth as AuthSession
    participant DB as Conexion (DB)
    
    JS->>C_Login: fetch("login/login", {POST email hash})
    
    C_Login->>Usuario: new Usuario(email, hash)
    Usuario->>DB: SELECT WHERE email=? AND hash=?
    DB-->>Usuario: usuario encontrado / null
    Usuario-->>C_Login: usuario encontrado / null

    alt Usuario no encontrado
        C_Login-->>JS: {success false message "Credenciales incorrectas"}
    end
    
    alt Usuario encontrado
        C_Login->>Auth: crearSesion(usuario)
        Auth->>Auth: session_start()
        Auth->>Auth: session.id = usuario.id
        Auth->>Auth: session.rol = usuario.rol
        
        C_Login-->>JS: {success true usuario {...}}
    end
```

## Logout

```mermaid
sequenceDiagram
    autonumber
    participant JS as JavaScript (Frontend)
    participant C_Login as C_Login.php
    participant Auth as AuthSession
    
    JS->>C_Login: fetch("login/logout")
    
    C_Login->>Auth: destruirSesion()
    Auth->>Auth: session_destroy()
    Auth->>Auth: session = []
    
    C_Login-->>JS: {success: true}
```
    JS->>C_Login: fetch("login/logout")
    
    C_Login->>Auth: destruirSesion()
    Auth->>Auth: session_destroy()
    Auth->>Auth: session = []
    
    C_Login-->>JS: {success: true}
```
