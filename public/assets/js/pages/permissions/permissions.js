import functionGeneral from "../../Functions.js";
import { nuevaBitacora, myfecth } from "../../Functions2.js"
import Templates from "../../templates.js";
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { setValidationStyles, validateField, print, searchParam, searchFilter, Delete, edit, sessionInfo, binnacle, update, add, permission } = functionGeneral();
const { targetPermission } = Templates()
let session = await sessionInfo();
permission('roles y permisos')

// Mapas para convertir nombres a IDs
let modulosMap = new Map();
let permisosMap = new Map();

async function loadModulosYPermisos() {
    // Cargar módulos
    let modulos = myfecth("permisos/get_modulos", {}, { active: 1 }, null, 'POST');
    if (modulos && modulos.json) {
        modulos = modulos.json();
    }
    if (Array.isArray(modulos)) {
        modulos.forEach(m => modulosMap.set(m.nombre.toLowerCase(), m.id));
    }
    
    // Cargar permisos
    let permisos = myfecth("permisos/get_all", {}, { active: 1 }, null, 'POST');
    if (permisos && permisos.json) {
        permisos = permisos.json();
    }
    if (Array.isArray(permisos)) {
        permisos.forEach(p => permisosMap.set(p.nombre.toLowerCase(), p.id));
    }
}

// Llamar al inicio
await loadModulosYPermisos();

const config = {
    search: () => searchParam({ active: 1 }, "roles"),
    template: targetPermission,
    container: ".cont_permission",
    funtions: () => {
        Delete(config, () => nuevaBitacora('Rol', 'Eliminacion', 'Se elimino un rol'));
        edit((response) => editData(response));
        permission("roles y permisos")
    }
}
searchFilter("#SearchRol", (e) => {
    if (e.target.value == "") print(config)
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "roles") })
})

// Función para obtener ID de módulo por nombre
function getModuloId(nombreModulo) {
    return modulosMap.get(nombreModulo.toLowerCase()) || null;
}

// Función para obtener ID de permiso por nombre
function getPermisoId(nombrePermiso) {
    return permisosMap.get(nombrePermiso.toLowerCase()) || null;
}

// Función para cargar permisos de un rol
async function cargarPermisosPorRol(idRol) {
    // Limpiar todos los checkboxes
    document.querySelectorAll(".form-check-input").forEach(input => input.checked = false);
    
    // Obtener permisos del rol
    let permisosData = myfecth("roles/obtener_permisos", {}, { id_rol: idRol }, null, 'POST');
    if (permisosData && permisosData.json) {
        permisosData = permisosData.json();
    }
    
    if (Array.isArray(permisosData)) {
        permisosData.forEach(element => {
            if (element.permisos) {
                let check = document.querySelectorAll(`[data-module='${element.modulo}']`);
                for (const data of check) {
                    if (element.permisos.includes(data.getAttribute("data-action"))) {
                        data.checked = true;
                    }
                }
            }
        });
    }
}

// Toggle permiso individual
async function togglePermiso(idRol, nombreModulo, nombrePermiso) {
    let idModulo = getModuloId(nombreModulo);
    let idPermiso = getPermisoId(nombrePermiso);
    
    if (!idModulo || !idPermiso) {
        console.error("No se encontró el módulo o permiso:", nombreModulo, nombrePermiso);
        return;
    }
    
    let result = myfecth(
        "permisos/toggle_permiso", 
        {}, 
        { id_rol: idRol, id_modulo: idModulo, id_permiso: idPermiso }, 
        null, 
        'POST'
    );
    
    if (result && result.json) {
        result = result.json();
        console.log("Permiso actualizado:", result);
        nuevaBitacora("Permisos", "Actualizar", `Permiso ${nombrePermiso} del módulo ${nombreModulo} ${result.action === 'added' ? 'agregado' : 'eliminado'}`);
    }
}

// Select de roles
let select = document.querySelector(".select_rol")
const SelectRol = async (select) => {
    let option = await searchParam({ active: 1 }, "roles")
    option.forEach((element) => { 
        select.insertAdjacentHTML("beforeend", `<option value="${element.id}">${element.nombre}</option>`) 
    })
    select.addEventListener("change", async (e) => {
        if (e.target.value) {
            await cargarPermisosPorRol(e.target.value);
        }
    })
}
SelectRol(select)

// Manejar cambios en checkboxes de permisos
function attachPermisoListeners() {
    const allCheckboxes = document.querySelectorAll("#form-submit-permissions .form-check-input");
    
    allCheckboxes.forEach(checkbox => {
        if (!checkbox.dataset.listenerAttached) {
            checkbox.addEventListener("change", async (e) => {
                let idRol = select.value;
                if (!idRol || idRol === "Elige un rol") {
                    checkbox.checked = !checkbox.checked;
                    let tooltip = new bootstrap.Tooltip(select, {
                        title: "Debe seleccionar un rol",
                        placement: "right"
                    });
                    tooltip.show();
                    setTimeout(() => tooltip.dispose(), 3000);
                    return;
                }
                
                let nombreModulo = checkbox.getAttribute("data-module");
                let nombrePermiso = checkbox.getAttribute("data-action");
                
                await togglePermiso(idRol, nombreModulo, nombrePermiso);
            });
            checkbox.dataset.listenerAttached = "true";
        }
    });
}

// Verificar si hay un rol seleccionado al cargar
if (select.value && select.value !== "Elige un rol") {
    cargarPermisosPorRol(select.value);
}

// Llamar a la función para agregar listeners
attachPermisoListeners();

// Check "Seleccionar Todos"
let checkAll = document.querySelector(".check-all");
if (checkAll) {
    checkAll.addEventListener("change", async () => {
        let idRol = select.value;
        if (!idRol || idRol === "Elige un rol") {
            checkAll.checked = false;
            let tooltip = new bootstrap.Tooltip(select, {
                title: "Debe seleccionar un rol",
                placement: "right"
            });
            tooltip.show();
            setTimeout(() => tooltip.dispose(), 3000);
            return;
        }
        
        const allCheckboxes = document.querySelectorAll("#form-submit-permissions .form-check-input");
        
        if (checkAll.checked) {
            allCheckboxes.forEach(checkbox => checkbox.checked = true);
        } else {
            allCheckboxes.forEach(checkbox => checkbox.checked = false);
        }
        
        // Sincronizar cada checkbox con la API
        for (const checkbox of allCheckboxes) {
            let nombreModulo = checkbox.getAttribute("data-module");
            let nombrePermiso = checkbox.getAttribute("data-action");
            await togglePermiso(idRol, nombreModulo, nombrePermiso);
        }
    });
}

// Validación de formulario de roles

document.querySelectorAll("input[type='text'], textarea").forEach(input => {
    input.addEventListener("keyup", (e) => validateField(e, reglas_validaciones));
    input.addEventListener("blur", (e) => validateField(e, reglas_validaciones));
})
let form = document.getElementById("form-submit-rol")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", (e) => {
        let hasError = false
        e.preventDefault()
        let data = {
            nombre: form.querySelector("#input-name-permission").value,
            descripcion: form.querySelector("#input-description-permission").value,
        }
        const errors = validate(data, reglas_validaciones);
        setValidationStyles("input-name-permission", errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles("input-description-permission", errors?.descripcion ? errors.descripcion[0] : null);
        if (errors?.nombre || errors?.descripcion) hasError = true
        else hasError = false
        if (!hasError) {
            let data = new FormData(form)
            data.append("lista[0][nombre]", form.querySelector("#input-name-permission").value)
            data.append("lista[0][descripcion]", form.querySelector("#input-description-permission").value)
            add(config, "roles", data, () => nuevaBitacora('Rol', 'Agregar', 'Se creo un rol'));
            bootstrap.Modal.getOrCreateInstance('#register-rol').hide()
            SelectRol(select)
        }
    })
    form.dataset.listenerAttached = "true";
}
const editData = async (response) => {
    let hasError = false
    document.querySelector("#input-name-permission-edit").value = response[0].nombre;
    document.querySelector("#input-description-permission-edit").value = response[0].descripcion;
    document.querySelector("#input-id-permission").value = response[0].id;

    let data = {
        nombre: document.querySelector("#input-name-permission-edit").value,
        descripcion: document.querySelector("#input-description-permission-edit").value,
    }
    const errors = validate(data, reglas_validaciones);
    setValidationStyles("input-name-permission-edit", errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles("input-description-permission-edit", errors?.descripcion ? errors.descripcion[0] : null);
    if (errors?.nombre || errors?.descripcion) hasError = true
    else hasError = false
    bootstrap.Modal.getOrCreateInstance('#edit-rol').show()

    let formEdit = document.getElementById("form-submit-edit-rol")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", (e) => {
            e.preventDefault()
            let data = {
                nombre: document.querySelector("#input-name-permission-edit").value,
                descripcion: document.querySelector("#input-description-permission-edit").value,
            }
            const errors = validate(data, reglas_validaciones);
            setValidationStyles("input-name-permission-edit", errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles("input-description-permission-edit", errors?.descripcion ? errors.descripcion[0] : null);
            if (errors?.nombre || errors?.descripcion) hasError = true
            else hasError = false

            if (!hasError) {
                let data = new FormData()
                data.append("id", document.querySelector("#input-id-permission").value)
                data.append("nombre", document.querySelector("#input-name-permission-edit").value)
                data.append("descripcion", document.querySelector("#input-description-permission-edit").value)
                update(config, "roles", data, () => nuevaBitacora('Rol', 'Editar', 'Se actualizo un rol'));
                bootstrap.Modal.getOrCreateInstance('#edit-rol').hide()
            }
        })
        formEdit.dataset.listenerAttached = "true";
    }
}
print(config);