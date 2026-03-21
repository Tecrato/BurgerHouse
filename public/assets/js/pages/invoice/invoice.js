import functionGeneral from "../../Functions.js";
import Templates from "../../templates.js";
import { invoice } from "./report.js"
import { myfecth } from "../../Functions2.js"
const { print, searchParam, searchFilter, searchBetween, amountDolar, setValidationStyles } = functionGeneral()
const { targetInvoice, targetInvoiceReservation } = Templates()
const dolar = parseFloat(await amountDolar())
let typeFilter = "delivery"
let filterClient = ""
let filterClientRes = ""
let data_between = ""
let data_betweenRes = ""
const rules_between = {
    initDate: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        }
    },
    endDate: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        }
    }
}
const config = {
    search: () => searchParam({ status: typeFilter == "local" ? "pagado" : "entregada", tipo: typeFilter }, "orden", 12),
    template: targetInvoice,
    container: ".cont_invoice",
    funtions: () => {
        viewDetails()
    },
}
const configRes = {
    search: () => searchParam({ status: 'finalizada' }, "calendario", 12),
    template: targetInvoiceReservation,
    container: ".cont_invoice_reservation",
    funtions: () => {
        viewDetails()
    },
}
print(config)
print(configRes)

searchFilter("#searchInvoice", (e) => {
    filterClient = e.target.value
    if (filterClient == "") print(config)
    else {
        if (data_between != "") {
            print({
                ...config, search: () => searchParam({
                    nombre_like: filterClient,
                    cedula_like: filterClient,
                    nro_factura: filterClient,
                    apellido_like: filterClient,
                    between_fecha: data_between,
                    status: typeFilter == "local" ? "pagado" : "entregada",
                    tipo: typeFilter
                }, "orden", 12)
            })
        } else {
            print({
                ...config, search: () => searchParam({
                    nombre_like: filterClient,
                    cedula_like: filterClient,
                    nro_factura: filterClient,
                    apellido_like: filterClient,
                    status: typeFilter == "local" ? "pagado" : "entregada",
                    tipo: typeFilter
                }, "orden", 12)
            })
        }
    }
})
searchBetween("#filterInvoiceBetween", (e) => {
    const form = e.target
    const initDate = form.querySelector("#initDate-invoice").value
    const endDate = form.querySelector("#endDate-invoice").value

    const error = validate({ initDate, endDate }, rules_between)
    setValidationStyles("initDate-invoice", error?.initDate ? error.initDate[0] : null)
    setValidationStyles("endDate-invoice", error?.endDate ? error.endDate[0] : null)

    if (!error) {
        data_between = { inicio: initDate, fin: endDate }
        print({
            ...config, search: () => searchParam({
                between_fecha: data_between,
                nombre_like: filterClient,
                cedula_like: filterClient,
                nro_factura: filterClient,
                apellido_like: filterClient,
                status: typeFilter == "local" ? "pagado" : "entregada",
                tipo: typeFilter
            }, "orden", 12)
        })
    }
})
searchFilter("#searchInvoiceRes", (e) => {
    filterClientRes = e.target.value

    if (filterClientRes == "") {
        if (data_betweenRes != "") {
            print({
                ...configRes,
                search: () => searchParam({
                    nombre_like: filterClientRes,
                    cedula_like: filterClientRes,
                    apellido_like: filterClientRes,
                    nro_factura: filterClientRes,
                    between_fecha: data_betweenRes,
                    status: 'finalizada'
                }, "calendario", 12),
            })
        } else {
            print({
                ...configRes,
                search: () => searchParam({
                    nombre_like: filterClientRes,
                    cedula_like: filterClientRes,
                    apellido_like: filterClientRes,
                    nro_factura: filterClientRes,
                    status: 'finalizada'
                }, "calendario", 12),
            })
        }
    }
    else {
        if (data_betweenRes != "") {
            print({
                ...configRes,
                search: () => searchParam({
                    nombre_like: filterClientRes,
                    cedula_like: filterClientRes,
                    apellido_like: filterClientRes,
                    nro_factura: filterClientRes,
                    between_fecha: data_betweenRes,
                    status: 'finalizada'
                }, "calendario", 12),
            })
        } else {
            print({
                ...configRes,
                search: () => searchParam({
                    nombre_like: filterClientRes,
                    cedula_like: filterClientRes,
                    apellido_like: filterClientRes,
                    nro_factura: filterClientRes,
                    status: 'finalizada'
                }, "calendario", 12),
            })
        }
    }
})
searchBetween("#filterResBetween", (e) => {
    const form = e.target
    const initDate = form.querySelector("#initDate-res").value
    const endDate = form.querySelector("#endDate-res").value

    const error = validate({ initDate, endDate }, rules_between)
    setValidationStyles("initDate-res", error?.initDate ? error.initDate[0] : null)
    setValidationStyles("endDate-res", error?.endDate ? error.endDate[0] : null)

    if (!error) {
        data_betweenRes = { inicio: initDate, fin: endDate }
        print({
            ...configRes, search: () => searchParam({
                between_fecha: data_betweenRes,
                nombre_like: filterClientRes,
                cedula_like: filterClientRes,
                nro_factura: filterClientRes,
                apellido_like: filterClientRes,
                status: 'finalizada'
            }, "calendario", 12)
        })
    }
})

document.querySelectorAll(".btn_check").forEach(item => {
    item.addEventListener("click", () => {
        typeFilter = item.id
        if (typeFilter == "invoice_delivery") typeFilter = "delivery"
        else if (typeFilter == "invoice_takeaway") typeFilter = "llevar"
        else if (typeFilter == "invoice_local") typeFilter = "local"
        const type = item.id
        if (type == "invoice_delivery") {
            if (data_between != "") {
                print({
                    ...config, search: () => searchParam({
                        nombre_like: filterClient,
                        cedula_like: filterClient,
                        nro_factura: filterClient,
                        apellido_like: filterClient,
                        between_fecha: data_between,
                        status: "entregada",
                        tipo: "delivery"
                    }, "orden", 12)
                })
            } else {
                print({
                    ...config, search: () => searchParam({
                        nombre_like: filterClient,
                        cedula_like: filterClient,
                        nro_factura: filterClient,
                        apellido_like: filterClient,
                        status: "entregada",
                        tipo: "delivery"
                    }, "orden", 12)
                })
            }
        } else if (type == "invoice_takeaway") {
            if (data_between != "") {
                print({
                    ...config, search: () => searchParam({
                        nombre_like: filterClient,
                        cedula_like: filterClient,
                        nro_factura: filterClient,
                        apellido_like: filterClient,
                        between_fecha: data_between,
                        status: "entregada",
                        tipo: "llevar"
                    }, "orden", 12)
                })
            } else {
                print({
                    ...config, search: () => searchParam({
                        nombre_like: filterClient,
                        cedula_like: filterClient,
                        nro_factura: filterClient,
                        apellido_like: filterClient,
                        status: "entregada",
                        tipo: "llevar"
                    }, "orden", 12)
                })
            }
        } else if (type == "invoice_local") {
            if (data_between != "") {
                print({
                    ...config, search: () => searchParam({
                        nombre_like: filterClient,
                        cedula_like: filterClient,
                        nro_factura: filterClient,
                        apellido_like: filterClient,
                        between_fecha: data_between,
                        status: "pagado",
                        tipo: "local"
                    }, "orden", 12)
                })
            } else {
                print({
                    ...config, search: () => searchParam({
                        nombre_like: filterClient,
                        cedula_like: filterClient,
                        nro_factura: filterClient,
                        apellido_like: filterClient,
                        status: "pagado",
                        tipo: "local"
                    }, "orden", 12)
                })
            }
        }
    })
})
const viewDetails = () => {
    const btnDetails = document.querySelectorAll(".btn-details-invoice")
    btnDetails.forEach(btn => {
        btn.addEventListener("click", async () => {
            if (btn.getAttribute("type") == "orden") {
                document.querySelector(".btn-print-invoice").setAttribute("data-id", btn.getAttribute("data-id"))
                document.querySelector(".btn-print-invoice").setAttribute("type", "orden")
                document.querySelector(".btn-print-invoice").setAttribute("data-id-sale", btn.getAttribute("data-id-sale"))
                const id = btn.getAttribute("data-id")
                const id_venta = btn.getAttribute("data-id-sale")
                let petOrder = await searchParam({ id: id }, "orden")
                document.querySelector(".nro_invoice").textContent = "Factura: " + petOrder[0].id.toString().padStart(8, "0")
                bootstrap.Modal.getOrCreateInstance(document.querySelector("#modal-details-invoice")).show()
                const { templateProductPrepared, templateProductProcess } = await detailsProduct(id)
                document.querySelector(".tbody-detail-invoice").innerHTML = templateProductPrepared
                document.querySelector(".tbody-detail-invoice").innerHTML += templateProductProcess
                const templatePay = await detailsPay(id_venta)
                document.querySelector(".cont-detail-payment").innerHTML = templatePay
                amount(id)
            } else {
                document.querySelector(".btn-print-invoice").setAttribute("data-id-order", btn.getAttribute("data-id-order"))
                document.querySelector(".btn-print-invoice").setAttribute("data-id-reservation", btn.getAttribute("data-id-reservation"))
                document.querySelector(".btn-print-invoice").setAttribute("type", "reservation")

                const id_order = btn.getAttribute("data-id-order")
                const id_reservation = btn.getAttribute("data-id-reservation")
                let petOrder = await searchParam({ id: id_order }, "orden")
                document.querySelector(".nro_invoice").textContent = "Factura: " + petOrder[0].id.toString().padStart(8, "0")
                const { templateProductPrepared, templateProductProcess } = await detailsProduct(id_order)
                document.querySelector(".tbody-detail-invoice").innerHTML = templateProductPrepared
                document.querySelector(".tbody-detail-invoice").innerHTML += templateProductProcess
                let template = ""
                if (petOrder[0].id_venta != null) {
                    const templateSale = await detailsPay(petOrder[0].id_venta)
                    template += templateSale
                }
                const templateReservation = await detailsPayRes(id_reservation)
                template += templateReservation
                document.querySelector(".cont-detail-payment").innerHTML = template
                amount(id_order)
                bootstrap.Modal.getOrCreateInstance(document.querySelector("#modal-details-invoice")).show()
            }
        })
    })
}
const detailsProduct = async (id_order) => {
    let data = new FormData();
    data.append("id_orden", id_order)
    let dataProductPrepared = []
    let templateProductPrepared = ""
    let templateProductProcess = ""
    let res = myfecth("Detalle_orden_producto_preparado/get_all", {}, data).json()
    let res2 = myfecth("Detalle_orden_producto_procesado/get_all", {}, data).json()
    let group = {}
    res.forEach((productPrepared) => { if (productPrepared.tipo == "producto") dataProductPrepared.push(productPrepared) })
    dataProductPrepared.forEach((productPrepared) => {
        templateProductPrepared += `
            <tr>
              <td>${productPrepared.nombre}</td>
              <td>${productPrepared.cantidad}</td>
              <td>${productPrepared.precio} $</td>
              <td>${productPrepared.descripcion == null ? "S/D" : productPrepared.descripcion}</td>
              <td>${productPrepared.adicionales == null ? "S/A" : productPrepared.adicionales}</td>
            </tr>
          `
    })
    res2.forEach((productProcess) => {
        if (!group[productProcess.id_producto]) group[productProcess.id_producto] = productProcess
        else group[productProcess.id_producto] = { ...group[productProcess.id_producto], cantidad: parseInt(group[productProcess.id_producto].cantidad) + parseInt(productProcess.cantidad) }
    })
    group = Object.entries(group).map(([key, value]) => ({ id_producto: key, ...value }));
    group.forEach((productProcess) => {
        templateProductProcess += `
            <tr>
              <td>${productProcess.nombre}</td>
              <td>${productProcess.cantidad}</td>
              <td>${productProcess.precio} $</td>
            </tr>
          `
    })
    return {
        templateProductPrepared,
        templateProductProcess
    }

}
const detailsPay = async (id_venta) => {
    let data = new FormData();
    data.append("id_venta", id_venta)
    let dataPayment = []
    let templatePayment = ""
    let res = myfecth("paymentSale/get_all/0/10000000/id/asc", {}, data).json()
    console.log(res);
    res.forEach((payment) => {
        let type = payment.metodo_pago.toLowerCase() != "divisa" ? "bs" : "usd"
        templatePayment += `
      <div class="col-md-10 mt-3 d-flex align-items-center justify-content-between">
          <h3>Tipo de pago: ${payment.metodo_pago}</h3>
          <h3>Monto: ${payment.monto} ${type}</h3>
        ${type == "divisa" ? "" : `<h3>Tasa: ${payment.tasa} bs</h3>`}
      </div>`
    })
    return templatePayment

}
const detailsPayRes = async (id_reservation) => {
    let data = new FormData();
    data.append("id_reserva", id_reservation)
    let templatePayment = ""
    let res = myfecth("paymentReservation/get_all/0/10000000/id/asc", {}, data).json()
    res.forEach((payment) => {
        templatePayment += `
      <div class="col-md-7 mt-3 d-flex align-items-center justify-content-between">
          <h3>Tipo de pago: ${payment.metodo_pago}</h3>
          <h3>Monto: ${payment.monto}</h3>
      </div>`
    })
    return templatePayment
}
const amount = async (id_order) => {
    let detailsPrepered = await searchParam({ id_orden: id_order }, "Detalle_orden_producto_preparado")
    let detailsProcess = await searchParam({ id_orden: id_order }, "Detalle_orden_producto_procesado")
    let totalAmountPrepared = detailsPrepered.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
    let totalAmountProcess = detailsProcess.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
    let iva = (totalAmountPrepared + totalAmountProcess) * 0.16

    let amountTotal = {
        total_dolares: (((totalAmountPrepared + totalAmountProcess) + iva).toFixed(2)),
        total_bs: (((totalAmountPrepared + totalAmountProcess) + iva) * dolar).toFixed(2),
        subtotal: ((totalAmountPrepared + totalAmountProcess).toFixed(2)),
        iva: (iva.toFixed(2))
    }
    document.querySelector(".iva-invoice").textContent = amountTotal.iva + " $"
    document.querySelector(".subtotal-invoice").textContent = amountTotal.subtotal + " $"
    document.querySelector(".total-invoice").textContent = amountTotal.total_dolares + " $"
}
const printInvoice = async () => {
    let btn = document.querySelector(".btn-print-invoice")
    btn.addEventListener("click", async () => {
        if (btn.getAttribute("type") == "orden") {
            let id = btn.getAttribute("data-id")
            let id_venta = btn.getAttribute("data-id-sale")
            let info = await searchParam({ id: id }, "orden")
            let detailsPrepered = await searchParam({ id_orden: id }, "Detalle_orden_producto_preparado")
            let detailsProcess = await searchParam({ id_orden: id }, "Detalle_orden_producto_procesado")
            let payment = await searchParam({ id_venta: id_venta }, "paymentSale")
            let dolar = payment.reduce((a, b) => a > b.tasa ? a : b.tasa, 0)
            let totalAmountPrepared = detailsPrepered.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
            let totalAmountProcess = detailsProcess.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
            let iva = (totalAmountPrepared + totalAmountProcess) * 0.16
            let clientData = {
                id_cliente: info[0].id_cliente ?? "POR ASIGNAR",
                nameClient: info[0].cliente_nombre ? info[0].cliente_nombre + " " + info[0].cliente_apellido : "POR ASIGNAR",
                telefonoClient: info[0].cliente_telefono ?? "POR ASIGNAR"
            };
            let amountTotal = {
                total_dolares: "TOTAL: " + (((totalAmountPrepared + totalAmountProcess) + iva).toFixed(2)),
                total_bs: (((totalAmountPrepared + totalAmountProcess) + iva) * dolar).toFixed(2),
                subtotal: "SUBTOTAL: " + ((totalAmountPrepared + totalAmountProcess).toFixed(2)),
                iva: "IVA: " + (iva.toFixed(2))
            }
            let dataPayment = new FormData();
            dataPayment.append("id_venta", document.querySelector(".btn-print-invoice").getAttribute("data-id-sale"))
            let payments = myfecth("paymentSale/get_all/0/10000000/id/asc", {}, dataPayment).json()
            invoice(detailsPrepered, detailsProcess, clientData, id, info[0].direccion, amountTotal, info, { payments, reservation: [] }, id_venta)
        } else {
            let id = btn.getAttribute("data-id-order")
            let id_reservation = btn.getAttribute("data-id-reservation")
            let info = await searchParam({ id: id }, "orden")
            let detailsPrepered = await searchParam({ id_orden: id }, "Detalle_orden_producto_preparado")
            let detailsProcess = await searchParam({ id_orden: id }, "Detalle_orden_producto_procesado")
            let reservation = await searchParam({ id_reserva: id_reservation }, "paymentReservation", 100000)
            let dolar = reservation.reduce((a, b) => a > Number(b.tasa) ? a : Number(b.tasa), 0)
            let totalAmountPrepared = detailsPrepered.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
            let totalAmountProcess = detailsProcess.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
            let iva = (totalAmountPrepared + totalAmountProcess) * 0.16
            let clientData = {
                id_cliente: info[0].id_cliente ?? "POR ASIGNAR",
                nameClient: info[0].cliente_nombre ? info[0].cliente_nombre + " " + info[0].cliente_apellido : "POR ASIGNAR",
                telefonoClient: info[0].cliente_telefono ?? "POR ASIGNAR"
            };
            let amountTotal = {
                total_dolares: "TOTAL: " + (((totalAmountPrepared + totalAmountProcess) + iva).toFixed(2)),
                total_bs: (((totalAmountPrepared + totalAmountProcess) + iva) * await amountDolar()).toFixed(2),
                subtotal: "SUBTOTAL: " + ((totalAmountPrepared + totalAmountProcess).toFixed(2)),
                iva: "IVA: " + (iva.toFixed(2))
            }
            let payments = []
            if (info[0].id_venta) payments = await searchParam({ id_venta: info[0].id_venta }, "paymentSale", 10000)
            invoice(detailsPrepered, detailsProcess, clientData, id, info[0].direccion, amountTotal, info, { payments, reservation }, id_reservation)
        }

    })

}
printInvoice()