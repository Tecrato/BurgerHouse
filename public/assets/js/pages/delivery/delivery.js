import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
import { report } from "./report.js"
const { searchParam, binnacle, sessionInfo, print, searchFilter, permission, notification, notificationAlert } = functionGeneral();
const { targetDelivery, infoKitchenDelivery, detailsKitchenDelivery } = Templates();
let session = await sessionInfo()
const config = {
    search: () => searchParam({ status: 'para despachar', tipo: "delivery" }, "orden", 12),
    template: targetDelivery,
    container: ".cont-delivery-pending",
    funtions: () => {
        saleBTN(config, () => nuevaBitacora('Orden de delivery', 'Orden aceptada', 'Se acepto una orden de delivery'))
        modalDetails()
        permission("delivery")
    },
}
searchFilter("#searchDeliveryPending", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ status: "para despachar", nombre_like: e.target.value }, "orden") })
})
searchFilter("#searchDeliveryOff", (e) => {
    if (e.target.value == "") print({ ...config, search: () => searchParam({ status: "entregado", tipo: "delivery" }, "orden"), container: ".cont-delivery-off" })
    else print({ ...config, search: () => searchParam({ status: "entregado", nombre_like: e.target.value, tipo: "delivery" }, "orden"), container: ".cont-delivery-off" })
})
const saleBTN = async (config, binnacleSale) => {
    document.querySelectorAll(".btn_sale").forEach(item => {
        item.addEventListener("click", async () => {

            Swal.fire({
                title: "¿Deseas entregar esta orden?",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "Si, estoy seguro",
                cancelButtonText: "Cancelar",
                confirmButtonColor: "#FF4B00",
            }).then(async (result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                    title: 'Procesando...',
                    text: 'Por favor espera',
                    allowOutsideClick: false,
                    didOpen: () => { Swal.showLoading() }
                });
                    let id = item.getAttribute("id_order")
                    let data = new FormData();
                    data.append("id", id)
                    let verify = await searchParam({ id: id, status: 'en camino' }, "orden")
                    if (verify.length > 0) {
                        Swal.fire({
                            title: `Error!`,
                            text: "No se puede aceptar la orden",
                            icon: "error",
                        });
                        Swal.close();
                    } else {
                        data.append("status", "en camino")
                        let pet = await fetch('orden/update', { method: "POST", body: data })
                        let res = await pet.json()
                        if (res.success == true) {
                            Swal.close();
                            Swal.fire({
                                title: `Exito!`,
                                text: "La orden se acepto correctamente",
                                icon: "success",
                            });
                            print(config)
                            print({ ...config, search: () => searchParam({ status: "entregada", tipo: "delivery" }, "orden", 12), container: ".cont-delivery-off" })
                            binnacleSale()
                            let deliveryData = new FormData();
                            deliveryData.append("id_venta", item.getAttribute("id_venta"))
                            deliveryData.append("id_usuario_delivery", session.message.id)
                            let deliveryName = await fetch("delivery/add", { method: "POST", body: deliveryData })
                            notification({
                                id_usuario: session.message.id,
                                titulo: `Orden tomada`,
                                mensaje: `La orden ${id.toString().padStart(4, '0')} esta en camino para despachar`,
                            })
                            notificationAlert({
                                channel: "orden",
                                message: `La orden ${id.toString().padStart(4, '0')} esta en camino para despachar`,
                                event: "orden"
                            })
                            notificationAlert({
                                channel: "General",
                                message: `La orden ${id.toString().padStart(4, '0')} esta en camino para despachar`,
                                event: "notificaciones"
                            })
                        } else {
                            Swal.fire({
                                title: `Error!`,
                                text: "No se puede aceptar la orden",
                                icon: "error",
                            });
                            Swal.close();
                        }
                    }
                }
            });
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
                    intro: 'Bienvenido a la seccion de delivery, aqui podras ver todas las ordenes a domicilio de tu negocio.',
                    position: 'bottom'
                },
                {
                    element: document.querySelector('#home-tab'),
                    intro: 'Aqui podras ver todas las ordenes a domicilio, pendientes para entregar.',
                    position: 'bottom'
                },
                {
                    element: document.querySelector('#profile-tab'),
                    intro: 'Aqui podras ver todas las ordenes para llevar ya entregadas.',
                    position: 'bottom'
                },
                {
                    element: document.querySelector('.card'),
                    intro: 'Tarjeta de ordenes a domicilio pendientes, puedes ver los detalles de la orden y aceptar la entrega.',
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
print(config)
print({ ...config, search: () => searchParam({ status: "entregada", tipo: "delivery" }, "orden", 12), container: ".cont-delivery-off" })
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
            detailsPrepered.forEach(item => {
                template += detailsKitchenDelivery(item, "prepared")
            })
            detailsProcess.forEach(item => {
                template += detailsKitchenDelivery(item, "process")
            })
            document.querySelector(".cont_details_kitchen_delivery_process").innerHTML = template
        })
    })
}
const pusher = new Pusher('2a7ca356d030e2945ae9', { cluster: 'us2' });
const channelKitchen = pusher.subscribe('Delivery');
channelKitchen.bind('delivery', function (data) {
    const toas = document.querySelector(".toast-container")
    toas.querySelector("strong").textContent = data.event
    dayjs.extend(window.dayjs_plugin_relativeTime);
    dayjs.locale('es');
    toas.querySelector("small").textContent = dayjs(data.time).fromNow()
    toas.querySelector(".toast-body").textContent = data.message
    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toas.querySelector("#liveToast"), { delay: 5000 })
    toastBootstrap.show()
    print(config)
    print({ ...config, search: () => searchParam({ status: "entregada", tipo: "delivery" }, "orden", 12), container: ".cont-delivery-off" })
});