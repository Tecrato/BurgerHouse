import introTooltip from "../../intro-tooltip.js"
import { myfecth,nuevaBitacora } from "../../Functions2.js"
import functionGeneral from "../../Functions.js"
const {capital} = introTooltip()
const { fecha, hora, setValidationStyles, addDataTables, binnacle, sessionInfo, permission, InputPrice } = functionGeneral()
capital('navbarDropdown')
InputPrice("[input_price]")
let session = await sessionInfo()
permission("capital")
let n = $(".table_movimientos_capital").DataTable({
    order: [[0, "desc"]],
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'capital/get_all/0/10000000/id/asc',
        dataSrc: '',
        type: 'POST',
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
    let pet = await fetch('capital/getCapital')
    let data = await pet.json()
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
            let dataFinal = new FormData()
            dataFinal.append("lista[0][descripcion]", data.descripcion)
            dataFinal.append("lista[0][monto]", type_action == "Guardar Gasto" ? -data.monto : data.monto)
            addDataTables(n, dataFinal, "capital", () => {
                nuevaBitacora("capital", `Agregar`, `${type_action} en capital de ${data.monto} $`)
                target()
            })
            form.reset()
        }
    })
    form.dataset.listenerAttached = "true"
}