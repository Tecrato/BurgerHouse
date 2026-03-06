import {myfecth} from "./Functions2.js"
import functionGeneral from "./Functions.js"
const { searchParam, fecha, hora } = functionGeneral()
const name_user = (id_user) => {
    let result = myfecth("users/get_all", {}, { id: id_user }, null, "POST")
    result = result.json()
    
    let nombre = result[0].nombre + " " + result[0].apellido
    return nombre
}
export function targetPermission(data, edit=false, del=false) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <span class="badge bh_1 d-flex justify-content-center align-items-center position-absolute rounded-circle" style="z-index: 1; width: 40px; height: 40px; top: -15px; right: -10px;">
                    <span><i style="font-size: 24px;" data-feather="shield" class="svg-icon"></i></span>
                </span>
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">${data.nombre}</h5>
                            </div>
                        </div>

                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="text-start">
                                    <h4>Descripcion</h4>
                                    <div class="fs-6">${data.descripcion}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    ${edit ? 
                                    `<a class="link-secondary edit_btn" data-id="${data.id}" module-edit="rol" data-module="rol" data-module-edit="roles y permisos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Editar Permiso" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>`
                                    : ""}
                                    ${del ?
                                        `<a class="link-secondary trash_btn btn_eliminar" data-id="${data.id}" data-module="rol" data-module-delete="roles y permisos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Permiso" data-bs-placement="bottom">
                                            <i data-feather="trash-2"></i>
                                        </a>`
                                    : ""}
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }



export default function Templates() {
    function targetProductPrepared(objet) {
        return `
        <div class="col">
            <div class="card">
                <img src="${objet.imagen ? "media/producto_preparado/" + objet.imagen : "./assets/img/big/banner_login.png"}" class="card-img-top" alt="${objet.nombre ? 'Imagen de ' + objet.nombre : 'Imagen del producto preparado'}" style="object-fit: cover; height: 140px">
                <div class="card-body">
                    <h5 class="card-title">${objet.nombre}</h5>
                    <p class=" fs-6 truncate-3-lines">${objet.detalles}</p>
                </div>
                <div class="card-footer">
                    <small class="text-body-secondary">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <p class="mb-0">Precio: ${objet.precio}$</p>
                            <div class="d-flex gap-3">
                                <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="productPrepared" data-module-edit="Producto preparado"  style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-product" data-bs-title="Editar Producto" data-bs-placement="bottom">
                                    <i data-feather="edit"></i>
                                </a>
                                <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="productPrepared" data-module-delete="Producto preparado"  style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Producto" data-bs-placement="bottom">
                                    <i data-feather="trash-2"></i>
                                </a>
                            </div>
                        </div>
                    </small>
                </div>
            </div>
        </div>
                `
    }
    function targetProductProcess(objet) {
        return `
        <div class="col">
            <div class="card">
                <img src="${objet.imagen ? "media/producto_procesado/" + objet.imagen : "./assets/img/big/banner_login.png"}" class="card-img-top" alt="${objet.nombre ? 'Imagen de ' + objet.nombre : 'Imagen del producto procesado'}" style="object-fit: cover; height: 140px">
                <div class="card-body">
                    <h5 class="card-title">${objet.nombre}</h5>
                    <p class=" fs-6 truncate-3-lines">${objet.detalles}</p>
                    <p>STOCK: <span class="fw-bold">${objet.existencia}
                    </span></p>
                </div>
                <div class="card-footer">
                    <small class="text-body-secondary">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <p class="mb-0">Precio: ${objet.precio}$</p>
                            <div class="d-flex gap-3">
                                <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="productProcess" data-module-edit="Producto procesado" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-product" data-bs-title="Editar Producto" data-bs-placement="bottom">
                                    <i data-feather="edit"></i>
                                </a>
                                <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="productProcess" data-module-delete="Producto procesado" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Producto" data-bs-placement="bottom">
                                    <i data-feather="trash-2"></i>
                                </a>
                            </div>
                        </div>
                    </small>
                </div>
            </div>
        </div>
                `
    }
    function targetCash(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <span class="badge ${objet.estado == 1 ? "bg-success" : "bg-danger"} d-flex justify-content-center align-items-center position-absolute rounded-circle" style="z-index: 1; width: 40px; height: 40px; top: -15px; right: -10px;" data-bs-toggle="tooltip" data-bs-title="Estado de caja" data-bs-placement="top">
                    <span><i style="font-size: 20px;" data-feather="inbox" class="svg-icon"></i></span>
                </span>
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">Nro Caja</h5>
                                <div>
                                    <p class="fs-6">${objet.id}</p>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <p class="fw-lighter fs-6">Fecha: ${fecha(objet.fecha_apertura)}</p>
                                <p class="fw-lighter fs-6">Hora: ${hora(objet.fecha_apertura)}</p>
                            </div>
                        </div>


                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="d-flex align-item-center justify-content-between text-start">
                                    <div>Usuario</div>
                                    <div class="fs-6">${name_user(objet.id_usuario)}</div>
                                </div>

                                <div class="d-flex justify-content-center pt-3 border-top ${objet.estado == 1 ? "gap-3" : ""}">
                                    ${objet.estado == 1 ? `<button class="btn bh_1 text-white close_cash" data-module-close="caja" data-id="${objet.id}">Cerrar</button>` : ""}
                                    <button class="btn bh_5 text-white datails_cash" data-id="${objet.id}" data-module-details="caja">Detalles</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
     `
    }
    function targetKitchen(objet) {
        let text
        if (objet.status == "en cocina") {
            text = "preparar"
        } else {
            text = "Entregar"
        }
        return `
        <div class="col-md-4 col-lg-3"">
            <div class="m-auto">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">Nro Orden</h5>
                                <div>
                                    <p class="fs-6">${objet.id.toString().padStart(6, "0")}</p>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <p class="fw-lighter fs-6">Fecha: ${fecha(objet.fecha)}</p>
                                <p class="fw-lighter fs-6">Hora: ${hora(objet.fecha)}</p>
                            </div>
                        </div>
                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="d-flex align-item-center justify-content-between text-start">
                                    <div>Cliente</div>
                                    <div class="fs-6">${objet.cliente_nombre ? objet.cliente_nombre + " " + objet.cliente_apellido : "POR ASIGNAR"}</div>
                                </div>
                                <div class="d-flex align-item-center justify-content-between text-start">
                                    <div>Tipo</div>
                                    <div class="fs-6 badge bg-secondary">${objet.tipo}</div>
                                </div>
                                <div class="d-flex justify-content-around pt-3 border-top">
                                    ${objet.status == "en cocina" || objet.status == "en preparacion" ? `<button class="btn bh_1 btn_prepared" data-module-prepared="cocina" id_order="${objet.id}" type_order="${objet.tipo}" action="${objet.status}" style="color: #fff;">${text}</button>` : ""}
                                    <button data-bs-toggle="modal" data-bs-target="#delivery-kitchen" data-module-details="cocina" class="btn bh_5 text-white btn-details-kitchen-delivery" data-id="${objet.id}">Detalles</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetDelivery(objet) {
        return `
        <div class="col-md-4 col-lg-3">
            <div class="m-auto">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">Nro Orden</h5>
                                <div>
                                    <p class="fs-6">${objet.nro_orden}</p>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <p class="fw-lighter fs-6">Fecha: ${fecha(objet.fecha)}</p>
                                <p class="fw-lighter fs-6">Hora: ${hora(objet.fecha)}</p>
                            </div>
                        </div>
                        <div class="row gap-3">
                            <div class="d-flex flex-column">
                                <div class="text-start">
                                    <div>Cliente</div>
                                    <p class="fs-6">${objet.cliente_nombre + " " + objet.cliente_apellido}</p>
                                </div>
                                <div class="text-start">
                                    <div>Nro de contacto</div>
                                    <p class="fs-6">${objet.cliente_telefono}</p>
                                </div>
                                <div class="">
                                    <div class="text-start">Direccion</div>
                                    <p class="fs-6 w-100 text-truncate">${objet.direccion}</p>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div class="text-start">Tipo</div>
                                    <div class="fs-6 badge bg-secondary">${objet.tipo}</div>
                                </div>
                                <div class="d-flex justify-content-around pt-3 border-top">
                                    ${objet.status == "para despachar" ? `<button class="btn btn-sm bh_1 text-white btn_sale" id_order="${objet.id}" id_venta="${objet.id_venta}" data-module-acceptDelivery="delivery" >Aceptar Entrega</button>` : ""}
                                    <button data-bs-toggle="modal" data-module-details="delivery" data-bs-target="#delivery-kitchen" class="btn btn-sm bh_5 text-white btn-details-kitchen-delivery" data-id="${objet.id}">Detalles</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    async function targetInvoice(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">Nro Factura</h5>
                                <div>
                                    <p class="fs-6">${objet.id_venta.toString().padStart(6, "0")}</p>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <p class="fw-lighter fs-6">Fecha: ${fecha(objet.fecha)}</p>
                                <p class="fw-lighter fs-6">Hora: ${hora(objet.fecha)}</p>
                            </div>
                        </div>


                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-3">
                                <div class="d-flex align-item-center justify-content-between text-start">
                                    <div>Cliente</div>
                                    <div class="fs-6">${objet.cliente_nombre + " " + objet.cliente_apellido}</div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <div class="text-start">Total</div>
                                    <div class=" text-end fs-6 w-50 ">${objet.monto_final}$</div>
                                </div>
                                <div class="d-flex justify-content-center pt-3 border-top">
                                    <button class="btn btn-sm bh_5 text-white btn-details-invoice" type="orden" data-id="${objet.id}" data-id-sale="${objet.id_venta}">Detalles</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        `
    }
    async function targetInvoiceReservation(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">Nro Factura</h5>
                                <div>
                                    <p class="fs-6">${objet.id.toString().padStart(6, "0")}</p>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <p class="fw-lighter fs-6">Fecha: ${fecha(objet.fecha_inicio)}</p>
                                <p class="fw-lighter fs-6">Hora: ${hora(objet.fecha_inicio)}</p>
                            </div>
                        </div>


                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-3">
                                <div class="d-flex align-item-center justify-content-between text-start">
                                    <div>Cliente</div>
                                    <div class="fs-6">${objet.nombre_cliente + " " + objet.apellido_cliente}</div>
                                </div>
                                <div class="d-flex justify-content-center pt-3 border-top">
                                    <button class="btn btn-sm bh_5 text-white btn-details-invoice" type="reservation" data-id-order="${objet.id_orden}" data-id-reservation="${objet.id}">Detalles</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        `
    }
    function targetSupplier(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">${objet.razon_social}</h5>
                                <div>
                                    <p class="fs-6">${objet.documento}</p>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <p class="fw-lighter fs-6">Nombre</p>
                                <p class="fw-lighter fs-6">${objet.nombre}</p>
                            </div>
                        </div>


                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="text-start">
                                    <h4>Telefono</h4>
                                    <div class="fs-6">${objet.n_telefono1 + (objet.n_telefono2 ? " / " + objet.n_telefono2 : "")}</div>
                                </div>
                                <div class="">
                                    <h4>Direccion</h4>
                                    <div class="fs-6">${objet.direccion}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="proveedor" data-module-edit="proveedores" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-supplier" data-bs-title="Editar Proveedor" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>
                                    <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="proveedor" data-module-delete="proveedores" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Proveedor" data-bs-placement="bottom">
                                        <i data-feather="trash-2"></i>
                                    </a>
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetUser(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">${objet.nombre + " " + objet.apellido}</h5>
                                <div>
                                    <p style="font-size: 12px"">${objet.id}</p>
                                </div>
                            </div>
                        </div>

                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">

                                <div class="text-start">
                                    <h4>Rol</h4>
                                    <div class="fs-6">${objet.rol}</div>
                                </div>
                                <div class="text-start">
                                    <h4>Correo Electronico</h4>
                                    <div class="fs-6">${objet.email}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="users" data-module-edit="usuarios" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-user" data-bs-title="Editar Usuario" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>
                                    <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="users" data-module-delete="usuarios" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Usuario" data-bs-placement="bottom">
                                        <i data-feather="trash-2"></i>
                                    </a>
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    async function targetPackage(objet) {
        let tables = await searchParam({ id_paquete: objet.id }, "paquete_mesa", 50)
        tables = tables.reduce((acc, table) => acc + (parseInt(table.sillas) || 0), 0)
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">${objet.nombre}</h5>
                                <div>
                                    <p>${objet.id}</p>
                                </div>
                            </div>
                        </div>

                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="text-start d-flex align-items-center gap-3">
                                    <h4 class="m-0">Precio</h4>
                                    <div class="fs-4">${objet.precio} $</div>
                                </div>
                                <div class="text-start d-flex align-items-center gap-3">
                                    <h4 class="m-0">Sillas</h4>
                                    <div class="fs-4">${tables}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="package_reservation" data-module-edit="paquetes" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-package" data-bs-title="Editar paquete" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>
                                    <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="package_reservation" data-module-delete="paquetes" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar paquete" data-bs-placement="bottom">
                                        <i data-feather="trash-2"></i>
                                    </a>
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetClient(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 pb-2 border-bottom">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="card-title">${objet.nombre + " " + objet.apellido}</h5>
                                <img src="./assets/img/users/1.jpg" alt="user" class="rounded-circle" style="width: 20%">
                            </div>
                        </div>
                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="text-start">
                                    <h4>Telefono</h4>
                                    <div class="fs-6">${objet.telefono}</div>
                                </div>
                                 <div class="text-start">
                                    <h4>CEDULA</h4>
                                    <div class="fs-6">${objet.documento}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="clients" data-module-edit="clientes" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-client" data-bs-title="Editar Cliente" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>
                                    <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="clients" data-module-delete="clientes" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Cliente" data-bs-placement="bottom">
                                        <i data-feather="trash-2"></i>
                                    </a>
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetPermission(objet) {
        return `
        <div class="col-md-4 col-lg-3 ">
            <div class="position-relative">
                <span class="badge bh_1 d-flex justify-content-center align-items-center position-absolute rounded-circle" style="z-index: 1; width: 40px; height: 40px; top: -15px; right: -10px;">
                    <span><i style="font-size: 24px;" data-feather="shield" class="svg-icon"></i></span>
                </span>
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">${objet.nombre}</h5>
                            </div>
                        </div>

                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="text-start">
                                    <h4>Descripcion</h4>
                                    <div class="fs-6">${objet.descripcion}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="rol" data-module-edit="roles y permisos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Editar Permiso" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>
                                    <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="rol" data-module-delete="roles y permisos" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Permiso" data-bs-placement="bottom">
                                        <i data-feather="trash-2"></i>
                                    </a>
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetTable(objet) {
        let action = `
        <div class="card-footer">
            <small class="text-body-secondary">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <p class="mb-0">Estado: <span class="badge text-bg-${objet.estado == "LIBRE" ? 'success' : 'secondary'}">${objet.estado}</span></p>
                    <div class="d-flex gap-3">
                        <a class="link-secondary edit_btn" data-id="${objet.id}" module-edit="table" data-module-edit="mesas" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-table" data-bs-title="Editar Mesa" data-bs-placement="bottom">
                            <i data-feather="edit"></i>
                        </a>
                        <a class="link-secondary trash_btn" data-id="${objet.id}" module-delete="table" data-module-delete="mesas" style="cursor: pointer" data-bs-toggle="tooltip" data-bs-title="Eliminar Mesa" data-bs-placement="bottom">
                            <i data-feather="trash-2"></i>
                        </a>
                    </div>
                </div>
            </small>
        </div>
        `
        let action2 = `
        <div class="card-footer">
            <small class="text-body-secondary">
                <div style="display: flex; justify-content: center; align-items: center;">
                    <p class="mb-0">Estado: <span class="badge text-bg-${objet.estado == "LIBRE" ? 'success' : 'secondary'}">${objet.estado}</span></p>
                </div>
            </small>
        </div>
        `
        return `
        <div class="col-md-3 mb-5">
            <div class="card h-100">
                <img src="media/table/${objet.imagen}" class="card-img-top" style="object-fit: cover; height: 200px;" alt="${objet.nombre ? 'Imagen de la mesa ' + objet.nombre : 'Imagen de mesa'}">
                <div class="card-body p-1">
                    <div class="d-flex justify-content-center align-items-center gap-4 h-100">
                        <h5 class="card-title m-0">${objet.nombre}</h5>
                        <h5 class="card-title m-0">Sillas: ${objet.sillas}</h5>
                        <h5 class="card-title m-0">VIP: ${objet.vip == true ? 'Si' : 'No'}</h5>
                    </div>
                </div>
                ${objet.estado == "LIBRE" ? action : action2}
            </div>
        </div>
`
    }
    function targetRecipe(object1, objet2) {
        let template = "";
        objet2.forEach((item) => {
            template += itemIngredientes(item);
        })
        return `
        <div class="col-md-4 col-lg-6 ">
            <div class="position-relative">
                <div class="card">
                    <div class="card-body">
                        <div class="mb-3 border-bottom">
                            <div class="d-flex justify-content-between ">
                                <h5 class="card-title">${object1.nombre_producto}</h5>
                            </div>
                        </div>

                        <div class="row gap-3">
                            <div class="d-flex flex-column gap-4">
                                <div class="row">
                                    <div class="container mb-3">
                                        <ul class=" list-unstyled lista-multi">
                                            ${template}
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <small class="text-body-secondary">
                            <div style="display: flex; justify-content: end; align-items: center;">
                                <div class="d-flex gap-3">
                                    <a class="link-secondary edit_btn" data-id="${object1.id}" module-edit="Detalle_receta"" data-module-edit="Recetas" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#edit-recipe" data-bs-title="Editar Receta" data-bs-placement="bottom">
                                        <i data-feather="edit"></i>
                                    </a>
                                </div>
                            </div>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function itemIngredientes(objet) {
        return `
            <li class="fs-5">• ${objet.ingrediente + " " + objet.cantidad + " " + objet.unidad}</li>
        `
    }
    function elemenFormCombo(objet) {
        return `
        <div class="row g-2 product" id="product-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3">
                <h4 class="m-0">Producto ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-product">
                    <i data-feather="trash"></i>
                </button>
            </div>

            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-combo-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-combo-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Precio</label>
                <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-combo-${objet}" name="precio">
                    <div class="text-danger mt-1 fs-6" id="error-input-price-combo-${objet}"></div>
                </div>
            </div>
            <div class="col-md-4">
                <label for="inputCity" class="form-label">Categoria</label>
                <div class="dropdown select_options_category_combo">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-category-combo-${objet}" name="id_categoria" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">
                                    <a class="dropdown-item">1</a>
                                    <a class="dropdown-item">2</a>
                                    <a class="dropdown-item">3</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-category-combo-${objet}"></div>
            </div>

            <div class="col-12">
                <label for="inputAddress2" class="form-label">Detalles</label>
                <textarea placeholder="Detalles" class="form-control" id="input-details-combo-${objet}" rows="5" name="detalles"></textarea>
                <div class="text-danger mt-1 fs-6" id="error-input-details-combo-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Imagen</label>
                <input class="form-control input-image" type="file" id="input-image-combo-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-combo-${objet}"></div>
                <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
            </div>
            <div class="bg-secondary my-5" style="font-size: 1px;"> 2</div>
        </div>
    `
    }
    function elemenFormProductProcess(objet) {
        return `
        <div class="row g-2 product" id="product-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3">
                <h4 class="m-0">Producto ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-product">
                    <i data-feather="trash"></i>
                </button>
            </div>

            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-combo-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-combo-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Precio</label>
                <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-combo-${objet}" name="precio">
                    <div class="text-danger mt-1 fs-6" id="error-input-price-combo-${objet}"></div>
                </div>
            </div>
            <div class="col-md-4">
                <label for="inputCity" class="form-label">Categoria</label>
                <div class="dropdown select_options_category_combo">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-category-combo-${objet}" name="id_categoria" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">
                                    <a class="dropdown-item">1</a>
                                    <a class="dropdown-item">2</a>
                                    <a class="dropdown-item">3</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-category-combo-${objet}"></div>
            </div>

            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Stock Min</label>
                <input type="number" class="form-control" placeholder="Nombre" id="input-min-combo-${objet}" name="min">
                <div class="text-danger mt-1 fs-6" id="error-input-min-combo-1"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Stock Max</label>
                <input type="number" class="form-control" placeholder="Nombre" id="input-max-combo-${objet}" name="max">
                <div class="text-danger mt-1 fs-6" id="error-input-max-combo-1"></div>
            </div>

            <div class="col-12">
                <label for="inputAddress2" class="form-label">Detalles</label>
                <textarea placeholder="Detalles" class="form-control" id="input-details-combo-${objet}" rows="5" name="detalles"></textarea>
                <div class="text-danger mt-1 fs-6" id="error-input-details-combo-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Imagen</label>
                <input class="form-control input-image" type="file" id="input-image-combo-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-combo-${objet}"></div>
                <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
            </div>
            <div class="bg-secondary my-5" style="font-size: 1px;"> 2</div>
        </div>
    `
    }
    function elemenFormTables(objet) {
        return `
        <div class="row g-2 tables" id="tables-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-3">
                <h4 class="m-0">Combo ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-table">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-3">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-tables-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-tables-${objet}"></div>
            </div>
            <div class="col-md-3">
                <label for="inputEmail4" class="form-label">Nro de sillas</label>
                <input type="number" class="form-control" placeholder="Nro de sillas" id="input-chair-tables-${objet}" name="sillas">
                <div class="text-danger mt-1 fs-6" id="error-input-chair-tables-${objet}"></div>
            </div>
            <div class="col-md-1">
                <label for="inputAddress2" class="form-label">VIP</label>
                <br>
                <input type="checkbox" class="btn-check" id="input-vip-tables-${objet}" autocomplete="off" name="vip">
                <label class="btn btn-outline-primary w-100" for="input-vip-tables-${objet}">VIP</label><br>
                <div class="text-danger mt-1 fs-6" id="error-input-vip-tables-${objet}"></div>
            </div>
            <div class="col-md-5">
                <label for="inputZip" class="form-label">Imagen</label>
                <input class="form-control input-image" type="file" id="input-image-tables-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-tables-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    function elemenFormUnit(objet) {
        return `
        <div class="row g-2 units" id="unit-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">Uad ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-unit">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-units-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-units-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Alias</label>
                <input type="text" class="form-control" placeholder="Alias" id="input-alias-units-${objet}" name="alias">
                <div class="text-danger mt-1 fs-6" id="error-input-alias-units-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormPaymentMethod(objet) {
        return `
        <div class="row g-2 payments" id="payments-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-payment">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-12">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-payments-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-payments-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormAdditional(objet) {
        return `
        <div class="row g-2 additionals" id="additionals-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-additional">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-additional-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-additional-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Precio</label>
                <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-additional-${objet}" name="precio">
                    <div class="text-danger mt-1 fs-6" id="error-input-price-additional-${objet}"></div>
                </div>
            </div>
            <div class="col-4">
                <label for="inputZip" class="form-label">Imagen</label>
                <input class="form-control input-image" type="file" id="input-image-additional-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-additional-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    function elemenFormDrink(objet) {
        return `
        <div class="row g-2 drinks" id="drinks-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-drink">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-drink-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-drink-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Precio</label>
                <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-drink-${objet}" name="precio">
                    <div class="text-danger mt-1 fs-6" id="error-input-price-drink-${objet}"></div>
                </div>
            </div>
            <div class="col-4">
                <label for="inputZip" class="form-label">Imagen</label>
                <input class="form-control input-image" type="file" id="input-image-drink-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-drink-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    function elemenFormCategoryProduct(objet) {
        return `
        <div class="row g-2 categoryCombos" id="categoryCombos-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">Uad ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-categoryProducts">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-12">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-categoryProduct-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-categoryProduct-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormCategoryRawmaterial(objet) {
        return `
        <div class="row g-2 categoryRawMaterials" id="categoryRawMaterials-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">Uad ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-categoryRawMaterials">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-12">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-categoryRawMaterials-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-categoryRawMaterials-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormRecipe(objet, objet2 = null) {
        return `
        <div class="row g-2 recipes" id="recipes-${objet}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">Item ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-recipe" data-id="${objet2 ? objet2.id : ''}">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Materia prima</label>
                <div class="dropdown select_options_rawmaterial">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="${objet2 ? objet2.ingrediente : "Seleccione una opcion"}" id="input-rawmaterial-recipe-${objet}" name="id_rawmaterial" data-id="${objet2 ? objet2.id_materia_prima : "Seleccione una opcion"}">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-rawmaterial-recipe-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_unit">${objet2 ? objet2.unidad : '0'} </span>
                    <input type="text" class="form-control w-75" placeholder="Cantidad" input_price id="input-quantity-recipe-${objet}" name="cantidad" value="${objet2 ? objet2.cantidad : ''}">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-quantity-recipe-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormEditRecipe(objet, objet2 = null, objet3 = null) {
        return `
        <div class="row g-2 recipe-edit" id="recipe-edit-${objet}" id_details="${objet2 ? objet2.id : ''}">
            <div class="d-flex align-items-center gap-4 mb-0 mt-4">
                <h4 class="m-0">Item ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-recipe" data-id="${objet2 ? objet2.id : ''}" isNew="${objet3}">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Materia prima</label>
                <div class="dropdown select_options_edit_rawmaterial">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="${objet2 ? objet2.ingrediente : 'Seleccione una opcion'}" id="input-edit-rawmaterial-${objet}" name="id_rawmaterial" data-id="${objet2 ? objet2.id_materia_prima : 'Seleccione una opcion'}">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-edit-rawmaterial-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_unit">${objet2 ? objet2.unidad : '0'}</span>
                    <input type="text" class="form-control w-75" placeholder="Cantidad" input_price id="input-edit-quantity-${objet}" name="cantidad" value="${objet2 ? String(objet2.cantidad).replace('.', ',') : ''}">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-edit-quantity-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormRawMaterial(objet) {
        return `
        <div class="rawmaterials row mt-4" id="rawmaterials-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3">
                <h4 class="m-0">Materia Prima ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-rawmaterial">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-2">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-rawMaterial-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-rawMaterial-${objet}"></div>
            </div>
            <div class="col-md-3">
                <label for="inputCity" class="form-label">Categoria</label>
                <div class="dropdown select_options_categorys_rawmaterial">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-category-rawMaterial-${objet}" name="id_categoria" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">
                                    <!-- aqui cargan las opciones con ajax -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-category-rawMaterial-${objet}"></div>
            </div>
            <div class="col-md-3">
                <label for="inputCity" class="form-label">Unidad</label>
                <div class="dropdown select_options_units_rawmaterial">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-unit-rawMaterial-${objet}" name="id_unidad" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">
                                    <!-- aqui cargan las opciones con ajax -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-unit-rawMaterial-${objet}"></div>
            </div>
            <div class="col-md-2">
                <label for="inputEmail4" class="form-label">Stock Min</label>
                <input type="number" class="form-control" placeholder="Nombre" id="input-min-rawMaterial-${objet}" name="min">
                <div class="text-danger mt-1 fs-6" id="error-input-min-rawMaterial-${objet}"></div>
            </div>
            <div class="col-md-2">
                <label for="inputEmail4" class="form-label">Stock Max</label>
                <input type="number" class="form-control" placeholder="Nombre" id="input-max-rawMaterial-${objet}" name="max">
                <div class="text-danger mt-1 fs-6" id="error-input-max-rawMaterial-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormSupplier(objet) {
        return `
        <div class="row g-2 suppliers mt-4" id="suppliers-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3">
                <h4 class="m-0">Proveedor ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-supplier">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-3">
                <label for="inputEmail4" class="form-label">Nombre de acreditado</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-supplier-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-supplier-${objet}"></div>
            </div>
            <div class="col-md-3">
                <label for="inputEmail4" class="form-label">Razon Social</label>
                <input type="text" class="form-control" placeholder="Razon Social" id="input-razonSocial-supplier-${objet}" name="razonSocial">
                <div class="text-danger mt-1 fs-6" id="error-input-razonSocial-supplier-${objet}"></div>
            </div>
            <div class="col-md-3 mb-3">
                <label for="inputCity" class="form-label">Tipo de documento</label>
                <div class="dropdown select_options_td">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-td-supplier-${objet}" name="tipo_documento">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div class="options_search">
                                    <a class="dropdown-item">V</a>
                                    <a class="dropdown-item">E</a>
                                    <a class="dropdown-item">J</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-td-supplier-${objet}"></div>
            </div>
            <div class="col-md-3">
                <label for="inputEmail4" class="form-label">Nro de documento</label>
                <input type="text" class="form-control" placeholder="Numero de documento" id="input-rif-supplier-${objet}" name="rif">
                <div class="text-danger mt-1 fs-6" id="error-input-rif-supplier-${objet}"></div>
            </div>
            <div class="col-6">
                <label for="inputEmail4" class="form-label">Telefono</label>
                <input type="tel" class="form-control" placeholder="Telefono 1" id="input-num1-supplier-${objet}" name="n_telefono1">
                <div class="text-danger mt-1 fs-6" id="error-input-num1-supplier-${objet}"></div>
            </div>
            <div class="col-6">
                <label for="inputEmail4" class="form-label">Telefono 2</label>
                <input type="tel" class="form-control" placeholder="Telefono 2" id="input-num2-supplier-${objet}" name="n_telefono2">
                <div class="text-danger mt-1 fs-6" id="error-input-num2-supplier-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputEmail4" class="form-label">Direccion</label>
                <textarea class="form-control" id="input-direction-supplier-${objet}" name="direccion" rows="5"></textarea>
                <div class="text-danger mt-1 fs-6" id="error-input-direction-supplier-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormClient(objet) {
        return `
        <div class="row g-2 clients mt-4" id="clients-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3">
                <h4 class="m-0">Cliente ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-client">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-client-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-client-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Apellido</label>
                <input type="text" class="form-control" placeholder="Apellido" id="input-lastname-client-${objet}" name="apellido">
                <div class="text-danger mt-1 fs-6" id="error-input-lastname-client-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Telefono</label>
                <input type="tel" class="form-control" placeholder="Telefono" id="input-tel-client-${objet}" name="telefono">
                <div class="text-danger mt-1 fs-6" id="error-input-tel-client-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormUser(objet) {
        return `
        <div class="row g-2 users" id="user-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h4 class="m-0">Cliente ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-user">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Nombre</label>
                <input type="text" class="form-control" placeholder="Nombre" id="input-name-user-${objet}" name="nombre">
                <div class="text-danger mt-1 fs-6" id="error-input-name-user-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Apellido</label>
                <input type="text" class="form-control" placeholder="Apellido" id="input-lastname-user-${objet}" name="apellido">
                <div class="text-danger mt-1 fs-6" id="error-input-lastname-user-${objet}"></div>
            </div>
            <div class="col-md-6 ">
                <label for="inputCity" class="form-label">Tipo de documento</label>
                <div class="dropdown select_options_td">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-td-user-${objet}" name="tipo_documento">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div class="options_search">
                                    <a class="dropdown-item">V</a>
                                    <a class="dropdown-item">E</a>
                                    <a class="dropdown-item">J</a>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-td-user-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Nro de documento</label>
                <input type="text" class="form-control" placeholder="Nro de documento" id="input-rif-user-${objet}" name="rif">
                <div class="text-danger mt-1 fs-6" id="error-input-rif-user-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Correo Electronico</label>
                <input type="text" class="form-control" placeholder="Correo Electronico" id="input-email-user-${objet}" name="email">
                <div class="text-danger mt-1 fs-6" id="error-input-email-user-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Contraseña</label>
                <input type="password" autocomplete="new-password" class="form-control" placeholder="Contraseña" id="input-password-user-${objet}" name="hash">
                <div class="text-danger mt-1 fs-6" id="error-input-password-user-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputCity" class="form-label">Rol</label>
                <div class="dropdown select_options_rol">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-rol-user-${objet}" name="id_rol" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">
                                    <a class="dropdown-item">V</a>
                                    <a class="dropdown-item">E</a>
                                    <a class="dropdown-item">J</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-rol-user-${objet}"></div>
            </div>
        </div>
        `
    }


    function elementFormEntrysRawMaterial(objet, object2, object3) {
        return `
        <div class="row g-2 entrys" id="entrys-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h3 class="fw-bold text-uppercase">Detalles de entrada</h3>
                <button type="button" class="btn btn-circle btn-secondary remove-entrys">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-12">
                <label for="inputCity" class="form-label">Proveedor</label>
                <div class="dropdown select_options_supplier">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-supplier-entrys-${objet}" name="id_proveedor" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-supplier-entrys-${objet}"></div>
            </div>
            
            <div id="details_entry_container">
                    ${object3(objet)}
                <div class="d-flex justify-content-center my-2">
                    <i data-feather="plus-circle" class="add-product-btn" style="cursor: pointer;"></i>
                </div>
            </div>

             <h5 class="fw-bold text-uppercase">Metodos de pago</h5>
            <div class="mt-3" id="payment_entry_container">
               ${object2(objet)}
               </div>
            <button type="button" class="btn bh_1 text-white mt-3 add-pay-btn">Agregar pago</button>
        </div>
        
        `
    }
    function elementFormPaymentEntrysRawMaterial(objet) {
        return `
        <div class="row g-2 payment_entry bg-light-subtle p-3 px-3 pt-3 pb-4 rounded my-3 position-relative" id="payment-entrys-${objet}">
            <div class="position-relative">
                <button type="button" class="btn btn-circle btn-secondary remove-payment-entrys position-absolute end-0" style="top: -15px;">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-4">
                <label for="inputCity" class="form-label">Metodo de pago</label>
                <div class="dropdown select_options_payment">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-mp-entrys-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-mp-entrys-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Precio de compra</label>
                <div class="input-group">
                    <span class="input-group-text type_payment">$</span>
                    <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-entrys-${objet}" name="precio">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-price-entrys-${objet}"></div>
            </div>
            <div class="col-md-4 mb-3">
                <label for="inputZip" class="form-label">Referencia</label>
                <input type="text" class="form-control" placeholder="Referencia" id="input-ref-entrys-${objet}" name="referencia">
                <div class="text-danger mt-1 fs-6" id="error-input-ref-entrys-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Comprobante</label>
                <input class="form-control input-image" type="file" id="input-image-entrys-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-entrys-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    function elemenFormProductEntrysRawMaterial(objet) {
        return `
         <div class="row g-2 details_entry bg-light-subtle p-3 px-3 pt-3 pb-4 rounded my-3 position-relative" id="details-entrys-${objet}">
            <div class="position-relative">
                <i data-feather="trash-2" class="remove-product-entrys position-absolute end-0" style="top: -15px; cursor: pointer;"></i>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Codigo</label>
                <input type="text" class="form-control" placeholder="Codigo" id="input-code-entrys-${objet}" name="codigo">
                <div class="text-danger mt-1 fs-6" id="error-input-code-entrys-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Materia Prima</label>
                <div class="dropdown select_options_raw_material">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-rawmaterial-entrys-${objet}" name="id_materia_prima" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-rawmaterial-entrys-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_unit">0</span>
                    <input type="text" class="form-control w-75" placeholder="Cantidad" input_price id="input-quantity-entrys-${objet}" name="cantidad">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-quantity-entrys-${objet}"></div>
            </div>
            <div class="col-md-6 mb-3">
                <label for="inputZip" class="form-label">F. Vencimiento</label>
                <input type="date" class="form-control" id="input-date-entrys-${objet}" name="fecha_vencimiento">
                <div class="text-danger mt-1 fs-6" id="error-input-date-entrys-${objet}"></div>
            </div>
        </div>
        
        `
    }
    function elemenFormProductEntrysRawMaterialEdit(objet, Objet2) {
        return `
        <div class="row g-2 detail_entry-edit bg-light-subtle p-3 px-3 pt-3 pb-4 rounded my-3" isNew="false" id="details-entry-edit-${objet}">
            <input type="hidden" name="id" id="input-id-entry-${objet}" value="${Objet2.id}">
             <div class="position-relative">
                <i data-feather="trash-2" class="remove-product-entrys-edit-old position-absolute end-0" style="top: -15px; cursor: pointer;"></i>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Codigo</label>
                <input type="text" class="form-control" placeholder="Codigo" id="input-code-entryEdit-${objet}" name="codigo" value="${Objet2.codigo}">
                <div class="text-danger mt-1 fs-6" id="error-input-code-entryEdit-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Materia Prima</label>
                <div class="dropdown select_options_raw_material_edit">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="${Objet2.nombre_materia_prima}" id="input-rawmaterial-entryEdit-${objet}" name="id_materia_prima" data-id="${Objet2.id_materia_prima}">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-rawmaterial-entryEdit-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_unit type_unit_edit">${Objet2.nombre_unidad}</span>
                    <input type="text" class="form-control w-75" placeholder="Cantidad" input_price id="input-quantity-entryEdit-${objet}" name="cantidad" value="${Objet2.cantidad}">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-quantity-entryEdit-${objet}"></div>
            </div>
            <div class="col-md-6 mb-3">
                <label for="inputZip" class="form-label">F. Vencimiento</label>
                <input type="date" class="form-control" id="input-date-entryEdit-${objet}" value="${Objet2.fecha_vencimiento.split(' ')[0]}" name="fecha_vencimiento">
                <div class="text-danger mt-1 fs-6" id="error-input-date-entryEdit-${objet}"></div>
            </div>
        </div>
        `
    }
    function elemenFormProductEntrysRawMaterialNew(objet) {
        return `
        <div class="row g-2 detail_entry-edit bg-light-subtle p-3 px-3 pt-3 pb-4 rounded my-3" isNew="true" id="details-entry-edit-${objet}">
             <div class="position-relative">
                <i data-feather="trash-2" class="remove-product-entrys-edit-new position-absolute end-0" style="top: -15px; cursor: pointer;"></i>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Codigo</label>
                <input type="text" class="form-control" placeholder="Codigo" id="input-code-entryEdit-${objet}" name="codigo">
                <div class="text-danger mt-1 fs-6" id="error-input-code-entryEdit-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Materia Prima</label>
                <div class="dropdown select_options_raw_material_edit">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-rawmaterial-entryEdit-${objet}" name="id_materia_prima" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-rawmaterial-entryEdit-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_unit type_unit_edit">0</span>
                    <input type="text" class="form-control w-75" placeholder="Cantidad" input_price id="input-quantity-entryEdit-${objet}" name="cantidad">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-quantity-entryEdit-${objet}"></div>
            </div>
            <div class="col-md-6 mb-3">
                <label for="inputZip" class="form-label">F. Vencimiento</label>
                <input type="date" class="form-control" id="input-date-entryEdit-${objet}" name="fecha_vencimiento">
                <div class="text-danger mt-1 fs-6" id="error-input-date-entryEdit-${objet}"></div>
            </div>
        </div>
        `
    }




    const elementFormPaymentEntrysRawMaterialEdit = (objet, Objet2) => {
        return `
        <div class="row g-2 payment_entry_edit bg-light-subtle p-3 px-3 pt-3 pb-4 rounded mb-4" id-payment="${Objet2.id}" id="payment-entrysEdit-${objet}">
            <div class="position-relative">
                <button type="button" id="${Objet2.id}" class="btn btn-circle btn-secondary remove-payment-entry-old position-absolute end-0" style="top: -15px;">
                    <i data-feather="trash"></i>
                </button>
            </div>
                <div class="col-md-4">
                    <label for="inputCity" class="form-label">Metodo de pago</label>
                    <div class="dropdown select_options_payment_edit">
                        <div class="dropdown">
                            <div class="btn-group w-100" bis_skin_checked="1">
                                <input type="button" class="btn btn-light w-75 text-start fs-6" value="${Objet2.metodo_pago}" id="input-mp-entry-${objet}" name="id_metodo_pago" data-id="${Objet2.id_metodo_pago}">
                                <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span> <i data-feather="chevron-down"></i></span>
                                </button>
                                <div class="dropdown-menu p-2" bis_skin_checked="1">
                                    <div>
                                        <input class="form-control search_select" type="search" placeholder="Buscar">
                                    </div>
                                    <div class="options_search">

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-mp-entry-${objet}"></div>
                </div>
                <div class="col-md-4">
                    <label for="inputEmail4" class="form-label">Precio de compra</label>
                    <div class="input-group">
                        <span class="input-group-text type_payment">$</span>
                        <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-entry-${objet}" name="precio" value="${Objet2.precio_compra}">
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-price-entry-${objet}"></div>
                </div>
                <div class="col-md-4 mb-3">
                    <label for="inputZip" class="form-label">Referencia</label>
                    <input type="text" class="form-control" placeholder="Referencia" id="input-ref-entry-${objet}" name="referencia" value="${Objet2.referencia}">
                    <div class="text-danger mt-1 fs-6" id="error-input-ref-entry-${objet}"></div>
                </div>
                <div class="col-12">
                    <label for="inputZip" class="form-label">Comprobante</label>
                    <input class="form-control input-image" type="file" id="input-image-entry-${objet}" name="imagen">
                    <div class="text-danger mt-1 fs-6" id="error-input-image-entry-${objet}"></div>
                </div>
                <img class="mt-3" isImage="true" src="media/pay_entrys_materia_prima/${Objet2.comprobante}" alt="Vista previa" style="max-width: 200px;">
            </div>
        
        `
    }
    const elementFormPaymentEntrysRawMaterialEditNew = (objet) => {
        return `
        <div class="row g-2 payment_entry_edit bg-light-subtle p-3 px-3 pt-3 pb-4 rounded mb-4" id="payment-entrysEdit-${objet}">
            <div class="position-relative">
                <button type="button" class="btn btn-circle btn-secondary remove-payment-entry position-absolute end-0" style="top: -15px;">
                    <i data-feather="trash"></i>
                </button>
            </div>
                <div class="col-md-4">
                    <label for="inputCity" class="form-label">Metodo de pago</label>
                    <div class="dropdown select_options_payment_edit">
                        <div class="dropdown">
                            <div class="btn-group w-100" bis_skin_checked="1">
                                <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-mp-entry-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                                <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span> <i data-feather="chevron-down"></i></span>
                                </button>
                                <div class="dropdown-menu p-2" bis_skin_checked="1">
                                    <div>
                                        <input class="form-control search_select" type="search" placeholder="Buscar">
                                    </div>
                                    <div class="options_search">

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-mp-entry-${objet}"></div>
                </div>
                <div class="col-md-4">
                    <label for="inputEmail4" class="form-label">Precio de compra</label>
                    <div class="input-group">
                        <span class="input-group-text type_payment">$</span>
                        <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-entry-${objet}" name="precio">
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-price-entry-${objet}"></div>
                </div>
                <div class="col-md-4 mb-3">
                    <label for="inputZip" class="form-label">Referencia</label>
                    <input type="text" class="form-control" placeholder="Referencia" id="input-ref-entry-${objet}" name="referencia">
                    <div class="text-danger mt-1 fs-6" id="error-input-ref-entry-${objet}"></div>
                </div>
                <div class="col-12">
                    <label for="inputZip" class="form-label">Comprobante</label>
                    <input class="form-control input-image" type="file" id="input-image-entry-${objet}" name="imagen">
                    <div class="text-danger mt-1 fs-6" id="error-input-image-entry-${objet}"></div>
                </div>
                <img class="mt-3" src="" isImage="false" alt="Vista previa" style="max-width: 200px; display: none;">
            </div>
        
        `
    }



    function elemenFormEntrysProductProcess(objet, object2) {
        return `
        <div class="row g-2 entrys" id="entrys-${objet}">
            <h3 class="fw-bold text-uppercase">Detalles de entrada</h3>
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h4 class="m-0">Entrada ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-entrys">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div id="details_entry_container">
                <div class="row g-2 details_entry" id="details-entrys-${objet}">
                    <div class="col-md-4">
                        <label for="inputEmail4" class="form-label">Codigo</label>
                        <input type="text" class="form-control" placeholder="Codigo" id="input-code-entrys-${objet}" name="codigo">
                        <div class="text-danger mt-1 fs-6" id="error-input-code-entrys-${objet}"></div>
                    </div>
                    <div class="col-md-4">
                        <label for="inputCity" class="form-label">Producto</label>
                        <div class="dropdown select_options_product">
                            <div class="dropdown">
                                <div class="btn-group w-100" bis_skin_checked="1">
                                    <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-product-entrys-${objet}" name="id_producto" data-id="Seleccione una opcion">
                                    <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        <span> <i data-feather="chevron-down"></i></span>
                                    </button>
                                    <div class="dropdown-menu p-2" bis_skin_checked="1">
                                        <div>
                                            <input class="form-control search_select" type="search" placeholder="Buscar">
                                        </div>
                                        <div class="options_search">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="text-danger mt-1 fs-6" id="error-input-product-entrys-${objet}"></div>
                    </div>
                    <div class="col-md-4">
                        <label for="inputCity" class="form-label">Proveedor</label>
                        <div class="dropdown select_options_supplier">
                            <div class="dropdown">
                                <div class="btn-group w-100" bis_skin_checked="1">
                                    <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-supplier-entrys-${objet}" name="id_proveedor" data-id="Seleccione una opcion">
                                    <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        <span> <i data-feather="chevron-down"></i></span>
                                    </button>
                                    <div class="dropdown-menu p-2" bis_skin_checked="1">
                                        <div>
                                            <input class="form-control search_select" type="search" placeholder="Buscar">
                                        </div>
                                        <div class="options_search">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="text-danger mt-1 fs-6" id="error-input-supplier-entrys-${objet}"></div>
                    </div>
                    <div class="col-md-4">
                        <label for="inputCity" class="form-label">Unidad</label>
                        <div class="dropdown select_options_unit">
                            <div class="dropdown">
                                <div class="btn-group w-100" bis_skin_checked="1">
                                    <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-unit-entrys-${objet}" name="id_unidad" data-id="Seleccione una opcion">
                                    <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        <span> <i data-feather="chevron-down"></i></span>
                                    </button>
                                    <div class="dropdown-menu p-2" bis_skin_checked="1">
                                        <div>
                                            <input class="form-control search_select" type="search" placeholder="Buscar">
                                        </div>
                                        <div class="options_search">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="text-danger mt-1 fs-6" id="error-input-unit-entrys-${objet}"></div>
                    </div>
                    <div class="col-md-4">
                        <label for="inputEmail4" class="form-label">Cantidad</label>
                        <div class="input-group">
                            <span class="input-group-text type_unit">0</span>
                            <input type="text" class="form-control w-75" placeholder="Cantidad" input_price id="input-quantity-entrys-${objet}" name="cantidad">
                        </div>
                        <div class="text-danger mt-1 fs-6" id="error-input-quantity-entrys-${objet}"></div>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label for="inputZip" class="form-label">F. Vencimiento</label>
                        <input type="date" class="form-control" id="input-date-entrys-${objet}" name="fecha_vencimiento">
                        <div class="text-danger mt-1 fs-6" id="error-input-date-entrys-${objet}"></div>
                    </div>
                </div>
            </div>

            <caption>Metodos de pago</caption>
            <div class="mt-3" id="payment_entry_container">
                ${object2(objet)}                    
            </div>
            <button type="button" class="btn bh_1 text-white mt-3 mb-4 add-pay-btn">Agregar pago</button>
        </div>
        `
    }
    function elementFormPaymentEntrysProductProcess(objet) {
        return `
        <div class="row g-2 payment_entry bg-light-subtle p-3 px-3 pt-3 pb-4 rounded my-3 position-relative" id="payment-entrys-${objet}">
            <div class="position-relative">
                <button type="button" class="btn btn-circle btn-secondary remove-payment-entrys position-absolute end-0" style="top: -15px;">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-4">
                <label for="inputCity" class="form-label">Metodo de pago</label>
                <div class="dropdown select_options_payment">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-mp-entrys-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-mp-entrys-${objet}"></div>
            </div>
            <div class="col-md-4">
                <label for="inputEmail4" class="form-label">Precio de compra</label>
                <div class="input-group">
                    <span class="input-group-text type_payment">$</span>
                    <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-entrys-${objet}" name="precio">
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-price-entrys-${objet}"></div>
            </div>
            <div class="col-md-4 mb-3">
                <label for="inputZip" class="form-label">Referencia</label>
                <input type="text" class="form-control" placeholder="Referencia" id="input-ref-entrys-${objet}" name="referencia">
                <div class="text-danger mt-1 fs-6" id="error-input-ref-entrys-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Comprobante</label>
                <input class="form-control input-image" type="file" id="input-image-entrys-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-image-entrys-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    const elementFormPaymentEntrysProductProcessEdit = (objet, Objet2) => {
        return `
        <div class="row g-2 payment_entry_edit bg-light-subtle p-3 px-3 pt-3 pb-4 rounded mb-4" id-payment="${Objet2.id}" id="payment-entrysEdit-${objet}">
            <div class="position-relative">
                <button type="button" id="${Objet2.id}" class="btn btn-circle btn-secondary remove-payment-entry-old position-absolute end-0" style="top: -15px;">
                    <i data-feather="trash"></i>
                </button>
            </div>
                <div class="col-md-4">
                    <label for="inputCity" class="form-label">Metodo de pago</label>
                    <div class="dropdown select_options_payment_edit">
                        <div class="dropdown">
                            <div class="btn-group w-100" bis_skin_checked="1">
                                <input type="button" class="btn btn-light w-75 text-start fs-6" value="${Objet2.metodo_pago}" id="input-mp-entry-${objet}" name="id_metodo_pago" data-id="${Objet2.id_metodo_pago}">
                                <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span> <i data-feather="chevron-down"></i></span>
                                </button>
                                <div class="dropdown-menu p-2" bis_skin_checked="1">
                                    <div>
                                        <input class="form-control search_select" type="search" placeholder="Buscar">
                                    </div>
                                    <div class="options_search">

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-mp-entry-${objet}"></div>
                </div>
                <div class="col-md-4">
                    <label for="inputEmail4" class="form-label">Precio de compra</label>
                    <div class="input-group">
                        <span class="input-group-text type_payment">$</span>
                        <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-entry-${objet}" name="precio" value="${Objet2.precio_compra}">
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-price-entry-${objet}"></div>
                </div>
                <div class="col-md-4 mb-3">
                    <label for="inputZip" class="form-label">Referencia</label>
                    <input type="text" class="form-control" placeholder="Referencia" id="input-ref-entry-${objet}" name="referencia" value="${Objet2.referencia}">
                    <div class="text-danger mt-1 fs-6" id="error-input-ref-entry-${objet}"></div>
                </div>
                <div class="col-12">
                    <label for="inputZip" class="form-label">Comprobante</label>
                    <input class="form-control input-image" type="file" id="input-image-entry-${objet}" name="imagen">
                    <div class="text-danger mt-1 fs-6" id="error-input-image-entry-${objet}"></div>
                </div>
                <img class="mt-3" isImage="true" src="media/pay_entrys_materia_prima/${Objet2.comprobante}" alt="Vista previa" style="max-width: 200px;">
            </div>
        
        `
    }
    const elementFormPaymentEntrysProductProcessEditNew = (objet) => {
        return `
        <div class="row g-2 payment_entry_edit bg-light-subtle p-3 px-3 pt-3 pb-4 rounded mb-4" id="payment-entrysEdit-${objet}">
            <div class="position-relative">
                <button type="button" class="btn btn-circle btn-secondary remove-payment-entry position-absolute end-0" style="top: -15px;">
                    <i data-feather="trash"></i>
                </button>
            </div>
                <div class="col-md-4">
                    <label for="inputCity" class="form-label">Metodo de pago</label>
                    <div class="dropdown select_options_payment_edit">
                        <div class="dropdown">
                            <div class="btn-group w-100" bis_skin_checked="1">
                                <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-mp-entry-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                                <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span> <i data-feather="chevron-down"></i></span>
                                </button>
                                <div class="dropdown-menu p-2" bis_skin_checked="1">
                                    <div>
                                        <input class="form-control search_select" type="search" placeholder="Buscar">
                                    </div>
                                    <div class="options_search">

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-mp-entry-${objet}"></div>
                </div>
                <div class="col-md-4">
                    <label for="inputEmail4" class="form-label">Precio de compra</label>
                    <div class="input-group">
                        <span class="input-group-text type_payment">$</span>
                        <input type="text" class="form-control w-75" placeholder="Precio" input_price id="input-price-entry-${objet}" name="precio">
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-price-entry-${objet}"></div>
                </div>
                <div class="col-md-4 mb-3">
                    <label for="inputZip" class="form-label">Referencia</label>
                    <input type="text" class="form-control" placeholder="Referencia" id="input-ref-entry-${objet}" name="referencia">
                    <div class="text-danger mt-1 fs-6" id="error-input-ref-entry-${objet}"></div>
                </div>
                <div class="col-12">
                    <label for="inputZip" class="form-label">Comprobante</label>
                    <input class="form-control input-image" type="file" id="input-image-entry-${objet}" name="imagen">
                    <div class="text-danger mt-1 fs-6" id="error-input-image-entry-${objet}"></div>
                </div>
                <img class="mt-3" src="" isImage="false" alt="Vista previa" style="max-width: 200px; display: none;">
            </div>
        
        `
    }




    function optionsRol(object) {
        return `
         <a class="dropdown-item" data-id="${object.id}">${object.nombre}</a>
        `
    }
    function optionsRawMaterial(object) {
        return `
         <a class="dropdown-item" data-id="${object.id}" data-unit="${object.alias_unidad}">${object.nombre}</a>
        `
    }
    function optionsSupplier(object) {
        return `
         <a class="dropdown-item" data-id="${object.id}">${object.razon_social}</a>
        `
    }
    function Watermark() {
        return `
        <div class="col-12">
            <div class="d-flex justify-content-center align-items-center flex-column mb-4">
                <img src="./assets/img/bh_logo.png" alt="Logo" class="img-fluid opacity-25">
            </div>
        </div>
        `
    }
    function notificationItem(objet) {
        return `
        <a href="javascript:void(0)" id="${objet.id}" class="message-item d-flex align-items-center border-bottom px-3 py-2 ${objet.status == 0 ? "" : "itemNotification"}">
            <div class="btn bh_1 rounded-circle btn-circle">
                <i data-feather="airplay" class="text-white"></i>
            </div>
            <div class="w-75 d-inline-block v-middle ps-2">
                <h6 class="message-title mb-0 mt-1">${objet.titulo}</h6>
                <span class="font-12 text-nowrap d-block text-muted">${objet.mensaje}</span>
                <span class="font-12 text-nowrap d-block text-muted">${fecha(objet.fecha)} a las ${hora(objet.fecha)}</span>
            </div>
        </a>
        `
    }

    //templates de order
    function tagFilterProduct(objet) {
        return `
        <div>
            <input type="radio" class="btn-check btn-filter-product" name="options-outlined" data-filter="${objet.nombre}" id="${objet.id + objet.nombre}" autocomplete="off">
            <label class="btn bh_1CHECKBOX rounded-pill" for="${objet.id + objet.nombre}">${objet.nombre}</label>
        </div>
        `
    }
    function tagAdditional(objet) {
        return `
        <div class="form-check" ">
            <input class="form-check-input" type="checkbox" precio="${objet.precio}" value="${objet.nombre}" id="${objet.id}">
            <label class="form-check-label" for="flexCheckDefault">${objet.nombre}</label>
        </div>
        `
    }
    function selectProduct(objet, typeProduct) {
        return `
        <div class="col-md-6 col-lg-3" data-id="${objet.id}" data-filter-id="${objet.nombre_categoria}" tipo="${objet.tipo ? objet.tipo : ""}" nombre="${objet.nombre}" imagen="${objet.imagen}" precio="${objet.precio}">
            <div class="card position-relative">
                <div class="counter-container position-absolute" style="top: -10px; right: -5px;">
                    <button class="trigger-btn p-1 plusTrigger">
                        <i data-feather="plus"></i>
                    </button>
                    <div class="controls" id="controls">
                        <button class="btn-round me-2 p-1 minusBtn">
                            <i data-feather="minus"></i>
                        </button>
                        <input type="text" class="number-input" value="0" readonly>
                        <button class="btn-round ms-2 p-1 plusBtn">
                            <i data-feather="plus"></i>
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 align-items-center d-flex justify-content-center">
                            <img ${objet.imagen ? `src='./media/${typeProduct}/${objet.imagen}'` : `src='./assets/img/big/banner_login.png'`} class="rounded-full" width="100" height="100" alt="${objet.nombre ? 'Imagen de ' + objet.nombre : 'Imagen del producto'}">
                        </div>
                        <div class="col-md-8">
                            <h4>${objet.nombre}</h4>
                            <p class="text-muted fs-6">${objet.detalles}</p>
                            <h4 class="border text-center rounded-pill p-1 fs-6 w-75">Precio: ${objet.precio}$</h4>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetDetailProductOrder(objet) {
        let src = ""
        if (objet.type == "" && objet.imagen) src = `src='./media/productProcess/${objet.imagen}'`
        else if (objet.type == "producto" && objet.imagen) src = `src='./media/producto_preparado/${objet.imagen}'`
        else if (objet.type == "adicional" && objet.imagen) src = `src='./media/additional/${objet.imagen}'`
        else src = `src='./assets/img/big/banner_login.png'`
        return `
        <div class="col-lg-3 col-md-6">
            <div class="card position-relative">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 col-lg-6 d-flex flex-column align-items-center justify-content-center gap-2">
                            <img ${src} width="100" height="90" style="object-fit: cover;" alt="${objet.nombre ? 'Imagen de ' + objet.nombre : 'Imagen del producto'}">
                            <h5 class="text-truncate w-100 text-center" data-id="${objet.id}">${objet.nombre}</h5>
                            <h4 class="border text-center rounded-pill p-1 fs-6 w-100">Precio: ${objet.precio}$</h4>
                            <textarea class="form-control details" placeholder="detalles" rows="3"></textarea>
                            <div class="counter-container mb-2">
                                <button class="trigger-btn p-1 plusTrigger">
                                    <i data-feather="plus"></i>
                                </button>
                                <div class="controls" id="controls">
                                    <button class="btn-round me-2 p-1 minusBtn">
                                        <i data-feather="minus"></i>
                                    </button>
                                    <input type="text" class="number-input" value="1" readonly>
                                    <button class="btn-round ms-2 p-1 plusBtn">
                                        <i data-feather="plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 col-lg-6 count_additional p-0 border border-2 rounded-3">
                            <textarea rows="6" class="form-control border-0 " style="box-shadow: none;" name="tags" placeholder="Agregar Adicional" /></textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetDetailOtherOrder(objet) {
        let src = ""
        if (objet.type == "" && objet.imagen) src = `src='./media/productProcess/${objet.imagen}'`
        else if (objet.type == "adicional" && objet.imagen) src = `src='./media/additional/${objet.imagen}'`
        else src = `src='./assets/img/big/banner_login.png'`
        return `
        <div class="col-lg-2 col-md-3">
            <div class="card position-relative">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-12 col-lg-12 d-flex flex-column align-items-center justify-content-center gap-2">
                            <img ${src} width="100" height="90" style="object-fit: cover;" alt="${objet.nombre ? 'Imagen de ' + objet.nombre : 'Imagen del producto'}">
                            <h5 data-id="${objet.id}">${objet.nombre}</h5>
                            <h4 class="border text-center rounded-pill p-1 fs-6 w-100">Precio: ${objet.precio}$</h4>
                            <div class="counter-container mb-2">
                                <button class="trigger-btn p-1 plusTrigger">
                                    <i data-feather="plus"></i>
                                </button>
                                <div class="controls" id="controls">
                                    <button class="btn-round me-2 p-1 minusBtn">
                                        <i data-feather="minus"></i>
                                    </button>
                                    <input type="text" class="number-input" value="1" readonly>
                                    <button class="btn-round ms-2 p-1 plusBtn">
                                        <i data-feather="plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function targetClienteOrder(objet) {
        return `
        <div class="col-sm-6 col-md-6 col-lg-6" id="${objet.id}">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-6 col-md-6">
                            <h4 id="${objet.id}">NOMBRE</h4>
                            <p class="text-muted fs-6 nombre_client">${objet.nombre + " " + objet.apellido}</p>
                            <h4>CEDULA</h4>
                            <p class="text-muted fs-6 document_client">${objet.documento}</p>
                        </div>
                        <div class="col-lg-6 col-md-6 d-flex justify-content-center align-items-center">
                            <img src="./assets/img/users/1.jpg" class="rounded-circle" width="100" alt="Avatar del cliente">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }
    function elemenFormPaymentOrder(objet) {
        return `
        <div class="row g-2 payments" id="payments-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h4 class="m-0">Cliente ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-payments">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Metodo de pago</label>
                <div class="dropdown select_options_payment">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-payment-order-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-payment-order-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_payment">$</span>
                    <input type="text" class="form-control w-75" placeholder="0.00" input_price id="input-quantity-order-${objet}" name="cantidad">
                    <div class="text-danger mt-1 fs-6" id="error-input-quantity-order-${objet}"></div>
                </div>
            </div>
            <div class="col-md-12">
                <label for="inputEmail4" class="form-label">Referencia</label>
                <input type="text" class="form-control" placeholder="Referencia" id="input-reference-order-${objet}" name="referencia">
                <div class="text-danger mt-1 fs-6" id="error-input-reference-order-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Comprobante</label>
                <input class="form-control input-image" type="file" id="input-comprobante-order-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-comprobante-order-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    function elemenFormPaymentOrderLocal(objet) {
        return `
        <div class="row g-2 payments-local" id="payments-local-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h4 class="m-0">Pago ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-payments-local">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Metodo de pago</label>
                <div class="dropdown select_options_payment_local">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-payment-orderLocal-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-payment-orderLocal-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_payment">N/S</span>
                    <input type="text" class="form-control w-75" placeholder="0.00" input_price id="input-quantity-orderLocal-${objet}" name="cantidad">
                    <div class="text-danger mt-1 fs-6" id="error-input-quantity-orderLocal-${objet}"></div>
                </div>
            </div>
            <div class="col-md-12">
                <label for="inputEmail4" class="form-label">Referencia</label>
                <input type="text" class="form-control" placeholder="Referencia" id="input-reference-orderLocal-${objet}" name="referencia">
                <div class="text-danger mt-1 fs-6" id="error-input-reference-orderLocal-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Comprobante</label>
                <input class="form-control input-image" type="file" id="input-comprobante-orderLocal-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-comprobante-orderLocal-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    const selectTable = (objet) => {
        return `
        <div class="col-md-6 col-lg-3 mt-3">
            <div class="card position-relative">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 align-items-center d-flex justify-content-center">
                            <img src="${objet.imagen ? "media/table/" + objet.imagen : "./assets/img/big/banner_login.png"}" class="rounded-full" width="100" height="100" alt="${objet.nombre ? 'Imagen de la mesa ' + objet.nombre : 'Imagen de mesa'}">
                        </div>
                        <div class="col-md-8 d-flex flex-column justify-content-center">
                            <h4>${objet.nombre}</h4>
                            <p>capacidad: ${objet.sillas + " personas"}</p>
                            <div>
                                <input type="checkbox" id_table="${objet.id}" table_name="${objet.nombre}" class="btn-check btn_table_order" id="btn-check-outlined-${objet.id}" autocomplete="off">
                                <label class="btn bh_1CHECKBOX" for="btn-check-outlined-${objet.id}">SELECCIONAR</label><br>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    }

    //template de los detalles de caja
    async function infoCash(objet) {
        let user = await searchParam({ id: objet.id_usuario }, "users", 1)
        user = user[0].nombre + " " + user[0].apellido
        return `
        
        <div class="d-flex justify-content-between align-items-center">
            <h2>CAJA NRO ${objet.id}</h2>
            <i class="btn_print" data-bs-toggle="tooltip" data-bs-title="Imprimir" data-feather="printer" data-id="${objet.id}" style="cursor: pointer"></i>
        </div>
        <hr>
        <div class="row">
            <div class="col-md-6">
                <div class="d-flex">
                    <h4 class="fw-bold">Usuario:</h4>
                    <p class="ms-2">${user}</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="d-flex">
                    <h4 class="fw-bold">Fecha:</h4>
                    <p class="ms-2">${fecha(objet.fecha_apertura)}</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="d-flex">
                    <h4 class="fw-bold">Valor inicial Bs:</h4>
                    <p class="ms-2">${objet.monto_inicial_bs}</p>
                </div>
                <div class="d-flex">
                    <h4 class="fw-bold">Valor inicial $:</h4>
                    <p class="ms-2">${objet.monto_inicial_dolar}</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="d-flex">
                    <h4 class="fw-bold">Estado:</h4>
                    <p class="ms-2">${objet.estado == 1 ? "Abierta" : "Cerrada"}</p>
                </div>
            </div>
        </div>
        <hr>
        `
    }
    function amountCash(objet) {
        return `
        <div>
            <h5>${objet.metodo_pago}</h5>
            <p>${objet.metodo_pago.toLowerCase() == "transferencia" || objet.metodo_pago.toLowerCase() == "pago movil" ? "Bs" : "$"} ${objet.monto.toFixed(2)}</p>
        </div>
        `
    }
    function cashDetail(objet, objet2) {
        let template = "";
        objet2.forEach((item) => {
            template += `
                 <div class="d-flex gap-4">
                     <p class="fs-6"> PAGO DE ${item.tipo_pago == "reserva" ? "RESERVA" : "VENTA"} DE ${item.cliente} POR ORDEN NRO ${item.nro_orden}</p>
                     <p class="fw-bold">${item.metodo_pago.toLowerCase() == "transferencia" || item.metodo_pago.toLowerCase() == "pago movil" ? "Bs" : "$"} ${(
                    item.metodo_pago.toLowerCase() == "transferencia" || item.metodo_pago.toLowerCase() == "pago movil" ? item.monto : item.monto
                ).toFixed(2)}</p>
                 </div>
                `
        })
        return `
        <div>
            <h3 class="ms-3 fw-bold">INGRESOS EN ${objet.toUpperCase()}</h3>
            <div class="ms-5">
                ${template}
            </div>
        </div>
        `
    }


    //template de detalles de delivery y cocina
    function infoKitchenDelivery(objet) {
        return `
        <div class="row">
            <div class="col-md-6 col-lg-6 d-flex gap-3">
                <i class="btn_print" data-feather="printer" data-bs-toggle="tooltip" data-bs-title="Imprimir" style="cursor: pointer"></i>
            </div>
            <div class="col-md-6 col-lg-6 d-flex justify-content-end gap-3">
                <h5>Fecha</h5>
                <p class="mb-0">${fecha(objet.fecha)}</p>
            </div>
        </div>
        <div class="row border-bottom border-2">
            <div class="col-md-6 w-50 col-lg-6 d-flex gap-3">
                <h5>Nro de orden</h5>
                <p class="fw-bolder">${objet.nro_orden}</p>
            </div>
            <div class="col-md-6 w-50 col-lg-6 d-flex justify-content-end gap-3">
                <h5>Hora</h5>
                <p>${hora(objet.fecha)}</p>
            </div>
        </div>
        <div class="row mt-3 border-bottom border-2">
            <div class="col-12 d-flex gap-3">
                <h5>Cliente</h5>
                <p class="fw-bolder">${objet.cliente ? objet.cliente_nombre + " " + objet.cliente_apellido : "POR ASIGNAR"}</p>
            </div>
            <div class="col-12 d-flex gap-3">
                <h5>Dirección</h5>
                <p class="fw-bolder">${objet.direccion || "POR ASIGNAR"}</p>
            </div>
            <div class="col-12 d-flex gap-3">
                <h5>Telefono</h5>
                <p class="fw-bolder">${objet.cliente_telefono ? objet.cliente_telefono : "S/T"}</p>
            </div>
        </div>
        `
    }
    function detailsKitchenDelivery(objet, type) {
        if (objet.tipo != "adicional" || objet.tipo == undefined) {
            let details = `
         <ul class="ms-2 list-unstyled">
            ${objet.descripcion != null && objet.descripcion != "" ? `<li><strong class="fw-bold">• Descripcion:</strong> ${objet.descripcion}</li>` : ""}
            ${objet.adicionales != null && objet.adicionales != "" ? `<li><strong class="fw-bold">• Adicionales:</strong> ${objet.adicionales}</li>` : ""}
        </ul>`

            return `
        <div class="container border-bottom border-2 mb-3">
            <h3 class="fw-bold">${objet.cantidad + " x " + objet.nombre}</h3>
            ${type == "prepared" ? details : ""}
        </div>
        `
        }
        return ""
    }


    //templates de reservas
    async function tagPackage(objet) {
        let tables = await searchParam({ id_paquete: objet.id }, "package_table", 50)
        tables = tables.reduce((acc, table) => acc + (parseInt(table.sillas) || 0), 0)
        return `

        <div class="col-md-4 col-lg-3">
            <input type="radio" class="btn-check btn-filter-product" name="options-outlined" data-filter="${objet.nombre}" id="${objet.id}" autocomplete="off">
            <label class="btn bh_1CHECKBOX card" for="${objet.id}">
                <div class="position-relative">
                    <div class="mb-3 border-bottom">
                        <div class="d-flex justify-content-between">
                            <h5 class="card-title">${objet.nombre}</h5>
                        </div>
                    </div>

                    <div class="row gap-3">
                        <div class="d-flex flex-column gap-4">
                            <div class="text-start d-flex align-items-center gap-3">
                                <h4 class="m-0">Precio</h4>
                                <div class="fs-4 data_price">${objet.precio} $</div>
                            </div>
                            <div class="text-start d-flex align-items-center gap-3">
                                <h4 class="m-0">Sillas</h4>
                                <div class="fs-4 data_tables">${tables}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </label>
        </div>`
    }
    async function tagPackageChecked(objet) {
        let tables = await searchParam({ id_paquete: objet.id }, "package_table", 50)
        tables = tables.reduce((acc, table) => acc + (parseInt(table.sillas) || 0), 0)
        return `

        <div class="col-md-4 col-lg-3">
            <input type="radio" class="btn-check" name="options-outlined" id="package-${objet.id}" checked autocomplete="off">
            <label class="btn bh_1CHECKBOX card" for="package-${objet.id}">
                <div class="position-relative">
                    <div class="mb-3 border-bottom">
                        <div class="d-flex justify-content-between">
                            <h5 class="card-title">${objet.nombre}</h5>
                        </div>
                    </div>

                    <div class="row gap-3">
                        <div class="d-flex flex-column gap-4">
                            <div class="text-start d-flex align-items-center gap-3">
                                <h4 class="m-0">Precio</h4>
                                <div class="fs-4 data_price">${objet.precio} $</div>
                            </div>
                            <div class="text-start d-flex align-items-center gap-3">
                                <h4 class="m-0">Sillas</h4>
                                <div class="fs-4 data_tables">${tables}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </label>
        </div>`
    }
    function elemenFormPaymentReservation(objet) {
        return `
        <div class="row g-2 payments-reservation" id="payments-reservation-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h4 class="m-0">Pago ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-payments-reservation">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Metodo de pago</label>
                <div class="dropdown select_options_payment_reservation">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-payment-reservation-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-payment-reservation-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_payment">N/S</span>
                    <input type="text" class="form-control w-75" placeholder="0.00" input_price id="input-quantity-reservation-${objet}" name="cantidad">
                    <div class="text-danger mt-1 fs-6" id="error-input-quantity-reservation-${objet}"></div>
                </div>
            </div>
            <div class="col-md-12">
                <label for="inputEmail4" class="form-label">Referencia</label>
                <input type="text" class="form-control" placeholder="Referencia" id="input-reference-reservation-${objet}" name="referencia">
                <div class="text-danger mt-1 fs-6" id="error-input-reference-reservation-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Comprobante</label>
                <input class="form-control input-image" type="file" id="input-comprobante-reservation-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-comprobante-reservation-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }
    function elemenFormPaymentReservationEdit(objet) {
        return `
        <div id="payments-container-reservation_edit">
            <div class="row g-2 payments-reservation_edit" id="payments-reservation-edit-${objet}">
                <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                    <h4 class="m-0">Pago ${objet}</h4>
                    <button type="button" class="btn btn-circle btn-secondary remove-payments-reservation-edit">
                        <i data-feather="trash"></i>
                    </button>
                </div>
                <div class="col-md-6">
                    <label for="inputCity" class="form-label">Metodo de pago</label>
                    <div class="dropdown select_options_payment_reservation_edit">
                        <div class="dropdown">
                            <div class="btn-group w-100" bis_skin_checked="1">
                                <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-payment-reservationEdit-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                                <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span> <i data-feather="chevron-down"></i></span>
                                </button>
                                <div class="dropdown-menu p-2" bis_skin_checked="1">
                                    <div>
                                        <input class="form-control search_select" type="search" placeholder="Buscar">
                                    </div>
                                    <div class="options_search">

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="text-danger mt-1 fs-6" id="error-input-payment-reservationEdit-${objet}"></div>
                </div>
                <div class="col-md-6">
                    <label for="inputEmail4" class="form-label">Cantidad</label>
                    <div class="input-group">
                        <span class="input-group-text type_payment">N/S</span>
                        <input type="text" class="form-control w-75" placeholder="0.00" input_price id="input-quantity-reservationEdit-${objet}" name="cantidad">
                        <div class="text-danger mt-1 fs-6" id="error-input-quantity-reservationEdit-${objet}"></div>
                    </div>
                </div>
                <div class="col-md-12">
                    <label for="inputEmail4" class="form-label">Referencia</label>
                    <input type="text" class="form-control" placeholder="Referencia" id="input-reference-reservationEdit-${objet}" name="referencia">
                    <div class="text-danger mt-1 fs-6" id="error-input-reference-reservationEdit-${objet}"></div>
                </div>
                <div class="col-12">
                    <label for="inputZip" class="form-label">Comprobante</label>
                    <input class="form-control input-image" type="file" id="input-comprobante-reservationEdit-${objet}" name="imagen">
                    <div class="text-danger mt-1 fs-6" id="error-input-comprobante-reservationEdit-${objet}"></div>
                </div>
                <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
            </div>
        </div>
        
        `
    }
    function elemenFormPaymentReservationOrder(objet) {
        return `
        <div class="row g-2 payments-local-reservation" id="payments-local-reservation-${objet}">
            <div class="d-flex align-items-center gap-4 mb-3 mt-5">
                <h4 class="m-0">Pago ${objet}</h4>
                <button type="button" class="btn btn-circle btn-secondary remove-payments-reservation-local">
                    <i data-feather="trash"></i>
                </button>
            </div>
            <div class="col-md-6">
                <label for="inputCity" class="form-label">Metodo de pago</label>
                <div class="dropdown select_options_payment_local_reservation">
                    <div class="dropdown">
                        <div class="btn-group w-100" bis_skin_checked="1">
                            <input type="button" class="btn btn-light w-75 text-start fs-6" value="Seleccione una opcion" id="input-payment-orderLocalRes-${objet}" name="id_metodo_pago" data-id="Seleccione una opcion">
                            <button type="button" class="btn btn-light dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span> <i data-feather="chevron-down"></i></span>
                            </button>
                            <div class="dropdown-menu p-2" bis_skin_checked="1">
                                <div>
                                    <input class="form-control search_select" type="search" placeholder="Buscar">
                                </div>
                                <div class="options_search">

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-danger mt-1 fs-6" id="error-input-payment-orderLocalRes-${objet}"></div>
            </div>
            <div class="col-md-6">
                <label for="inputEmail4" class="form-label">Cantidad</label>
                <div class="input-group">
                    <span class="input-group-text type_payment">N/S</span>
                    <input type="text" class="form-control w-75" placeholder="0.00" input_price id="input-quantity-orderLocalRes-${objet}" name="cantidad">
                    <div class="text-danger mt-1 fs-6" id="error-input-quantity-orderLocalRes-${objet}"></div>
                </div>
            </div>
            <div class="col-md-12">
                <label for="inputEmail4" class="form-label">Referencia</label>
                <input type="text" class="form-control" placeholder="Referencia" id="input-reference-orderLocalRes-${objet}" name="referencia">
                <div class="text-danger mt-1 fs-6" id="error-input-reference-orderLocalRes-${objet}"></div>
            </div>
            <div class="col-12">
                <label for="inputZip" class="form-label">Comprobante</label>
                <input class="form-control input-image" type="file" id="input-comprobante-orderLocalRes-${objet}" name="imagen">
                <div class="text-danger mt-1 fs-6" id="error-input-comprobante-orderLocalRes-${objet}"></div>
            </div>
            <img class="mt-3" src="" alt="Vista previa" style="max-width: 200px; display: none;">
        </div>
        `
    }

    return {
        targetProductPrepared,
        targetProductProcess,
        targetSupplier,
        targetKitchen,
        targetDelivery,
        targetUser,
        targetPackage,
        targetInvoice,
        targetInvoiceReservation,
        targetClient,
        targetCash,
        targetRecipe,
        itemIngredientes,
        targetPermission,
        targetTable,
        elemenFormCombo,
        elemenFormProductProcess,
        elemenFormCategoryProduct,
        elemenFormCategoryRawmaterial,
        elemenFormTables,
        elemenFormEditRecipe,
        elemenFormUnit,
        elemenFormPaymentMethod,
        elemenFormRawMaterial,
        elemenFormProductEntrysRawMaterial,
        elemenFormRecipe,
        elemenFormSupplier,
        elemenFormClient,
        elemenFormAdditional,
        elemenFormDrink,
        elemenFormUser,
        elementFormEntrysRawMaterial,
        elementFormPaymentEntrysRawMaterial,
        elemenFormProductEntrysRawMaterialEdit,
        elemenFormProductEntrysRawMaterialNew,
        elementFormPaymentEntrysRawMaterialEdit,
        elementFormPaymentEntrysRawMaterialEditNew,
        elemenFormEntrysProductProcess,
        elementFormPaymentEntrysProductProcess,
        elementFormPaymentEntrysProductProcessEdit,
        elementFormPaymentEntrysProductProcessEditNew,
        optionsRol,
        optionsRawMaterial,
        optionsSupplier,
        Watermark,
        notificationItem,
        tagFilterProduct,
        selectProduct,
        selectTable,
        targetDetailProductOrder,
        targetDetailOtherOrder,
        tagAdditional,
        targetClienteOrder,
        elemenFormPaymentOrder,
        elemenFormPaymentOrderLocal,
        infoCash,
        amountCash,
        cashDetail,
        infoKitchenDelivery,
        detailsKitchenDelivery,
        tagPackage,
        tagPackageChecked,
        elemenFormPaymentReservation,
        elemenFormPaymentReservationEdit,
        elemenFormPaymentReservationOrder
    }
}



