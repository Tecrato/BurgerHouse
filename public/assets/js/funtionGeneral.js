import functionGeneral from "./Functions.js";
import Templates from "./templates.js";
const { CheckCash } = functionGeneral()
const { notificationItem } = Templates()
document.addEventListener('DOMContentLoaded', async () => {
    const savedTheme = localStorage.getItem('darkMode');
    const check = localStorage.getItem('check');
    const isDark = savedTheme === 'true';
    document.body.classList.toggle('dark-mode', isDark);
    if (check == "true") {
        document.getElementById("themeToggle").removeAttribute("checked")
        document.querySelector(".img-bcv").src = "./assets/img/bcv2.png"
    }
});

document.getElementById("themeToggle").addEventListener("click", () => {
    const isDark = document.body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    localStorage.setItem('check', isDark);
    if (localStorage.getItem("check") == "true") {
        document.querySelector(".img-bcv").src = "./assets/img/bcv2.png"
    } else {
        document.querySelector(".img-bcv").src = "./assets/img/bcv.png"
    }
});
const dolarBCV = async () => {
    let search = await fetch("https://ve.dolarapi.com/v1/dolares")
    let response = await search.json()
    document.getElementById("Dolar_bcv").textContent = parseFloat(response[0].promedio).toFixed(2) + " Bs"
}
dolarBCV()

document.querySelectorAll(".logout_btn").forEach((btn) => {
    btn.addEventListener("click", async () => {
        let pet = await fetch("login/logout")
        window.location = "login"
    })
})
//caja
if (await CheckCash() != null) {
    document.querySelector(".cash_status").classList.add("bg-success")
    document.querySelector(".cash_status").classList.remove("bg-danger")
    const tooltip = bootstrap.Tooltip.getInstance(document.querySelector(".cash_status"));
    if (tooltip) {
        tooltip._config.title = "Estado de caja: Abierta";
        tooltip.update();
    }
} else {
    document.querySelector(".cash_status").classList.remove("bg-success")
    document.querySelector(".cash_status").classList.add("bg-danger")
    const tooltip = bootstrap.Tooltip.getInstance(document.querySelector(".cash_status"));
    if (tooltip) {
        tooltip._config.title = "Estado de caja: Cerrada";
        tooltip.update();
    }
}
//notificaciones 
const not = async () => {
    let contNot = document.querySelector(".notifications")
    let template = ""
    let pet = await fetch("notificaciones/get_all/0/4/id/desc")
    let response = await pet.json()
    if (response.length == 0) {
        template = `
        <div class="message-center notifications position-relative">
            <div class="p-3 text-center">
            <i data-feather="info" class="svg-icon"></i>
                <h4 class="fs-6 text-muted">No se encontraron notificaciones</h4>
                </div>
                </div>
                `
    } else {
        response.forEach(item => {
            template += notificationItem(item)
        });
    }
    contNot.innerHTML = template
    feather.replace();
    let params = new FormData()
    params.append("status", 0)
    let petBadge = await fetch("notificaciones/get_all/0/10000/id/desc", { method: "POST", body: params })
    let responseBadge = await petBadge.json()
    let badge = document.querySelector('.notification-badge')
    if (responseBadge.length == 0) {
        badge.classList.add("d-none")
    } else {
        badge.textContent = responseBadge.length
        badge.classList.remove("d-none")
    }
}
not()
const pusher = new Pusher('2a7ca356d030e2945ae9', { cluster: 'us2' });
const channelGeneral = pusher.subscribe('General');
let sonidoNotificacion;
document.addEventListener('click', () => {
    sonidoNotificacion = new Audio('./assets/sound/new-notification-09-352705.mp3');
    sonidoNotificacion.load();
}, { once: true });

function reproducirNotificacion() {
    if (sonidoNotificacion) {
        sonidoNotificacion.currentTime = 0; // Reinicia al inicio
        sonidoNotificacion.play().catch(err => console.warn("⚠️ Error al reproducir sonido:", err));
    }
}
channelGeneral.bind('notificaciones', function (data) {
    not()
    reproducirNotificacion();
    notificationSetStatus()
});

const bell = document.querySelector(".btn-bell")
const notificationSetStatus = async () => {
    const notify = document.querySelector(".notifications")
    let children = notify.querySelectorAll("a")
    if (children.length > 0) {
        let data = new FormData();
        children.forEach((item, index) => {
            data.append(`lista[${index}][id]`, item.id)
            data.append(`lista[${index}][status]`, "1")
        })
        let pet = await fetch('notification/updateMany', { method: "POST", body: data })
        let res = await pet.json()
        if (res.success == true) not()
    }

}
bell.addEventListener("click", () => {
    setTimeout(notificationSetStatus, 3000)
})

// const pet = await fetch("login/prueba")
// const session = await pet.json()
// console.log(session);

// let data = new FormData();
// data.append("id_cliente", 1);
// data.append("tipo", "delivery");
// data.append("nro_orden", 51689296);
// data.append("status", "en cocina");
// data.append("lista_detalle_procesado[0][id_producto]", 41)
// data.append("lista_detalle_procesado[0][cantidad]", 1)
// data.append("lista_detalle_preparado[0][id_producto]", 41);
// data.append("lista_detalle_preparado[0][cantidad]", 2);
// data.append("lista_detalle_preparado[0][adicionales]", "");
// data.append("lista_detalle_preparado[0][descripcion]", "");
// data.append("lista_detalle_preparado[1][id_producto]", 41);
// data.append("lista_detalle_preparado[1][cantidad]", 1);
// data.append("lista_detalle_preparado[1][adicionales]", "");
// data.append("lista_detalle_preparado[1][descripcion]", "");
// data.append("lista_detalle_preparado[2][id_producto]", 50);
// data.append("lista_detalle_preparado[2][cantidad]", 1);
// let pet = await fetch('order/add', { method: "POST", body: data })
// let res = await pet.json()
// console.log(res);