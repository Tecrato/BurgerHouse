import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js";
const { setValidationStyles, validateField, reindex, resetForm, searchParam, print, add, update, permission, searchFilter, sessionInfo, binnacle, edit, Delete, pagination, InputPrice } = functionGeneral();
const { targetPackage } = Templates()
let session = await sessionInfo()
InputPrice("[input-price]")
searchFilter("#SearchPackages", (e) => {
  if (e.target.value == "") print(config)
  else print({ ...config, search: () => searchParam({ active: 1, nombre_like: e.target.value }, "paquete_reservacion", 1000) })
})
const config = {
    search: () => searchParam({ active: 1 }, "paquete_reservacion", null, 0),
    template: targetPackage,
    container: ".cont_packages",
    funtions: () => {
        permission("paquetes")
        Delete(config, () => binnacle(session.message.id, 'paquetes', 'Eliminacion', 'Se elimino un paquete de reserva'));
        edit((response) => editData(response));
        document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
    },
}
print(config)
let toas = (type, msj) => {
    const Toast = Swal.mixin({
        toast: true,
        position: "bottom-end",
        showConfirmButton: false,
        timer: 1000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.onmouseenter = Swal.stopTimer;
            toast.onmouseleave = Swal.resumeTimer;
        }
    });
    Toast.fire({
        icon: `${type}`,
        title: `${msj}`
    });
}
const TablesDataAdd = async () => {
    let tables = await searchParam({}, "paquete_mesa", 50);
    let data = await searchParam({ active: 1, estado: "LIBRE" }, "mesa", 50);
    let mesaIdsEnPaquetes = tables.map(t => t.id_mesa);
    let mesasFiltradas = data.filter(mesa => !mesaIdsEnPaquetes.includes(mesa.id));
    let mesasFiltradasEdit = data.filter(mesa => !mesaIdsEnPaquetes.includes(mesa.id) && mesaIdsEnPaquetes.includes(mesa.id));
    let templatesTables = "";
    let templatesTablesEdit = "";
    mesasFiltradas.forEach(mesa => {
        templatesTables += `
        <div class="col-md-1">
            <input type="checkbox" class="btn-check" id="input-vip-tables-${mesa.id}" autocomplete="off" name="vip" data-id="${mesa.id}">
            <label class="btn bh_1CHECKBOX w-100" for="input-vip-tables-${mesa.id}">
                ${mesa.nombre}
                <h6>Sillas: ${mesa.sillas}</h6>
            </label><br>
        </div>`;
    });
    mesasFiltradasEdit.forEach(mesa => {
        templatesTablesEdit += `
        <div class="col-md-1">
            <input type="checkbox" class="btn-check" id="input-edit-${mesa.id}" autocomplete="off" name="vip" data-id="${mesa.id}">
            <label class="btn bh_1CHECKBOX w-100" for="input-edit-${mesa.id}">
                ${mesa.nombre}
                <h6>Sillas: ${mesa.sillas}</h6>
            </label><br>
        </div>`;
    })
    document.querySelector(".cont_tables_package").innerHTML = templatesTables;
    document.querySelector(".cont_tables_package_edit").innerHTML = templatesTablesEdit;
};
TablesDataAdd()
validate.validators.precio = function (value, options, key, attributes) {
    if (!value) return;
    const cleanValue = value.replace(/\./g, '').replace(',', '.');
    const numberValue = parseFloat(cleanValue);

    if (isNaN(numberValue)) {
        return options.message || "no es un número válido";
    }
    if (numberValue <= 0) {
        return options.message || "debe ser un número mayor a 0";
    }
};
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
    precio: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
};

function attachValidationListeners(index) {
    const productElement = document.getElementById(`package-1`);
    productElement.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
        input.addEventListener("change", (e) => validateField(e, rules));
    });
    const table2 = document.getElementById(`packages-1`);
    table2.querySelectorAll("input[type='text']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
    });
}
let form = document.getElementById("form-submit-package")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", async (e) => {
        bootstrap.Modal.getOrCreateInstance('#register-package').hide()
        e.preventDefault()
        let hasError = false
        let data = {
            nombre: form.querySelector("#input-name-package-1").value,
            precio: form.querySelector("#input-price-package-1").value,
        }
        const errors = validate(data, rules)
        setValidationStyles("input-name-package-1", errors?.nombre ? errors.nombre[0] : null);
        setValidationStyles("input-price-package-1", errors?.precio ? errors.precio[0] : null);
        if (errors) hasError = true
        else hasError = false
        if (!hasError) {
            let tables = document.querySelector(".cont_tables_package")
            let count = 0
            tables.querySelectorAll(".btn-check").forEach((btn) => { if (btn.checked) count++ })
            if (count == 0) toas("error", "Seleccione una mesa")
            else {
                let dataTables = []
                tables.querySelectorAll(".btn-check").forEach((btn) => { if (btn.checked) dataTables.push({ id: btn.getAttribute("data-id") }) })

                let packageData = new FormData()
                packageData.append("nombre", form.querySelector("#input-name-package-1").value)
                packageData.append("precio", (form.querySelector("#input-price-package-1").value).replace(/\./g, '').replace(',', '.'))
                let send = await fetch("paquete_reservacion/add", { method: "POST", body: packageData })
                let response = await send.json()
                let idPackage = response.last_id
                let tablesData = new FormData()
                dataTables.forEach((table, index) => {
                    tablesData.append(`lista[${index}][id_paquete]`, idPackage)
                    tablesData.append(`lista[${index}][id_mesa]`, table.id)
                })
                add(config, "paquete_mesa", tablesData, () => {
                    binnacle(session.message.id, "paquete", "Paquete creado", `Se agrego un nuevo paquete`)
                })
                form.reset()
                form.querySelector("#input-name-package-1").classList.remove("is-invalid", "is-valid")
                form.querySelector("#input-price-package-1").classList.remove("is-invalid", "is-valid")
                TablesDataAdd()
            }
        }
        form.dataset.listenerAttached = "true"
    })
}
async function editData(response) {
    document.getElementById("id_package").value = response[0].id
    const TablesDataAdd = async (idPaqueteSeleccionado) => {
        let tables = await searchParam({}, "paquete_mesa", 50); // todas las asociaciones
        let data = await searchParam({ active: 1, estado: "LIBRE" }, "table", 50); // mesas libres
        let todasLasMesasAsociadas = tables.map(t => t.id_mesa);
        let mesasDelPaquete = tables
            .filter(t => t.id_paquete === idPaqueteSeleccionado)
            .map(t => t.id_mesa);
        let mesasFinales = data.filter(mesa =>
            !todasLasMesasAsociadas.includes(mesa.id) || mesasDelPaquete.includes(mesa.id)
        );

        let templates = mesasFinales.map(mesa => `
        <div class="col-md-1">
            <input type="checkbox" class="btn-check" id="input-edit-${mesa.id}" autocomplete="off" name="vip" data-id="${mesa.id}">
            <label class="btn bh_1CHECKBOX w-100" for="input-edit-${mesa.id}">
                ${mesa.nombre}
                <h6>Sillas: ${mesa.sillas}</h6>
            </label><br>
        </div>
    `).join("");

        document.querySelector(".cont_tables_package_edit").innerHTML = templates;
        document.querySelector(".cont_tables_package_edit").querySelectorAll(".btn-check").forEach((btn) => {
            let idBtn = btn.getAttribute("data-id")
            if (tables.find(table => table.id_mesa == idBtn)) btn.checked = true
            else btn.checked = false
            btn.addEventListener("change", async (e) => {
                if (btn.checked == true) {
                    let id_table = btn.getAttribute("data-id")
                    let id_package = response[0].id
                    let data = new FormData()
                    data.append("lista[0][id_mesa]", id_table), data.append("lista[0][id_paquete]", id_package)
                    let send = await fetch("paquete_mesa/add_many", { method: "POST", body: data })
                    let responseData = await send.json()
                } else {
                    let id_table = btn.getAttribute("data-id")
                    let search = await searchParam({ id_mesa: id_table }, "paquete_mesa")
                    let data = new FormData()
                    data.append("id", search[0].id)
                    let count = 0
                    document.querySelector(".cont_tables_package_edit").querySelectorAll(".btn-check").forEach((btn) => {
                        if (btn.checked == true) count++
                    })
                    if (count < 2) {
                        toas("error", "Debe haber al menos 1 mesa asociadas al paquete")
                        btn.checked = true
                    } else if (count >= 2) {
                        let send = await fetch("paquete_mesa/delete", { method: "POST", body: data })
                        let response = await send.json()
                    }
                }
            })
        })
    };
    TablesDataAdd(response[0].id)
    document.querySelector("#input-name-package").value = response[0].nombre
    document.querySelector("#input-price-package").value = response[0].precio
    const data = {
        nombre: document.querySelector("#input-name-package").value,
        precio: document.querySelector("#input-price-package").value,
    }
    const errors = validate(data, rules)
    setValidationStyles("input-name-package", errors?.nombre ? errors.nombre[0] : null);
    setValidationStyles("input-price-package", errors?.precio ? errors.precio[0] : null);

    let formEdit = document.getElementById("form-submit-edit-package")
    if (!formEdit.dataset.listenerAttached) {
        formEdit.addEventListener("submit", async (e) => {
            bootstrap.Modal.getOrCreateInstance('#edit-package').hide()
            e.preventDefault()
            let hasError = false
            const data = {
                nombre: formEdit.querySelector("#input-name-package").value,
                precio: formEdit.querySelector("#input-price-package").value.replace(",", "."),
            }
            const errors = validate(data, rules)
            setValidationStyles("input-name-package", errors?.nombre ? errors.nombre[0] : null);
            setValidationStyles("input-price-package", errors?.precio ? errors.precio[0] : null);
            if (errors) hasError = true
            else hasError = false
            if (!hasError) {
                let dataUpdate = new FormData()
                dataUpdate.append("id", document.getElementById("id_package").value)
                dataUpdate.append("nombre", data.nombre)
                dataUpdate.append("precio", (data.precio))
                update(config, "paquete_reservacion", dataUpdate, () => {
                    binnacle(session.message.id, "paquete", "Actualizacion", `Se actualizo el paquete ${document.getElementById("id_package").value}`);
                })
            }
        })

        formEdit.dataset.listenerAttached = true
    }
    attachValidationListeners(1)
}
attachValidationListeners(1)
pagination((page) => print({ ...config, search: () => searchParam({ active: 1 }, "paquete_reservacion", null, page) }), ".pagination")