import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js";
import { report } from "./report.js"
const { print, searchParam, binnacle, sessionInfo, searchFilter, permission, pagination, notification, notificationAlert } = functionGeneral();
const { targetKitchen, infoKitchenDelivery, detailsKitchenDelivery } = Templates();
let session = await sessionInfo()
const config = {
    search: () => searchParam({ status: "en cocina" }, "orden", 12),
    template: targetKitchen,
    container: ".kitchen-cont-prepared",
    funtions: () => {
        preparedKitchen()
        modalDetails()
        permission("cocina")
    }
}
print(config)
print({ ...config, search: () => searchParam({ status: "en preparacion" }, "orden"), container: ".kitchen-cont-inprepared" })
print({ ...config, search: () => searchParam({ status: "para despachar" }, "orden"), container: ".kitchen-cont-prepared-off" })

searchFilter("#searchKitchenPending", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ status: "en cocina", nombre_like: e.target.value }, "orden  ") })
})
searchFilter("#searchKitchenPrepared", (e) => {
    if (e.target.value == "") print({ ...config, search: () => searchParam({ status: "para despachar" }, "orden"), container: ".kitchen-cont-prepared-off" })
    else print({ ...config, search: () => searchParam({ status: "para despachar", nombre_like: e.target.value }, "orden"), container: ".kitchen-cont-prepared-off" })
})
searchFilter("#searchKitchenInPrepared", (e) => {
    if (e.target.value == "") print({ ...config, search: () => searchParam({ status: "en preparacion" }, "orden"), container: ".kitchen-cont-inprepared" })
    else print({ ...config, search: () => searchParam({ status: "en preparacion", nombre_like: e.target.value }, "orden"), container: ".kitchen-cont-inprepared" })
})
const preparedKitchen = () => {
    document.querySelectorAll(".btn_prepared").forEach(item => {
        if (!item.dataset.listenerAttached) {
            item.addEventListener("click", async () => {
                let action = item.getAttribute("action")
                Swal.fire({
                    title: action == "en cocina" ? "¿Deseas preparar la orden?" : "¿La orden ya se encuentra lista?",
                    icon: "warning",
                    showCancelButton: true,
                    confirmButtonText: "Si, estoy seguro",
                    cancelButtonText: "Cancelar",
                    confirmButtonColor: "#FF4B00",
                }).then(async (result) => {
                    if (result.isConfirmed) {
                        let id = item.getAttribute("id_order")
                        let type = item.getAttribute("type_order")
                        let data = new FormData();
                        let verify = await searchParam({ id: id }, "orden")
                        if (verify[0].status == "en preparacion" && action == "en cocina") {
                            Swal.fire({
                                title: `Error!`,
                                text: "La orden ya se encuentra en preparacion",
                                icon: "error",
                            });
                        } else {
                            data.append("id", id)
                            if (action == "en cocina") data.append("status", "en preparacion")
                            else data.append("status", "para despachar")
                            let pet = await fetch('orden/update', { method: "POST", body: data })
                            let res = await pet.json()
                            if (res.success == true) {
                                Swal.fire({
                                    title: `Exito!`,
                                    text: action == "en cocina" ? "Se ha enviado a preparar la orden" : "Se ha enviado a despachar la orden",
                                    icon: "success",
                                });
                                print(config)
                                print({ ...config, search: () => searchParam({ status: "en preparacion" }, "orden"), container: ".kitchen-cont-inprepared" })
                                print({ ...config, search: () => searchParam({ status: "para despachar" }, "orden"), container: ".kitchen-cont-prepared-off" })
                                binnacle(session.message.id, 'Orden de cocina', action == "en cocina" ? "La orden se encuentra en preparacion" : 'La orden se encuentra para despachar', action == "en cocina" ? 'Se envio una orden a preparar' : 'Se envio una orden a despachar')
                                notification({
                                    id_usuario: session.message.id,
                                    titulo: `${action == "en cocina" ? "La orden se encuentra en preparacion" : 'La orden se encuentra para despachar'}`,
                                    mensaje: `${action == "en cocina" ? 'Se envio una orden a preparar' : 'Se envio una orden a despachar'} con el nro ${id.toString().padStart(4, '0')}`,
                                })
                                notificationAlert({
                                    channel: "orden",
                                    message: `${action == "en cocina" ? "Se ha enviado a preparar la orden" : "Se ha enviado a despachar la orden"} con el nro ${id.toString().padStart(4, '0')}`,
                                    event: "orden"
                                })
                                notificationAlert({
                                    channel: "General",
                                    message: `${action == "en cocina" ? "Se ha enviado a preparar la orden" : "Se ha enviado a despachar la orden"} con el nro ${id.toString().padStart(4, '0')}`,
                                    event: "notificaciones"
                                })
                                if (action != "en cocina") {
                                    notificationAlert({
                                        channel: "Delivery",
                                        message: `Nueva orden para despachar con el nro ${id.toString().padStart(4, '0')}`,
                                        event: "delivery"
                                    })
                                }

                            } else {
                                Swal.fire({
                                    title: `Error!`,
                                    text: "No se pudo preparar la orden",
                                    icon: "error",
                                });
                            }
                        }
                    }
                });
            })
            item.dataset.listenerAttached = "true"
        }
    })
}
//filtro
document.querySelectorAll(".btn_check_pending").forEach(item => {
    item.addEventListener("click", () => {
        let type = item.id
        if (type == "kitchen_all_pending") print(config)
        else if (type == "kitchen_delivery_pending") print({ ...config, search: () => searchParam({ tipo: "delivery", status: "en cocina" }, "orden", 1000000000) })
        else if (type == "kitchen_takeaway_pending") print({ ...config, search: () => searchParam({ tipo: "llevar", status: "en cocina" }, "orden", 1000000000) })
        else if (type == "kitchen_local_pending") print({ ...config, search: () => searchParam({ tipo: "local", status: "en cocina" }, "orden", 1000000000) })
        else print({ ...config, search: () => searchParam({ tipo: "reserva", status: "en cocina" }, "orden", 1000000000) })
    })
})
document.querySelectorAll(".btn_check_off").forEach(item => {
    item.addEventListener("click", () => {
        let type = item.id
        if (type == "kitchen_all_off") print({ ...config, search: () => searchParam({ status: "para despachar" }, "orden"), container: ".kitchen-cont-prepared-off" })
        else if (type == "kitchen_delivery_off") print({ ...config, search: () => searchParam({ status: "para despachar", tipo: "delivery" }, "orden"), container: ".kitchen-cont-prepared-off" })
        else if (type == "kitchen_takeaway_off") print({ ...config, search: () => searchParam({ status: "para despachar", tipo: "llevar" }, "orden"), container: ".kitchen-cont-prepared-off" })
        else if (type == "kitchen_local_off") print({ ...config, search: () => searchParam({ status: "para despachar", tipo: "local" }, "orden"), container: ".kitchen-cont-prepared-off" })
        else print({ ...config, search: () => searchParam({ tipo: "reserva", status: "para despachar" }, "orden", 1000000000), container: ".kitchen-cont-prepared-off" })

    })
})
document.querySelectorAll(".btn_check_inprepared").forEach(item => {
    item.addEventListener("click", () => {
        let type = item.id
        if (type == "kitchen_all_inprepared") print({ ...config, search: () => searchParam({ status: "en preparacion" }, "orden"), container: ".kitchen-cont-inprepared" })
        else if (type == "kitchen_delivery_inprepared") print({ ...config, search: () => searchParam({ status: "en preparacion", tipo: "delivery" }, "orden"), container: ".kitchen-cont-inprepared" })
        else if (type == "kitchen_takeaway_inprepared") print({ ...config, search: () => searchParam({ status: "en preparacion", tipo: "llevar" }, "orden"), container: ".kitchen-cont-inprepared" })
        else if (type == "kitchen_local_inprepared") print({ ...config, search: () => searchParam({ status: "en preparacion", tipo: "local" }, "orden"), container: ".kitchen-cont-inprepared" })
        else print({ ...config, search: () => searchParam({ tipo: "reserva", status: "en preparacion" }, "orden", 1000000000), container: ".kitchen-cont-inprepared" })

    })
})
//modal de detalles
const modalDetails = () => {
    document.querySelectorAll(".btn-details-kitchen-delivery").forEach(item => {
        item.addEventListener("click", async () => {
            let id = item.getAttribute('data-id')
            let info = await searchParam({ id: id }, "orden")
            let detailsPrepered = await searchParam({ id_orden: id }, "Detalle_orden_producto_preparado")
            let detailsProcess = await searchParam({ id_orden: id }, "Detalle_orden_producto_procesado")
            document.querySelector(".cont_info_kitchen_delivery").innerHTML = infoKitchenDelivery(info[0])
            feather.replace()
            new bootstrap.Tooltip(document.querySelector('.btn_print'))
            report(info, detailsPrepered, detailsProcess)
            let template = ""
            let group = {}
            detailsPrepered.forEach(item => {
                template += detailsKitchenDelivery(item, "prepared")
            })
            detailsProcess.forEach(item => {
                if (!group[item.id_producto]) group[item.id_producto] = item
                else group[item.id_producto] = { ...item, cantidad: parseInt(group[item.id_producto].cantidad) + parseInt(item.cantidad) }
            })
            group = Object.entries(group).map(([key, value]) => ({ nombre: key, ...value }));
            group.forEach(item => {
                template += detailsKitchenDelivery(item, "process")
            })
            document.querySelector(".cont_details_kitchen_delivery_process").innerHTML = template
        })
    })
}
// IntroJs
document.getElementById('navbarDropdown').addEventListener('click', function () {
    if (typeof introJs !== 'undefined') {
        let intro = introJs();
        intro.setOptions({
            steps: [
                {
                    element: document.querySelector('.page-wrapper'),
                    intro: 'Bienvenido a la seccion de cocina, aqui podras ver todas las ordenes por preparar de tu negocio.',
                    position: 'bottom'
                },
                {
                    element: document.querySelector('#home-tab'),
                    intro: 'Aqui podras ver todas las ordenes por preparar pendientes.',
                    position: 'bottom'
                },
                {
                    element: document.querySelector('#profile-tab'),
                    intro: 'Aqui podras ver las ordenes que ya han sido preparadas.',
                    position: 'bottom'
                },
                {
                    element: document.querySelector('.card'),
                    intro: 'Tarjeta de ordenes a domicilio pendientes, puedes ver los detalles de la orden y confirmar la preparación de dicha orden.',
                    position: 'bottom'
                }
            ],
            showBullets: true,
            exitOnOverlayClick: false,
            showProgress: true
        });
        intro.start();
    }
});

pagination((page) => {
    print({ ...config, search: () => searchParam({ status: "en cocina" }, "orden", 12, page) })
}, ".pagination_prepared")

const pusher = new Pusher('2a7ca356d030e2945ae9', { cluster: 'us2' });
const channelKitchen = pusher.subscribe('Kitchen');
channelKitchen.bind('orden de cocina', function (data) {
    const toas = document.querySelector(".toast-container")
    toas.querySelector("strong").textContent = data.event
    dayjs.extend(window.dayjs_plugin_relativeTime);
    dayjs.locale('es');
    toas.querySelector("small").textContent = dayjs(data.time).fromNow()
    toas.querySelector(".toast-body").textContent = data.message
    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toas.querySelector("#liveToast"), { delay: 5000 })
    toastBootstrap.show()
    print(config)
    print({ ...config, search: () => searchParam({ status: "en preparacion" }, "orden"), container: ".kitchen-cont-inprepared" })
    print({ ...config, search: () => searchParam({ status: "para despachar" }, "orden"), container: ".kitchen-cont-prepared-off" })
});