import functionGeneral from "../../Functions.js";
import { nuevaBitacora, modal_operacion, myfecth } from "../../Functions2.js"
import Templates from "../../templates.js";
import introTooltip from "../../intro-tooltip.js"
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { table } = introTooltip()
const { setValidationStyles, validateField, reindex, resetForm, viewImage, searchParam, print, add, update, permission, searchFilter, sessionInfo, binnacle, edit, Delete, pagination } = functionGeneral();
const { elemenFormTables, targetTable } = Templates()
let session = await sessionInfo()
console.log(session);
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
function attachValidationListeners(index) {
    const productElement = document.getElementById(`mesa-${index}`);
    productElement.querySelectorAll("input[type='text'], input[type='file'], input[type='number']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("change", (e) => validateField(e, reglas_validaciones));
    });
    const table2 = document.getElementById(`mesa_editar`);
    table2.querySelectorAll("input[type='text'], input[type='number'], input[type='file']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
        input.addEventListener("change", (e) => validateField(e, reglas_validaciones));
    });

}
// document.getElementById("btn_agregar_mesa").addEventListener("click", () => { addTable(), reindex("#contenedor_mesas .mesa", "mesa", TableCount, "Mesas") });


let form = document.getElementById("formulario_enviar_mesas")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        let formHasError = false;
        let data = new FormData()

        let imagenFile = form.querySelector(`input[name="imagen"]`) ? form.querySelector(`input[name="imagen"]`).files[0] : "";
        
        data.append("nombre",form.querySelector(`input[name="nombre"]`).value)
        data.append("sillas",form.querySelector(`input[name="sillas"]`).value)
        data.append("vip",form.querySelector(`input[name="vip"]`).checked ? 1 : 0)
        if (imagenFile) {
            data.append("imagen", imagenFile)
            data.append("imagen_name", imagenFile.name)
        }

        const errors = validate({
            nombre: data.get("nombre"),
            sillas: data.get("sillas"),
            vip: data.get("vip"),
        }, reglas_validaciones);
        const nombreElement = document.getElementById("input_nombre_mesa");
        const sillasElement = document.getElementById("input_numero_sillas_mesa");
            
        if (nombreElement) setValidationStyles("input_nombre_mesa", errors?.nombre ? errors.nombre[0] : null);
        if (sillasElement) setValidationStyles("input_numero_sillas_mesa", errors?.sillas ? errors.sillas[0] : null);
        
        if (errors?.nombre || errors?.sillas) {
            formHasError = true;
        }

        if (!formHasError) {
            resetForm("#contenedor_mesas .mesa", form)
            modal_operacion(
                () => myfecth("mesas/add", {}, data),
                'agregar',
                (response) => {
                    nuevaBitacora("Mesas", "Agregar", "Se agregó una mesa con el id: " + response['last_id'])
                    bootstrap.Modal.getOrCreateInstance('#registrar_mesa').hide()
                    print(config)
                }
            )
            // add(config, "mesas", data, () => nuevaBitacora("Mesas", "Agregar", "Se agrego una mesa"))
            
        }
    });
    form.dataset.listenerAttached = "true";
}
let hasError = false
const editData = (response) => {
    document.querySelector("#input_nombre_mesa_editar").value = response[0].nombre;
    document.querySelector("#input_numero_sillas_mesa_editar").value = response[0].sillas;
    document.querySelector("#img_mesa_respuesta").src = response[0].imagen ? "media/mesas/" + response[0].imagen : "";
    document.querySelector("#input_vip_mesa_editar").checked = response[0].vip == 1 ? true : false;
    document.querySelector("#input_id_mesa").value = response[0].id;
    const data = {
        nombre: document.querySelector(`#input_nombre_mesa_editar`).value,
        sillas: document.querySelector(`#input_numero_sillas_mesa_editar`).value,
        imagen: document.querySelector(`#input_imagen_mesa_editar`) ? document.querySelector(`#input_imagen_mesa_editar`).files[0] : "",
        vip: document.querySelector(`#input_vip_mesa_editar`).checked,
    };
    const errors = validate(data, reglas_validaciones);
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
        const errors = validate(data, reglas_validaciones);
        setValidationStyles(`input_nombre_mesa_editar`, errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles(`input_numero_sillas_mesa_editar`, errors?.sillas ? errors.sillas[0] : null);
        
        // Solo validar imagen si se seleccionó una nueva
        if (data.imagen && data.imagen instanceof File) {
            setValidationStyles(`input_imagen_mesa_editar`, errors?.imagen ? errors.imagen[0] : null);
            if (errors?.imagen) hasError = true;
        }
        
        if (errors?.nombre || errors?.sillas) hasError = true;
        else hasError = false;

        if (!hasError) {
            let dataFinal = new FormData()
            dataFinal.append(`id`, document.querySelector("#input_id_mesa").value);
            dataFinal.append(`nombre`, data.nombre);
            dataFinal.append(`sillas`, data.sillas);
            dataFinal.append(`vip`, data.vip == true ? 1 : 0);
            if (data.imagen && data.imagen instanceof File) {
                dataFinal.append(`imagen`, data.imagen);
                dataFinal.append(`imagen_name`, data.imagen.name);
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