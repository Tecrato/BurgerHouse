export async function payOrderReservation(functions, templates, invoice, reload) {
    const { searchParam, amountDolar, viewImage, InputPrice, selectOptionAll, validateField, setValidationStyles, reindex, CheckCash, sessionInfo, binnacle, resetForm, notification, notificationAlert } = functions()
    const { optionsRol, elemenFormPaymentReservationOrder } = templates()
    selectOptionAll(".select_options_payment_local_reservation", "metodo_pago", optionsRol);
    viewImage(".input-image")
    InputPrice("[input_price]");
    const dolar = parseFloat(await amountDolar())
    let session = await sessionInfo()
    const DataFormat = (fecha) => {
        const fechaFormat = new Date(fecha);
        const año = fechaFormat.getFullYear();
        const mes = String(fechaFormat.getMonth() + 1).padStart(2, '0');
        const dia = String(fechaFormat.getDate()).padStart(2, '0');
        const hora = String(fechaFormat.getHours()).padStart(2, '0');
        const minutos = String(fechaFormat.getMinutes()).padStart(2, '0');
        const segundos = String(fechaFormat.getSeconds()).padStart(2, '0');

        const fechaMysql = `${año}-${mes}-${dia} ${hora}:${minutos}:${segundos}`;
        return fechaMysql
    }
    document.querySelector(".amount_payment_usd_local_res").textContent = window.amountTotalOrderLocalPayment.total_dolares
    document.querySelector(".amount_payment_bs_local_res").textContent = window.amountTotalOrderLocalPayment.total_bs
    document.querySelector(".amount_abono_usd_reservation").textContent = window.amountAboveReservation.montoUSD
    document.querySelector(".amount_abono_bs_reservation").textContent = window.amountAboveReservation.montoBs
    document.querySelector(".amount_abono_bs_reservation").textContent = window.amountAboveReservation.montoBs
    const total_order = parseFloat(window.amountTotalOrderLocalPayment.total_bs) - (parseFloat(window.amountAboveReservation.montoBs) + (parseFloat(window.amountAboveReservation.montoUSD) * dolar))
    document.querySelector(".amount_total_payment_usd_reservation").textContent = `${total_order.toFixed(2)} Bs --- ${(total_order / dolar).toFixed(2)} USD`
    stepperReservationOrder.to(0)
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
    //validacion de pago ------------------------------------------------------------------
    let paymentCount = 1;
    function addPayment() {
        paymentCount++;
        document.getElementById("payments-container-local-reservation").insertAdjacentHTML('beforeend', elemenFormPaymentReservationOrder(paymentCount));
        feather.replace();
        selectOptionAll(".select_options_payment_local_reservation", "metodo_pago", optionsRol);
        viewImage(".input-image")
        InputPrice("[input_price]");
        attachValidationListeners(paymentCount);
        const newProduct = document.getElementById(`payments-local-reservation-${paymentCount}`);
        newProduct.querySelector(".remove-payments-reservation-local").addEventListener("click", function () {
            newProduct.remove();
            reindex("#payments-container-local-reservation .payments-local-reservation", "payments-local-reservation", paymentCount, "Pago");
        });
    }
    function attachValidationListeners(index) {
        const paymentElement = document.getElementById(`payments-local-reservation-${index}`);
        paymentElement.querySelectorAll("input[type='text'], input[type='button'], input[type='file']").forEach(input => {
            input.addEventListener("keyup", (e) => validateField(e, rules));
            input.addEventListener("blur", (e) => validateField(e, rules));
            input.addEventListener("change", (e) => validateField(e, rules));
        });
    }
    document.getElementById("add-payment-order-localRes-btn").addEventListener("click", () => {
        addPayment();
        reindex("#payments-container-local-reservation .payments-local-reservation", "payments-local-reservation", paymentCount, "Pago");
    });
    validate.validators.cantidad = function (value, options, key, attributes) {
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
    validate.validators.validateCategoryAndRecipe = function (value, options, key, attributes) {
        if (!value) {
            return options.message || "es requerido";
        }
        if (value.toLowerCase() === "seleccione una opcion") {
            return options.message || "es requerido";
        }
    };
    validate.validators.number = function (value, options, key, attributes) {
        if (!value) return;

        if (!/^[0-9]/.test(value)) {
            return options.notnumber;
        }
    };
    validate.validators.fileType = function (value, options, key, attributes) {
        if (!value) return
        if (value.type) {
            const typeFile = value.type.split("/")[1]
            if (!options.types.includes(typeFile)) {
                return `debe ser una imagen JPG, PNG o WEBP`;
            }
        } else {
            const typeFile = value.split(".")[1]
            if (!options.types.includes(typeFile)) {
                return `debe ser una imagen JPG, PNG o WEBP`;
            }
        }

    };
    const rules = {
        cantidad: {
            presence: {
                allowEmpty: false,
                message: "^es requerido"
            },
            cantidad: { message: "^debe ser un número mayor a 0" }
        },
        id_metodo_pago: {
            presence: {
                allowEmpty: false,
                message: "^es requerida"
            },
            validateCategoryAndRecipe: { message: "^es requerido" }
        },
        referencia: {
            presence: {
                allowEmpty: false,
                message: "^es requerido"
            },
            number: {
                notnumber: "^solo numeros"
            }
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
    attachValidationListeners(1);
    let btn_next_payment = document.querySelector(".btn_next_payment_localRes");
    if (!btn_next_payment.dataset.listenerAttached) {
        btn_next_payment.addEventListener("click", async () => {
            let hasError = false;
            const payment = document.querySelectorAll(".payments-local-reservation");
            payment.forEach((payment, i) => {
                const index = i + 1;
                const data = {
                    id_metodo_pago: payment.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                    cantidad: payment.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                    referencia: payment.querySelector(`input[name="referencia"]`).value,
                    imagen: payment.querySelector(`input[name="imagen"]`) ? payment.querySelector(`input[name="imagen"]`).files[0] : ""
                };
                const errors = validate(data, rules);
                setValidationStyles(`input-payment-orderLocalRes-${index}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
                setValidationStyles(`input-quantity-orderLocalRes-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
                setValidationStyles(`input-reference-orderLocalRes-${index}`, errors?.referencia ? errors.referencia[0] : null);
                setValidationStyles(`input-comprobante-orderLocalRes-${index}`, errors?.imagen ? errors.imagen[0] : null);
                if (errors) hasError = true
                else hasError = false
            });
            if (hasError) {
                toas("error", "Complete todos los campos");
            } else {
                let dataPayment = [];
                const payment = document.querySelectorAll(".payments-local-reservation");
                payment.forEach((payment) => {
                    const data = {
                        id_metodo_pago: payment.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                        metodo: payment.querySelector(`input[name="id_metodo_pago"]`).value,
                        cantidad: payment.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                        referencia: payment.querySelector(`input[name="referencia"]`).value,
                        imagen: payment.querySelector(`input[name="imagen"]`) ? payment.querySelector(`input[name="imagen"]`).files[0] : ""
                    };
                    dataPayment.push(data)
                });
                let group = {};
                dataPayment.forEach((payment) => {
                    const metodo = payment.metodo;
                    const cantidad = parseFloat(payment.cantidad);
                    if (!group[metodo]) group[metodo] = { metodo: metodo, cantidad: cantidad };
                    else group[metodo].cantidad += cantidad;
                });
                group = Object.values(group);
                let amountVerify = []
                group.forEach(async (payment) => {
                    if ((payment.metodo).toLowerCase() == "pago movil" || (payment.metodo).toLowerCase() == "transferencia" || (payment.metodo).toLowerCase() == "efectivo") {
                        amountVerify.push({
                            total_bs: payment.cantidad,
                        })
                    } else amountVerify.push({ total_usd: payment.cantidad })
                });
                amountVerify = amountVerify.reduce((a, b) => {
                    return {
                        total_bs: parseFloat(((a.total_bs || 0) + (b.total_bs || 0)).toFixed(2)),
                        total_usd: (a.total_usd || 0) + (b.total_usd || 0)
                    };
                });
                let propina
                let total_verify_bs_above = parseFloat(window.amountTotalOrderLocalPayment.total_bs) - parseFloat(window.amountAboveReservation.montoBs)
                let total_verify_usd_above = parseFloat(window.amountTotalOrderLocalPayment.total_bs) - (parseFloat(window.amountAboveReservation.montoBs) + (parseFloat(window.amountAboveReservation.montoUSD) * dolar))
                total_verify_usd_above = parseFloat((total_verify_usd_above / dolar).toFixed(2))
                let total_amount_verify_bs = parseFloat(total_verify_bs_above - amountVerify.total_bs).toFixed(2);
                let total_amount_verify_usd = parseFloat(total_verify_usd_above - (amountVerify.total_usd ? amountVerify.total_usd : 0)).toFixed(2);
                let verifyDivisa = dataPayment.find((payment) => (payment.metodo).toLowerCase() == "divisa");
                let verifyBs = dataPayment.find((payment) => (payment.metodo).toLowerCase() != "divisa");

                if (verifyBs != undefined) propina = (total_amount_verify_bs * -1) + " Bs"
                else if (verifyDivisa != undefined) propina = (total_amount_verify_usd * -1) + " USD"


                console.log({
                    total_descuento_bs: total_verify_bs_above,
                    total_descuento_usd: total_verify_usd_above,
                    total_amount_verify_bs: total_amount_verify_bs,
                    total_amount_verify_usd: total_amount_verify_usd
                })
                if (verifyDivisa != undefined && verifyBs != undefined) {
                    let total_verify = (total_amount_verify_usd * dolar) + total_amount_verify_bs;
                    let total__order = parseFloat(total_verify_bs_above)
                    if (total_verify < total__order) toas("error", "El total de la orden no puede ser menor al total de la orden");
                    else {
                        stepperReservationOrder.next()
                        propina = total__order - total_verify + " Bs";
                    }
                } else {
                    if (amountVerify.total_bs >= total_verify_bs_above || amountVerify.total_usd >= total_verify_usd_above) {
                        stepperReservationOrder.next()
                        let templatePayment = "";
                        dataPayment.forEach((payment) => {
                            const file = payment.imagen;
                            const reader = new FileReader();
                            let cantidad
                            if (payment.metodo.toLowerCase() != "divisa") cantidad = payment.cantidad + " Bs";
                            else cantidad = payment.cantidad + " $";
                            reader.onload = (event) => {
                                const imgresult = event.target.result;
                                templatePayment +=
                                    `<tr>
                                        <td>${payment.metodo}</td>
                                        <td>${cantidad}</td>
                                        <td>${payment.referencia}</td>
                                        <td><img src="${imgresult}" alt="Comprobante" style="max-width: 100px; max-height: 100px;"></td>
                                    </tr>`;

                                document.querySelector(".cont_confirm_payment_order_local_reservation").innerHTML = templatePayment;
                            };
                            reader.readAsDataURL(file);
                        });
                        document.querySelector(".total_usd_confirm_payment_reservation").textContent = total_verify_usd_above
                        document.querySelector(".total_bs_confirm_payment_reservation").textContent = total_verify_bs_above
                        if (propina.includes("Bs")) document.querySelector(".propina_usd_reservation").textContent = propina
                        else if (propina.includes("USD")) document.querySelector(".propina_bs_reservation").textContent = propina

                        let btnsend = document.querySelector(".confirm_order_local_payment_reservation");
                        if (!btnsend.dataset.listenerAttached) {
                            btnsend.addEventListener("click", async () => {
                                Swal.fire({
                                    title: 'Procesando...',
                                    text: 'Por favor espera',
                                    allowOutsideClick: false,
                                    didOpen: () => { Swal.showLoading() }
                                });
                                let info = await searchParam({ id: window.IdOrderPaymentLocal }, "orden")
                                bootstrap.Modal.getOrCreateInstance('#payment_order_local_reservation').hide()
                                if (info[0].status == "pagado") {
                                    Swal.close();
                                    Swal.fire({
                                        title: `Error!`,
                                        text: "La orden ya fue pagada",
                                        icon: "error",
                                    });
                                } else {
                                    let dataOrder = new FormData();
                                    dataOrder.append("id", window.IdOrderPaymentLocal)
                                    dataOrder.append("status", "pagado")
                                    let petOrder = await fetch("orden/update", { method: "POST", body: dataOrder })
                                    console.log(await petOrder.json());

                                    let dataRes = new FormData();
                                    dataRes.append("id", window.IdReservationPaymentLocal)
                                    dataRes.append("status", "finalizada")
                                    dataRes.append("fecha_final", DataFormat(new Date()))
                                    let petRes = await fetch("calendar/update", { method: "POST", body: dataRes })
                                    let resSale = await petRes.json()
                                    console.log(resSale);

                                    let paymentData = new FormData();
                                    dataPayment.forEach((payment, index) => {
                                        paymentData.append(`lista[${index}][id_metodo_pago]`, payment.id_metodo_pago)
                                        paymentData.append(`lista[${index}][monto]`, payment.cantidad)
                                        paymentData.append(`lista[${index}][tasa]`, dolar)
                                        paymentData.append(`lista[${index}][referencia]`, payment.referencia)
                                        paymentData.append(`lista[${index}][imagen]`, payment.imagen)
                                        paymentData.append(`lista[${index}][imagen_name]`, payment.imagen.name)
                                    })
                                    let petPayment = await fetch("payment/add_many", { method: "POST", body: paymentData })
                                    let resPayment = await petPayment.json()
                                    console.log(resPayment);
                                    let id_payments = resPayment.lista
                                    let dataPaymentDetails = new FormData();
                                    id_payments.forEach((payment, index) => {
                                        dataPaymentDetails.append(`lista[${index}][id_pago]`, payment)
                                        dataPaymentDetails.append(`lista[${index}][id_reserva]`, window.IdReservationPaymentLocal)
                                    })
                                    let petPaymentDetails = await fetch("PaymentSale/add_many", { method: "POST", body: dataPaymentDetails })
                                    let resPaymentDetails = await petPaymentDetails.json()
                                    console.log(resPaymentDetails);
                                    let infoOrderActualizada = await searchParam({ id: window.IdOrderPaymentLocal }, "orden")
                                    let detailsPrepered = await searchParam({ id_orden: window.IdOrderPaymentLocal }, "Detalle_orden_producto_preparado")
                                    let detailsProcess = await searchParam({ id_orden: window.IdOrderPaymentLocal }, "Detalle_orden_producto_procesado")
                                    let totalAmountPrepared = detailsPrepered.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
                                    let totalAmountProcess = detailsProcess.map(item => item.precio * item.cantidad).reduce((a, b) => a + b, 0)
                                    let iva = (totalAmountPrepared + totalAmountProcess) * 0.16
                                    let clientData = {
                                        id_cliente: infoOrderActualizada[0].id_cliente ? infoOrderActualizada[0].id_cliente : "POR ASIGNAR",
                                        nameClient: infoOrderActualizada[0].cliente_nombre ? infoOrderActualizada[0].cliente_nombre + " " + infoOrderActualizada[0].cliente_apellido : "POR ASIGNAR",
                                        telefonoClient: infoOrderActualizada[0].cliente_telefono ? infoOrderActualizada[0].cliente_telefono : "POR ASIGNAR"
                                    };
                                    let amountTotal = {
                                        total_dolares: "TOTAL: " + (((totalAmountPrepared + totalAmountProcess) + iva).toFixed(2)),
                                        total_bs: (((totalAmountPrepared + totalAmountProcess) + iva) * await amountDolar()).toFixed(2),
                                        subtotal: "SUBTOTAL: " + ((totalAmountPrepared + totalAmountProcess).toFixed(2)),
                                        iva: "IVA: " + (iva.toFixed(2))
                                    }
                                    let dataPaymentAbove = await searchParam({ id_reserva: window.IdReservationPaymentLocal }, "PaymentReservation")
                                    let amountBs = []
                                    let amountUSD = []
                                    dataPaymentAbove.forEach(item => {
                                        if (item.metodo_pago != "divisa") {
                                            amountBs.push(parseFloat(item.monto))
                                        } else {
                                            amountUSD.push(parseFloat(item.monto))
                                        }
                                    })
                                    const above = {
                                        montoBs: amountBs.reduce((a, b) => a + b, 0),
                                        montoDolar: amountUSD.reduce((a, b) => a + b, 0)
                                    }

                                    let directionSale = "BURGER HOUSE"
                                    let invoiceBlob = await invoice(detailsPrepered, detailsProcess, clientData, window.IdOrderPaymentLocal, directionSale, amountTotal, "invoice", null, above)
                                    let invoiceData = new FormData();
                                    invoiceData.append("pdf", invoiceBlob, "factura.pdf");
                                    let send = await fetch("orden/sendInvoice", { method: "POST", body: invoiceData });
                                    let dataResInvoice = await send.json();
                                    const mensaje = `*FACTURA DE ORDEN* \n\n*${clientData.nameClient}*\n\n${dataResInvoice.url}`;
                                    const url = `https://wa.me/${clientData.telefonoClient}?text=${encodeURIComponent(mensaje)}`;
                                    if (dataResInvoice.url) {
                                        Swal.close();
                                        Swal.fire({
                                            title: `Exito!`,
                                            text: "Se pago la orden",
                                            icon: "success",
                                        });
                                        binnacle(session.message.id, 'Orden Reservacion', 'Pago', `Se pago la orden ${window.IdOrderPaymentLocal}`);
                                        resetForm(".payments-local-reservation", document.getElementById("form-submit-payment-local-reservation"))
                                        reload()
                                        notification({
                                            id_usuario: session.message.id,
                                            titulo: `Se ha pagado una orden`,
                                            mensaje: `Se ha pagado una orden con el nro ${window.IdOrderPaymentLocal.toString().padStart(4, '0')}`,
                                        })
                                        notificationAlert({
                                            channel: "General",
                                            message: `Se pago una orden con el nro ${window.IdOrderPaymentLocal.toString().padStart(4, '0')}`,
                                            event: "notificaciones"
                                        })
                                        window.open(url, '_blank');
                                    } else {
                                        Swal.fire({
                                            title: `Error!`,
                                            text: "Hubo un error al pagar la orden",
                                            icon: "error",
                                        });
                                    }
                                    resetForm(".payments-local-reservation", document.getElementById("form-submit-payment-local-reservation"))
                                }
                            });
                            btnsend.dataset.listenerAttached = "true";
                        }
                    } else toas("error", "La cantidad de pago no puede ser menor al total de la orden");
                }
            }
        })
        btn_next_payment.dataset.listenerAttached = "true";
    }
}