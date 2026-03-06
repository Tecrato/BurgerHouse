import introTooltip from "../../intro-tooltip.js"
import { payReservation } from "./addReservation.js"
import { editReservationClient, editDateReservation, editPackageReservation } from "./editReservation.js"
import functionGeneral from "../../Functions.js"
import {
    nuevaBitacora,
    myfecth,
} from "../../Functions2.js"
import Templates from "../../templates.js"
const { calendarIntro } = introTooltip()
const { fecha, hora, binnacle, sessionInfo, permission } = functionGeneral()
calendarIntro("navbarDropdown")
const calendarEl = document.getElementById('calendar');
const session = await sessionInfo();
permission("reservaciones")

const events = async () => {
    const pet = await fetch('calendario/get_all/0/10000000/id/asc', { method: 'POST' })
    let res = await pet.json()
    return res.map(item => {
        let color = '#FFB200';
        if (item.status === 'confirmada') color = '#FF4B00';
        else if (item.status === 'anulada') color = '#b41a1a';

        return {
            id: item.id,
            id_orden: item.id_orden,
            id_paquete: item.id_paquete,
            status_reservation: item.status,
            clienteData: {
                documento: item.documento.split('-')[1],
                nombre: item.nombre_cliente,
                apellido: item.apellido_cliente,
                id: item.id_cliente,
                telefono: item.telefono,
                id_orden: item.id_orden
            },
            title: 'Reservación',
            start: item.fecha_inicio,
            end: item.fecha_inicio,
            color: color,
        };
    });
}
async function recargarEventos() {
    const newEvents = await events();
    calendar.getEvents().forEach(e => e.remove());
    newEvents.forEach(evento => calendar.addEvent(evento));
}

let eventos = await events()
const calendar = new FullCalendar.Calendar(calendarEl, {
    themeSystem: 'bootstrap5',
    locale: 'es',
    initialView: 'dayGridMonth',
    headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
    },
    buttonText: {
        prev: '<',
        next: '>'
    },
    events: eventos,
    eventClick: function (info) {
        window.dataClient = info.event._def.extendedProps.clienteData
        const id_reserva = info.event.id
        const id_orden = info.event._def.extendedProps.id_orden
        const id_paquete = info.event._def.extendedProps.id_paquete
        const status_R = info.event._def.extendedProps.status_reservation
        detailsClient(id_orden)
        detailsReservation(id_reserva)
        detailsPay(id_reserva)

        if (document.querySelector('.edit_client_edit_reservation') && document.querySelector('.edit_date_reservationEdit') && document.querySelector('.edit_package_reservationEdit')) {
            document.querySelector('.edit_client_edit_reservation').setAttribute('data-id', id_reserva)
            document.querySelector('.edit_date_reservationEdit').setAttribute('data-id', id_reserva)
            document.querySelector('.edit_package_reservationEdit').setAttribute('data-id', id_reserva)
        }

        if (document.querySelector(".btn-null-reservation")) {
            document.querySelector(".btn-null-reservation").setAttribute("data-id-reserva", id_reserva)
            document.querySelector(".btn-null-reservation").setAttribute("data-id-order", id_orden)
        }

        if (document.querySelector(".btn-verify-reservation")) {
            if (status_R != "por verificar" && document.querySelector(".btn-verify-reservation")) document.querySelector(".btn-verify-reservation").disabled = true
        }

        if (document.querySelector(".btn-edit-reservation")) {
            document.querySelector(".btn-verify-reservation").setAttribute("data-id-reserva", id_reserva)
            document.querySelector(".btn-verify-reservation").setAttribute("data-id-order", id_orden)
        }

        bootstrap.Modal.getOrCreateInstance('#edit-reservation').show()
    },
});

calendar.render();
setTimeout(() => { calendar.updateSize() }, 100);

window.stepperReservation = new Stepper(document.querySelector('#stepper-5'), { linear: true, animation: true });
window.stepperReservationEdit = new Stepper(document.querySelector('#stepper-edit-packages'), { linear: true, animation: true });

let btnAddReservation = document.querySelector(".btn_add_reservation");
if (!btnAddReservation.dataset.listenerAttached) {
    btnAddReservation.addEventListener("click", () => {
        payReservation(functionGeneral, Templates, recargarEventos)
        setTimeout(() => { bootstrap.Modal.getOrCreateInstance('#add_reservation').show() }, 300)
    });
    btnAddReservation.dataset.listenerAttached = "true";
}

const detailsClient = async (id) => {
    let data = new FormData();
    data.append("id", id)
    let pet = await fetch("orden/get_all", { method: "POST", body: data })
    let res = await pet.json()
    document.querySelector(".name_client_edit_reservation").textContent = "CLIENTE: " + res[0].cliente_nombre + " " + res[0].cliente_apellido
    document.querySelector(".document_client_edit_reservation").textContent = "DOCUMENTO: " + res[0].cliente_documento
    document.querySelector(".phone_client_edit_reservation").textContent = "TELEFONO: " + res[0].cliente_telefono
}
const detailsReservation = async (id_reserva) => {
    let data = new FormData();
    data.append("id", id_reserva)
    let pet = await fetch("calendario/get_all", { method: "POST", body: data })
    let res = await pet.json()
    let dataPackage = new FormData();
    dataPackage.append("id_paquete", res[0].id_paquete)
    let tables = await fetch("package_mesa/get_all", { method: "POST", body: dataPackage })
    let resTables = await tables.json()
    document.querySelector(".date_edit_reservation").textContent = fecha(res[0].fecha_inicio) + " a las " + hora(res[0].fecha_inicio)
    document.querySelector(".cont_edit_package_reservation").textContent = res[0].paquete + " por " + res[0].precio_paquete + " USD" + " para " + resTables.reduce((acc, item) => acc + parseInt(item.sillas), 0) + " personas"
}
const detailsPay = async (id_reserva) => {
    let data = new FormData();
    data.append("id_reserva", id_reserva)
    let templatePayment = ""
    let pet = await fetch("paymentReservation/get_all/0/10000000/id/asc", { method: "POST", body: data })
    let res = await pet.json()
    res.forEach((payment) => {
        templatePayment += `
      <div class="col-md-4 mt-3 border p-3 border-2 text-center">
          <img src="media/pay/${payment.comprobante}" alt="Logo" class="w-75">
          <h3 class="fs-5 mt-2">Tipo de pago: ${payment.metodo_pago}</h3>
          <h3 class="fs-5 mt-2">Monto: ${payment.monto}</h3>
      </div>`
    })
    document.querySelector(".cont_edit_payment_reservation").innerHTML = templatePayment
}

document.querySelector(".edit_client_edit_reservation").addEventListener("click", async () => {
    let data = new FormData();
    data.append("id", document.querySelector('.edit_client_edit_reservation').getAttribute('data-id'))
    const pet = await fetch('calendario/get_all/0/10000000/id/asc', { method: 'POST', body: data })
    let res = await pet.json()
    window.dataClient = {
        documento: res[0].documento.split('-')[1],
        nombre: res[0].nombre_cliente,
        apellido: res[0].apellido_cliente,
        id: res[0].id_cliente,
        telefono: res[0].telefono,
        id_orden: res[0].id_orden,
        id_reserva: res[0].id
    }

    const dbDate = new Date(res[0].fecha_inicio.replace(" ", "T"))
    const dbNow = new Date()

    if (res[0].status_orden == "pendiente" && dbNow < dbDate) {
        editReservationClient(functionGeneral, Templates)
    } else {
        Swal.fire({
            icon: "error",
            title: "No se puede editar la reserva",
            text: "La reserva no se puede editar, ya que se encuentra en cocina"
        })
    }

})

document.querySelector(".edit_date_reservationEdit").addEventListener("click", async () => {
    let data = new FormData();
    data.append("id", document.querySelector('.edit_date_reservationEdit').getAttribute('data-id'))
    const pet = await fetch('calendario/get_all/0/10000000/id/asc', { method: 'POST', body: data })
    let res = await pet.json()
    window.editDateReservation = { date: res[0].fecha_inicio, id: res[0].id }

    const dbDate = new Date(res[0].fecha_inicio.replace(" ", "T"))
    const dbNow = new Date()

    if (res[0].status_orden == "pendiente" && dbNow < dbDate) {
        editDateReservation(functionGeneral, recargarEventos)
    } else {
        Swal.fire({
            icon: "error",
            title: "No se puede editar la reserva",
            text: "La reserva no se puede editar, ya que se encuentra en cocina"
        })
    }
})

document.querySelector(".edit_package_reservationEdit").addEventListener("click", async () => {
    let data = new FormData();
    data.append("id", document.querySelector('.edit_package_reservationEdit').getAttribute('data-id'))
    let res = myfecth('calendario/get_all/0/10000000/id/asc', {}, data ).json()

    stepperReservationEdit.to(0)
    window.editPackageReservation = {
        package: res[0].id_paquete,
        id: res[0].id,
        fecha_reserva: res[0].fecha_inicio,
        clientData: {
            nombre: res[0].nombre_cliente + " " + res[0].apellido_cliente,
            documento: res[0].documento.split('-')[1],
        }
    }
    const dbDate = new Date(res[0].fecha_inicio.replace(" ", "T"))
    const dbNow = new Date()
    if (res[0].status_orden == "pendiente" && dbNow < dbDate) {
        editPackageReservation(functionGeneral, Templates, recargarEventos)
    } else {
        Swal.fire({
            icon: "error",
            title: "No se puede editar la reserva",
            text: "La reserva no se puede editar, ya que se encuentra en cocina"
        })
    }
})

document.querySelector(".btn-null-reservation").addEventListener("click", () => {
    const id_reserva = document.querySelector(".btn-null-reservation").getAttribute("data-id-reserva")
    const id_orden = document.querySelector(".btn-null-reservation").getAttribute("data-id-order")

    Swal.fire({
        title: "¿Deseas anular esta reserva?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Si, quiero anularla",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#FF4B00",
    }).then(async (result) => {
        if (result.isConfirmed) {
            bootstrap.Modal.getOrCreateInstance('#edit-reservation').hide()
            Swal.fire({
                title: 'Procesando...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading() }
            });
            let dataReservation = new FormData()
            let dataOrder = new FormData()
            dataReservation.append("id", id_reserva)
            dataReservation.append("status", "anulada")
            let petReservation = await fetch("calendar/update", { method: "POST", body: dataReservation })
            let responseReservation = await petReservation.json()
            dataOrder.append("id", id_orden)
            dataOrder.append("status", "anulada")
            let petOrder = await fetch("orden/update", { method: "POST", body: dataOrder })
            let responseOrder = await petOrder.json()
            if (responseOrder.success == true && responseReservation.success == true) {
                Swal.fire({
                    title: `Exito!`,
                    text: "La reserva fue anulada correctamente",
                    icon: "success",
                });
                nuevaBitacora("Reservacion", "Anular", "Se anulo la reserva " + id_reserva)
                recargarEventos()
            } else {
                Swal.fire({
                    title: `Error!`,
                    text: "La reserva no pudo ser anulada",
                    icon: "error",
                });
            }
        }
    });

})

document.querySelector(".btn-verify-reservation").addEventListener("click", () => {
    const id_reserva = document.querySelector(".btn-verify-reservation").getAttribute("data-id-reserva")
    const id_orden = document.querySelector(".btn-verify-reservation").getAttribute("data-id-order")

    Swal.fire({
        title: "¿Deseas verificar esta reserva?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Si",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#FF4B00",
    }).then(async (result) => {
        if (result.isConfirmed) {
            bootstrap.Modal.getOrCreateInstance('#edit-reservation').hide()
            Swal.fire({
                title: 'Procesando...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading() }
            });
            let dataReservation = new FormData()
            let dataOrder = new FormData()
            dataReservation.append("id", id_reserva)
            dataReservation.append("status", "confirmada")
            let petReservation = await fetch("calendar/update", { method: "POST", body: dataReservation })
            let responseReservation = await petReservation.json()
            dataOrder.append("id", id_orden)
            dataOrder.append("status", "pendiente")
            let petOrder = await fetch("orden/update", { method: "POST", body: dataOrder })
            let responseOrder = await petOrder.json()
            if (responseOrder.success == true && responseReservation.success == true) {
                Swal.fire({
                    title: `Exito!`,
                    text: "La reserva fue verficada correctamente",
                    icon: "success",
                });
                nuevaBitacora("Reservacion", "Verificacion", "Se verifico la reserva " + id_reserva)
                recargarEventos()
            } else {
                Swal.fire({
                    title: `Error!`,
                    text: "La reserva no pudo ser verificada",
                    icon: "error",
                });
            }
        }
    });

})