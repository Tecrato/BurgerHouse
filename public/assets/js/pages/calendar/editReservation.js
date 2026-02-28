export const editReservationClient = async (functionGeneral, Templates) => {
    const { searchParam, validateField, setValidationStyles, binnacle, sessionInfo } = functionGeneral()
    const { targetClienteOrder } = Templates()
    let iti = window.intlTelInput(document.querySelector("#input-tel-client-reservationEdit"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
    iti.setNumber(window.dataClient.telefono)
    let session = await sessionInfo()
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
    let formClient = document.getElementById("form-search-client-reservation-edit")


    validate.validators.telefonoValido = function (value) {
        if (!value) return
        if (!iti.isValidNumber()) {
            const pais = iti.getSelectedCountryData().name;
            return `^Número inválido para ${pais}`;
        }
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
    document.querySelector("#input-tel-client-reservationEdit").addEventListener("keyup", (e) => { validateField(e, rules_tel) });

    formClient.querySelector("input").value = window.dataClient.documento
    document.querySelector(".loader_client_reservation-edit").querySelector("h3").classList.add("d-none")
    document.querySelector(".loader_client_reservation-edit").querySelector(".loader").classList.add("d-none")
    document.querySelector(".target_client_reservation-edit").innerHTML = targetClienteOrder(window.dataClient);
    document.querySelector(".target_client_reservation-edit").classList.remove("d-none")

    setTimeout(() => {
        const errors = validate({ telefono: iti.getNumber() }, rules_tel);
        setValidationStyles(`input-tel-client-reservationEdit`, errors?.telefono ? errors.telefono[0] : null);
    }, 300)

    //validacion de cliente
    if (!formClient.dataset.listenerAttached) {
        formClient.addEventListener("submit", async (e) => {
            e.preventDefault()
            document.querySelector(".loader_client_reservation-edit").querySelector("h3").classList.add("d-none")
            document.querySelector(".target_client_reservation-edit").classList.add("d-none")
            document.querySelector(".loader_client_reservation-edit").querySelector(".loader").classList.remove("d-none")
            let pet = await searchParam({ active: 1 }, "clients", 100000)
            let result = pet.find((client) => { return client.documento.split("-")[1] == formClient.querySelector("input").value })
            if (result != undefined) {
                let template = targetClienteOrder(result)
                iti.setNumber(result.telefono)
                document.querySelector(".loader_client_reservation-edit").querySelector(".loader").classList.add("d-none")
                document.querySelector(".target_client_reservation-edit").innerHTML = template
                document.querySelector(".target_client_reservation-edit").classList.remove("d-none")
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
                    let pet2 = await fetch(`clients/add`, { method: "POST", body: data })
                    let res2 = await pet2.json()
                    if (res2.success == true) {
                        let pet3 = await searchParam({ active: 1, id: res2.last_id }, "clients", 1);
                        let template = targetClienteOrder(pet3[0])
                        document.querySelector(".loader_client_reservation-edit").querySelector(".loader").classList.add("d-none")
                        document.querySelector(".target_client_reservation-edit").innerHTML = template
                        document.querySelector(".target_client_reservation-edit").classList.remove("d-none")
                        iti.setNumber("")
                        document.querySelector("#input-tel-client-reservationEdit").classList.remove("is-invalid", "is-valid")
                    } else {
                        toas("error", "Error al registrar el cliente")
                        document.querySelector(".loader_client_reservation-edit").querySelector(".loader").classList.add("d-none")
                        document.querySelector(".target_client_reservation-edit").innerHTML = template
                        document.querySelector(".target_client_reservation-edit").classList.remove("d-none")
                    }
                } else {
                    toas("error", "Cliente no encontrado")
                    document.querySelector(".loader_client_reservation-edit").querySelector("h3").classList.remove("d-none")
                    document.querySelector(".loader_client_reservation-edit").querySelector(".loader").classList.add("d-none")
                    document.querySelector(".target_client_reservation-edit").innerHTML = ""
                }
            }
        })
        formClient.dataset.listenerAttached = "true"
    }

    let btnSendEdit = document.querySelector(".btn_edit_client_reservation");
    if (!btnSendEdit.dataset.listenerAttached) {
        btnSendEdit.addEventListener("click", async () => {
            console.log(window.dataClient);
            const errors = validate({ telefono: iti.getNumber() }, rules_tel);
            setValidationStyles(`input-tel-client-reservationEdit`, errors?.telefono ? errors.telefono[0] : null);
            if (!errors && document.querySelector(".cont_client-reservation-edit").querySelector("h4[id]")) {
                let data = new FormData()
                data.append("id", window.dataClient.id_orden);
                data.append("id_cliente", document.querySelector(".cont_client-reservation-edit").querySelector("h4[id]").getAttribute("id"));
                let pet = await fetch(`orden/update`, { method: "POST", body: data })
                let res = await pet.json()

                let dataCli = new FormData()
                dataCli.append("id", document.querySelector(".cont_client-reservation-edit").querySelector("h4[id]").getAttribute("id"));
                dataCli.append("telefono", iti.getNumber());
                let updateClient = await fetch(`clients/update`, { method: "POST", body: dataCli })
                let resClient = await updateClient.json()
                if (res.success == true && resClient.success == true) {
                    Swal.fire({
                        title: `Exito!`,
                        text: "El cliente de la reserva fue actualizado correctamente",
                        icon: "success",
                    })
                    bootstrap.Modal.getOrCreateInstance('#edit-client-reservation').hide()
                    binnacle(session.message.id, "Reservas", "Edicion", "Se actualizo el cliente de la reserva" + window.dataClient.id_reserva)
                } else {
                    Swal.fire({
                        title: `Error!`,
                        text: "El cliente de la reserva no pudo ser actualizado",
                        icon: "error",
                    })
                }
            } else {
                toas("error", "Faltan campos por llenar")
            }
        })
        btnSendEdit.dataset.listenerAttached = "true"
    }

    bootstrap.Modal.getOrCreateInstance('#edit-reservation').hide()
    bootstrap.Modal.getOrCreateInstance("#edit-client-reservation").show()

}

export const editDateReservation = async (funtionGeneral, reload) => {
    const { searchParam, validateField, setValidationStyles, binnacle, sessionInfo } = funtionGeneral()
    const { date } = window.editDateReservation
    document.getElementById("input-date-reservationEdit").value = date
    const session = await sessionInfo()
    validate.extend(validate.validators.datetime, {
        parse: function (value) {
            return Date.parse(value) || NaN;
        },
        format: function (value, options) {
            return new Date(value).toISOString().split("T")[0];
        }
    });
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
    function getTodayAtMidnight() {
        const now = new Date();
        now.setHours(0, 0, 0, 0);
        return now;
    }

    const error = validate({ fecha: date }, rules_date);
    setValidationStyles("input-date-reservationEdit", error?.fecha ? error.fecha[0] : null);
    document.getElementById("input-date-reservationEdit").addEventListener("change", (e) => validateField(e, rules_date));
    bootstrap.Modal.getOrCreateInstance('#edit-reservation').hide()
    bootstrap.Modal.getOrCreateInstance("#edit-date-reservation").show()

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
    let btn = document.querySelector(".btn_edit_date_reservation")
    if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => {
            const id = window.editDateReservation.id
            const errors = validate({ fecha: document.getElementById("input-date-reservationEdit").value }, rules_date);
            setValidationStyles("input-date-reservationEdit", errors?.fecha ? errors.fecha[0] : null);
            if (!errors) {
                const date = setDate(document.getElementById("input-date-reservationEdit").value)
                let data = new FormData()
                data.append("id", id);
                data.append("fecha_inicio", date.fecha_inicio);
                data.append("fecha_bloqueo", date.fecha_bloqueo);
                let pet = await fetch(`calendar/update`, { method: "POST", body: data })
                let res = await pet.json()
                if (res.success == true) {
                    Swal.fire({
                        title: `Exito!`,
                        text: "La fecha de la reserva fue actualizada correctamente",
                        icon: "success",
                    })
                    reload()
                    bootstrap.Modal.getOrCreateInstance('#edit-date-reservation').hide()
                    binnacle(session.message.id, "Reservas", "Actualizacion", "Se actualizo la fecha de una reserva " + id)
                } else {
                    Swal.fire({
                        title: `Error!`,
                        text: "La fecha de la reserva no pudo ser actualizada",
                        icon: "error",
                    })
                }
            }
        })
        btn.dataset.listenerAttached = "true"
    }

}

export const editPackageReservation = async (functionGeneral, Templates) => {
    const { searchParam, validateField, setValidationStyles, binnacle, sessionInfo, amountDolar, fecha, hora, viewImage, InputPrice, selectOptionAll, reindex } = functionGeneral()
    const { tagPackageChecked, elemenFormPaymentReservationEdit, tagPackage, optionsRol } = Templates()
    const packageData = window.editPackageReservation
    const dolar = parseFloat(await amountDolar())
    const session = await sessionInfo()
    const packageSelect = await searchParam({ id: packageData.package }, "Package_reservation")
    document.querySelector(".cont_packages_reservation_edit_select").innerHTML = await tagPackageChecked(packageSelect[0])

    let toas = (type, msj) => {
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 3000,
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

    let template = ""
    const total_bs = []
    let propinaData
    let infoPackage = { id_paquete_actual: packageData.package }
    const dataPayment = await searchParam({ id_reserva: packageData.id }, "PaymentReservation")
    dataPayment.forEach((payment) => {
        if (payment.metodo_pago.toLowerCase() != "divisa") total_bs.push(payment.monto)

        let signo = payment.metodo_pago.toLowerCase() != "divisa" ? "Bs" : "USD"
        template += `
        <div class="col-md-3 mt-3 border p-3 border-2 text-center">
          <img src="media/pay/${payment.comprobante}" alt="Logo" class="w-75">
          <h3 class="fs-5 mt-2">Tipo de pago: ${payment.metodo_pago}</h3>
          <h3 class="fs-5 mt-2">Monto: ${payment.monto} ${signo}</h3>
      </div>
        `
    })
    document.querySelector(".cont_payment_reservation_edit").innerHTML = template
    document.querySelector(".total_bs_edit_reservation_payment").textContent = total_bs.reduce((a, b) => a + (parseFloat(b)), 0)
    document.querySelector(".total_usd_edit_reservation_payment").textContent = (total_bs.reduce((a, b) => a + (parseFloat(b)), 0) / dolar).toFixed(2)

    infoPackage = { ...infoPackage, monto_total: (total_bs.reduce((a, b) => a + (parseFloat(b)), 0) / dolar).toFixed(2) }

    const packageItem = await searchParam({}, "Package_reservation", 1000)
    let packageItem2 = []
    let templatePackages = ""
    for (const element of packageItem) {
        if (element.id != packageData.package) {
            packageItem2.push(element)
        }
    }
    for (const element of packageItem2) {
        templatePackages += await tagPackage(element)
    }
    document.querySelector(".cont_packages_reservation_edit").innerHTML = templatePackages

    bootstrap.Modal.getOrCreateInstance('#edit-reservation').hide()
    bootstrap.Modal.getOrCreateInstance("#edit-packages-reservation").show()


    const verifyPay = (dataPackage, infoDataPackage) => {
        window.dataPayEditReservation = dataPayment
        let btn = document.querySelector(".next_reservation_payment_edit")
        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);
        window.infoEditPackage = { id: packageData.id }
        newBtn.addEventListener("click", async () => {
            let id_paquete_nuevo = {}
            let info_paquete_nuevo = {}
            const packageItem = document.querySelectorAll(".btn-check")
            packageItem.forEach((item) => {
                if (item.checked) {
                    info_paquete_nuevo = {
                        name: item.nextElementSibling.querySelector(".card-title").textContent,
                        monto: item.nextElementSibling.querySelector(".data_price").textContent,
                        sillas: item.nextElementSibling.querySelector(".data_tables").textContent
                    }
                }
                item.checked ? id_paquete_nuevo = { id_paquete_nuevo: item.getAttribute("id"), monto_total: item.nextElementSibling.querySelector(".data_price").textContent.split(" ")[0] } : null
            })
            if (id_paquete_nuevo.id_paquete_nuevo.includes("package")) {
                id_paquete_nuevo = { ...id_paquete_nuevo, id_paquete_nuevo: parseInt(id_paquete_nuevo.id_paquete_nuevo.split("-")[1]) }
            }
            console.log(id_paquete_nuevo);
            console.log(dataPackage);

            if (dataPackage.id_paquete_actual == id_paquete_nuevo.id_paquete_nuevo) {
                toas("error", "El paquete actual, es el mismo al ya guardado, por favor elija otro paquete")
                return
            }
            window.infoEditPackage = { ...window.infoEditPackage, id_paquete: id_paquete_nuevo.id_paquete_nuevo }
            if (parseFloat(dataPackage.monto_total) >= parseFloat(id_paquete_nuevo.monto_total)) {
                document.querySelector(".name_client_confirm_reservation_edit").textContent = infoDataPackage.clientData.nombre
                document.querySelector(".document_client_confirm_reservation_edit").textContent = infoDataPackage.clientData.documento
                document.querySelector(".date_client_confirm_reservation_edit").textContent = fecha(infoDataPackage.fecha_reserva) + " a las " + hora(infoDataPackage.fecha_reserva)

                let template = `
                                    <tr>
                                        <td>${info_paquete_nuevo.name}</td>
                                        <td>${info_paquete_nuevo.sillas}</td>
                                        <td>${info_paquete_nuevo.monto}</td>
                                    </tr>
                `
                document.querySelector(".cont_confirm_package_reservation_edit").innerHTML = template

                let templatePayment = "";
                window.dataPayEditReservation.forEach((payment) => {
                    let cantidad
                    if (payment.metodo_pago.toLowerCase() != "divisa") cantidad = payment.monto + " Bs";
                    else cantidad = payment.monto + " $";
                    templatePayment +=
                        `<tr>
                            <td>${payment.metodo_pago}</td>
                            <td>${cantidad}</td>
                            <td>${payment.referencia}</td>
                            <td><img src="media/pay/${payment.comprobante}" alt="Comprobante" style="max-width: 100px; max-height: 100px;"></td>
                        </tr>`;
                });
                document.querySelector(".cont_confirm_payment_reservation_edit").innerHTML = templatePayment;

                document.querySelector(".total_usd_confirm_payment_edit").textContent = id_paquete_nuevo.monto_total + " $"
                document.querySelector(".total_bs_confirm_payment_edit").textContent = (parseFloat(id_paquete_nuevo.monto_total) * dolar).toFixed(2) + " Bs"
                document.querySelector(".propina_usd_edit").textContent = (parseFloat(dataPackage.monto_total) - parseFloat(id_paquete_nuevo.monto_total)).toFixed(2) + " $"
                document.querySelector(".propina_bs_edit").textContent = ((parseFloat(dataPackage.monto_total) - parseFloat(id_paquete_nuevo.monto_total)) * dolar).toFixed(2) + " Bs"

                sendDataPackage()
                stepperReservationEdit.to(3)

            } else {
                stepperReservationEdit.to(2)
                NextConfirmReservation(id_paquete_nuevo, dataPackage)
                sendPaymentPackage()
            }

        })
    }
    const FinalData = () => {
        let PackageData
        document.querySelectorAll(".btn-check").forEach((element) => {
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
        const payment = document.querySelectorAll(".payments-reservation_edit");
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
        return {
            PackageData,
            dataPayment,
            propinaUSD: propinaData?.propinaUSD ? propinaData.propinaUSD : 0,
            propinaBS: propinaData?.propina ? propinaData.propina : 0
        }
    }
    const NextConfirmReservation = (packageNew, packageOld) => {
        viewImage(".input-image")
        InputPrice("[input_price]");
        selectOptionAll(".select_options_payment_reservation_edit", "metodo_pago", optionsRol);

        document.querySelector(".amount_payment_usd_reservation_edit").textContent = packageNew.monto_total + " $"
        document.querySelector(".amount_payment_bs_reservation_edit").textContent = (parseFloat(packageNew.monto_total) * dolar).toFixed(2) + " Bs"

        document.querySelector(".amount_abono_usd_reservation_edit").textContent = packageOld.monto_total + " $"
        document.querySelector(".amount_abono_bs_reservation_edit").textContent = (parseFloat(packageOld.monto_total) * dolar).toFixed(2) + " Bs"

        const totalAmount$ = (parseFloat(packageNew.monto_total) - parseFloat(packageOld.monto_total)).toFixed(2)
        const totalAmountbs = ((parseFloat(packageNew.monto_total) - parseFloat(packageOld.monto_total)) * dolar).toFixed(2)

        document.querySelector(".amount_total_payment_usd_reservation_edit").textContent = `${totalAmount$} $ --- ${totalAmountbs} Bs`


        // window.dataPayEditReservation
        let paymentCount = 1;
        function addPayment() {
            paymentCount++;
            document.getElementById("payments-container-reservation_edit").insertAdjacentHTML('beforeend', elemenFormPaymentReservationEdit(paymentCount));
            feather.replace();
            selectOptionAll(".select_options_payment_reservation_edit", "metodo_pago", optionsRol);
            viewImage(".input-image")
            InputPrice("[input_price]");
            attachValidationListeners(paymentCount);
            const newProduct = document.getElementById(`payments-reservation-edit-${paymentCount}`);
            newProduct.querySelector(".remove-payments-reservation-edit").addEventListener("click", function () {
                newProduct.remove();
                reindex("#payments-container-reservation_edit .payments-reservation_edit", "payments-reservation_edit", paymentCount, "Pago");
            });
        }
        function attachValidationListeners(index) {
            const paymentElement = document.getElementById(`payments-reservation-edit-${index}`);
            paymentElement.querySelectorAll("input[type='text'], input[type='button'], input[type='file']").forEach(input => {
                input.addEventListener("keyup", (e) => validateField(e, rules));
                input.addEventListener("blur", (e) => validateField(e, rules));
                input.addEventListener("change", (e) => validateField(e, rules));
            });
        }
        document.getElementById("add-payment-reservation-btn-edit").addEventListener("click", () => {
            addPayment();
            reindex("#payments-container-reservation_edit .payments-reservation_edit", "payments-reservation_edit", paymentCount, "Pago");

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
        attachValidationListeners(1)
        let btn = document.querySelector(".btn_next_reservation_confirm_edit")
        btn.addEventListener("click", async () => {
            let hasError = false;
            const payment = document.querySelectorAll(".payments-reservation_edit");
            payment.forEach((payment, i) => {
                const index = i + 1;
                const data = {
                    id_metodo_pago: payment.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                    cantidad: payment.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                    referencia: payment.querySelector(`input[name="referencia"]`).value,
                    imagen: payment.querySelector(`input[name="imagen"]`) ? payment.querySelector(`input[name="imagen"]`).files[0] : ""
                };
                const errors = validate(data, rules);
                setValidationStyles(`input-payment-reservationEdit-${index}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
                setValidationStyles(`input-quantity-reservationEdit-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
                setValidationStyles(`input-reference-reservationEdit-${index}`, errors?.referencia ? errors.referencia[0] : null);
                setValidationStyles(`input-comprobante-reservationEdit-${index}`, errors?.imagen ? errors.imagen[0] : null);
                if (errors) hasError = true
                else hasError = false
            });

            if (hasError) {
                toas("error", "Complete todos los campos");
            } else {
                await validatePayment(parseFloat(packageOld.monto_total), parseFloat((parseFloat(packageOld.monto_total) * dolar).toFixed(2)))
                PrintConfirmData(packageData)
            }
        })
    }
    const PrintConfirmData = async (infoDataPackage) => {
        const { PackageData, dataPayment, propinaBS, propinaUSD } = FinalData()
        document.querySelector(".name_client_confirm_reservation_edit").textContent = infoDataPackage.clientData.nombre
        document.querySelector(".document_client_confirm_reservation_edit").textContent = infoDataPackage.clientData.documento
        document.querySelector(".date_client_confirm_reservation_edit").textContent = fecha(infoDataPackage.fecha_reserva) + " a las " + hora(infoDataPackage.fecha_reserva)

        let templatePackage = `
            <tr>
                <td>${PackageData.nombre}</td>
                <td>${PackageData.sillas}</td>
                <td>${PackageData.precio}</td>
            </tr>
            `
        document.querySelector(".cont_confirm_package_reservation_edit").innerHTML = templatePackage

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

                document.querySelector(".cont_confirm_payment_reservation_edit").innerHTML = templatePayment;
            };
            reader.readAsDataURL(file);
        });

        document.querySelector(".total_usd_confirm_payment_edit").textContent = PackageData.precio + " $"
        document.querySelector(".total_bs_confirm_payment_edit").textContent = (parseFloat((PackageData.precio).replace("$", "")) * dolar).toFixed(2)
        document.querySelector(".propina_usd_edit").textContent = propinaUSD
        document.querySelector(".propina_bs_edit").textContent = propinaBS


    }
    const validatePayment = async (totalAmount$, totalAmountbs) => {
        const { dataPayment, PackageData } = FinalData()
        const totalAmountUSD = parseFloat(totalAmount$)
        const totalAmountBS = parseFloat(totalAmountbs)

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
        let total_amount_verify_bs = (parseFloat((PackageData.precio).replace("$", "")) * dolar) - (amountVerify.total_bs + totalAmountBS);
        let total_amount_verify_usd = parseFloat((PackageData.precio).replace("$", "")) - amountVerify.total_usd
        let verifyDivisa = dataPayment.find((payment) => (payment.metodo).toLowerCase() == "divisa");
        let verifyBs = dataPayment.find((payment) => (payment.metodo).toLowerCase() != "divisa");


        if (verifyBs != undefined) propina = (total_amount_verify_bs).toFixed(2) + " Bs"
        else if (verifyDivisa != undefined) propina = (total_amount_verify_usd).toFixed(2) + " USD"

        if (verifyDivisa != undefined && verifyBs != undefined) {
            let total_verify = parseFloat((amountVerify.total_usd * dolar).toFixed(2)) + amountVerify.total_bs
            let total__order = parseFloat((parseFloat((parseFloat((PackageData.precio).replace("$", "")) * dolar)) - totalAmountBS).toFixed(2))

            if (total_verify < total__order) toas("error", "El total de la orden no puede ser menor al total de la orden");
            else {
                stepperReservationEdit.next()
                propina = total__order - total_verify + " Bs";
            }
        } else {
            let dolares = parseFloat((PackageData.precio).replace("$", ""))
            let bs = parseFloat((dolares * dolar).toFixed(2))
            const USD_RESERVATION = dolares - totalAmountUSD
            const BS_RESERVATION = bs - totalAmountBS

            if (amountVerify.total_bs >= BS_RESERVATION || amountVerify.total_usd >= USD_RESERVATION) {
                stepperReservationEdit.next()
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
    const sendDataPackage = () => {
        let btn = document.querySelector(".next_payment_reservation_confirm_edit")
        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);
        newBtn.addEventListener("click", async () => {
            Swal.fire({
                title: 'Procesando...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading() }
            });
            const { id, id_paquete } = window.infoEditPackage
            let data = new FormData();
            data.append("id", id)
            data.append("id_paquete", id_paquete)
            let pet = await fetch("calendar/update", { method: "POST", body: data })
            let res = await pet.json()
            if (res.success == true) {
                Swal.close();
                Swal.fire({
                    title: `Exito!`,
                    text: "El paquete fue actualizado correctamente",
                    icon: "success",
                })
                binnacle(session.message.id, "Reservas", "Actualizacion", "Se actualizo el paquete de la reserva " + id)
                bootstrap.Modal.getOrCreateInstance("#edit-packages-reservation").hide()
            } else {
                Swal.close();
                Swal.fire({
                    title: `Error!`,
                    text: "El paquete no fue actualizado",
                    icon: "error",
                })
            }
        })
    }
    const sendPaymentPackage = () => {
        let btn = document.querySelector(".next_payment_reservation_confirm_edit")
        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);
        newBtn.addEventListener("click", async () => {
            Swal.fire({
                title: 'Procesando...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading() }
            });
            const payment = document.querySelectorAll(".payments-reservation_edit");
            const dataPaymentNew = []
            payment.forEach((payment, i) => {
                const data = {
                    id_metodo_pago: payment.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                    cantidad: payment.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                    referencia: payment.querySelector(`input[name="referencia"]`).value,
                    imagen: payment.querySelector(`input[name="imagen"]`) ? payment.querySelector(`input[name="imagen"]`).files[0] : ""
                };
                dataPaymentNew.push(data);
            });

            let paymentDataNew = new FormData();
            dataPaymentNew.forEach((payment, index) => {
                paymentDataNew.append(`lista[${index}][id_metodo_pago]`, payment.id_metodo_pago)
                paymentDataNew.append(`lista[${index}][monto]`, payment.cantidad)
                paymentDataNew.append(`lista[${index}][tasa]`, dolar)
                paymentDataNew.append(`lista[${index}][referencia]`, payment.referencia)
                paymentDataNew.append(`lista[${index}][imagen]`, payment.imagen)
                paymentDataNew.append(`lista[${index}][imagen_name]`, payment.imagen.name)
            })
            let petPayment = await fetch("payment/add_many", { method: "POST", body: paymentDataNew })
            let resPayment = await petPayment.json()
            console.log(resPayment);
            let id_payments = resPayment.lista
            let dataPaymentDetails = new FormData();
            id_payments.forEach((payment, index) => {
                dataPaymentDetails.append(`lista[${index}][id_pago]`, payment)
                dataPaymentDetails.append(`lista[${index}][id_reserva]`, packageData.id)
            })
            let petPaymentDetails = await fetch("paymentReservation/add_many", { method: "POST", body: dataPaymentDetails })
            let resPaymentDetails = await petPaymentDetails.json()
            console.log(resPaymentDetails);

            const { id, id_paquete } = window.infoEditPackage
            let data = new FormData();
            data.append("id", id)
            data.append("id_paquete", id_paquete)
            let pet = await fetch("calendar/update", { method: "POST", body: data })
            let res = await pet.json()
            console.log(res);

            if (resPaymentDetails.success == true && res.success == true) {
                Swal.close();
                Swal.fire({
                    title: `Exito!`,
                    text: "El paquete fue actualizado correctamente",
                    icon: "success",
                })
                binnacle(session.message.id, "Reservas", "Actualizacion", "Se actualizo el paquete de la reserva " + id)
                bootstrap.Modal.getOrCreateInstance("#edit-packages-reservation").hide()
            } else {
                Swal.close();
                Swal.fire({
                    title: `Error!`,
                    text: "El paquete no fue actualizado",
                    icon: "error",
                })
            }
        })
    }
    verifyPay(infoPackage, packageData)
}