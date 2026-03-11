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
    document.getElementById("contenedor_mesas").insertAdjacentHTML('beforeend', elemenFormTables(TableCount));
    feather.replace();
    viewImage(".input-image")
    attachValidationListeners(TableCount);
    const newTable = document.getElementById(`mesa-${TableCount}`);
    newTable.querySelector(".remove-table").addEventListener("click", function () {
        newTable.remove();
        reindex("#contenedor_mesas .mesa", "mesa", TableCount, "Mesas");
    });
}
function attachValidationListeners(index) {
    const productElement = document.getElementById(`mesa-${index}`);
    productElement.querySelectorAll("input[type='text'], input[type='file'], input[type='number']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
        input.addEventListener("change", (e) => validateField(e, rules));
    });
    const table2 = document.getElementById(`mesa_editar`);
    table2.querySelectorAll("input[type='text'], input[type='number'], input[type='file']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules2));
        input.addEventListener("blur", (e) => validateField(e, rules2));
        input.addEventListener("change", (e) => validateField(e, rules3));
    });

}
document.getElementById("btn_agregar_mesa").addEventListener("click", () => { addTable(), reindex("#contenedor_mesas .mesa", "mesa", TableCount, "Mesas") });

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
let form = document.getElementById("formulario_enviar_mesas")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const mesas = document.querySelectorAll(".mesa");
        let formHasError = false;
        let tablesData = []

        mesas.forEach((mesa, i) => {
            const index = i + 1;
            const data = {
                nombre: mesa.querySelector(`input[name="nombre"]`).value,
                sillas: mesa.querySelector(`input[name="sillas"]`).value,
                imagen: mesa.querySelector(`input[name="imagen"]`) ? mesa.querySelector(`input[name="imagen"]`).files[0] : "",
                vip: mesa.querySelector(`input[name="vip"]`).checked,
            };
            tablesData.push(data)

            const errors = validate(data, rules);
            const nombreElement = document.getElementById(`input_nombre_mesa-${index}`);
            const sillasElement = document.getElementById(`input_numero_sillas_mesa-${index}`);
            const imagenElement = document.getElementById(`input_imagen_mesa-${index}`);
            
            if (nombreElement) setValidationStyles(`input_nombre_mesa-${index}`, errors?.nombre ? errors.nombre[0] : null);
            if (sillasElement) setValidationStyles(`input_numero_sillas_mesa-${index}`, errors?.sillas ? errors.sillas[0] : null);
            if (imagenElement) setValidationStyles(`input_imagen_mesa-${index}`, errors?.imagen ? errors.imagen[0] : null);
            if (errors?.nombre || errors?.sillas || errors?.imagen) {
                formHasError = true;
            }
        });

        if (!formHasError) {
            let data = new FormData()
            tablesData.forEach((table, index) => {
                data.append(`lista[${index}][nombre]`, table.nombre);
                data.append(`lista[${index}][sillas]`, table.sillas);
                data.append(`lista[${index}][imagen_name]`, table.imagen.name); // El controlador lo sobreescribirá
                data.append(`lista[${index}][imagen]`, table.imagen);
                data.append(`lista[${index}][vip]`, table.vip == true ? 1 : 0);
            })
            resetForm("#contenedor_mesas .mesa", form)
            add(config, "mesas", data, () => nuevaBitacora("Mesas", "Agregar", "Se agrego una mesa"))
            bootstrap.Modal.getOrCreateInstance('#registrar_mesa').hide()
        }
    });
    form.dataset.listenerAttached = "true";
}
let hasError = false
const editData = (response) => {
    document.querySelector("#input_nombre_mesa_editar").value = response[0].nombre;
    document.querySelector("#input_numero_sillas_mesa_editar").value = response[0].sillas;
    document.querySelector("#img_mesa_respuesta").src = "media/mesas/" + response[0].imagen;
    document.querySelector("#input_vip_mesa_editar").checked = response[0].vip == 1 ? true : false;
    document.querySelector("#input_id_mesa").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input_nombre_mesa_editar`).value,
        sillas: document.querySelector(`#input_numero_sillas_mesa_editar`).value,
        imagen: document.querySelector(`#input_imagen_mesa_editar`) ? document.querySelector(`#input_imagen_mesa_editar`).files[0] : "",
        vip: document.querySelector(`#input_vip_mesa_editar`).checked,
    };
    const errors = validate(data, rules2);
    setValidationStyles(`input_nombre_mesa_editar`, errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles(`input_numero_sillas_mesa_editar`, errors?.sillas ? errors.sillas[0] : null);
    if (errors?.nombre || errors?.sillas) hasError = true;
}
let formEdit = document.querySelector("#formulario_editar_mesa")
if (!formEdit.dataset.listenerAttached) {
    formEdit.addEventListener("submit", (e) => {
        e.preventDefault()
        const data = {
            nombre: document.querySelector(`#input_nombre_mesa_editar`).value,
            sillas: document.querySelector(`#input_numero_sillas_mesa_editar`).value,
            imagen: document.querySelector(`#input_imagen_mesa_editar`) ? document.querySelector(`#input_imagen_mesa_editar`).files[0] : "",
            vip: document.querySelector(`#input_vip_mesa_editar`).checked,
        };
        const errors = validate(data, rules3);
        setValidationStyles(`input_nombre_mesa_editar`, errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles(`input_numero_sillas_mesa_editar`, errors?.sillas ? errors.sillas[0] : null);
        setValidationStyles(`input_imagen_mesa_editar`, errors?.imagen ? errors.imagen[0] : null);
        if (errors?.nombre || errors?.sillas || errors?.imagen) hasError = true;
        else hasError = false;

        if (!hasError) {
            let dataFinal = new FormData()
            dataFinal.append(`id`, document.querySelector("#input_id_mesa").value);
            dataFinal.append(`nombre`, data.nombre);
            dataFinal.append(`sillas`, data.sillas);
            dataFinal.append(`vip`, data.vip == true ? 1 : 0);
            if (data.imagen && data.imagen instanceof File) {
                dataFinal.append(`imagen`, data.imagen);
                dataFinal.append(`imagen_name`, data.imagen.name); // El controlador lo sobreescribirá
            }
            update(config, "mesas", dataFinal, () => nuevaBitacora("Mesas", "Edicion", "Se Edito un mesa"))
            bootstrap.Modal.getOrCreateInstance('#editar_mesa').hide()
        }
    })
    formEdit.dataset.listenerAttached = "true";
}
attachValidationListeners(1);
print(config);
print({ ...config, search: () => searchParam({ active: 1, estado: "OCUPADA" }, "mesas"), container: ".cont_tables_occupied" });

// paginacion

pagination((page) => print({ ...config, search: () => searchParam({ active: 1, estado: "OCUPADA" }, "mesas", null, page), container: ".cont_tables_occupied" }), ".pagination_occupied")
pagination((page) => print({ ...config, search: () => searchParam({ active: 1, estado: "LIBRE" }, "mesas", null, page), container: ".cont_tables_free" }), ".pagination_free")