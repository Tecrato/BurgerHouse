export async function payReservation(functions, templates, calendar) {
    const { searchParam, amountDolar, viewImage, InputPrice, selectOptionAll, validateField, setValidationStyles, reindex, CheckCash, sessionInfo, resetForm, hora, fecha } = functions()
    const { tagPackage, targetClienteOrder, optionsRol, elemenFormPaymentReservation, selectTable } = templates()
    viewImage(".input-image")
    InputPrice("[input_price]");
    let session = await sessionInfo()
    let cash = await CheckCash()
    stepperReservation.to(0)
    selectOptionAll(".select_options_payment_reservation", "metodo_pago", optionsRol);
    selectOptionAll(".select_options_client_reservation", "clients", optionsRol);
    let iti = window.intlTelInput(document.querySelector("#input-tel-client-reservation"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
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
    const resetFormModal = () => {
        document.querySelector(".target_client_reservation").innerHTML = ""
        document.querySelector(".target_client_reservation").classList.add("d-none")
        document.querySelector(".loader_client_reservation").querySelector("h3").classList.remove("d-none")
        document.querySelector(".loader_client_reservation").querySelector(".loader").classList.add("d-none")
        document.getElementById('form-search-client-reservation').reset()
        document.querySelector("#input-tel-client-reservation").value = ""
        document.querySelector("#input-tel-client-reservation").classList.remove("is-invalid", "is-valid")
        document.querySelector("#input-date-reservation").value = ""
        document.querySelector("#input-date-reservation").classList.remove("is-invalid", "is-valid")
        resetForm(".payments-reservation", document.getElementById("form-submit-payment-reservation"))
    }
    //validacion de cliente
    let formClient = document.getElementById("form-search-client-reservation")
    let propinaData
    formClient.addEventListener("submit", async (e) => {
        if (formClient.querySelector("input").value != "") {
            e.preventDefault()
            document.querySelector(".loader_client_reservation").querySelector("h3").classList.add("d-none")
            document.querySelector(".target_client_reservation").classList.add("d-none")
            document.querySelector(".loader_client_reservation").querySelector(".loader").classList.remove("d-none")
            let pet = await searchParam({ active: 1 }, "clientes", 100000)
            let result = pet.find((client) => { return client.documento.includes(formClient.querySelector("input").value) })
            if (result != undefined) {
                let template = targetClienteOrder(result)
                result.telefono != null ? iti.setNumber(result.telefono) : iti.setNumber("")
                document.querySelector(".loader_client_reservation").querySelector(".loader").classList.add("d-none")
                document.querySelector(".target_client_reservation").innerHTML = template
                document.querySelector(".target_client_reservation").classList.remove("d-none")
            } else {
                let data = new FormData()
                data.append("cedula", formClient.querySelector("input").value);
                let pet = await fetch(`login/cedula`, { method: "POST", body: data })
                let res = await pet.json()
                if (res.success == true) {
                    let data = new FormData()
                    data.append("nombre", res.message.primer_nombre);
                    data.append("apellido", res.message.primer_apellido);
                    data.append("documento", res.message.nacionalidad + "-" + res.message.cedula);
                    let pet2 = await fetch(`clientes/add`, { method: "POST", body: data })
                    let res2 = await pet2.json()
                    if (res2.success == true) {
                        let pet3 = await searchParam({ active: 1, id: res2.last_id }, "clientes", 1);
                        let template = targetClienteOrder(pet3[0])
                        document.querySelector(".loader_client_reservation").querySelector(".loader").classList.add("d-none")
                        document.querySelector(".target_client_reservation").innerHTML = template
                        document.querySelector(".target_client_reservation").classList.remove("d-none")
                    } else {
                        toas("error", "Error al registrar el cliente")
                        document.querySelector(".loader_client_reservation").querySelector(".loader").classList.add("d-none")
                        document.querySelector(".target_client_reservation").classList.remove("d-none")
                    }
                } else {
                    toas("error", "Cliente no encontrado")
                    document.querySelector(".loader_client_reservation").querySelector("h3").classList.remove("d-none")
                    document.querySelector(".loader_client_reservation").querySelector("div").classList.add("d-none")
                }
            }
        } else {
            e.preventDefault()
            toas("error", "Ingrese un numero de cedula")
        }
    })
    const Package = async () => {
        let template = ""
        let pet = await searchParam({ active: 1 }, "paquete_reservacion", null, 0)
        for (const element of pet) {
            template += await tagPackage(element)
        }
        document.querySelector(".cont_packages_reservation").innerHTML = template
    }
    const NextPayment = () => {
        let btn = document.querySelector(".next_reservation_payment")
        if (!btn.dataset.listenerAttached) {
            btn.addEventListener("click", async () => {
                let hasErrorTel = false
                let hasErrorDate = false
                let tel = iti.getNumber();
                const errors = validate({ telefono: tel }, rules_tel);
                const errors2 = validate({ fecha: document.querySelector("#input-date-reservation").value }, rules_date);
                setValidationStyles(`input-date-reservation`, errors2?.fecha ? errors2.fecha[0] : null);
                setValidationStyles(`input-tel-client-reservation`, errors?.telefono ? errors.telefono[0] : null);

                if (errors) hasErrorTel = true
                else hasErrorTel = false

                if (errors2) hasErrorDate = true
                else hasErrorDate = false

                let count = 0;
                document.querySelector(".cont_packages_reservation").querySelectorAll(".btn-check").forEach((element) => {
                    if (element.checked) count++
                })

                if (!document.querySelector(".cont_client-reservation").querySelector("h4")) {
                    toas("error", "Seleccione un cliente");
                } else if (hasErrorDate) {
                    toas("error", "Seleccione una fecha");
                } else if (hasErrorTel) {
                    toas("error", "Seleccione un telefono");
                } else if (count == 0) {
                    toas("error", "Seleccione un paquete");
                } else {
                    const { PackageData } = FinalData()
                    let dolar = await amountDolar()
                    stepperReservation.next()
                    document.querySelector(".amount_payment_usd_reservation").textContent = PackageData.precio
                    document.querySelector(".amount_payment_bs_reservation").textContent = (parseFloat(PackageData.precio) * dolar).toFixed(2)
                }
            })
            btn.dataset.listenerAttached = "true"
        }
    }
    const NextConfirmReservation = () => {
        let btn = document.querySelector(".btn_next_reservation_confirm")
        if (!btn.dataset.listenerAttached) {
            btn.addEventListener("click", () => {
                let hasError = false;
                const payment = document.querySelectorAll(".payments-reservation");
                payment.forEach((payment, i) => {
                    const index = i + 1;
                    const data = {
                        id_metodo_pago: payment.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                        cantidad: payment.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                        referencia: payment.querySelector(`input[name="referencia"]`).value,
                        imagen: payment.querySelector(`input[name="imagen"]`) ? payment.querySelector(`input[name="imagen"]`).files[0] : ""
                    };
                    const errors = validate(data, rules);
                    setValidationStyles(`input-payment-reservation-${index}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
                    setValidationStyles(`input-quantity-reservation-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
                    setValidationStyles(`input-reference-reservation-${index}`, errors?.referencia ? errors.referencia[0] : null);
                    setValidationStyles(`input-comprobante-reservation-${index}`, errors?.imagen ? errors.imagen[0] : null);
                    if (errors) hasError = true
                    else hasError = false
                });

                if (hasError) {
                    toas("error", "Complete todos los campos");
                } else {
                    validatePayment()
                    PrintConfirmData()
                }
            })
            btn.dataset.listenerAttached = "true"
        }
    }
    const PrintConfirmData = async () => {
        let dolar = parseFloat(await amountDolar())
        const { PackageData, dateReservation, clientData, dataPayment, propinaBS, propinaUSD } = FinalData()
        console.log(dateReservation);
        document.querySelector(".name_client_confirm_reservation").textContent = clientData.nameClient
        document.querySelector(".document_client_confirm_reservation").textContent = clientData.documentClient
        document.querySelector(".date_client_confirm_reservation").textContent = fecha(dateReservation.fecha_inicio) + " a las " + hora(dateReservation.fecha_inicio)

        let templatePackage = `
            <tr>
                <td>${PackageData.nombre}</td>
                <td>${PackageData.sillas}</td>
                <td>${PackageData.precio}</td>
            </tr>
            `
        document.querySelector(".cont_confirm_package_reservation").innerHTML = templatePackage

        let templatePayment = "";
        dataPayment.forEach((payment) => {
            const file = payment.imagen;
            const reader = new FileReader();
            let cantidad
            if (payment.metodo.toLowerCase() == "efectivo") cantidad = payment.cantidad + " Bs";
            else if (payment.metodo.toLowerCase() == "transferencia") cantidad = payment.cantidad + " Bs";
            else if (payment.metodo.toLowerCase() == "pago movil") cantidad = payment.cantidad + " Bs";
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

                document.querySelector(".cont_confirm_payment_reservation").innerHTML = templatePayment;
            };
            reader.readAsDataURL(file);
        });
        document.querySelector(".total_usd_confirm_payment").textContent = PackageData.precio
        document.querySelector(".total_bs_confirm_payment").textContent = (parseFloat((PackageData.precio).replace("$", "")) * dolar).toFixed(2)
        document.querySelector(".propina_usd").textContent = propinaUSD
        document.querySelector(".propina_bs").textContent = propinaBS


    }
    const FinalData = () => {
        const clientData = {
            id_cliente: document.querySelector(".cont_client-reservation").querySelector("h4[id]").getAttribute("id"),
            nameClient: document.querySelector(".cont_client-reservation").querySelector(".nombre_client").textContent,
            documentClient: document.querySelector(".cont_client-reservation").querySelector(".document_client").textContent,
            telefonoClient: iti.getNumber()
        }
        const dateReservation = {
            fecha_inicio: document.querySelector("#input-date-reservation").value
        }
        let PackageData
        document.querySelector(".cont_packages_reservation").querySelectorAll(".btn-check").forEach((element) => {
            if (element.checked) {
                PackageData = {
                    id_paquete: element.id,
                    nombre: element.getAttribute("data-filter"),
                    precio: element.closest("div").querySelector(".data_price").textContent,
                    sillas: element.closest("div").querySelector(".data_tables").textContent
                }
            }
        })
        let dataPayment = [];
        const payment = document.querySelectorAll(".payments-reservation");
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
        const { fecha_bloqueo, fecha_inicio } = setDate(dateReservation.fecha_inicio)
        return {
            clientData,
            dateReservation: { ...dateReservation, fecha_bloqueo, fecha_inicio },
            PackageData,
            dataPayment,
            propinaUSD: propinaData?.propinaUSD ? propinaData.propinaUSD : 0,
            propinaBS: propinaData?.propina ? propinaData.propina : 0
        }
    }
    const validatePayment = async () => {
        const { dataPayment, PackageData } = FinalData()
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
        let dolar = parseFloat(await amountDolar())
        let propina
        let total_amount_verify_bs = (parseFloat((PackageData.precio).replace("$", "")) * dolar) - amountVerify.total_bs;
        let total_amount_verify_usd = parseFloat((PackageData.precio).replace("$", "")) - amountVerify.total_usd
        let verifyDivisa = dataPayment.find((payment) => (payment.metodo).toLowerCase() == "divisa");
        let verifyBs = dataPayment.find((payment) => (payment.metodo).toLowerCase() != "divisa");

        if (verifyBs != undefined) propina = (total_amount_verify_bs).toFixed(2) + " Bs"
        else if (verifyDivisa != undefined) propina = (total_amount_verify_usd).toFixed(2) + " USD"

        if (verifyDivisa != undefined && verifyBs != undefined) {
            let total_verify = parseFloat((amountVerify.total_usd * dolar).toFixed(2)) + amountVerify.total_bs
            let total__order = parseFloat((parseFloat((PackageData.precio).replace("$", "")) * dolar).toFixed(2))
            if (total_verify < total__order) toas("error", "El total de la orden no puede ser menor al total de la orden");
            else {
                stepperReservation.next()
                propina = total__order - total_verify + " Bs";
            }
        } else {
            let dolares = parseFloat((PackageData.precio).replace("$", ""))
            let bs = parseFloat((dolares * dolar).toFixed(2))
            if (amountVerify.total_bs >= bs || amountVerify.total_usd >= dolares) {
                stepperReservation.next()
            } else {
                toas("error", "El total de la reserva no puede ser menor al total del pago");
            }
        }
        let propinaUSD
        if (propina.includes("-")) propina = propina.replace("-", "")
        if (!propina.includes("Bs")) propinaUSD = propina

        propinaData = {
            propina,
            propinaUSD
        }

    }
    const setDate = (fecha) => {
        const DataBlock = (fecha) => {
            const fechaOriginal = new Date(fecha);
            fechaOriginal.setHours(fechaOriginal.getHours() - 1);
            return fechaOriginal.toISOString()
        }
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

        let fecha_bloqueo = DataFormat(DataBlock(fecha))
        let fecha_inicio = DataFormat(fecha)

        return {
            fecha_bloqueo,
            fecha_inicio
        }
    }
    const SendData = async () => {
        let btn = document.querySelector(".next_payment_reservation_confirm")
        if (!btn.dataset.listenerAttached) {
            btn.addEventListener("click", async () => {
                const { clientData, dateReservation, PackageData, dataPayment } = FinalData()
                if (cash == null) {
                    Swal.fire({
                        icon: "error",
                        title: "Error",
                        text: "No hay cajas disponibles",
                    })
                } else {
                    let dolar = parseFloat(await amountDolar())
                    Swal.fire({
                        title: 'Procesando...',
                        text: 'Por favor espera',
                        allowOutsideClick: false,
                        didOpen: () => { Swal.showLoading() }
                    });
                    bootstrap.Modal.getOrCreateInstance('#add_reservation').hide()
                    let DataTelClient = new FormData();
                    DataTelClient.append("id", clientData.id_cliente);
                    DataTelClient.append("telefono", clientData.telefonoClient);
                    let updateTelClient = await fetch("clientes/update", { method: "POST", body: DataTelClient })
                    let responseTelClient = await updateTelClient.json()
                    console.log(responseTelClient);
                    let order = new FormData();
                    let nro_orden = Math.floor(Math.random() * (99999999 - 10000000 + 1)) + 10000000
                    order.append("id_cliente", clientData.id_cliente);
                    order.append("tipo", "reserva");
                    order.append("nro_orden", nro_orden)
                    order.append("status", "confirmada")
                    let petOrder = await fetch("orden/add", { method: "POST", body: order })
                    let resOrder = await petOrder.json()
                    console.log(resOrder);
                    let id_order = resOrder.last_id
                    let reservationData = new FormData();
                    reservationData.append("id_orden", id_order);
                    reservationData.append("id_paquete", PackageData.id_paquete);
                    reservationData.append("id_caja", cash);
                    reservationData.append("fecha_inicio", dateReservation.fecha_inicio);
                    reservationData.append("fecha_bloqueo", dateReservation.fecha_bloqueo);
                    reservationData.append("metodo_pedido", "Sistema");
                    reservationData.append("status", "confirmada");
                    let petReservation = await fetch("calendario/add", { method: "POST", body: reservationData })
                    let resReservation = await petReservation.json()
                    console.log(resReservation);
                    let paymentData = new FormData();
                    dataPayment.forEach((payment, index) => {
                        paymentData.append(`lista[${index}][id_metodo_pago]`, payment.id_metodo_pago)
                        paymentData.append(`lista[${index}][monto]`, payment.cantidad)
                        paymentData.append(`lista[${index}][tasa]`, dolar)
                        paymentData.append(`lista[${index}][referencia]`, payment.referencia)
                        paymentData.append(`lista[${index}][imagen]`, payment.imagen)
                        paymentData.append(`lista[${index}][imagen_name]`, payment.imagen.name)
                    })
                    let petPayment = await fetch("pago/add_many", { method: "POST", body: paymentData })
                    let resPayment = await petPayment.json()
                    console.log(resPayment);
                    let id_payments = resPayment.lista
                    let dataPaymentDetails = new FormData();
                    id_payments.forEach((payment, index) => {
                        dataPaymentDetails.append(`lista[${index}][id_pago]`, payment)
                        dataPaymentDetails.append(`lista[${index}][id_reserva]`, resReservation.last_id)
                    })
                    let petPaymentDetails = await fetch("pago_reserva/add_many", { method: "POST", body: dataPaymentDetails })
                    let resPaymentDetails = await petPaymentDetails.json()
                    console.log(resPaymentDetails);

                    if (resPaymentDetails.success == true) {
                        Swal.close();
                        Swal.fire({
                            icon: "success",
                            title: "Reserva creada",
                            text: "Reserva creada con exito",
                        })
                        nuevaBitacora("reserva", "Creacion", `Se agrego una reserva para el ${fecha(dateReservation.fecha_inicio)}`);
                        calendar()
                        resetFormModal()
                    } else {
                        Swal.close();
                        Swal.fire({
                            icon: "error",
                            title: "Error",
                            text: "Error al crear la reserva",
                        })
                    }
                }
            })
            btn.dataset.listenerAttached = "true"
        }
    }
    Package()
    NextPayment()
    NextConfirmReservation()
    SendData()

    //validacion de pago ------------------------------------------------------------------

    let paymentCount = 1;
    function addPayment() {
        paymentCount++;
        document.getElementById("payments-container-reservation").insertAdjacentHTML('beforeend', elemenFormPaymentReservation(paymentCount));
        feather.replace();
        selectOptionAll(".select_options_payment_reservation", "metodo_pago", optionsRol);
        viewImage(".input-image")
        InputPrice("[input_price]");
        attachValidationListeners(paymentCount);
        const newProduct = document.getElementById(`payments-reservation-${paymentCount}`);
        newProduct.querySelector(".remove-payments-reservation").addEventListener("click", function () {
            newProduct.remove();
            reindex("#payments-container-reservation .payments-reservation", "payments-reservation", paymentCount, "Pago");
        });
    }
    function attachValidationListeners(index) {
        const paymentElement = document.getElementById(`payments-reservation-${index}`);
        paymentElement.querySelectorAll("input[type='text'], input[type='button'], input[type='file']").forEach(input => {
            input.addEventListener("keyup", (e) => validateField(e, rules));
            input.addEventListener("blur", (e) => validateField(e, rules));
            input.addEventListener("change", (e) => validateField(e, rules));
        });
        document.getElementById("input-date-reservation").addEventListener("change", (e) => validateField(e, rules_date));
        document.getElementById("input-tel-client-reservation").addEventListener("keyup", (e) => validateField(e, rules_tel));
    }
    document.getElementById("add-payment-reservation-btn").addEventListener("click", () => {
        addPayment();
        reindex("#payments-container-reservation .payments-reservation", "payments-reservation", paymentCount, "Pago");
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
    validate.validators.telefonoValido = function (value) {
        if (!value) return
        if (!iti.isValidNumber()) {
            const pais = iti.getSelectedCountryData().name;
            return `^Número inválido para ${pais}`;
        }
    };
    validate.extend(validate.validators.datetime, {
        parse: function (value) {
            return Date.parse(value) || NaN;
        },
        format: function (value, options) {
            console.log(new Date(value).toISOString().split("T")[0]);
            return new Date(value).toISOString().split("T")[0];
        }
    });
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
    const rules_tel = {
        telefono: {
            presence: {
                allowEmpty: false,
                message: "^es requerida"
            },
            telefonoValido: true

        }
    }
    function getTodayAtMidnight() {
        const now = new Date();
        now.setHours(0, 0, 0, 0);
        return now;
    }
    const rules_date = {
        fecha: {
            presence: {
                allowEmpty: false,
                message: "^es requerido"
            },
            datetime: {
                dateOnly: false,
                earliest: getTodayAtMidnight(),
                message: "^Debe ser una fecha válida"
            }
        },
    }
    attachValidationListeners(1);
}
