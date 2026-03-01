import Templates, {targetPermission} from "../../templates.js";
import { sessionInfo, imprimir, myfecth, funcs_btn_editar, funcs_btn_eliminar, searchFilter, setValidationStyles } from "../../Functions2.js";

var [session, permisos] = sessionInfo('roles y permisos');
permisos = permisos[0] || {permisos: ''}

console.log(session,permisos)

var search_like = ""
var cachedList = []

async function imprimir_roles() {
    imprimir("roles/get_all", targetPermission, ".cont_permission", {}, { nombre_like: search_like, active: 1 }, (response) => {
        funcs_btn_eliminar(imprimir_roles)
        funcs_btn_editar(editar)
        cachedList = response;
    }, 
    {
        edit: permisos.permisos.includes("editar"),
        del: permisos.permisos.includes("eliminar")
    });
}
searchFilter("#SearchRol", (e) => {
    search_like = e.target.value;
    imprimir_roles()
})

imprimir_roles()
validate.validators.nombreValidator = function (value, options, key, attributes) {
    if (!value) return;
    if (!/^[A-Z]/.test(value)) {
        return options.uppercaseMessage;
    }
    if (!/^[A-Za-z0-9\s]*$/.test(value)) {
        return options.specialCharMessage;
    }
};
const reglas = {
    nombre: {
        nombreValidator: {
            uppercaseMessage: "El nombre debe comenzar con mayúscula",
            specialCharMessage: "El nombre no puede contener caracteres especiales"
        },
        presence: {
            allowEmpty: false,
            message: "El nombre es requerido"
        },
        length: {
            minlength: 3,
            maxlength: 100
        }
    },
    descripcion: {
        presence: {
            allowEmpty: false,
            message: "La descripción es requerida"
        },
        length: {
            minimum: 3,
            maximum: 255
        }
    }
}

function editar(id) {
    const item = cachedList.find(item => item.id == id);
    console.log("Editando rol:", item);

    // Aquí iría la lógica para abrir el modal de edición
    const input_name = document.getElementById("input-name-permission-edit");
    const input_description = document.getElementById("input-description-permission-edit");
    const input_id = document.getElementById("input-id-permission");
    input_name.value = item.nombre;
    input_description.value = item.descripcion;
    input_id.value = item.id;

    const data = {nombre: item.nombre, descripcion: item.descripcion}

    let error = validate(data, reglas)

    if (error) {
        setValidationStyles("input-name-permission-edit", error?.nombre ? error.nombre[0] : null);
        setValidationStyles("input-description-permission-edit", error?.descripcion ? error.descripcion[0] : null);
    } else {
        setValidationStyles("input-name-permission-edit", null);
        setValidationStyles("input-description-permission-edit", null);
    }

    bootstrap.Modal.getOrCreateInstance('#edit-rol').show()
}

function establecer_evento_form_edit() {
    const formEdit = document.getElementById("form-submit-edit-rol")
    if (!formEdit) return console.error("No se encontró el formulario de edición");
    if (document.getElementById("form-submit-edit-rol").dataset.listenerAttached) return console.log("El evento del formulario de edición ya está establecido");

    formEdit.dataset.listenerAttached = "true";
    
    formEdit.addEventListener("submit", (e) => {
        e.preventDefault();
        const input_name = document.getElementById("input-name-permission-edit");
        const input_description = document.getElementById("input-description-permission-edit");
        const input_id = document.getElementById("input-id-permission");
        const data = {nombre: input_name.value, descripcion: input_description.value}

        let errors = validate(data, reglas)
        if (errors) {
            setValidationStyles("input-name-permission-edit", errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles("input-description-permission-edit", errors?.descripcion ? errors.descripcion[0] : null);
            return;
        }
        setValidationStyles("input-name-permission-edit", null);
        setValidationStyles("input-description-permission-edit", null);
        myfecth("roles/update", {}, {id: input_id.value, ...data}, (response) => {
            if (response.status === 200) {
                Swal.fire({
                    title: "¡Éxito!",
                    text: "El rol fue actualizado correctamente",
                    icon: "success",
                });
                console.log("Rol actualizado:", response);
                
                bootstrap.Modal.getOrCreateInstance('#edit-rol').hide()
                imprimir_roles()
            } else {
                Swal.fire({
                    title: "Error",
                    text: "Hubo un error al actualizar el rol",
                    icon: "error",
                });
            }
        }, "POST");
        
    })
}
establecer_evento_form_edit()