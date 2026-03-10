import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
import introTooltip from "../../intro-tooltip.js"
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { table } = introTooltip()
const { setValidationStyles, validateField, reindex, resetForm, viewImage, searchParam, print, add, update, permission, searchFilter, sessionInfo, binnacle, edit, Delete, pagination } = functionGeneral();
const { elemenFormTables, targetTable } = Templates()
let session = await sessionInfo()
table('navbarDropdown')
permission("mesas")
const config = {
    search: () => searchParam({ active: 1, estado: "LIBRE" }, "mesas"),
    template: targetTable,
    container: ".cont_tables_free",
    funtions: () => {
        Delete(config, () => nuevaBitacora("Mesas", "Eliminacion", "Se Elimino un mesa"));
        edit((response) => editData(response));
        document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
        permission("mesas");
    }
}
viewImage(".input-image")
searchFilter("#SearchTablesFREE", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value, estado: "LIBRE" }, "mesas") })
})
searchFilter("#SearchTablesOCCUPIED", (e) => {
    if (e.target.value == "") print({ ...config, search: () => searchParam({ active: 1, estado: "OCUPADA" }, "mesas"), container: ".cont_tables_occupied" })
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value, estado: "OCUPADA" }, "mesas"), container: ".cont_tables_occupied" })
})
let TableCount = 1;
function addTable() {
    TableCount++;
    document.getElementById("tables-container").insertAdjacentHTML('beforeend', elemenFormTables(TableCount));
    feather.replace();
    viewImage(".input-image")
    attachValidationListeners(TableCount);
    const newTable = document.getElementById(`tables-${TableCount}`);
    newTable.querySelector(".remove-table").addEventListener("click", function () {
        newTable.remove();
        reindex("#tables-container .tables", "tables", TableCount, "Mesas");
    });
}
function attachValidationListeners(index) {
    const productElement = document.getElementById(`tables-${index}`);
    productElement.querySelectorAll("input[type='text'], input[type='file'], input[type='number']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
        input.addEventListener("change", (e) => validateField(e, rules));
    });
    const table2 = document.getElementById(`table`);
    table2.querySelectorAll("input[type='text'], input[type='number'], input[type='file']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules2));
        input.addEventListener("blur", (e) => validateField(e, rules2));
        input.addEventListener("change", (e) => validateField(e, rules3));
    });

}
document.getElementById("add-table-btn").addEventListener("click", () => { addTable(), reindex("#tables-container .tables", "tables", TableCount, "Mesas") });

const rules = {
    nombre: reglas_validaciones.nombre,
    sillas: reglas_validaciones.sillas,
    imagen: reglas_validaciones.imagen,
};
const rules2 = {
    nombre: reglas_validaciones.nombre,
    sillas: reglas_validaciones.sillas,
};
const rules3 = {
    nombre: reglas_validaciones.nombre,
    sillas: reglas_validaciones.sillas,
    imagen: reglas_validaciones.imagen,
};
let form = document.getElementById("form-submit-tables")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const tables = document.querySelectorAll(".tables");
        let formHasError = false;
        let tablesData = []

        tables.forEach((table, i) => {
            const index = i + 1;
            const data = {
                nombre: table.querySelector(`input[name="nombre"]`).value,
                sillas: table.querySelector(`input[name="sillas"]`).value,
                imagen: table.querySelector(`input[name="imagen"]`) ? table.querySelector(`input[name="imagen"]`).files[0] : "",
                vip: table.querySelector(`input[name="vip"]`).checked,
            };
            tablesData.push(data)

            const errors = validate(data, rules);
            setValidationStyles(`input-name-tables-${index}`, errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles(`input-chair-tables-${index}`, errors?.sillas ? errors.sillas[0] : null);
            setValidationStyles(`input-image-tables-${index}`, errors?.imagen ? errors.imagen[0] : null);
            if (errors?.nombre || errors?.sillas || errors?.imagen) {
                formHasError = true;
            }
        });

        if (!formHasError) {
            let data = new FormData()
            tablesData.forEach((table, index) => {
                data.append(`lista[${index}][nombre]`, table.nombre);
                data.append(`lista[${index}][sillas]`, table.sillas);
                data.append(`lista[${index}][imagen_name]`, table.imagen.name);
                data.append(`lista[${index}][imagen]`, table.imagen);
                data.append(`lista[${index}][vip]`, table.vip == true ? 1 : 0);
            })
            resetForm("#tables-container .tables", form)
            add(config, "mesas", data, () => nuevaBitacora("Mesas", "Agregar", "Se agrego una mesa"))
            bootstrap.Modal.getOrCreateInstance('#register-table').hide()
        }
    });
    form.dataset.listenerAttached = "true";
}
let hasError = false
const editData = (response) => {
    document.querySelector("#input-name-table").value = response[0].nombre;
    document.querySelector("#input-chair-table").value = response[0].sillas;
    document.querySelector("#img-table-response").src = "media/table/" + response[0].imagen;
    document.querySelector("#input-vip-table").checked = response[0].vip == 1 ? true : false;
    document.querySelector("#input-id-table").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input-name-table`).value,
        sillas: document.querySelector(`#input-chair-table`).value,
        imagen: document.querySelector(`#input-image-table`) ? document.querySelector(`#input-image-table`).files[0] : "",
        vip: document.querySelector(`#input-vip-table`).checked,
    };
    const errors = validate(data, rules2);
    setValidationStyles(`input-name-table`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input-chair-table`, errors?.sillas ? errors.sillas[0] : null);
    if (errors?.nombre || errors?.sillas) hasError = true;
}
let formEdit = document.querySelector("#form-submit-edit-table")
if (!formEdit.dataset.listenerAttached) {
    formEdit.addEventListener("submit", (e) => {
        e.preventDefault()
        const data = {
            nombre: document.querySelector(`#input-name-table`).value,
            sillas: document.querySelector(`#input-chair-table`).value,
            imagen: document.querySelector(`#input-image-table`) ? document.querySelector(`#input-image-table`).files[0] : "",
            vip: document.querySelector(`#input-vip-table`).checked,
        };
        const errors = validate(data, rules3);
        setValidationStyles(`input-name-table`, errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles(`input-chair-table`, errors?.sillas ? errors.sillas[0] : null);
        setValidationStyles(`input-image-table`, errors?.imagen ? errors.imagen[0] : null);
        if (errors?.nombre || errors?.sillas || errors?.imagen) hasError = true;
        else hasError = false
        if (!hasError) {
            let dataFinal = new FormData()
            dataFinal.append(`id`, document.querySelector("#input-id-table").value);
            dataFinal.append(`nombre`, data.nombre);
            dataFinal.append(`sillas`, data.sillas);
            dataFinal.append(`vip`, data.vip == true ? 1 : 0);
            if (document.querySelector(`#input-image-table`).value != "") {
                dataFinal.append(`imagen`, data.imagen);
                dataFinal.append(`imagen_name`, data.imagen.name);
            }
            update(config, "table", dataFinal, () => nuevaBitacora("Mesas", "Edicion", "Se Edito un mesa"))
            bootstrap.Modal.getOrCreateInstance('#edit-table').hide()
        }
    })
    form.dataset.listenerAttached = "true";
}
attachValidationListeners(1);
print(config);
print({ ...config, search: () => searchParam({ active: 1, estado: "OCUPADA" }, "mesas"), container: ".cont_tables_occupied" });

// paginacion

pagination((page) => print({ ...config, search: () => searchParam({ active: 1, estado: "OCUPADA" }, "mesas", null, page), container: ".cont_tables_occupied" }), ".pagination_occupied")
pagination((page) => print({ ...config, search: () => searchParam({ active: 1, estado: "LIBRE" }, "mesas", null, page), container: ".cont_tables_free" }), ".pagination_free")