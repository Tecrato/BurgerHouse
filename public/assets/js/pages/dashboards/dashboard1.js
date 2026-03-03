import graphicInstance from "../statistics/graphicInstance.js";
import functionGeneral from "../../Functions.js"
import { printPDF } from "../statistics/graphicPDF.js"
import introTooltip from "../../intro-tooltip.js"
import { myfecth } from "../../Functions2.js";
const {dashboard} = introTooltip()
const { searchParam } = functionGeneral();
const { graphic2, graphicDashboard1, graphicDashboard2 } = graphicInstance()
dashboard('navbarDropdown')
Chart.register(ChartDataLabels);
graphic2(undefined, undefined, undefined, "totalVentaAnio", () => printPDF());
graphicDashboard1(undefined, undefined, undefined, "utilidadNetaAnio", () => printPDF());
graphicDashboard2(undefined, undefined, undefined, "utilidadNetaSemana", () => printPDF());
dayjs.extend(window.dayjs_plugin_relativeTime);
dayjs.locale('es');
function formatearFecha(fecha, modo = "semana") {
    const meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
    const getNumeroSemana = (fecha) => {
        const inicioAño = new Date(fecha.getFullYear(), 0, 1);
        const diasTranscurridos = Math.floor((fecha - inicioAño) / (24 * 60 * 60 * 1000));
        const numeroSemana = Math.ceil((diasTranscurridos + inicioAño.getDay() + 1) / 7);
        return numeroSemana;
    };
    const mesNombre = meses[fecha.getMonth()];
    const año = fecha.getFullYear();
    switch (modo.toLowerCase()) {
        case "semana":
            const semana = getNumeroSemana(fecha);
            return `Semana ${semana} de ${mesNombre} del ${año}`;
        case "mes":
            return `${mesNombre} del ${año}`;
        case "ano":
        case "año":
            return `Año ${año}`;
        default:
            return "Modo no válido";
    }
}
function semanaISOaFecha(isoSemana) {
    const [año, semanaStr] = isoSemana.split("-W");
    const semana = parseInt(semanaStr, 10);
    const fecha = new Date(año, 0, 4);
    const diaSemana = fecha.getDay() || 7;
    fecha.setDate(fecha.getDate() - diaSemana + 1 + (semana - 1) * 7);
    return fecha;
}
document.querySelectorAll(".form_select_type_filter").forEach((select) => {
    select.addEventListener("change", (e) => {
        if (e.target.value == "Semana/mes/año") {
            for (const element of select.parentElement.parentElement.parentElement.parentElement.querySelectorAll("[type]")) {
                if (element.getAttribute("type") == "month" || element.getAttribute("type") == "year") element.classList.add("d-none")
                else element.classList.remove("d-none")
            };
            select.parentElement.parentElement.firstElementChild.lastElementChild.textContent = formatearFecha(new Date(), "semana");
            if (select.getAttribute("graphic") == 'Utilidad neta') graphicDashboard1(undefined, undefined, undefined, "utilidadNetaSemana", () => printPDF());
            else if (select.getAttribute("graphic") == "Total de ventas") graphic2(undefined, undefined, undefined, "totalVentaSemana", () => printPDF())
            else graphicDashboard2(undefined, undefined, undefined, "utilidadNetaSemana", () => printPDF());
        } else if (e.target.value == "Mes/Año") {
            for (const element of select.parentElement.parentElement.parentElement.parentElement.querySelectorAll("[type]")) {
                if (element.getAttribute("type") == "week") element.classList.add("d-none")
                else element.classList.remove("d-none")
            }
            select.parentElement.parentElement.firstElementChild.lastElementChild.textContent = formatearFecha(new Date(), "mes");
            if (select.getAttribute("graphic") == 'Utilidad neta') graphicDashboard1(undefined, undefined, undefined, "utilidadNetaMes", () => printPDF());
            else if (select.getAttribute("graphic") == "Total de ventas") graphic2(undefined, undefined, undefined, "totalVentaMes", () => printPDF())
            else graphicDashboard2(undefined, undefined, undefined, "utilidadNetaMes", () => printPDF());
        } else {
            for (const element of select.parentElement.parentElement.parentElement.parentElement.querySelectorAll("[type]")) {
                if (element.getAttribute("type") == "week" || element.getAttribute("type") == "month") element.classList.add("d-none")
                else element.classList.remove("d-none")
            }
            select.parentElement.parentElement.firstElementChild.lastElementChild.textContent = formatearFecha(new Date(), "año");
            if (select.getAttribute("graphic") == 'Utilidad neta') graphicDashboard1(undefined, undefined, undefined, "utilidadNetaAnio", () => printPDF());
            else if (select.getAttribute("graphic") == "Total de ventas") graphic2(undefined, undefined, undefined, "totalVentaAnio", () => printPDF())
            else graphicDashboard2(undefined, undefined, undefined, "utilidadNetaAnio", () => printPDF());
        }
    })
})
document.querySelectorAll(".type_flter_date").forEach((date) => {
    if (date.getAttribute("type_temporality") == "week") date.textContent = formatearFecha(new Date(), "semana");
    else if (date.getAttribute("type_temporality") == "month") date.textContent = formatearFecha(new Date(), "mes");
    else date.textContent = formatearFecha(new Date(), "año");
})
document.querySelectorAll(".container_inputs_filter").forEach(form => {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        let type = form.getAttribute("graphic")
        let selectOption = form.parentElement.parentElement.querySelector(".form_select_type_filter").value
        if (selectOption == "Semana/mes/año") {
            let anio = form.querySelector("input[type='week']").value.split("-")[0];
            let semana = form.querySelector("input[type='week']").value.split("-")[1].replace("W", "");
            if (type == 'Utilidad neta') graphicDashboard1(anio, semana, null, "utilidadNetaSemana", () => printPDF());
            else if (type == "Total de ventas") graphic2(anio, semana, null, "totalVentaSemana", () => printPDF())
            else graphicDashboard2(anio, semana, null, "utilidadNetaSemana", () => printPDF());
            form.parentElement.parentElement.parentElement.querySelector(".type_flter_date").textContent = formatearFecha(semanaISOaFecha(form.querySelector("input[type='week']").value), "semana");
        } else if (selectOption == "Mes/Año") {
            let mes = form.querySelector("select").value
            let anio = form.querySelector("input[type='year']").value;
            if (mes == "s/v") mes = new Date().getMonth() + 1;
            if (type == 'Utilidad neta') graphicDashboard1(anio, null, mes, "utilidadNetaMes", () => printPDF());
            else if (type == "Total de ventas") graphic2(anio, null, mes, "totalVentaMes", () => printPDF())
            else graphicDashboard2(anio, null, mes, "utilidadNetaMes", () => printPDF());
            form.parentElement.parentElement.parentElement.querySelector(".type_flter_date").textContent = formatearFecha(new Date(anio, mes - 1), "mes");
        } else {
            let anio = form.querySelector("input[type='year']").value;
            if (anio == "s/v") anio = new Date().getFullYear();
            if (type == 'Utilidad neta') graphicDashboard1(anio, null, null, "utilidadNetaAnio", () => printPDF());
            else if (type == "Total de ventas") graphic2(anio, null, null, "totalVentaAnio", () => printPDF())
            else graphicDashboard2(anio, null, mes, "utilidadNetaAnio", () => printPDF());
            form.parentElement.parentElement.parentElement.querySelector(".type_flter_date").textContent = formatearFecha(new Date(anio), "año");
        }
    })
})
const activity = async () => {
    let color = ['bh_1', 'bh_2', 'bh_4', 'bh_5', 'bh_6'];
    let pet = await searchParam({}, "bitacora", 5)
    let template = ""
    let icon = ""
    let title = ""
    console.log(pet)
    pet.forEach((item, index) => {
        const dict_icon = {
            "Se agrego ": "plus",
            "Se creo ": "plus",
            "Se elimino ": "trash",
            "Se Elimino": "trash",
            "Se actualizo ": "edit",
            "Se ha restaurado ": "refresh-cw",
            "Se abrio ": "book-open",
            "Se cerro ": "x",
            "Se preparo ": "coffee",
            "Se verifico ": "check",
            "Se anulo ": "x-circle",
            "Se acepto ": "check-circle",
            "inicio de sesion": "log-in",
            "Se ha agregado": "plus-circle",
            "Se despacho": "log-in",
            "Se envio": "log-out",
            "Guardar Gasto": "dollar-sign",
            "Guardar Ingreso": "dollar-sign",
            "Se pago": "dollar-sign"
        }

        const dict_title = {
            "Se agrego ": "Nuevo elemento agregado",
            "Se creo ": "Nuevo elemento agregado",
            "Se elimino ": "Elemento eliminado",
            "Se Elimino": "Elemento eliminado",
            "Se actualizo ": "Elemento actualizado",
            "Se ha restaurado ": "Elemento restaurado",
            "Se abrio ": "Elemento abierto",
            "Se cerro ": "Elemento cerrado",
            "Se preparo ": "Elemento preparado",
            "Se verifico ": "Elemento verificado",
            "Se anulo ": "Elemento anulado",
            "Se acepto ": "Elemento aceptado",
            "inicio de sesion": "Inicio de sesion",
            "Se ha agregado": "Nuevo elemento agregado",
            "Se despacho": "Nuevo despacho",
            "Se envio": "Nuevo envio",
            "Guardar Gasto": "Nuevo movimiento de dinero",
            "Guardar Ingreso": "Nuevo movimiento de dinero",
            "Se pago": "Pago realizado"
        }
        try {
            for (const key in dict_icon) {
                if (item.descripcion.includes(key)) {
                    icon = dict_icon[key];
                    title = dict_title[key];
                    break;
                }
            }
        } catch (error) {
            icon = "alert-triangle";
            title = "Nueva actividad";
            console.error("Error al asignar icono o título para la actividad:", error);
        }

        template += `
        <div class="d-flex align-items-start border-left-line pb-3">
            <div>
                <a href="javascript:void(0)" class="btn ${color[index]} btn-circle mb-2 btn-item text-white">
                    <i data-feather="${icon}"></i>
                </a>
            </div>
            <div class="ms-3 mt-2">
                <h5 class="text-dark font-weight-medium mb-2">${title}!</h5>
                <p class="font-14 mb-2 text-muted">
                    ${item.nombre_usuario + " " + (item.descripcion).replace("Se", "")}
                </p>
                <span class="font-weight-light font-14 text-muted">${dayjs(item.fecha).fromNow()}</span>
            </div>
        </div>
        `
    })
    document.querySelector(".activity").innerHTML = template;
    feather.replace();
}
const targetItem = async () => {
    let numeroClientes = myfecth("clientes/count", {}, { active: 1 }, null, "POST");
    let tablesAvaliable = myfecth("mesa/count", {}, { active: 1, estado: "LIBRE" }, null, "POST");
    let orders = myfecth("orden/count", {}, { status: "entregada" }, null, "POST");
    let orders2 = myfecth("orden/count", {}, { status: "pagado" }, null, "POST");
    let ganancias = myfecth("estadisticas/UtilidadNetaMes", {}, { anio: new Date().getFullYear(), mes: new Date().getMonth() + 1 }, null, "POST");
    let res = ganancias.json();
    let gananciasMes = res.reduce((acc, item) => acc + (item.ingresos || 0), 0);

    document.querySelector(".nro_clientes").textContent = numeroClientes;
    document.querySelector(".ganancias").innerHTML = `<sup class="set-doller">$</sup>${gananciasMes.toFixed(2)}`;
    document.querySelector(".order_completed").textContent = Number(orders) + Number(orders2);
    document.querySelector(".table_available").textContent = tablesAvaliable;
}
let clients = $(".table_clients").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'home/ClientesFrecuentes',
        dataSrc: function (json) {
            let group = {}
            Object.keys(json).forEach(key => {
                let clienteKey = `${json[key].cliente}|${json[key].apellido}|${json[key].telefono}`;
                if (!group[clienteKey]) {
                    group[clienteKey] = {
                        cliente: `${json[key].cliente} ${json[key].apellido}`,
                        telefono: json[key].telefono,
                        ultima_orden: json[key].ultima_orden,
                        total_gastado: json[key].total_gastado,
                        productos: []
                    };
                }
                const productos = [
                    { nombre: json[key].producto_1, imagen: json[key].imagen_1 },
                    { nombre: json[key].producto_2, imagen: json[key].imagen_2 },
                    { nombre: json[key].producto_3, imagen: json[key].imagen_3 }
                ];
                group[clienteKey].productos.push(...productos);
            })
            group = Object.values(group).map(item => {
                let productosUnicos = [];
                item.productos.forEach(prod => {
                    if (prod.nombre && prod.nombre !== "Sin producto" && !productosUnicos.some(p => p.nombre === prod.nombre)) {
                        productosUnicos.push(prod);
                    }
                });
                return { ...item, productos: productosUnicos };
            });
            return group
        },
        type: 'POST',
    },
    columns: [
        {
            data: false, render: function (data, type, row) {
                return `
            <div class="d-flex no-block align-items-center">
                <div class="me-3">
                    <img
                        src="./assets/img/users/1.jpg"
                        alt="user" class="rounded-circle" width="45"
                        height="45" />
                </div>
                <div class="">
                    <h5 class="text-dark mb-0 font-16 font-weight-medium">${row.cliente.toUpperCase()}</h5>
                    <span class="text-muted font-14">${row.telefono ? row.telefono : "S/T"}</span>
                </div>
            </div>
            `
            }
        },
        {
            data: false, render: function (data, type, row) {
                let productosHTML = row.productos.map(prod => {
                    return `<img ${prod.imagen ? `src="media/producto_preparado/${prod.imagen}"` : `src="./assets/img/big/banner_login.png"`} alt="${prod.nombre}" class="rounded-circle" width="60" height="60" data-bs-toggle="tooltip" data-bs-placement="top" title="${prod.nombre}">`;
                }).join('');
                return `<div class="d-flex align-items-center gap-2">${productosHTML}</div>`;
            }
        },
        { data: false, render: function (data, type, row) { return dayjs(row.ultima_orden).fromNow() } },
        { data: false, render: function (data, type, row) { return row.total_gastado ? `<span class="font-weight-medium text-dark">$${row.total_gastado.toFixed(2)}</span>` : "<span class='text-muted'>S/T</span>" } },
    ],
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$('#searchClientFrequent').on('keyup', function () { clients.search(this.value).draw() });

activity()
targetItem();