classDiagram
direction TB

class Conexion {
  +getInstance(): PDO
}

class Db_base {
  +agregar(): int
  +actualizar(): array
  +borrar(): bool
  +search(): array
  +COUNT(): int
}

class Usuario {
  -id: int
  -id_rol: int
  -nombre: string
  -apellido: string
  -hash: string
  -email: string
  -imagen: string
  -active: bool
}

class Cliente {
  -id: int
  -nombre: string
  -apellido: string
  -documento: string
  -telefono: string
  -active: bool
}

class Bitacora {
  -id: int
  -id_usuario: int
  -tabla: string
  -accion: string
  -fecha: datetime
  -descripcion: string
}

class Notificacion {
  -id: int
  -id_usuario: int
  -titulo: string
  -mensaje: string
  -status: int
  -fecha: datetime
}

class Rol {
  -id: int
  -nombre: string
  -descripcion: string
  -active: bool
  +obtener_permisos(): array
}

class Permiso {
  -id: int
  -nombre: string
  -descripcion: string
  -active: bool
}

class Modulo {
  -id: int
  -nombre: string
  -descripcion: string
  -active: bool
}

class Rol_modulo_permiso {
  -id: int
  -id_rol: int
  -id_modulo: int
  -id_permiso: int
  +toggle(): array
}

class Detalle_modulo_permiso {
  -id: int
  -id_rol: int
  -id_modulo: int
  -id_permiso: int
}

class Mesa {
  -id: int
  -nombre: string
  -sillas: int
  -estado: string
  -imagen: string
  -vip: bool
  -active: bool
}

class Orden_mesa {
  -id: int
  -id_mesa: int
  -id_orden: int
}

class Categoria_producto {
  -id: int
  -nombre: string
  -active: bool
}

class ProductoPreparado {
  -id: int
  -id_categoria: int
  -nombre: string
  -imagen: string
  -precio: float
  -detalles: string
  -tipo: string
  -active: bool
}

class ProductoProcesado {
  -id: int
  -id_categoria: int
  -nombre: string
  -imagen: string
  -precio: float
  -detalles: string
  -stock_min: float
  -stock_max: float
  -existencia: float
  -active: bool
}

class Receta {
  -id: int
  -id_producto: int
  -active: bool
}

class Detalle_receta {
  -id: int
  -id_receta: int
  -id_materia_prima: int
  -cantidad: float
}

class Orden {
  -id: int
  -nro_orden: string
  -id_cliente: int
  -fecha: datetime
  -tipo: string
  -status: string
  +getMateriaPrima(id): array
}

class DetalleOrdenProductoPreparado {
  -id: int
  -id_producto: int
  -id_orden: int
  -cantidad: int
  -descripcion: string
  -adicionales: string
}

class DetalleOrdenProductoProcesado {
  -id: int
  -id_producto: int
  -id_orden: int
  -cantidad: int
  -descripcion: string
}

class Categoria_materia_prima {
  -id: int
  -nombre: string
  -active: bool
}

class Unidad {
  -id: int
  -nombre: string
  -alias: string
  -active: bool
}

class Materia_prima {
  -id: int
  -id_categoria: int
  -id_unidad: int
  -nombre: string
  -stock_min: float
  -stock_max: float
  -existencia: float
  -active: bool
}

class Entrada_materia_prima {
  -id: int
  -id_proveedor: int
  -fecha_compra: datetime
}

class Detalle_entrada_materia_prima {
  -id: int
  -codigo: string
  -id_materia_prima: int
  -id_entrada: int
  -fecha_vencimiento: datetime
  -cantidad: float
  -existencia: float
  -broken: float
  -active: bool
}

class Pago_entrada_materia_prima {
  -id: int
  -id_metodo_pago: int
  -id_entrada: int
  -tasa: float
  -precio_compra: float
  -fecha: datetime
  -comprobante: string
  -referencia: string
}

class Entrada_producto_procesado {
  -id: int
  -id_producto: int
  -id_proveedor: int
  -id_unidad: int
  -codigo: string
  -fecha_compra: datetime
  -fecha_vencimiento: datetime
  -cantidad: float
  -existencia: float
  -broken: float
  -active: bool
}

class Pago_entrada_producto_procesado {
  -id: int
  -id_metodo_pago: int
  -id_entrada: int
  -tasa: float
  -precio_compra: float
  -fecha: datetime
  -comprobante: string
  -referencia: string
}

class Metodo_pago {
  -id: int
  -nombre: string
  -active: bool
}

class Venta {
  -id: int
  -id_caja: int
  -id_orden: int
  -IVA: float
  -monto_final: float
  -fecha: datetime
  -direccion: string
  -active: bool
}

class Pago {
  -id: int
  -id_metodo_pago: int
  -monto: float
  -fecha: datetime
  -tasa: float
  -referencia: string
  -comprobante: string
}

class Pago_venta {
  -id: int
  -id_venta: int
  -id_pago: int
}

class Pago_reserva {
  -id: int
  -id_reserva: int
  -id_pago: int
}

class Caja {
  -id: int
  -id_usuario: int
  -monto_inicial_dolar: float
  -monto_inicial_bs: float
  -monto_final_dolar: float
  -monto_final_bs: float
  -fecha_apertura: datetime
  -fecha_cierre: datetime
  -estado: string
  -total_ventas: float
  +cajaDetails(id): array
  +closeCash(id): array
}

class Movimiento_capital {
  -id: int
  -monto: float
  -descripcion: string
  -fecha: datetime
}

class Paquetes {
  -id: int
  -nombre: string
  -precio: float
  -active: bool
}

class Paquetes_mesa {
  -id: int
  -id_paquete: int
  -id_mesa: int
}

class Reservacion {
  -id: int
  -id_paquete: int
  -id_orden: int
  -id_caja: int
  -descripcion: string
  -fecha_inicio: datetime
  -fecha_final: datetime
  -fecha_bloqueo: datetime
  -metodo_pedido: string
  -status: string
}

class Proveedor {
  -id: int
  -nombre: string
  -razon_social: string
  -documento: string
  -n_telefono1: string
  -n_telefono2: string
  -direccion: string
  -active: bool
}

class Delivery {
  -id: int
  -id_usuario_delivery: int
  -id_venta: int
  -active: bool
}

class Credito {
  -id: int
  -id_venta: int
  -fecha: datetime
  -monto_credito: float
  -monto_final: float
  -estado: string
}

class Configuracion {
  -id: int
  -key: string
  -value: string
}

Conexion <|-- Db_base : extends
Db_base <|-- Usuario : extends
Db_base <|-- Cliente : extends
Db_base <|-- Bitacora : extends
Db_base <|-- Notificacion : extends
Db_base <|-- Rol : extends
Db_base <|-- Permiso : extends
Db_base <|-- Modulo : extends
Db_base <|-- Rol_modulo_permiso : extends
Db_base <|-- Detalle_modulo_permiso : extends
Db_base <|-- Mesa : extends
Db_base <|-- Orden_mesa : extends
Db_base <|-- Categoria_producto : extends
Db_base <|-- ProductoPreparado : extends
Db_base <|-- ProductoProcesado : extends
Db_base <|-- Receta : extends
Db_base <|-- Detalle_receta : extends
Db_base <|-- Orden : extends
Db_base <|-- DetalleOrdenProductoPreparado : extends
Db_base <|-- DetalleOrdenProductoProcesado : extends
Db_base <|-- Categoria_materia_prima : extends
Db_base <|-- Unidad : extends
Db_base <|-- Materia_prima : extends
Db_base <|-- Entrada_materia_prima : extends
Db_base <|-- Detalle_entrada_materia_prima : extends
Db_base <|-- Pago_entrada_materia_prima : extends
Db_base <|-- Entrada_producto_procesado : extends
Db_base <|-- Pago_entrada_producto_procesado : extends
Db_base <|-- Metodo_pago : extends
Db_base <|-- Venta : extends
Db_base <|-- Pago : extends
Db_base <|-- Pago_venta : extends
Db_base <|-- Pago_reserva : extends
Db_base <|-- Caja : extends
Db_base <|-- Movimiento_capital : extends
Db_base <|-- Paquetes : extends
Db_base <|-- Paquetes_mesa : extends
Db_base <|-- Reservacion : extends
Db_base <|-- Proveedor : extends
Db_base <|-- Delivery : extends
Db_base <|-- Credito : extends
Db_base <|-- Configuracion : extends
