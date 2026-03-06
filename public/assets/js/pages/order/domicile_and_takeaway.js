// import { myfecth } from "../../Functions2";

export default async function domicile_and_takeaway(functions, templates, report, targetUpdate, table_reload, myfecth) {
    const { searchParam, amountDolar, viewImage, InputPrice, selectOptionAll, validateField, setValidationStyles, reindex, CheckCash, sessionInfo, binnacle, resetForm, notification, notificationAlert } = functions()
    const { tagFilterProduct, selectProduct, targetDetailProductOrder, targetDetailOtherOrder, targetClienteOrder, optionsRol, elemenFormPaymentOrder } = templates()
    viewImage(".input-image")
    InputPrice("[input_price]");
    selectOptionAll(".select_options_payment", "metodo_pago", optionsRol);
    let iti = window.intlTelInput(document.querySelector("#input-tel-client-order"), { initialCountry: "ve", separateDialCode: true, utilsScript: "./assets/libs/libs/intl-tel-input/js/utils.js" });
    const resetFormModal = () => {
        document.querySelector(".cont-select-product-order").innerHTML = ""
        const container = document.querySelector(".cont_category_product_orders");
        container.innerHTML = container.children[0].outerHTML
        document.querySelector(".target_client_order").innerHTML = ""
        document.querySelector(".loader_client_order").querySelector("h3").classList.remove("d-none")
        document.querySelector(".target_client_order").classList.add("d-none")
        document.querySelector(".loader_client_order").querySelector(".loader").classList.add("d-none")
        document.getElementById('form-search-client-order').reset()
        document.querySelector(".direction_sale").value = ""
        document.querySelector("#input-tel-client-order").value = ""
        document.querySelector("#input-tel-client-order").classList.remove("is-invalid", "is-valid")
        resetForm(".payments", document.getElementById("form-submit-payment"))
    }
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
    const plusBtn = () => {
        const plusTriggers = document.querySelectorAll(".plusTrigger");
        plusTriggers.forEach((trigger) => {
            const container = trigger.closest(".counter-container");
            const input = container.querySelector("input");
            const plusBtn = container.querySelector(".plusBtn");
            const minusBtn = container.querySelector(".minusBtn");

            let counter = 0;

            if (input.value > 0) {
                counter = input.value;
                container.classList.add("active");
                container.style.width = "110px"
            }

            trigger.addEventListener("click", () => {
                if (counter === 0) {
                    counter = 1;
                    input.value = counter;
                }
                container.classList.add("active");
                container.style.width = "110px"
                amount()
            });

            plusBtn.addEventListener("click", () => {
                counter++;
                input.value = counter;
                amount()
            });

            minusBtn.addEventListener("click", () => {
                counter--;
                if (counter >= 1) {
                    input.value = counter;
                    amount()
                } else {
                    counter = 0;
                    input.value = counter;
                    container.classList.remove("active");
                    container.style.width = ""
                    amount()
                }
            });
        });
    }
    const initPopover = async () => {
        let data = []
        let elements = []
        let recipeDetails = myfecth("recetas/get_all/0/5000").json()
        for (const item of recipeDetails) {
            let pet = myfecth("adicionales/get_all/0/5000", {}, {active:1, tipo:"adicional", id:item.id_producto}).json()
            for (const el of pet) {
                elements.push(el)
            }
        }
        elements.forEach((item) => {
            data.push({
                value: item.nombre,
                id: item.id,
                precio: item.precio
            });
        })
        document.querySelectorAll('textarea[name="tags"]').forEach((input) => {
            let tagify = new Tagify(input, {
                whitelist: data,
                maxTags: 10,
                dropdown: {
                    maxItems: 20,
                    classname: 'tags-look',
                    enabled: 0,
                    closeOnSelect: false
                }
            })
            tagify.on('add', amount);
            tagify.on('remove', amount);
        })
    };
    const amount = async () => {
        let subT = []
        let priceAdditional = []
        let count1 = document.querySelector(".cont-details-product-order-food").children
        for (const key of count1) {
            let price = parseFloat(key.querySelector("h4").textContent.replace("$", "").replace("Precio:", ""))
            let quantity = parseInt(key.querySelector(".counter-container").querySelector("input").value)
            subT.push(price * quantity)
            key.querySelectorAll("tag").forEach((item) => {
                priceAdditional.push(parseFloat(item.getAttribute("precio")) * quantity)
            })
        }
        let count2 = document.querySelector(".cont-details-product-order-other").children
        for (const key of count2) {
            let price = parseFloat(key.querySelector("h4").textContent.replace("$", "").replace("Precio:", ""))
            let quantity = parseInt(key.querySelector(".counter-container").querySelector("input").value)
            subT.push(price * quantity)
        }

        let iva = ((subT.reduce((a, b) => a + b, 0) + priceAdditional.reduce((a, b) => a + b, 0)) * 0.16).toFixed(2)
        let subtotal = (subT.reduce((a, b) => a + b, 0) + priceAdditional.reduce((a, b) => a + b, 0)).toFixed(2)
        let total = parseFloat(subtotal) + parseFloat(iva)
        //MONTOS DE EL DETALLE
        document.querySelector(".subtotal").textContent = "SUBTOTAL: " + subtotal + " $"
        document.querySelector(".iva").textContent = "IVA: " + iva + " $"
        document.querySelector(".total-amount").textContent = "TOTAL: " + total.toFixed(2) + " $" + " ------ " + (total * await amountDolar()).toFixed(2) + " BS"

        //MONTOS DE EL PAGO
        document.querySelector(".amount_payment_usd").textContent = (total).toFixed(2)
        document.querySelector(".amount_payment_bs").textContent = ((total) * await amountDolar()).toFixed(2)
    }
    // funcion para los filtros de productos y carga de productos
    const filter = () => {
        let inputs = document.querySelectorAll(".btn-filter-product")
        inputs.forEach((input) => {
            input.addEventListener("click", () => {
                let filter = input.getAttribute("data-filter");
                let products = document.querySelectorAll("[data-filter-id]")
                products.forEach((product) => {
                    let filterID = product.getAttribute("data-filter-id");
                    if (filterID == filter) product.classList.remove("d-none")
                    else product.classList.add("d-none")

                    if (filter == "all") product.classList.remove("d-none")
                })
            })
        })
    }
    const categoryFilter = async () => {
        let template = "";
        let category = await searchParam({ active: 1 }, "categoria_producto", 100)
        category.forEach((category) => { template += tagFilterProduct(category); })
        document.querySelector(".cont_category_product_orders").insertAdjacentHTML("beforeend", template)
        filter()
    }
    const products = async () => {
        let templatePrepared = "";
        let templateProcess = "";
        let recipeDetails = await searchParam({}, "recetas", 5000)
        for (const recipe of recipeDetails) {
            const id = recipe.id_producto
            let product = await searchParam({ id: id, tipo: "producto" }, "producto_preparado", 100)
            product.forEach((product) => { templatePrepared += selectProduct(product, "producto_preparado") })
        }
        let productProcess = await searchParam({ active: 1 }, "producto_procesado", 100)
        productProcess.forEach((product) => { templateProcess += selectProduct(product, "producto_procesado") })

        document.querySelector(".cont-select-product-order").innerHTML = "";
        document.querySelector(".cont-select-product-order").insertAdjacentHTML("beforeend", templatePrepared)
        document.querySelector(".cont-select-product-order").insertAdjacentHTML("beforeend", templateProcess)
        categoryFilter()
        plusBtn()
        productForDetails()
        feather.replace()
    }
    const loader = () => {
        document.querySelector(".cont-select-product-order").innerHTML = `
        <div class="col-12 d-flex justify-content-center align-items-center fs-1" style="height: 50vh;">
            <div class="spinner-border" role="status" style="width: 150px; height: 150px; color: #c1c1c1;">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
        `
    }
    loader()
    products()
    //valida q si no hay productos, no puede pasar al step 2
    const productForDetails = () => {
        let btn = document.querySelector(".select_product_btn_next")
        btn.addEventListener("click", () => {
            let data = []
            let cantidad = []
            let products = document.querySelectorAll("[data-filter-id]")
            products.forEach((product) => {
                let input = product.querySelector(".counter-container").querySelector('input').value
                cantidad.push(input)
            })
            let sum = cantidad.reduce((a, b) => parseFloat(a) + parseFloat(b), 0);
            if (sum == 0) toas("error", "Seleccione al menos un producto")
            else {
                stepper.next()
                products.forEach((product) => {
                    let input = product.querySelector(".counter-container").querySelector('input').value
                    if (input != 0) {
                        for (let index = 0; index < input; index++) {
                            data.push({
                                id: product.getAttribute("data-id"),
                                type: product.getAttribute("tipo"),
                                nombre: product.getAttribute("nombre"),
                                imagen: product.getAttribute("imagen"),
                                precio: product.getAttribute("precio"),
                                cantidad: input
                            })
                        }
                    }
                })
                let templateProduct = "";
                let templateOther = "";
                data.forEach((product) => {
                    if (product.type == "producto") templateProduct += targetDetailProductOrder(product)
                    else templateOther += targetDetailOtherOrder(product)
                })
                document.querySelector(".cont-details-product-order-food").innerHTML = templateProduct
                document.querySelector(".cont-details-product-order-other").innerHTML = templateOther
                initPopover()
                feather.replace()
                plusBtn()
                amount()
            }
        })
    }
    //validacion de cliente y pagos--------------------------------------------------------
    let formClient = document.getElementById("form-search-client-order")
    //validacion de cliente
    formClient.addEventListener("submit", async (e) => {
        e.preventDefault()
        document.querySelector(".loader_client_order").querySelector("h3").classList.add("d-none")
        document.querySelector(".target_client_order").classList.add("d-none")
        document.querySelector(".loader_client_order").querySelector(".loader").classList.remove("d-none")
        let pet = await searchParam({ active: 1 }, "clientes", 100000)
        let result = pet.find((client) => { return client.documento.includes(formClient.querySelector("input").value) })
        if (result != undefined) {
            let template = targetClienteOrder(result)
            result.telefono != null ? iti.setNumber(result.telefono) : iti.setNumber("")
            document.querySelector(".loader_client_order").querySelector(".loader").classList.add("d-none")
            document.querySelector(".target_client_order").innerHTML = template
            document.querySelector(".target_client_order").classList.remove("d-none")
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
                    document.querySelector(".loader_client_order").querySelector(".loader").classList.add("d-none")
                    document.querySelector(".target_client_order").innerHTML = template
                    document.querySelector(".target_client_order").classList.remove("d-none")
                } else {
                    toas("error", "Error al registrar el cliente")
                    document.querySelector(".loader_client_order").querySelector(".loader").classList.add("d-none")
                    document.querySelector(".target_client_order").innerHTML = template
                    document.querySelector(".target_client_order").classList.remove("d-none")
                }
            } else {
                toas("error", "Cliente no encontrado")
                document.querySelector(".loader_client_order").querySelector("h3").classList.remove("d-none")
                document.querySelector(".loader_client_order").querySelector("div").classList.add("d-none")
            }
        }
    })
    //validacion de pago ------------------------------------------------------------------
    let paymentCount = 1;
    function addPayment() {
        paymentCount++;
        document.getElementById("payments-container").insertAdjacentHTML('beforeend', elemenFormPaymentOrder(paymentCount));
        feather.replace();
        selectOptionAll(".select_options_payment", "metodo_pago", optionsRol);
        viewImage(".input-image")
        InputPrice("[input_price]");
        attachValidationListeners(paymentCount);
        const newProduct = document.getElementById(`payments-${paymentCount}`);
        newProduct.querySelector(".remove-payments").addEventListener("click", function () {
            newProduct.remove();
            reindex("#payments-container .payments", "payments", paymentCount, "Pago");
        });
    }
    function attachValidationListeners(index) {
        const paymentElement = document.getElementById(`payments-${index}`);
        paymentElement.querySelectorAll("input[type='text'], input[type='button'], input[type='file']").forEach(input => {
            input.addEventListener("keyup", (e) => validateField(e, rules));
            input.addEventListener("blur", (e) => validateField(e, rules));
            input.addEventListener("change", (e) => validateField(e, rules));
        });
        document.getElementById("input-tel-client-order").addEventListener("keyup", (e) => validateField(e, rules_tel));
    }
    document.getElementById("add-payment-order-btn").addEventListener("click", () => {
        addPayment();
        reindex("#payments-container .payments", "payments", paymentCount, "Pago");
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
    let btn_next_payment = document.querySelector(".btn_next_payment");
    btn_next_payment.addEventListener("click", async () => {
        let hasError = false;
        let hasErrorTel = false;
        const payment = document.querySelectorAll(".payments");
        payment.forEach((payment, i) => {
            const index = i + 1;
            const data = {
                id_metodo_pago: payment.querySelector(`input[name="id_metodo_pago"]`).getAttribute("data-id"),
                cantidad: payment.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                referencia: payment.querySelector(`input[name="referencia"]`).value,
                imagen: payment.querySelector(`input[name="imagen"]`) ? payment.querySelector(`input[name="imagen"]`).files[0] : ""
            };
            const errors = validate(data, rules);
            setValidationStyles(`input-payment-order-${index}`, errors?.id_metodo_pago ? errors.id_metodo_pago[0] : null);
            setValidationStyles(`input-quantity-order-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
            setValidationStyles(`input-reference-order-${index}`, errors?.referencia ? errors.referencia[0] : null);
            setValidationStyles(`input-comprobante-order-${index}`, errors?.imagen ? errors.imagen[0] : null);
            if (errors) hasError = true
        });
        let tel = iti.getNumber();
        const errors = validate({ telefono: tel }, rules_tel);
        setValidationStyles(`input-tel-client-order`, errors?.telefono ? errors.telefono[0] : null);
        if (errors) hasErrorTel = true
        else hasErrorTel = false
        if (!document.querySelector(".cont_client-order").querySelector("h4")) {
            toas("error", "Seleccione un cliente");
        } else if (hasErrorTel) {
            toas("error", "Complete todos los campos");
        } else if (hasError) {
            toas("error", "Complete todos los campos");
        } else {
            const { amountTotal } = finalData();
            let dataPayment = [];
            const payment = document.querySelectorAll(".payments");
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
                if ((payment.metodo).toLowerCase() != "divisa") {
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
            console.log(amountVerify);
            let dolar = parseFloat(await amountDolar())
            let propina
            let total_amount_verify_bs = parseFloat((parseFloat(amountTotal.total_bs) - amountVerify.total_bs).toFixed(2));
            let total_amount_verify_usd = parseFloat((amountTotal.total_dolares).replace("TOTAL: ", "")) - amountVerify.total_usd
            let verifyDivisa = dataPayment.find((payment) => (payment.metodo).toLowerCase() == "divisa");
            let verifyBs = dataPayment.find((payment) => (payment.metodo).toLowerCase() != "divisa");
            if (verifyBs != undefined) propina = (total_amount_verify_bs * -1) + " Bs"
            else if (verifyDivisa != undefined) propina = (total_amount_verify_usd * -1) + " USD"


            if (verifyDivisa != undefined && verifyBs != undefined) {
                let total_verify = (total_amount_verify_usd * dolar) + total_amount_verify_bs;
                let total__order = parseFloat(amountTotal.total_bs)
                if (total_verify < total__order) toas("error", "El total de la orden no puede ser menor al total de la orden");
                else {
                    stepper.next()
                    finalData(printConfirmDetailsOrder);
                    propina = total__order - total_verify + " Bs";
                }
            } else {
                if (amountVerify.total_bs >= parseFloat(amountTotal.total_bs) || amountVerify.total_usd >= parseFloat(amountTotal.total_dolares)) {
                    stepper.next()
                    finalData(printConfirmDetailsOrder);
                } else toas("error", "La cantidad de pago no puede ser menor al total de la orden");
            }

        }
    })
    const finalData = (funtion = null) => {
        let productProcessData = []
        let productPreparedData = []
        let productPrepared = document.querySelector(".cont-details-product-order-food").children
        let productProcess = document.querySelector(".cont-details-product-order-other").children
        for (const product of productPrepared) {
            let additionalData = []
            let quantity = parseInt(product.querySelector(".counter-container").querySelector("input").value);
            let price = parseFloat(product.querySelector("h4").textContent.replace("$", "").replace("Precio:", ""));
            let name = product.querySelector("h5").textContent;
            let id = product.querySelector("h5").getAttribute("data-id");
            let detalles = product.querySelector(".details").value;
            product.querySelectorAll("tag").forEach((tag) => {
                additionalData.push({
                    id_producto: tag.getAttribute("id"),
                    nombre: tag.getAttribute("value"),
                    precio: tag.getAttribute("precio"),
                    cantidad: 1 * quantity
                })
            })
            productPreparedData.push({
                id_producto: id,
                nombre: name,
                cantidad: quantity,
                precio: price,
                detalles: detalles,
                adicionales: additionalData
            })
        }
        for (const product of productProcess) {
            let quantity = parseInt(product.querySelector(".counter-container").querySelector("input").value);
            let price = parseFloat(product.querySelector("h4").textContent.replace("$", "").replace("Precio:", ""));
            let name = product.querySelector("h5").textContent;
            let id = product.querySelector("h5").getAttribute("data-id");

            productProcessData.push({
                id_producto: id,
                nombre: name,
                cantidad: quantity,
                precio: price
            })
        }
        let clientData = {
            id_cliente: document.querySelector(".cont_client-order").querySelector("h4[id]").getAttribute("id"),
            nameClient: document.querySelector(".cont_client-order").querySelector(".nombre_client").textContent,
            documentClient: document.querySelector(".cont_client-order").querySelector(".document_client").textContent,
            telefonoClient: iti.getNumber()
        };
        let amountTotal = {
            total_dolares: document.querySelector(".amount_payment_usd").textContent,
            total_bs: document.querySelector(".amount_payment_bs").textContent,
            subtotal: document.querySelector(".subtotal").textContent,
            iva: document.querySelector(".iva").textContent
        }
        let directionSale = document.querySelector(".direction_sale").value;
        let dataPayment = [];
        const payment = document.querySelectorAll(".payments");
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
        if (funtion) funtion(productPreparedData, productProcessData, clientData, dataPayment)
        else return { productPreparedData, productProcessData, clientData, dataPayment, directionSale, amountTotal }
    }
    const printConfirmDetailsOrder = (productPreparedData, productProcessData, clientData, dataPayment) => {
        document.querySelector(".name_client_confirm_order").textContent = clientData.nameClient.toUpperCase();
        document.querySelector(".document_client_confirm_order").textContent = clientData.documentClient;
        let templateProductPrepared = "";
        let templateProductProcess = "";
        let templatePayment = "";
        productPreparedData.forEach((product) => {
            let additional = product.adicionales.map((index) => index.nombre).join(",");
            templateProductPrepared +=
                `<tr>
            <td>${product.nombre}</td>
            <td>${product.cantidad}</td></td>
            <td>${product.detalles == "" ? "S/D" : product.detalles}</td>
            <td>${additional ? additional : "S/A"}</td>
        </tr>`
        });
        productProcessData.forEach((product) => {
            templateProductProcess +=
                `<tr>
            <td>${product.nombre}</td>
            <td>${product.cantidad}</td></td>
            <td>S/D</td>
            <td>S/A</td>
        </tr>`
        });
        dataPayment.forEach((payment) => {
            const file = payment.imagen;
            const reader = new FileReader();
            let cantidad
            if (payment.metodo.toLowerCase() == "efectivo") {
                cantidad = payment.cantidad + " Bs";
            } else if (payment.metodo.toLowerCase() == "transferencia") {
                cantidad = payment.cantidad + " Bs";
            } else if (payment.metodo.toLowerCase() == "pago movil") {
                cantidad = payment.cantidad + " Bs";
            } else {
                cantidad = payment.cantidad + " $";
            }
            reader.onload = (event) => {
                const imgresult = event.target.result;
                templatePayment +=
                    `<tr>
                    <td>${payment.metodo}</td>
                    <td>${cantidad}</td>
                    <td>${payment.referencia}</td>
                    <td><img src="${imgresult}" alt="Comprobante" style="max-width: 100px; max-height: 100px;"></td>
                </tr>`;

                document.querySelector(".cont_confirm_payment_order").innerHTML = templatePayment;
            };
            reader.readAsDataURL(file);
        });

        document.querySelector(".cont_confirm_product_order").innerHTML = templateProductPrepared;
        document.querySelector(".cont_confirm_product_order").innerHTML += templateProductProcess;
    }
    attachValidationListeners(1)
    //enviar orden
    let btnSendOrder = document.querySelector(".confirm_order");
    if (!btnSendOrder.dataset.listenerAttached) {
        btnSendOrder.addEventListener("click", async () => {
            const { productPreparedData, productProcessData, clientData, dataPayment, directionSale, amountTotal } = finalData()
            let id_caja = await CheckCash()
            if (directionSale == "") {
                toas("error", "Ingrese una direccion de entrega")
            } else if (id_caja == null) {
                console.error(id_caja);
                toas("error", "No hay cajas abiertas")
            } else {
                Swal.fire({
                    title: 'Procesando...',
                    text: 'Por favor espera',
                    allowOutsideClick: false,
                    didOpen: () => { Swal.showLoading() }
                });
                bootstrap.Modal.getOrCreateInstance('#domicile_and_takeaway').hide()
                let DataTelClient = new FormData();
                DataTelClient.append("id", clientData.id_cliente);
                DataTelClient.append("telefono", clientData.telefonoClient);
                let updateTelClient = await fetch("clientes/update", { method: "POST", body: DataTelClient })
                let responseTelClient = await updateTelClient.json()
                console.log(responseTelClient);
                let order = new FormData();
                let nro_orden = Math.floor(Math.random() * (99999999 - 10000000 + 1)) + 10000000
                order.append("id_cliente", clientData.id_cliente);
                order.append("tipo", window.type_order)
                order.append("nro_orden", nro_orden)
                order.append("status", "en cocina")
                let index = 0;
                productPreparedData.forEach((product) => {
                    let additionalText = product.adicionales.map((index) => index.nombre).join(",");
                    order.append(`lista_detalle_preparado[${index}][id_producto]`, product.id_producto);
                    order.append(`lista_detalle_preparado[${index}][cantidad]`, product.cantidad);
                    order.append(`lista_detalle_preparado[${index}][adicionales]`, additionalText);
                    order.append(`lista_detalle_preparado[${index}][descripcion]`, product.detalles);
                    index++
                })
                productProcessData.forEach((product, i) => {
                    order.append(`lista_detalle_procesado[${i}][id_producto]`, product.id_producto);
                    order.append(`lista_detalle_procesado[${i}][cantidad]`, product.cantidad);
                })
                let groupedAdicionales = {};
                productPreparedData.forEach((product) => {
                    product.adicionales.forEach((aditional) => {
                        const key = aditional.id_producto;
                        if (!groupedAdicionales[key]) groupedAdicionales[key] = { ...aditional };
                        else groupedAdicionales[key].cantidad += aditional.cantidad;
                    });
                });
                let result = Object.values(groupedAdicionales);
                result.forEach((aditional) => {
                    order.append(`lista_detalle_preparado[${index}][id_producto]`, aditional.id_producto);
                    order.append(`lista_detalle_preparado[${index}][cantidad]`, aditional.cantidad);
                    index++
                })
                let resOrder = myfecth("orden/add", {}, order).json();
                // let petOrder = await fetch("orden/add", { method: "POST", body: order })
                // let resOrder = await petOrder.json()
                console.log(resOrder);
                if (resOrder.success == true) {
                    let id_orden = resOrder.last_id
                    window.id_orden_invoice = id_orden
                    let resSale = myfecth("venta/add", {}, {id_orden: id_orden, id_caja: await CheckCash(), monto_final: amountTotal.total_dolares, direccion: directionSale}).json()

                    console.log(resSale);
                    let id_venta = resSale.last_id

                    let dolar = await amountDolar()
                    let paymentData = new FormData();
                    dataPayment.forEach((payment, index) => {
                        paymentData.append(`lista[${index}][id_metodo_pago]`, payment.id_metodo_pago)
                        paymentData.append(`lista[${index}][monto]`, payment.cantidad)
                        paymentData.append(`lista[${index}][tasa]`, dolar)
                        paymentData.append(`lista[${index}][referencia]`, payment.referencia)
                        paymentData.append(`lista[${index}][imagen]`, payment.imagen)
                        paymentData.append(`lista[${index}][imagen_name]`, payment.imagen.name)
                    })
                    let petPayment = await fetch("pagos/add_many", { method: "POST", body: paymentData })
                    let resPayment = await petPayment.json()
                    console.log(resPayment);
                    let id_payments = resPayment.lista
                    let dataPaymentDetails = new FormData();

                    id_payments.forEach((payment, index) => {
                        dataPaymentDetails.append(`lista[${index}][id_pago]`, payment)
                        dataPaymentDetails.append(`lista[${index}][id_venta]`, id_venta)
                    })
                    // let resPaymentDetails = myfecth
                    let petPaymentDetails = await fetch("pago_venta/add_many", { method: "POST", body: dataPaymentDetails })
                    let resPaymentDetails = await petPaymentDetails.json()
                    console.log(resPaymentDetails);
                    const paymentInvoice = dataPayment.map(PAY => ({ ...PAY, id_venta: id_venta, metodo_pago: PAY.metodo, monto: PAY.cantidad }));
                    let invoice = await report(productPreparedData, productProcessData, clientData, window.id_orden_invoice, directionSale, amountTotal, "invoice", null, null, paymentInvoice)
                    let invoiceData = new FormData();
                    invoiceData.append("pdf", invoice, "factura.pdf");
                    let send = await fetch("orden/sendInvoice", { method: "POST", body: invoiceData });
                    let dataResInvoice = await send.json();
                    const mensaje = `*FACTURA DE ORDEN* \n\n*${clientData.nameClient}*\n\n${dataResInvoice.url}`;
                    const url = `https://wa.me/${clientData.telefonoClient}?text=${encodeURIComponent(mensaje)}`;
                    if (dataResInvoice.url) {
                        Swal.close();
                        Swal.fire({
                            title: `Exito!`,
                            text: "Se creo la orden de domicilio",
                            icon: "success",
                        });
                        nuevaBitacora('Orden de domicilio', 'Creacion', `Se creo una orden de ${window.type_order}`)
                        resetFormModal()
                        targetUpdate()
                        notification({
                            id_usuario: session.message.id,
                            titulo: `Nueva orden para preparar`,
                            mensaje: `Se ha creado una nueva orden para preparar con el nro ${window.id_orden_invoice.toString().padStart(4, '0')}`,
                        })
                        notificationAlert({
                            channel: "Kitchen",
                            message: `Se ha creado una nueva orden para preparar con el nro ${window.id_orden_invoice.toString().padStart(4, '0')}`,
                            event: "orden de cocina"
                        })
                        notificationAlert({
                            channel: "General",
                            message: `Se ha creado una nueva orden para preparar con el nro ${id_orden.toString().padStart(4, '0')}`,
                            event: "notificaciones"
                        })
                        table_reload()
                        window.open(url, '_blank');
                    } else {
                        Swal.fire({
                            title: `Error!`,
                            text: "Hubo un error al crear la orden",
                            icon: "error",
                        });
                    }
                } else {
                    Swal.close();
                    const error = resOrder.message
                    const product = []
                    if (error.detalle_preparado) {
                        error.detalle_preparado.forEach((item) => {
                            if (!product.includes(item.producto)) product.push(item.producto)
                        });
                    }

                    if (error.detalle_procesado) {
                        error.detalle_procesado.forEach((item) => {
                            if (!product.includes(item.producto)) product.push(item.producto)
                        });
                    }
                    let title
                    if (product.includes("No hay una receta asignada")) {
                        title = `
                                <p>Actualmente, algunos productos no cuentan con una <strong class="text-danger">receta asignada</strong></p>
                                <p class="mt-2 fst-italic text-secondary">Por favor, revise las recetas registradas.</p>
                        `
                    } else if (product.includes("No hay existencia en inventario")) {
                        title = `
                         <p>No se encontro existencia en inventario para algunos productos</p>
                        <p class="mt-2 fst-italic text-secondary">Por favor, revise el inventario y las recetas.</p>
                        `
                    } else {
                        title = `
                                <p>Los siguientes productos no tienen <strong class="text-danger">stock suficiente</strong>:</p>
                                <p>
                                    ${product.map(p => `<span class="badge bg-danger me-1">${p}</span>`).join('')}
                                </p>
                                <p class="mt-2 fst-italic text-secondary">Por favor, revise el inventario.</p>
                                `
                    }

                    Swal.fire({
                        title: `Error!`,
                        html: title,
                        icon: "error",
                    });

                    //   <p>Los siguientes productos no tienen <strong class="text-danger">stock suficiente</strong>:</p>
                    //         <ul class="list-group text-start">
                    //             ${product.map(p => `<li class="list-group-item list-group-item-danger">${p}</li>`).join('')}
                    //         </ul>
                    //         <p class="mt-2 fst-italic text-secondary">Por favor, revise los niveles de stock.</p>

                }

            }
        })
        btnSendOrder.dataset.listenerAttached = "true";
    }
}