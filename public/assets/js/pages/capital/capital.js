import introTooltip from "../../intro-tooltip.js"
import { myfecth, nuevaBitacora, modal_operacion } from "../../Functions2.js"
import functionGeneral from "../../Functions.js"
import { reglas_validaciones, set_validaciones } from "../../Validaciones.js"
const {capital} = introTooltip()
const { fecha, hora, setValidationStyles, addDataTables, binnacle, sessionInfo, permission, InputPrice } = functionGeneral()
capital('navbarDropdown')
InputPrice("[input_price]")
set_validaciones()
let session = await sessionInfo()
permission("capital")
let n = $(".table_movimientos_capital").DataTable({
    // order: [[0, "desc"]],
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        // obtener total vía la función síncrona myfecth
        let totalRaw = myfecth("capital/count", {}, {}, null, 'POST');
        let total = 0;
        try {
            total = JSON.parse(totalRaw);
        } catch (e) {
            total = parseInt(totalRaw) || 0;
        }
        myfecth(`capital/get_all/${page}/${size}/${settings.aoColumns[data.order[0].column].data}/${data.order[0].dir}`, {}, {}, function (resp) {
            resp = resp.json()
            const out = {
                draw: data.draw,
                data: resp.data || resp || [],
                recordsTotal: total,
                recordsFiltered: total
            }
            callback(out);
            }, 'POST', true, function (err) {
            console.error(err);
            callback({ draw: data.draw, data: [], recordsTotal: 0, recordsFiltered: 0 });
        })
    },
    columns: [
        { data: 'id' },
        { data: 'descripcion' },
        { data: 'monto' },
        { data: false, render: function (data, type, row) { return fecha(row.fecha) } },
        { data: false, render: function (data, type, row) { return hora(row.fecha) } },
    ],
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$("#searchCapital").on('keyup', function () { n.search(this.value).draw() })
const target = async () => {
    let data = myfecth('capital/getCapital', {}, {}).json()
    document.querySelector(".capital_ingresos").textContent = data[0].ingresos + " $"
    document.querySelector(".capital_ventas").textContent = data[0].ventas + " $"
    document.querySelector(".capital_gastos").textContent = data[0].gastos.toString().replace("-", "") + " $"
    document.querySelector(".capital_utilidad").textContent = data[0].utilidad_neta + " $"
}
target()
document.querySelectorAll(".btn_type_action").forEach(btn => {
    btn.addEventListener("click", (e) => {
        let type_action = btn.textContent
        btn.closest("form").setAttribute("data-type-action", type_action)
    })
})
let form = document.querySelector("#formCapital")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", async (e) => {
        let hasError = false
        e.preventDefault()
        let type_action = form.getAttribute("data-type-action")
        const data = {
            descripcion: form.querySelector("#input-capital-description").value,
            monto: form.querySelector("#input-capital-monto").value,
        }
        const errors = validate(data, reglas_validaciones)
        setValidationStyles("input-capital-description", errors?.descripcion ? errors.descripcion[0] : null);
        setValidationStyles("input-capital-monto", errors?.monto ? errors.monto[0] : null);
        if (errors?.descripcion || errors?.monto) hasError = true
        else hasError = false
        if (!hasError) {
            // Función para convertir formato de precio español a número
            const parsePriceToNumber = (priceString) => {
                return parseFloat(priceString.replace(/\./g, '').replace(',', '.'));
            };
            modal_operacion(
                () => myfecth("capital/add", {}, {monto: type_action == "Guardar Gasto" ? -parsePriceToNumber(data.monto) : parsePriceToNumber(data.monto), descripcion: data.descripcion}),
                'agregar',
                () => {
                    n.ajax.reload()
                    nuevaBitacora("capital", `Agregar`, `${type_action} en capital de ${data.monto} $`)
                    target()
                    form.reset()
                }
            )
            
        }
    })
    form.dataset.listenerAttached = "true"
}