import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
const { setValidationStyles, validateField, print, searchParam, searchFilter, Delete, edit, sessionInfo, binnacle, update, add, permission } = functionGeneral();
const { targetPermission } = Templates()
let session = await sessionInfo();
permission('roles y permisos')
const config = {
    search: () => searchParam({ active: 1 }, "rol"),
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
    else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "rol") })
})
//funcion para el check all
let check_all = document.querySelector(".check-all")
let form_check_input = document.querySelectorAll(".form-check-input")
check_all.addEventListener("change", () => {
    if (check_all.closest("#form-submit-permissions").querySelector(".select_rol").value == "Elige un rol") {
        check_all.checked = false
        let tootip = new bootstrap.Tooltip(check_all.closest("#form-submit-permissions").querySelector(".select_rol"), {
            title: "Debe seleccionar un rol",
            placement: "right"
        })
        tootip.show();
        setTimeout(() => {
            tootip.dispose();
        }, 5000);
    } else {
        if (check_all.checked) {
            form_check_input.forEach(input => {
                input.checked = true
            })
        } else {
            form_check_input.forEach(input => {
                input.checked = false
            })
        }
    }
    let idRol = check_all.closest("#form-submit-permissions").querySelector(".select_rol").value;
    let idEditPermission = 0;
    document.querySelectorAll(".table_permissions_normal tbody tr").forEach(async row => {
        let actionsUpdate = [];
        let actionsInsert = [];
        let modulo = row.querySelector(".form-check-input").getAttribute("data-module");
        let pet = await searchParam({ id_rol: idRol, modulo: modulo }, "permissions");
        row.querySelectorAll(".form-check-input").forEach(input => {
            if (input.checked) {
                let action = input.getAttribute("data-action");
                if (pet.length == 0) {
                    actionsInsert.push(action);
                } else {
                    actionsUpdate.push(action);
                }
            }
        });
        if (pet.length == 0) {
            let formData = new FormData();
            formData.append("id_rol", idRol);
            formData.append("modulo", modulo);
            formData.append("permisos", actionsInsert.join(","));
            let send = await fetch("permissions/add", { method: "POST", body: formData });
        } else {
            idEditPermission = pet[0].id;
            let permisos = actionsUpdate.join(",");
            let formData = new FormData();
            formData.append("id", idEditPermission);
            formData.append("permisos", permisos);
            let send = await fetch("permissions/update", { method: "POST", body: formData });
        }
    });
    document.querySelectorAll(".table_permissions_special").forEach(async (row, index) => {
        let actionsUpdate = [];
        let actionsInsert = [];
        let modulo = row.querySelector(".form-check-input").getAttribute("data-module");
        let pet = await searchParam({ id_rol: idRol, modulo: modulo }, "permissions");
        row.querySelectorAll(".form-check-input").forEach(input => {
            if (input.checked) {
                let action = input.getAttribute("data-action");
                if (pet.length == 0) {
                    actionsInsert.push(action);
                } else {
                    actionsUpdate.push(action);
                }
            }
        });
        if (pet.length == 0) {
            let formData = new FormData();
            formData.append("id_rol", idRol);
            formData.append("modulo", modulo);
            formData.append("permisos", actionsInsert.join(","));
            let send = await fetch("permissions/add", { method: "POST", body: formData });
        } else {
            idEditPermission = pet[0].id;
            let permisos = actionsUpdate.join(",");
            let formData = new FormData();
            formData.append("id", idEditPermission);
            formData.append("permisos", permisos);
            let send = await fetch("permissions/update", { method: "POST", body: formData });
        }
    });
})

form_check_input.forEach(input => {
    input.addEventListener("change", (e) => {
        if (input.closest("#form-submit-permissions").querySelector(".select_rol").value == "Elige un rol") {
            input.checked = false
            let tootip = new bootstrap.Tooltip(input.closest("#form-submit-permissions").querySelector(".select_rol"), {
                title: "Debe seleccionar un rol",
                placement: "right"
            })
            tootip.show();
            setTimeout(() => {
                tootip.dispose();
            }, 5000);
        }

    })
})
//funcion del select
let select = document.querySelector(".select_rol")
const SelectRol = async (select) => {
    let option = await searchParam({ active: 1 }, "rol")
    option.forEach((element) => { select.insertAdjacentHTML("beforeend", `<option value="${element.id}">${element.nombre}</option>`) })
    select.addEventListener("change", async (e) => {
        let idRol = e.target.value
        let pet = await searchParam({ id_rol: idRol }, "permissions", 100000000)
        if (pet.length != 0) {
            cargarPermisos(pet)
        } else {
            document.querySelector(".table_permissions_normal").querySelectorAll(".form-check-input").forEach(input => {
                input.checked = false
            })
            document.querySelectorAll(".table_permissions_special").forEach(input => {
                input.querySelectorAll(".form-check-input").forEach(input => {
                    input.checked = false
                })
            })
        }
    })
}
SelectRol(select)
function cargarPermisos(response) {
    response.forEach(element => {
        let check = document.querySelectorAll(`[data-module='${element.modulo}']`)
        for (const data of check) {
            if (element.permisos.includes(data.getAttribute("data-action"))) data.checked = true
        }
    })
}

const actionRol = () => {
    let idRol = 0
    let idEditPermission = 0
    if (!select.dataset.listenerAttached) {
        select.addEventListener("change", (e) => {
            idRol = e.target.value
            //tabla de permisos normales(primera tabla)
            document.querySelector(".table_permissions_normal").querySelectorAll(".form-check-input").forEach(input => {
                if (!input.dataset.listenerAttached) {
                    input.addEventListener("change", async () => {
                        let actionsUpdate = []
                        let actionsInsert = []
                        let modulo = input.getAttribute("data-module")
                        let pet = await searchParam({ id_rol: idRol, modulo: modulo }, "permissions")
                        if (pet.length == 0) {
                            let container = input.closest("tr")
                            container.querySelectorAll(".form-check-input").forEach(input => {
                                if (input.checked) {
                                    let action = input.getAttribute("data-action")
                                    actionsInsert.push(action)
                                }
                            })
                            let formData = new FormData()
                            formData.append("id_rol", idRol)
                            formData.append("modulo", modulo)
                            formData.append("permisos", actionsInsert.join(","))
                            let send = await fetch("permissions/add", { method: "POST", body: formData })
                            console.log(await send.json());
                        } else {
                            idEditPermission = pet[0].id
                            let container = input.closest("tr")
                            container.querySelectorAll(".form-check-input").forEach(input => {
                                if (input.checked) {
                                    let action = input.getAttribute("data-action")
                                    actionsUpdate.push(action)
                                }
                            })
                            let permisos = actionsUpdate.join(",")
                            let formData = new FormData()
                            formData.append("id", idEditPermission)
                            formData.append("permisos", permisos)
                            let send = await fetch("permissions/update", { method: "POST", body: formData })
                        }
                    })
                    input.dataset.listenerAttached = "true";
                }
            })
            //tabla con permisos especiales
            document.querySelectorAll(".table_permissions_special").forEach(table => {
                table.querySelectorAll(".form-check-input").forEach(input => {
                    if (!input.dataset.listenerAttached) {
                        input.addEventListener("change", async () => {
                            let actionsUpdate = []
                            let actionsInsert = []
                            let modulo = input.getAttribute("data-module")
                            let pet = await searchParam({ id_rol: idRol, modulo: modulo }, "permissions")
                            if (pet.length == 0) {
                                let container = input.closest(".table_permissions_special")
                                container.querySelectorAll(".form-check-input").forEach(input => {
                                    if (input.checked) {
                                        let action = input.getAttribute("data-action")
                                        actionsInsert.push(action)
                                    }
                                })
                                let formData = new FormData()
                                formData.append("id_rol", idRol)
                                formData.append("modulo", modulo)
                                formData.append("permisos", actionsInsert.join(","))
                                let send = await fetch("permissions/add", { method: "POST", body: formData })
                                console.log(await send.json());
                            } else {
                                idEditPermission = pet[0].id
                                let container = input.closest(".table_permissions_special")
                                container.querySelectorAll(".form-check-input").forEach(input => {
                                    if (input.checked) {
                                        let action = input.getAttribute("data-action")
                                        actionsUpdate.push(action)
                                    }
                                })
                                let permisos = actionsUpdate.join(",")
                                let formData = new FormData()
                                formData.append("id", idEditPermission)
                                formData.append("permisos", permisos)
                                let send = await fetch("permissions/update", { method: "POST", body: formData })
                                console.log(await send.json());
                            }
                        })
                        input.dataset.listenerAttached = "true";
                    }
                })
            })
        })
        select.dataset.listenerAttached = "true";
    }
}
actionRol()

//funcion para el check en caso de escojer una opcion q no sea consultar
let verify = document.querySelectorAll("[data-module]")
verify.forEach(d => {
    d.addEventListener("change", () => {
        if (d.closest("#form-submit-permissions").querySelector(".select_rol").value == "Elige un rol") {
            d.checked = false
            let tootip = new bootstrap.Tooltip(d.closest("#form-submit-permissions").querySelector(".select_rol"), {
                title: "Debe seleccionar un rol",
                placement: "right"
            })
            tootip.show();
            setTimeout(() => {
                tootip.dispose();
            }, 5000);
        } else {
            let action = d.getAttribute("data-action");

            if (d.closest('.table_permissions_special')) {
                console.log("object");
                let container = d.closest('.table_permissions_special');
                let cheked = container.querySelectorAll('[data-action]:not([data-action="consultar"]):checked').length;
                if (action != "consultar" && d.checked == true) container.querySelector("[data-action='consultar']").checked = true;
                if (action == "consultar" && d.checked == false && cheked > 0) container.querySelector("[data-action='consultar']").checked = true;
            } else {
                if (action == "consultar") {
                    let tr = d.closest("tr");
                    let cheked = tr.querySelectorAll('[data-action]:not([data-action="consultar"]):checked').length;
                    if (d.checked == true) tr.querySelector("[data-action='consultar']").checked = true;
                    if (d.checked == false && cheked > 0) tr.querySelector("[data-action='consultar']").checked = true;
                } else {
                    let tr2 = d.closest("tr");
                    let cheked = tr2.querySelector('[data-action="consultar"]')
                    if (d.checked == true) {
                        if (cheked.checked == false) tr2.querySelector("[data-action='consultar']").checked = true;
                    }
                }
            }
        }
    })
})
//-----------------------------------------------------------------------------
validate.validators.nombreValidator = function (value, options, key, attributes) {
    if (!value) return;
    if (!/^[A-Z]/.test(value)) {
        return options.uppercaseMessage;
    }
    if (!/^[A-Za-z0-9\s]*$/.test(value)) {
        return options.specialCharMessage;
    }
};
const rules = {
    nombre: {
        nombreValidator: {
            uppercaseMessage: "^debe tener la primera letra en mayúscula.",
            specialCharMessage: "^No se permiten signos como puntos (.) o comas (,)."
        },
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        length: {
            minimum: 4,
            message: "^debe tener al menos 4 caracteres"
        },
    },

    descripcion: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        length: {
            minimum: 15,
            message: "^debe tener al menos 15 caracteres"
        }
    },
};
document.querySelectorAll("input[type='text'], textarea").forEach(input => {
    input.addEventListener("keyup", (e) => validateField(e, rules));
    input.addEventListener("blur", (e) => validateField(e, rules));
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
        const errors = validate(data, rules);
        setValidationStyles("input-name-permission", errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles("input-description-permission", errors?.descripcion ? errors.descripcion[0] : null);
        if (errors) hasError = true
        else hasError = false
        if (!hasError) {
            let data = new FormData(form)
            data.append("lista[0][nombre]", form.querySelector("#input-name-permission").value)
            data.append("lista[0][descripcion]", form.querySelector("#input-description-permission").value)
            add(config, "rol", data, () => nuevaBitacora('Rol', 'Agregar', 'Se creo un rol'));
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
    const errors = validate(data, rules);
    setValidationStyles("input-name-permission-edit", errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles("input-description-permission-edit", errors?.descripcion ? errors.descripcion[0] : null);
    if (errors) hasError = true
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
            const errors = validate(data, rules);
            setValidationStyles("input-name-permission-edit", errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles("input-description-permission-edit", errors?.descripcion ? errors.descripcion[0] : null);
            if (errors) hasError = true
            else hasError = false

            if (!hasError) {
                let data = new FormData()
                data.append("id", document.querySelector("#input-id-permission").value)
                data.append("nombre", document.querySelector("#input-name-permission-edit").value)
                data.append("descripcion", document.querySelector("#input-description-permission-edit").value)
                update(config, "rol", data, () => nuevaBitacora('Rol', 'Editar', 'Se actualizo un rol'));
                bootstrap.Modal.getOrCreateInstance('#edit-rol').hide()
            }
        })
        formEdit.dataset.listenerAttached = "true";
    }
}
print(config);