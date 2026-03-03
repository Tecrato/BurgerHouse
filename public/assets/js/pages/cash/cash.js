import funtionGeneral from "../../Functions.js";
import { myfecth,nuevaBitacora } from "../../Functions2.js"
import Templates from "../../templates.js";
import { report } from "./report.js"
import introTooltip from "../../intro-tooltip.js"
const { cashIntro } = introTooltip()
const { targetCash, infoCash, amountCash, cashDetail } = Templates()
const { validateField, setValidationStyles, sessionInfo, binnacle, print, add, searchParam, InputPrice, CheckCash, searchFilter, permission } = funtionGeneral()
InputPrice("[input_price]")
cashIntro('navbarDropdown')
let session = await sessionInfo()
let cash = await CheckCash()
permission("caja")
searchFilter('#searchCashClose', async (e) => {
    if (e.target.value == "") {
        print({ ...config, search: () => searchParam({ estado: 0 }, "caja"), container: ".cont-cash_close" })
    } else {
        let user = await searchParam({ active: 1, nombre_like: e.target.value }, "users")
        if (user.length != 0) {
            user.forEach((user) => {
                print({ ...config, search: () => searchParam({ id_usuario: user.id, estado: 0 }, "caja"), container: ".cont-cash_close" })
            })
        } else {
            print({ ...config, search: () => searchParam({ estado: 25 }, "caja"), container: ".cont-cash_close" })
        }
    }
})
searchFilter('#searchCashOpen', async (e) => {
    if (e.target.value == "") {
        print(config)
    } else {
        let user = await searchParam({ active: 1, nombre_like: e.target.value }, "users")
        if (user.length != 0) {
            user.forEach((user) => {
                print({ ...config, search: () => searchParam({ id_usuario: user.id, estado: 1 }, "caja") })
            })
        } else {
            print({ ...config, search: () => searchParam({ estado: 25 }, "caja") })
        }
    }
})
const config = {
    search: () => searchParam({ estado: "1" }, "caja",12),
    template: targetCash,
    container: ".cont-cash_open",
    funtions: () => {
        document.querySelectorAll(".edit_btn, .trash_btn").forEach((element) => { let tooltip = new bootstrap.Tooltip(element) });
        modalDetail()
        closeCash()
        permission("caja")
    },
}
let form = document.getElementById("form-submit-cash")
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
const rules = {
    precio_bs: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
    precio_usd: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        precio: { message: "^debe ser un número mayor a 0" }
    },
};
print(config)
print({ ...config, search: () => searchParam({ estado: 0 }, "caja"), container: ".cont-cash_close" })
form.querySelectorAll("input").forEach((input) => {
    input.addEventListener("keyup", (e) => validateField(e, rules));
    input.addEventListener("blur", (e) => validateField(e, rules));
    input.addEventListener("change", (e) => validateField(e, rules));
});

form.addEventListener("submit", (e) => {
    e.preventDefault();
    let data = { precio_bs: document.getElementById("input-price-bs-cash").value, precio_usd: document.getElementById("input-price-usd-cash").value }
    const error = validate(data, rules);
    setValidationStyles("input-price-bs-cash", error?.precio_bs ? error.precio_bs[0] : null);
    setValidationStyles("input-price-usd-cash", error?.precio_usd ? error.precio_usd[0] : null);

    if (!error) {
        let data = new FormData()
        data.append("lista[0][monto_inicial_dolar]", document.getElementById("input-price-usd-cash").value.replace(/\./g, '').replace(',', '.'))
        data.append("lista[0][monto_inicial_bs]", document.getElementById("input-price-bs-cash").value.replace(/\./g, '').replace(',', '.'))
        data.append("lista[0][id_usuario]", session.message.id)
        add(config,
            'caja',
            data,
            () => {
                nuevaBitacora('Caja', 'Agregar', 'Se abrio una caja')
                document.querySelector(".cash_status").classList.add("bg-success")
                document.querySelector(".cash_status").classList.remove("bg-danger")
                const tooltip = bootstrap.Tooltip.getInstance(document.querySelector(".cash_status"));
                if (tooltip) {
                    tooltip._config.title = "Estado de caja: Abierta";
                    tooltip.update();
                }
            }
        )
        form.reset()
        document.getElementById("input-price-usd-cash").classList.remove("is-valid", "is-invalid")
        document.getElementById("input-price-bs-cash").classList.remove("is-valid", "is-invalid")
        bootstrap.Modal.getOrCreateInstance('#register-cash').hide()
    }
})
//modal de detalles
const modalDetail = () => {
    let btn = document.querySelectorAll(".datails_cash")
    btn.forEach((btn) => {
        if (!btn.dataset.listenerAttached) {
            btn.addEventListener("click", async (e) => {
                let info = await searchParam({ id: btn.getAttribute("data-id") }, "caja")
                document.querySelector(".infoCash").innerHTML = await infoCash(info[0])
                feather.replace()
                new bootstrap.Tooltip(document.querySelector(".btn_print"))
                let id = btn.getAttribute("data-id")
                let data = new FormData();
                data.append("id", id);
                let pet = await fetch(`caja/detailCash`, { method: "POST", body: data })
                let response = await pet.json()
                let group = {}
                let detailsCash = {}
                response.forEach((item) => {
                    if (group[item.metodo_pago]) group[item.metodo_pago].push(item)
                    else group[item.metodo_pago] = [item]
                    if (item.cliente != null) {
                        if (detailsCash[item.metodo_pago]) detailsCash[item.metodo_pago].push(item)
                        else detailsCash[item.metodo_pago] = [item]
                    }
                })
                Object.keys(group).forEach((key) => {
                    let monto_dolar = group[key].reduce((acc, item) => acc + item.monto, 0)
                    let tasaPlus = group[key].reduce((acc, item) => item.tasa > acc ? acc = item.tasa : acc, 0)
                    let monto_bs = monto_dolar
                    group[key].forEach((item) => {
                        if (item.metodo_pago.toLowerCase() == "transferencia" || item.metodo_pago.toLowerCase() == "pago movil") {
                            group[key] = {
                                "metodo_pago": item.metodo_pago,
                                "monto": monto_bs
                            }
                        } else {
                            group[key] = {
                                "metodo_pago": item.metodo_pago,
                                "monto": monto_dolar
                            }
                        }
                    })
                })
                group = Object.values(group)
                let template = ""
                let total_bs = []
                let total_dolar = []
                group.forEach((item) => {
                    template += amountCash(item)
                    if (item.metodo_pago.toLowerCase() == "transferencia" || item.metodo_pago.toLowerCase() == "pago movil") total_bs.push(item.monto)
                    else total_dolar.push(item.monto)
                })
                document.querySelector(".amountCash").innerHTML = template
                document.querySelector(".total_bs_cash").textContent = "Bs " + (total_bs.reduce((acc, item) => acc + item, 0) + info[0].monto_inicial_bs).toFixed(2)
                document.querySelector(".total_usd_cash").textContent = "$ " + (total_dolar.reduce((acc, item) => acc + item, 0) + info[0].monto_inicial_dolar).toFixed(2)
                let templateDetails = ""
                Object.keys(detailsCash).forEach((key) => {
                    templateDetails += cashDetail(key, detailsCash[key])
                })
                document.querySelector(".detailsCash").innerHTML = templateDetails
                report(group, detailsCash, total_bs, total_dolar)
                bootstrap.Modal.getOrCreateInstance('#details-cash').show()
            })
            btn.dataset.listenerAttached = "true"
        }
    })
}
const closeCash = () => {
    document.querySelectorAll(".close_cash").forEach((btn) => {
        btn.addEventListener("click", async (e) => {
            swal.fire({
                title: 'Cerrar caja',
                text: "¿Desea cerrar la caja?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: "#FF4B00",
                confirmButtonText: 'Si, cerrar',
                cancelButtonText: 'Cancelar'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    let id = btn.getAttribute("data-id")
                    let data = new FormData();
                    data.append("id", id);
                    let pet = await fetch(`caja/closeCash`, { method: "POST", body: data })
                    let response = await pet.json()
                    console.log(response);
                    if (response.success) {
                        swal.fire({
                            icon: 'success',
                            title: 'Exito',
                            text: "Se ha cerrado la caja correctamente",
                        })
                        nuevaBitacora('Caja', 'Cerrar', `Se cerro la caja ${id}`)
                        document.querySelector(".cash_status").classList.add("bg-danger")
                        document.querySelector(".cash_status").classList.remove("bg-success")
                        const tooltip = bootstrap.Tooltip.getInstance(document.querySelector(".cash_status"));
                        if (tooltip) {
                            tooltip._config.title = "Estado de caja: Cerrada";
                            tooltip.update();
                        }
                        print(config)
                        print({ ...config, search: () => searchParam({ estado: 0 }, "caja"), container: ".cont-cash_close" })
                    } else {
                        swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: "No se pudo cerrar la caja",
                        })
                    }
                }
            })
        })
    })
}
let formFilter = document.getElementById("form_cash_filter_date")
formFilter.addEventListener("submit", (e) => {
    e.preventDefault()
    let init = formFilter.querySelector("#date_start").value
    let end = formFilter.querySelector("#date_end").value
    console.log(searchParam({ init: init, end: end }, "caja"));
})