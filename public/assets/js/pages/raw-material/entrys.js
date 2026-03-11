import functionGeneral from "../../Functions.js";
import { nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
import { tableRawMaterial } from "./raw_material.js"
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();

const { optionsSupplier, optionsRawMaterial, elementFormEntrysRawMaterial, optionsRol, elementFormPaymentEntrysRawMaterial, elementFormPaymentEntrysRawMaterialEdit, elementFormPaymentEntrysRawMaterialEditNew, elemenFormProductEntrysRawMaterial, elemenFormProductEntrysRawMaterialEdit, elemenFormProductEntrysRawMaterialNew } = Templates()

const { InputPrice, selectOptionAll, viewImage, setValidationStyles, validateField, fecha, searchParam, diasRestantesFechaVencimiento, sessionInfo, binnacle, deleteDatatable, updateDataTables, permission, amountDolar } = functionGeneral();

selectOptionAll(".select_options_supplier", "proveedor", optionsSupplier)
selectOptionAll(".select_options_raw_material", "materia_prima", optionsRawMaterial)
selectOptionAll(".select_options_payment", "metodos_de_pago", optionsRol)
permission("Entradas de materia prima")
InputPrice("[input_price]")
viewImage(".input-image")
let session = await sessionInfo()
const dolar = await amountDolar()
//setear valores de las tarjetas de entradas
const cardEntrys = async () => {
    let entrysTotales = await searchParam({ active: 1 }, "Entrada_materia_prima_detalles")
    let entrysVigentes = entrysTotales.filter((element) => diasRestantesFechaVencimiento(element) > 10 && element.existencia > 0);
    let entrysPorVencer = entrysTotales.filter((element) => diasRestantesFechaVencimiento(element) <= 10 && diasRestantesFechaVencimiento(element) > 0 && element.existencia > 0);
    let entrysVencidos = entrysTotales.filter((element) => diasRestantesFechaVencimiento(element) <= 0);
    let entrysSinStock = entrysTotales.filter((element) => element.existencia <= 0);

    document.querySelector(".entry-totales").innerHTML = entrysTotales.length;
    document.querySelector(".entrys-vigentes").innerHTML = entrysVigentes.length;
    document.querySelector(".entrys-por-vencer").innerHTML = entrysPorVencer.length;
    document.querySelector(".entrys-vencidas").innerHTML = entrysVencidos.length;
    document.querySelector(".entrys-sin-stock").innerHTML = entrysSinStock.length;
}
cardEntrys()
function reindexEntrys(elementAll, id, counter, name) {
    const element = document.querySelectorAll(elementAll);
    counter = element.length;

    element.forEach((item, index) => {
        const newIndex = index + 1;
        item.id = `${id}-${newIndex}`;
        item.querySelectorAll("input").forEach((input) => {
            const parts = input.id.split("-");
            const baseId = parts.slice(0, parts.length - 1).join("-");
            const newId = `${baseId}-${newIndex}`;
            input.id = newId;
        });
        item.querySelectorAll("[id^='error-input']").forEach((errorDiv) => {
            const parts = errorDiv.id.split("-");
            const newId = `${parts[0]}-${parts[1]}-${parts[2]}-${parts[3]}-${newIndex}`;
            errorDiv.id = newId;
        });
        const header = item.querySelector("h4");
        if (header) {
            header.textContent = `${name} ${newIndex}`;
        }
    });
}
function reindexPayment(elementAll, id, counter, name) {
    const element = document.querySelectorAll(elementAll);
    counter = element.length;
    paymentCount = element.length
    element.forEach((item, index) => {
        const newIndex = index + 1;
        item.id = `${id}-${newIndex}`;
        item.querySelectorAll("input").forEach((input) => {
            const parts = input.id.split("-");
            const baseId = parts.slice(0, parts.length - 1).join("-");
            const newId = `${baseId}-${newIndex}`;
            input.id = newId;
        });
        item.querySelectorAll("[id^='error-input']").forEach((errorDiv) => {
            const parts = errorDiv.id.split("-");
            const baseId = parts.slice(0, parts.length - 1).join("-")
            const newId = `${baseId}-${newIndex}`;
            errorDiv.id = newId;
        });
        const header = item.querySelector("h4");
        if (header) {
            header.textContent = `${name} ${newIndex}`;
        }
    });
}
function reindexProduct(elementAll, id, counter, name) {
    const element = document.querySelectorAll(elementAll);
    counter = element.length;
    rawMaterialCount = element.length
    console.log(element);
    element.forEach((item, index) => {
        const newIndex = index + 1;
        item.id = `${id}-${newIndex}`;
        item.querySelectorAll("input").forEach((input) => {
            const parts = input.id.split("-");
            const baseId = parts.slice(0, parts.length - 1).join("-");
            const newId = `${baseId}-${newIndex}`;
            input.id = newId;
        });
        item.querySelectorAll("[id^='error-input']").forEach((errorDiv) => {
            const parts = errorDiv.id.split("-");
            const baseId = parts.slice(0, parts.length - 1).join("-")
            const newId = `${baseId}-${newIndex}`;
            errorDiv.id = newId;
        });
        const header = item.querySelector("h4");
        if (header) {
            header.textContent = `${name} ${newIndex}`;
        }
    });
}
function reindex(elementAll, id, counter, name) {
    const element = document.querySelectorAll(elementAll);
    counter = element.length;

    element.forEach((item, index) => {
        const newIndex = index + 1;
        item.id = `${id}-${newIndex}`;
        const header = item.querySelector("h4");
        if (header) {
            header.textContent = `${name} ${newIndex}`;
        }
    });
}
function resetFormEntrys(elements, form) {
    let supplier = document.querySelectorAll(elements);
    supplier.forEach((d) => {
        let id = d.id.split("-")[1];
        console.log(id);
        if (id > 1) d.remove();
        d.querySelectorAll('input:not(:is(.payment_entry_container *)), textarea:not(:is(.payment_entry_container *))').forEach((input) => {
            input.value = input.type === "button" ? "Seleccione una opcion" : "";
            if (input.tagName.toLowerCase() === "input") {
                if (input.type === "button") {
                    input.setAttribute("data-id", "Seleccione una opcion");
                }
            }
            input.classList.remove("is-valid", "is-invalid");
        });
        if (d.querySelectorAll("img")) {
            d.querySelectorAll("img").forEach((img) => {
                img.src = "";
                img.style.display = "none";
            });
        }
    });
    form.reset();
}
function resetFormPay(elements, form) {
    let supplier = document.querySelectorAll(elements);
    supplier.forEach((d) => {
        let id = parseInt(d.id.split("-")[2])
        if (id > 1) d.remove();
        d.querySelectorAll("input,textarea").forEach((input) => {
            input.value = input.type === "button" ? "Seleccione una opcion" : "";
            if (input.tagName.toLowerCase() === "input") {
                if (input.type === "button") {
                    input.setAttribute("data-id", "Seleccione una opcion");
                }
            }
            input.classList.remove("is-valid", "is-invalid");
        });
        if (d.querySelectorAll("img")) {
            d.querySelectorAll("img").forEach((img) => {
                img.src = "";
                img.style.display = "none";
            });
        }
    });
    form.reset();
}
async function reference() {
    let btn = document.querySelectorAll(".reference_btn");
    btn.forEach((element) => {
        if (!element.dataset.listenerAttached) {
            element.addEventListener("click", async () => {
                let id = element.getAttribute("data-id");
                let data = new FormData();
                data.append("id_entrada", id);
                let pet = await fetch(`Entry_rawmaterial_payment/get_all/0/100000`, {
                    method: "POST",
                    body: data,
                });
                let response = await pet.json();
                let template = ""
                response.forEach((element) => {
                    template += `
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="fw-bold text-uppercase">Comprobante</h5>
                                <img class="img-fluid" src="media/pay_entrys_materia_prima/${element.comprobante}" alt="Vista previa">
                                <h5 class="fw-bold text-uppercase mt-3">Metodo de pago</h5>
                                <p class="ms-2">${element.metodo_pago} <strong>${element.precio_compra} ${element.metodo_pago.toLowerCase() != "divisa" ? "Bs" : "Usd"}</strong></p>
                                <h5 class="fw-bold text-uppercase">Fecha</h5>
                                <p class="ms-2">${element.fecha}</p>
                            </div>
                        </div>
                    </div>
                    `
                })
                document.querySelector(".cont-details-payment-entry").innerHTML = template
                bootstrap.Modal.getOrCreateInstance('#comprobante_view').show()
            });
            element.dataset.listenerAttached = "true";
        }
    });
}

let tableActive = $(".table_entrys_active").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'Entrada_materia_prima_detalles/get_all/0/10000000/id/asc',
        dataSrc: function (json) {
            const EntrysActive = json.filter((element) => {
                let diasRestantes = diasRestantesFechaVencimiento(element)
                return diasRestantes > 10 && element.existencia > 0 && element.active == 1;
            });
            return EntrysActive;
        },
        type: 'POST',
    },
    columns: [
        { data: 'id_entrada' },
        { data: 'nombre_materia_prima' },
        { data: 'nombre_proveedor' },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_compra) } },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_vencimiento) } },
        { data: null, render: function (data, type, row, meta) { return data.cantidad + " " + data.nombre_unidad } },
        { data: null, render: function (data, type, row, meta) { return data.existencia + " " + data.nombre_unidad } },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <div class="dropdown dropstart">
                    <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                    <ul class="dropdown-menu" data-bs-boundary="viewport">
                        <li><a data-id="${data.id_entrada}" module-edit=Entrada_materia_prima_detalles data-module-edit="Entradas de materia prima" class="edit_btn_datatable dropdown-item" data-bs-title="Editar Entrada" data-bs-placement="bottom"><i class="me-1" data-feather="edit"></i>Editar</a></li>
                        <li><a data-id="${data.id}" module-delete=Entrada_materia_prima_detalles data-module-delete="Entradas de materia prima" class="trash_btn_datatable dropdown-item" data-bs-toggle="tooltip" data-bs-title="Eliminar Entrada" data-bs-placement="bottom"><i class="me-1" data-feather="trash"></i>Eliminar</a></li>
                        <li><a class="reference_btn dropdown-item" data-id="${data.id_entrada}" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#comprobante_view"><i class="me-1" data-feather="eye"></i>Ver datos de pago</a></li>
                    </ul>
                </div>
          `;
            }
        }
    ],
    drawCallback: function (settings) {
        feather.replace();
        reference();
        editEntrys();
        permission("Entradas de materia prima")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
let tablePorVencer = $(".table_entrys_por_vencer").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'Entrada_materia_prima_detalles/get_all/0/10000000/id/asc',
        dataSrc: function (json) {
            const EntryPorVencer = json.filter((element) => {
                let diasRestantes = diasRestantesFechaVencimiento(element)
                return diasRestantes <= 10 && diasRestantes >= 0 && element.existencia > 0;
            });
            return EntryPorVencer;
        },
        type: 'POST',
    },
    columns: [
        { data: 'codigo' },
        { data: 'nombre_materia_prima' },
        { data: 'nombre_proveedor' },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_compra) } },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_vencimiento) } },
        { data: null, render: function (data, type, row, meta) { return data.cantidad + " " + data.nombre_unidad } },
        { data: null, render: function (data, type, row, meta) { return data.existencia + " " + data.nombre_unidad } },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <div class="dropdown dropstart">
                    <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                    <ul class="dropdown-menu" data-bs-boundary="viewport">
                        <li><a class="reference_btn dropdown-item" data-id="${data.id}" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#comprobante_view"><i class="me-1" data-feather="eye"></i>Ver datos de pago</a></li>
                    </ul>
                </div>
          `;
            }
        }

    ],
    drawCallback: function (settings) {
        feather.replace();
        reference();
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
let tableVencidas = $(".table_entrys_vencidos").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'Entrada_materia_prima_detalles/get_all/0/10000000/id/asc',
        dataSrc: function (json) {
            const EntryVencidas = json.filter((element) => {
                let diasRestantes = diasRestantesFechaVencimiento(element)
                return diasRestantes <= 0;
            });
            return EntryVencidas;
        },
        type: 'POST',
    },
    columns: [
        { data: 'codigo' },
        { data: 'nombre_materia_prima' },
        { data: 'nombre_proveedor' },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_compra) } },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_vencimiento) } },
        { data: null, render: function (data, type, row, meta) { return data.cantidad + " " + data.nombre_unidad } },
        { data: null, render: function (data, type, row, meta) { return data.existencia + " " + data.nombre_unidad } },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <div class="dropdown dropstart">
                    <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                    <ul class="dropdown-menu" data-bs-boundary="viewport">
                        <li><a class="reference_btn dropdown-item" data-id="${data.id}" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#comprobante_view"><i class="me-1" data-feather="eye"></i>Ver datos de pago</a></li>
                    </ul>
                </div>
          `;
            }
        }
    ],
    drawCallback: function (settings) {
        feather.replace();
        reference();
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
let tableSinStock = $(".table_entrys_sin_stock").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    ajax: {
        url: 'Entrada_materia_prima_detalles/get_all/0/10000000/id/asc',
        dataSrc: function (json) {
            const EntrySinStock = json.filter((element) => {
                return element.existencia == 0;;
            });
            return EntrySinStock
        },
        type: 'POST',
    },
    columns: [
        { data: 'codigo' },
        { data: 'nombre_materia_prima' },
        { data: 'nombre_proveedor' },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_compra) } },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha_vencimiento) } },
        { data: null, render: function (data, type, row, meta) { return data.cantidad + " " + data.nombre_unidad } },
        { data: null, render: function (data, type, row, meta) { return data.existencia + " " + data.nombre_unidad } },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <div class="dropdown dropstart">
                    <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                    <ul class="dropdown-menu" data-bs-boundary="viewport">
                        <li><a class="reference_btn dropdown-item" data-id="${data.id}" style="cursor: pointer" data-bs-toggle="modal" data-bs-target="#comprobante_view"><i class="me-1" data-feather="eye"></i>Ver datos de pago</a></li>
                    </ul>
                </div>
          `;
            }
        }
    ],
    drawCallback: function (settings) {
        feather.replace();
        reference();
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$('#searchEntrysActive').on('keyup', function () { tableActive.search(this.value).draw() });
$('#searchEntrysPorVencer').on('keyup', function () { tablePorVencer.search(this.value).draw() });
$('#searchEntrysVencidos').on('keyup', function () { tableVencidas.search(this.value).draw() });
$('#searchEntrysSinStock').on('keyup', function () { tableSinStock.search(this.value).draw() });
deleteDatatable(".table_entrys_active", tableActive, () => nuevaBitacora("Entrada de Materia Prima", "Eliminacion", "Se ha eliminado una Entrada de Materia Prima"))

let entrysCount = 1;
let paymentCount = 1;
let rawMaterialCount = 1;
function addEntrys() {
    entrysCount++;
    paymentCount++;
    rawMaterialCount++;
    document.getElementById("entrys-container").insertAdjacentHTML('beforeend', elementFormEntrysRawMaterial(entrysCount, (counter) => {
        return elementFormPaymentEntrysRawMaterial(paymentCount);
    }, (counter) => {
        return elemenFormProductEntrysRawMaterial(rawMaterialCount);
    }));
    feather.replace();
    selectOptionAll(".select_options_supplier", "proveedor", optionsSupplier)
    selectOptionAll(".select_options_raw_material", "materia_prima", optionsRawMaterial)
    selectOptionAll(".select_options_payment", "metodo_pago", optionsRol)
    InputPrice("[input_price]")
    viewImage(".input-image")
    attachValidationListeners();
    const newEntry = document.getElementById(`entrys-${entrysCount}`);
    const payBtn = newEntry.querySelector(".add-pay-btn");
    const productBtn = newEntry.querySelector(".add-product-btn");
    const payRemove = newEntry.querySelector(".remove-payment-entrys");
    const productRemove = newEntry.querySelector(".remove-product-entrys");
    payBtn.addEventListener("click", () => {
        paymentCount++;
        newEntry.querySelector("#payment_entry_container").insertAdjacentHTML('beforeend', elementFormPaymentEntrysRawMaterial(paymentCount));
        feather.replace();
        InputPrice("[input_price]")
        viewImage(".input-image")
        selectOptionAll(".select_options_payment", "metodo_pago", optionsRol)
    });
    payRemove.addEventListener("click", () => {
        paymentCount--;
        payRemove.closest(".payment_entry").remove();
        reindexPayment("#payment_entry_container .payment_entry", "payment-entrys", paymentCount, "Pago");
    });
    newEntry.querySelector(".remove-entrys").addEventListener("click", function () {
        newEntry.remove();
        reindexEntrys(".entrys .select_options_supplier", "input-supplier-entrys", entrysCount, "Entrada");
        reindexPayment("#payment_entry_container .payment_entry", "payment-entrys", paymentCount, "Pago");
        reindexProduct("#details_entry_container .details_entry", "details_entry", rawMaterialCount, "Entrada");
        reindex("#entrys-container .entrys", "entrys", entrysCount, "Entrada");
    });
    productBtn.addEventListener("click", () => {
        rawMaterialCount++;
        newEntry.querySelector("#details_entry_container").insertAdjacentHTML('beforeend', elemenFormProductEntrysRawMaterial(rawMaterialCount));
        feather.replace();
        InputPrice("[input_price]")
        selectOptionAll(".select_options_raw_material", "materia_prima", optionsRawMaterial)
    });
    productRemove.addEventListener("click", () => {
        console.log("object");
        rawMaterialCount--;
        productRemove.closest(".details_entry").remove();
        reindexProduct("#details_entry_container .details_entry", "details_entry", rawMaterialCount, "Entrada");

    });
}
function addPayment() {
    document.querySelectorAll(".add-pay-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            let id = btn.closest(".entrys").id.split("-")[1]
            paymentCount++;
            document.querySelector(`#entrys-${id}`).querySelector("#payment_entry_container").insertAdjacentHTML('beforeend', elementFormPaymentEntrysRawMaterial(paymentCount));
            feather.replace();
            selectOptionAll(".select_options_payment", "metodo_pago", optionsRol)
            InputPrice("[input_price]")
            attachValidationListeners();
            viewImage(".input-image")
            let btn_remove = document.querySelectorAll(".remove-payment-entrys")
            btn_remove.forEach(btn => {
                btn.addEventListener("click", () => {
                    paymentCount--;
                    btn.closest(".payment_entry").remove();
                    reindexPayment("#payment_entry_container .payment_entry", "payment-entrys", paymentCount, "Pago");
                });
            })

        })
    })
}
function addProduct() {
    document.querySelectorAll(".add-product-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            let id = btn.closest(".entrys").id.split("-")[1]
            rawMaterialCount++;
            document.querySelector(`#entrys-${id}`).querySelector("#details_entry_container").insertAdjacentHTML('beforeend', elemenFormProductEntrysRawMaterial(rawMaterialCount));
            feather.replace();
            selectOptionAll(".select_options_raw_material", "materia_prima", optionsRawMaterial)
            InputPrice("[input_price]")
            attachValidationListeners();
            let btn_remove = document.querySelectorAll(".remove-product-entrys")
            btn_remove.forEach(btn => {
                btn.addEventListener("click", () => {
                    rawMaterialCount--;
                    btn.closest(".details_entry").remove();
                    reindexProduct("#details_entry_container .details_entry", "details_entry", rawMaterialCount, "Entrada");
                });
            })
        })
    })
}
addProduct();
addPayment();
function attachValidationListeners() {
    const row = document.querySelectorAll(`.entrys`);
    row.forEach(row => {
        row.querySelectorAll("input[type='text'], input[type='file'], input[type='date'], input[type='button']").forEach(input => {
            input.addEventListener("keyup", (e) => validateField(e, rules));
            input.addEventListener("blur", (e) => validateField(e, rules));
            input.addEventListener("change", (e) => validateField(e, rules));
        })
    })
    const rowedit = document.querySelectorAll(`.entry`);
    rowedit.forEach(row => {
        row.querySelectorAll("input[type='text'], input[type='date'], input[type='button']").forEach(input => {
            input.addEventListener("keyup", (e) => validateField(e, rules));
            input.addEventListener("blur", (e) => validateField(e, rules));
            input.addEventListener("change", (e) => validateField(e, rules));
        })
    })
}
document.getElementById("add-entrys-btn").addEventListener("click", () => {
    addEntrys();
    reindexPayment("#payment_entry_container .payment_entry", "payment-entrys", paymentCount, "Pago");
    reindexEntrys(".entrys .select_options_supplier", "input-supplier-entrys", entrysCount, "Entrada");
    reindexProduct("#details_entry_container .details_entry", "details_entry", rawMaterialCount, "Entrada");
    reindex("#entrys-container .entrys", "entrys", entrysCount, "Entrada");

});
validate.extend(validate.validators.datetime, {
    parse: function (value) {
        return Date.parse(value) || NaN;
    },
    format: function (value, options) {
        return new Date(value).toISOString().split("T")[0]; // Formato YYYY-MM-DD
    }
});
// Los validators ya están definidos en Validaciones.js
// Nota: validate.extend(validate.validators.datetime) se mantiene aquí
const rules = {
    precio: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    codigo: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_materia_prima: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    id_proveedor: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    imagen: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        fileType: {
            types: ['jpeg', 'png', 'webp', 'jpg']
        }
    },
    cantidad: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    fecha_vencimiento: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        datetime: {
            dateOnly: true,
            earliest: new Date(),
            message: "^Debe ser una fecha válida"
        }
    },
    referencia: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_metodo_pago: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
};
const rules_payment = {
    precio: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    referencia: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_metodo_pago: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    imagen: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        fileType: {
            types: ['jpeg', 'png', 'webp', 'jpg']
        }
    },
};
const rules_details = {
    codigo: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_materia_prima: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    id_proveedor: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    cantidad: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    fecha_vencimiento: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        datetime: {
            dateOnly: true,
            earliest: new Date(),
            message: "^Debe ser una fecha válida"
        }
    },
};
const rules_details_edit = {
    codigo: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_materia_prima: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    cantidad: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    fecha_vencimiento: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        datetime: {
            dateOnly: true,
            earliest: new Date(),
            message: "^Debe ser una fecha válida"
        }
    },
}
const rules_payment_edit = {
    precio: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    referencia: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_metodo_pago: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
};
const rules_payment_edit2 = {
    precio: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    referencia: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
    },
    id_metodo_pago: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateCategoryAndRecipe: { message: "^es requerido" }
    },
    imagen: {
        fileType: {
            types: ['jpeg', 'png', 'webp', 'jpg']
        }
    },
};
let form = document.getElementById("form-submit-entrys")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", function (e) {
        e.preventDefault();

        const entryDetails = document.querySelectorAll(".entrys");
        const PayDetails = document.querySelectorAll(".payment_entry");
        let formHasErrorDetails = false;
        let formHasErrorPayment = false;

        entryDetails.forEach((entry, i) => {
            const index = i + 1;
            const data = {
                codigo: entry.querySelector(`input[name="codigo"]`).value,
                id_materia_prima: entry.querySelector(`input[name="id_materia_prima"]`).getAttribute("data-id"),
                id_proveedor: entry.querySelector(`input[name="id_proveedor"]`).getAttribute("data-id"),
                cantidad: entry.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                fecha_vencimiento: entry.querySelector(`input[name="fecha_vencimiento"]`).value,
            };
            const errors = validate(data, rules_details);
            setValidationStyles(`input-code-entrys-${index}`, errors?.codigo ? errors.codigo[0] : null);
            setValidationStyles(`input-rawmaterial-entrys-${index}`, errors?.id_materia_prima ? errors.id_materia_prima[0] : null);
            setValidationStyles(`input-supplier-entrys-${index}`, errors?.id_proveedor ? errors.id_proveedor[0] : null);
            setValidationStyles(`input-quantity-entrys-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
            setValidationStyles(`input-date-entrys-${index}`, errors?.fecha_vencimiento ? errors.fecha_vencimiento[0] : null);
            if (errors) {
                formHasErrorDetails = true;
            }
        });
        PayDetails.forEach((pay, i) => {
            const index = i + 1;
            const data = {
                precio: pay.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'),
                id_metodo_pago: pay.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                imagen: pay.querySelector(`input[name="imagen"]`) ? pay.querySelector(`input[name="imagen"]`).files[0] : "",
                referencia: pay.querySelector(`input[name="referencia"]`).value,
            };
            const errors = validate(data, rules_payment);
            setValidationStyles(`input-price-entrys-${index}`, errors?.precio ? errors.precio[0] : null);
            setValidationStyles(`input-mp-entrys-${index}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
            setValidationStyles(`input-image-entrys-${index}`, errors?.imagen ? errors.imagen[0] : null);
            setValidationStyles(`input-ref-entrys-${index}`, errors?.referencia ? errors.referencia[0] : null);
            if (errors) {
                formHasErrorPayment = true;
            }
        });

        if (!formHasErrorDetails && !formHasErrorPayment) {
            bootstrap.Modal.getOrCreateInstance('#register-entrys').hide()
            Swal.fire({
                title: 'Procesando...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading() }
            });
            let data = new FormData()
            let entrys = document.querySelectorAll(".entrys");
            entrys.forEach((entry, i) => {
                entry.querySelectorAll(".details_entry").forEach((detail, index) => {
                    data.append(`lista[info_entrada][${i}][id_proveedor]`, entry.querySelector(`input[name="id_proveedor"]`).getAttribute("data-id"));
                    data.append(`lista[info_entrada][${i}][detalles_entrada][${index}][codigo]`, detail.querySelector(`input[name="codigo"]`).value);
                    data.append(`lista[info_entrada][${i}][detalles_entrada][${index}][id_materia_prima]`, detail.querySelector(`input[name="id_materia_prima"]`).getAttribute("data-id"));
                    data.append(`lista[info_entrada][${i}][detalles_entrada][${index}][cantidad]`, detail.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'));
                    data.append(`lista[info_entrada][${i}][detalles_entrada][${index}][existencia]`, detail.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'));
                    data.append(`lista[info_entrada][${i}][detalles_entrada][${index}][fecha_vencimiento]`, detail.querySelector(`input[name="fecha_vencimiento"]`).value);
                })
                entry.querySelectorAll(".payment_entry").forEach((pay, j) => {
                    data.append(`lista[info_entrada][${i}][payment][${j}][precio_compra]`, pay.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'));
                    data.append(`lista[info_entrada][${i}][payment][${j}][id_metodo_pago]`, pay.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"));
                    data.append(`lista[info_entrada][${i}][payment][${j}][imagen]`, pay.querySelector(`input[name="imagen"]`) ? pay.querySelector(`input[name="imagen"]`).files[0] : "");
                    data.append(`lista[info_entrada][${i}][payment][${j}][imagen_name]`, pay.querySelector(`input[name="imagen"]`) ? pay.querySelector(`input[name="imagen"]`).files[0].name : "");
                    data.append(`lista[info_entrada][${i}][payment][${j}][referencia]`, pay.querySelector(`input[name="referencia"]`).value);
                    data.append(`lista[info_entrada][${i}][payment][${j}][tasa]`, dolar);
                })
            })
            let send = async () => {
                let pet = await fetch(`Entrada_materia_prima/add_many`, { method: "POST", body: data, })
                let response = await pet.json()
                console.log(response);
                if (response.success == true) {
                    Swal.close()
                    Swal.fire({
                        title: `Exito!`,
                        text: "El elemento fue agregado correctamente",
                        icon: "success",
                    });
                    tableActive.ajax.reload();
                    tablePorVencer.ajax.reload();
                    tableVencidas.ajax.reload();
                    tableSinStock.ajax.reload();
                    cardEntrys()
                    nuevaBitacora("Entradas", "Agregado", "Se agrego una entrada de materia prima")
                    tableRawMaterial.ajax.reload();
                } else {
                    Swal.fire({
                        title: `Error!`,
                        text: "El elemento no fue agregado",
                        icon: "error",
                    });
                }
                resetFormEntrys("#entrys-container .entrys", form)
                resetFormPay("#payment_entry_container .payment_entry", form)
                paymentCount = 1
                rawMaterialCount = 1
            }
            send()
        }
    });
    form.dataset.listenerAttached = "true";
}
const editEntrys = () => {
    const btn = document.querySelectorAll(".edit_btn_datatable");
    btn.forEach((element) => {
        element.addEventListener("click", async () => {
            let indexPayment = 1
            let indexProduct = 1

            let id = element.getAttribute("data-id");
            const data = new FormData();
            data.append("id_entrada", id);
            const pet = await fetch('entrada_materia_prima_detalles/get_all/0/1000', { method: "POST", body: data });
            const response = await pet.json();

            document.getElementById("input-supplier-entryEdit").value = response[0].nombre_proveedor;
            document.getElementById("input-supplier-entryEdit").setAttribute("data-id", response[0].id_proveedor);
            document.querySelector("#input-id-entry-edit").value = response[0].id_entrada;
            let templateItemsProduct = ""
            response.forEach((element, i) => {
                templateItemsProduct += elemenFormProductEntrysRawMaterialEdit(indexProduct, element)
                indexProduct++
            })
            let dataPayment = new FormData();
            dataPayment.append("id_entrada", response[0].id_entrada);
            let petPayment = await fetch(`Entry_rawmaterial_payment/get_all/0/100000`, { method: "POST", body: data });
            let petRes = await petPayment.json();
            let templatePayment = ""
            for (const element of petRes) {
                templatePayment += elementFormPaymentEntrysRawMaterialEdit(indexPayment, element)
                indexPayment++
            }
            document.getElementById("detail_entry_container_edit").innerHTML = templateItemsProduct
            document.querySelector("#payment_entry_container_edit").innerHTML = templatePayment;
            feather.replace()
            selectOptionAll(".select_options_supplier_edit", "proveedor", optionsSupplier)
            selectOptionAll(".select_options_raw_material_edit", "materia_prima", optionsRawMaterial)
            selectOptionAll(".select_options_payment_edit", "metodo_pago", optionsRol)
            InputPrice("[input_price]")
            viewImage(".input-image")
            attachValidationListeners()

            const removePayEdit = () => {
                document.querySelectorAll(".remove-payment-entry-old").forEach((payRemove, i) => {
                    payRemove.addEventListener("click", () => {
                        Swal.fire({
                            title: "¿Deseas eliminar este elemento?",
                            text: "No podras revertir esta accion",
                            icon: "warning",
                            showCancelButton: true,
                            confirmButtonText: "Eliminar",
                            cancelButtonText: "Cancelar",
                            confirmButtonColor: "#FF4B00",
                        }).then(async (result) => {
                            if (result.isConfirmed) {
                                const id = payRemove.id
                                let data = new FormData();
                                data.append("id", id);
                                let pet = await fetch("Entry_rawmaterial_payment/delete", { method: "POST", body: data });
                                let petRes = await pet.json();
                                if (petRes.success == true) {
                                    payRemove.closest(".payment_entry_edit").remove()
                                    indexPayment--
                                    reindexPayment("#payment_entry_container_edit .payment_entry_edit", index, "pago")
                                } else {
                                    Swal.fire({
                                        title: `Error!`,
                                        text: "El elemento no fue eliminado",
                                        icon: "error",
                                    });
                                }
                            }
                        });
                    });
                })
            }
            const removeProductEditOld = () => {
                document.querySelectorAll(".remove-product-entrys-edit-old").forEach((productRemove, i) => {
                    productRemove.addEventListener("click", () => {
                        console.log("object");
                        //             // Swal.fire({
                        //             //     title: "¿Deseas eliminar este elemento?",
                        //             //     text: "No podras revertir esta accion",
                        //             //     icon: "warning",
                        //             //     showCancelButton: true,
                        //             //     confirmButtonText: "Eliminar",
                        //             //     cancelButtonText: "Cancelar",
                        //             //     confirmButtonColor: "#FF4B00",
                        //             // }).then(async (result) => {
                        //             //     if (result.isConfirmed) {
                        //             //         const id = productRemove.id
                        //             //         let data = new FormData();
                        //             //         data.append("id", id);
                        //             //         let pet = await fetch("Entrada_materia_prima_detalles/delete", { method: "POST", body: data });
                        //             //         let petRes = await pet.json();
                        //             //         if (petRes.success == true) {
                        productRemove.closest(".detail_entry-edit").remove()
                        indexProduct--
                        reindexProduct("#detail_entry_container_edit .detail_entry-edit", "detail_entry-edit", indexProduct, "Entrada");
                        //                 //     } else {
                        //                 //         Swal.fire({
                        //                 //             title: `Error!`,
                        //                 //             text: "El elemento no fue eliminado",
                        //                 //             icon: "error",
                        //                 //         });
                        //                 //     }
                        //                 // }
                        //             // });
                    });
                })
            }
            const removeProductEditNew = () => {
                document.querySelectorAll(".remove-product-entrys-edit-new").forEach((productRemove, i) => {
                    productRemove.addEventListener("click", () => {
                        productRemove.closest(".detail_entry-edit").remove()
                        indexProduct--
                        reindexProduct("#detail_entry_container_edit .detail_entry-edit", "detail_entry-edit", indexProduct, "Entrada");
                    });
                })
            }
            const addProductBtnEdit = document.querySelector(".add-product-btn-edit");
            if (!addProductBtnEdit.dataset.listenerAttached) {
                addProductBtnEdit.addEventListener("click", () => {
                    indexProduct++
                    document.getElementById("detail_entry_container_edit").innerHTML += elemenFormProductEntrysRawMaterialNew(indexProduct)
                    reindexProduct("#detail_entry_container_edit .detail_entry-edit", "detail_entry-edit", indexProduct, "Entrada");
                    feather.replace()
                    InputPrice("[input_price]")
                    selectOptionAll(".select_options_raw_material_edit", "materia_prima", optionsRawMaterial)
                    removeProductEditNew()
                    removeProductEditOld()
                    attachValidationListeners()
                });
                addProductBtnEdit.dataset.listenerAttached = "true";
            }
            const addPaymentBtnEdit = document.querySelector(".add-pay-btn-edit");
            if (!addPaymentBtnEdit.dataset.listenerAttached) {
                addPaymentBtnEdit.addEventListener("click", () => {
                    indexPayment = document.querySelectorAll("#payment_entry_container_edit .payment_entry_edit").length + 1;
                    document.querySelector("#payment_entry_container_edit").insertAdjacentHTML('beforeend', elementFormPaymentEntrysRawMaterialEditNew(indexPayment));
                    feather.replace();
                    attachValidationListeners();
                    selectOptionAll(".select_options_payment_edit", "metodo_pago", optionsRol);
                    InputPrice("[input_price]");
                    viewImage(".input-image");
                    document.querySelectorAll(".remove-payment-entry").forEach(payRemove => {
                        payRemove.addEventListener("click", () => {
                            payRemove.closest(".payment_entry_edit").remove()
                            indexPayment--
                            reindexPayment("#payment_entry_container_edit .payment_entry_edit", indexPayment, "pago")
                        })
                    })
                });
                addPaymentBtnEdit.dataset.listenerAttached = "true";
            }
            const validateItems = () => {
                let hasError = false
                let supplier = document.getElementById("input-supplier-entryEdit").getAttribute("data-id")
                const errorSupplier = validate({ id_proveedor: supplier }, rules_details);
                if (errorSupplier) hasError = true
                else hasError = false
                setValidationStyles("input-supplier-entryEdit", errorSupplier?.id_proveedor ? errorSupplier.id_proveedor[0] : null);
                document.querySelectorAll(".detail_entry-edit").forEach((detail, i) => {
                    let index = i + 1
                    const data = {
                        codigo: detail.querySelector(`input[name="codigo"]`).value,
                        id_materia_prima: detail.querySelector(`input[name="id_materia_prima"]`).getAttribute("data-id") ? detail.querySelector(`input[name="id_materia_prima"]`).getAttribute("data-id") : "",
                        cantidad: detail.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                        fecha_vencimiento: detail.querySelector(`input[name="fecha_vencimiento"]`).value,
                    }
                    const errors = validate(data, rules_details_edit);
                    if (errors) hasError = true
                    else hasError = false
                    setValidationStyles(`input-code-entryEdit-${index}`, errors?.codigo ? errors.codigo[0] : null);
                    setValidationStyles(`input-quantity-entryEdit-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
                    setValidationStyles(`input-date-entryEdit-${index}`, errors?.fecha_vencimiento ? errors.fecha_vencimiento[0] : null);
                    setValidationStyles(`input-rawmaterial-entryEdit-${index}`, errors?.id_materia_prima ? errors.id_materia_prima[0] : null);
                })
                document.querySelectorAll(".payment_entry_edit").forEach((pay, i) => {
                    let inD = i + 1
                    const data = {
                        precio: pay.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'),
                        id_metodo_pago: pay.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                        imagen: pay.querySelector(`input[name="imagen"]`) ? pay.querySelector(`input[name="imagen"]`).files[0] : "",
                        referencia: pay.querySelector(`input[name="referencia"]`).value,
                    };
                    const errors = validate(data, rules_payment);
                    if (errors) hasError = true
                    else hasError = false
                    setValidationStyles(`input-price-entry-${inD}`, errors?.precio ? errors.precio[0] : null);
                    setValidationStyles(`input-mp-entry-${inD}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
                    // setValidationStyles(`input-image-entry-${inD}`, errors?.imagen ? errors.imagen[0] : null);
                    setValidationStyles(`input-ref-entry-${inD}`, errors?.referencia ? errors.referencia[0] : null);
                })
                return hasError
            }
            removePayEdit()
            removeProductEditOld()
            validateItems()

            bootstrap.Modal.getOrCreateInstance('#edit-entrys').show()
        })
    })
}
const formEdit = document.querySelector("#form-submit-edit-entry")
if (!formEdit.dataset.listenerAttached) {
    formEdit.addEventListener("submit", async (e) => {
        e.preventDefault()

        let hasErrorDetails = false
        let hasErrorPayments = false
        let dataPaymentsUpdate = []
        let dataPaymentsInsert = []
        let dataEntrysUpdate = []
        let dataEntrysInsert = []
        document.querySelectorAll(".detail_entry-edit").forEach((detail, i) => {
            let index = i + 1
            const data = {
                codigo: detail.querySelector(`input[name="codigo"]`).value,
                id_materia_prima: detail.querySelector(`input[name="id_materia_prima"]`).getAttribute("data-id") ? detail.querySelector(`input[name="id_materia_prima"]`).getAttribute("data-id") : "",
                cantidad: detail.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                fecha_vencimiento: detail.querySelector(`input[name="fecha_vencimiento"]`).value,
            }
            const errors = validate(data, rules_details_edit);
            setValidationStyles(`input-code-entryEdit-${index}`, errors?.codigo ? errors.codigo[0] : null);
            setValidationStyles(`input-quantity-entryEdit-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
            setValidationStyles(`input-date-entryEdit-${index}`, errors?.fecha_vencimiento ? errors.fecha_vencimiento[0] : null);
            setValidationStyles(`input-rawmaterial-entryEdit-${index}`, errors?.id_materia_prima ? errors.id_materia_prima[0] : null);
            if (errors) {
                hasErrorDetails = true
            } else {
                hasErrorDetails = false
                detail.getAttribute("isNew") == "true" ? dataEntrysInsert.push(data) : dataEntrysUpdate.push({ ...data, id: detail.querySelector(`input[type="hidden"]`).value })
            }
        })
        document.querySelectorAll(".payment_entry_edit").forEach((detail, i) => {
            let ind = i + 1
            const img = detail.querySelector(`input[name="imagen"]`).parentElement.nextElementSibling.getAttribute("isImage")
            let data
            if (img == "true") {
                data = {
                    precio: detail.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'),
                    id_metodo_pago: detail.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                    referencia: detail.querySelector(`input[name="referencia"]`).value,
                    imagen: detail.querySelector(`input[name="imagen"]`).files[0],
                };
                const errors = validate(data, rules_payment_edit2);
                setValidationStyles(`input-price-entry-${ind}`, errors?.precio ? errors.precio[0] : null);
                setValidationStyles(`input-mp-entry-${ind}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
                setValidationStyles(`input-ref-entry-${ind}`, errors?.referencia ? errors.referencia[0] : null);
                setValidationStyles(`input-image-entry-${ind}`, errors?.imagen ? errors.imagen[0] : null);
                if (errors) {
                    hasErrorPayments = true
                } else {
                    hasErrorPayments = false
                    if (detail.querySelector(`input[name="imagen"]`).value == "") {
                        dataPaymentsUpdate.push({ ...data, id: detail.getAttribute("id-payment") })
                    } else {
                        dataPaymentsUpdate.push({
                            ...data,
                            id: detail.getAttribute("id-payment"),
                            imagen: detail.querySelector(`input[name="imagen"]`).files[0]
                        })
                    }
                }
            } else {
                data = {
                    precio: detail.querySelector(`input[name="precio"]`).value.replace(/\./g, '').replace(',', '.'),
                    id_metodo_pago: detail.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                    referencia: detail.querySelector(`input[name="referencia"]`).value,
                    imagen: detail.querySelector(`input[name="imagen"]`) ? detail.querySelector(`input[name="imagen"]`).files[0] : "",
                };
                const errors = validate(data, rules_payment);
                setValidationStyles(`input-price-entry-${ind}`, errors?.precio ? errors.precio[0] : null);
                setValidationStyles(`input-mp-entry-${ind}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
                setValidationStyles(`input-ref-entry-${ind}`, errors?.referencia ? errors.referencia[0] : null);
                setValidationStyles(`input-image-entry-${ind}`, errors?.imagen ? errors.imagen[0] : null);

                if (errors) {
                    hasErrorPayments = true
                } else {
                    hasErrorPayments = false
                    dataPaymentsInsert.push(data)
                }
            }
        })

        if (!hasErrorDetails && !hasErrorPayments) {
            Swal.fire({
                title: 'Procesando...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading() }
            });
            let EntryUpdate = new FormData()
            let dataSupplier = new FormData()
            let dataPayUpdate = new FormData()
            dataSupplier.append("id_proveedor", document.querySelector("#input-supplier-entryEdit").getAttribute("data-id"))
            dataSupplier.append("id", document.querySelector("#input-id-entry-edit").value)
            dataEntrysUpdate.forEach((element, index) => {
                EntryUpdate.append(`lista[${index}][id]`, element.id)
                EntryUpdate.append(`lista[${index}][codigo]`, element.codigo)
                EntryUpdate.append(`lista[${index}][cantidad]`, element.cantidad)
                EntryUpdate.append(`lista[${index}][fecha_vencimiento]`, element.fecha_vencimiento)
                EntryUpdate.append(`lista[${index}][id_materia_prima]`, element.id_materia_prima)
            })
            dataPaymentsUpdate.forEach((element, index) => {
                dataPayUpdate.append(`lista[${index}][id]`, element.id)
                dataPayUpdate.append(`lista[${index}][precio_compra]`, element.precio)
                dataPayUpdate.append(`lista[${index}][id_metodo_pago]`, element.id_metodo_pago)
                dataPayUpdate.append(`lista[${index}][referencia]`, element.referencia)
                if (element.imagen) {
                    dataPayUpdate.append(`lista[${index}][imagen]`, element.imagen)
                    dataPayUpdate.append(`lista[${index}][imagen_name]`, element.imagen.name)
                }
            })
            if (dataEntrysInsert.length != 0) {
                let EntryInsert = new FormData()
                dataEntrysInsert.forEach((element, index) => {
                    EntryInsert.append(`lista[${index}][codigo]`, element.codigo)
                    EntryInsert.append(`lista[${index}][cantidad]`, element.cantidad)
                    EntryInsert.append(`lista[${index}][fecha_vencimiento]`, element.fecha_vencimiento)
                    EntryInsert.append(`lista[${index}][id_materia_prima]`, element.id_materia_prima)
                })
                let updateEntry = await fetch("Entrada_materia_prima_detalles/add_many", { method: "POST", body: EntryInsert })
                let responseEntry = await updateEntry.json()
                console.log(responseEntry);
            }
            if (dataPaymentsInsert.length != 0) {
                let dataPayInsert = new FormData()
                dataPayInsert.forEach((element, index) => {
                    dataPayInsert.append(`lista[${index}][id_metodo_pago]`, element.id_metodo_pago)
                    dataPayInsert.append(`lista[${index}][precio_compra]`, element.precio)
                    dataPayInsert.append(`lista[${index}][referencia]`, element.referencia)
                    dataPayInsert.append(`lista[${index}][imagen]`, element.imagen)
                    dataPayInsert.append(`lista[${index}][imagen_name]`, element.imagen.name)
                })
                let insertPayment = await fetch("Entry_rawmaterial_payment/add_many", { method: "POST", body: dataPayInsert })
                let responseInsertPayment = await insertPayment.json()
                console.log(responseInsertPayment);
            }
            let updateEntry = await fetch("Entrada_materia_prima_detalles/updateMany", { method: "POST", body: EntryUpdate })
            let responseEntry = await updateEntry.json()
            let updatePayment = await fetch("Entry_rawmaterial_payment/updateMany", { method: "POST", body: dataPayUpdate })
            let responsePayment = await updatePayment.json()
            console.log(responsePayment);
            let updateEntrySupplier = await fetch("Entrada_materia_prima_detalles/update", { method: "POST", body: dataSupplier })
            let responseEntrySupplier = await updateEntrySupplier.json()
            console.log(responseEntrySupplier);

            if (responseEntry.success == true && responsePayment.success == true && responseEntrySupplier.success == true) {
                Swal.close()
                Swal.fire({
                    title: `Exito!`,
                    text: "El elemento fue actualizado correctamente",
                    icon: "success",
                });
                tableActive.ajax.reload();
                tablePorVencer.ajax.reload();
                tableVencidas.ajax.reload();
                tableSinStock.ajax.reload();
                cardEntrys()
                nuevaBitacora("Entradas", "Actualizado", "Se actualizo una entrada de materia prima")
                tableRawMaterial.ajax.reload();
                tableActive.ajax.reload();
                bootstrap.Modal.getOrCreateInstance('#edit-entrys').hide()

            } else {
                Swal.fire({
                    title: `Error!`,
                    text: "El elemento no fue actualizado",
                    icon: "error",
                });

            }
        }
    })
    formEdit.dataset.listenerAttached = "true"
}
editEntrys()
attachValidationListeners()