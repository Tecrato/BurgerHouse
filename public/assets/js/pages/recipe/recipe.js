import functionGeneral from "../../Functions.js";
import { nuevaBitacora, myfecth } from "../../Functions2.js"
import Templates from "../../templates.js";
import introTooltip from "../../intro-tooltip.js"
import { recipe_detail, recipe_detail_all } from "./report.js"
import { set_validaciones, reglas_validaciones, validate } from "../../Validaciones.js";
// Inicializar validators personalizados
set_validaciones();
const { recipe } = introTooltip()
const { InputPrice, selectOptionAll, setValidationStyles, validateField, reindex, resetForm, edit, searchParam, sessionInfo, binnacle, permission } = functionGeneral();
const { elemenFormRecipe, optionsRol, optionsRawMaterial, targetRecipe, elemenFormEditRecipe } = Templates()
recipe('navbarDropdown')
InputPrice("[input_price]");
permission("Recetas")
selectOptionAll(".select_options_product", "producto_preparado", optionsRol)
selectOptionAll(".select_options_rawmaterial", "materia_prima", optionsRawMaterial)
let session = await sessionInfo()
let RecipeCount = 1;
function addRecipe() {
    RecipeCount++;
    document.getElementById("recipes-container").insertAdjacentHTML('beforeend', elemenFormRecipe(RecipeCount));
    feather.replace();
    selectOptionAll(".select_options_product", "producto_preparado", optionsRol)
    selectOptionAll(".select_options_rawmaterial", "materia_prima", optionsRawMaterial)
    InputPrice("[input_price]");
    attachValidationListeners(RecipeCount);

    const newProduct = document.getElementById(`recipes-${RecipeCount}`);
    newProduct.querySelector(".remove-recipe").addEventListener("click", function () {
        newProduct.remove();
        reindex("#recipes-container .recipes", "recipes", RecipeCount, "Item");
    });
}
function attachValidationListeners(index) {
    const recipeElement = document.getElementById(`recipes-${index}`);
    recipeElement.querySelectorAll("input[type='text'], input[type='button']").forEach(input => {
        input.addEventListener("keyup", (e) => validateField(e, rules));
        input.addEventListener("blur", (e) => validateField(e, rules));
    });
}
document.getElementById("input-product-recipe").addEventListener("change", (e) => validateField(e, rules2));
document.getElementById("add-recipe-btn").addEventListener("click", () => {
    addRecipe()
    reindex("#recipes-container .recipes", "recipes", RecipeCount, "Item")
});
// Las reglas se definen en cada validate() usando reglas_validaciones
const rules = {
    cantidad: reglas_validaciones.cantidad,
    id_rawmaterial: {
        presence: { allowEmpty: false, message: "^es requerido" }
    },
};
const rules2 = {
    cantidad: {
        presence: {
            allowEmpty: false,
            message: "^es requerido"
        },
        cantidad: { message: "^debe ser un número mayor a 0" }
    },
    id_rawmaterial: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateRecipe: { message: "^es requerido" }
    },
    id_producto: {
        presence: {
            allowEmpty: false,
            message: "^es requerida"
        },
        validateRecipe: { message: "^es requerido" }
    },
};
let form = document.getElementById("form-submit-recipes")
if (!form.dataset.listenerAttached) {
    form.addEventListener("submit", function (e) {
        e.preventDefault();
        const recipe = document.querySelectorAll(".recipes");
        let formHasError = false;
        let recetaData = [];
        recipe.forEach((recipe, i) => {
            const index = i + 1;
            const data = {
                cantidad: recipe.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                id_rawmaterial: recipe.querySelector(`input[name="id_rawmaterial"]`).getAttribute("data-id"),
            };
            const errors = validate(data, rules);
            setValidationStyles(`input-quantity-recipe-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
            setValidationStyles(`input-rawmaterial-recipe-${index}`, errors?.id_rawmaterial ? errors.id_rawmaterial[0] : null);
            if (errors) {
                formHasError = true;
            }
            recetaData.push(data)
        });
        const productId = document.getElementById("input-product-recipe").getAttribute("data-id");
        const errorsName = validate({ id_producto: productId }, { id_producto: rules2.id_producto });
        setValidationStyles("input-product-recipe", errorsName?.id_producto ? errorsName.id_producto[0] : null);
        if (errorsName) {
            formHasError = true;
        }
        if (!formHasError) {
            let data = new FormData();
            data.append(`id_producto`, productId);
            recetaData.forEach((item, index) => {
                data.append(`lista[${index}][id_materia_prima]`, item.id_rawmaterial);
                data.append(`lista[${index}][cantidad]`, item.cantidad);
            })
            const add = async () => {
                let res = myfecth('recipe/add', {}, data).json()
                if (res.success == true) {
                    Swal.fire({
                        title: `Exito!`,
                        text: "El elemento fue agregado correctamente",
                        icon: "success",
                    });
                    nuevaBitacora("Recetas", "Agregar", "Se agrego una nueva receta")
                } else {
                    Swal.fire({
                        title: `Error!`,
                        text: "El elemento no fue agregado",
                        icon: "error",
                    });
                }
            }
            add()
            n.ajax.reload();
            bootstrap.Modal.getOrCreateInstance('#register-recipe').hide()
            resetForm("#recipes-container .recipes", form)
            document.getElementById("input-product-recipe").classList.remove("is-invalid", "is-valid");
            document.getElementById("input-product-recipe").value = "Seleccione una opcion";
            document.getElementById("input-product-recipe").setAttribute("data-id", "Seleccione una opcion")
        }
    });
    form.dataset.listenerAttached = "true";
}
attachValidationListeners(1);

let n = $(".table_recipe").DataTable({
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        let totalRaw = myfecth("recetas/count", {}, { active: 1 }, null, 'POST');
        let total = 0;
        try {
            total = JSON.parse(totalRaw);
        } catch (e) {
            total = parseInt(totalRaw) || 0;
        }
        myfecth(
            `recetas/get_all/${page}/${size}/${settings.aoColumns[data.order[0].column].data}/${data.order[0].dir}`,
            {},
            { active: 1 },
            function (resp) {
                resp = resp.json()
                callback({
                    draw: data.draw,
                    data: resp.data || resp || [],
                    recordsTotal: total,
                    recordsFiltered: total
                });
            },
            'POST',
            true,
            function (err) {
                console.error(err);
                callback({ draw: data.draw, data: [], recordsTotal: 0, recordsFiltered: 0 });
            }
        )
    },
    columns: [
        { data: 'nombre_producto' },
        { data: 'tipo' },
        {
            data: null,
            orderable: false,
            render: function (data, type, row, meta) {
                return `
                <div class="dropdown dropstart">
                    <i data-feather="more-horizontal" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer"></i>
                    <ul class="dropdown-menu" data-bs-boundary="viewport">
                        <li><a data-id="${data.id}" module-edit="Detalle_receta"" data-module-edit="Recetas" class="edit_btn dropdown-item" data-bs-title="Editar Receta" data-bs-placement="bottom"><i class="me-1" data-feather="edit"></i>Editar</a></li>
                        <li><a class="details_recipe dropdown-item" data-id="${data.id}" style="cursor: pointer"><i class="me-1" data-feather="eye"></i>Ver detalles</a></li>
                    </ul>
                </div>
                `;
            }
        }
    ],
    drawCallback: function (settings) {
        feather.replace();
        document.querySelectorAll(".trash_btn_datatable, .edit_btn_datatable").forEach((btn) => {
            let tooltip = new bootstrap.Tooltip(btn)
        })
        edit((response) => {
            document.getElementById("input-id-recipe-edit").value = response[0].id_receta;
            let template = "";
            let index = 0;
            document.getElementById("recipe-edit-container").innerHTML = "";
            response.forEach((item, i) => {
                index++;
                template += elemenFormEditRecipe(index, item, "false");
            });
            document.getElementById("recipe-edit-container").innerHTML = template;
            selectOptionAll(".select_options_edit_rawmaterial", "materia_prima", optionsRawMaterial);
            InputPrice("[input_price]");
            feather.replace();
            document.querySelectorAll(".recipe-edit").forEach((item, i) => {
                item.querySelectorAll("input[type='text'], input[type='button']").forEach((input) => {
                    input.addEventListener("keyup", (e) => validateField(e, rules));
                });
                let index = i + 1;
                let data = {
                    cantidad: item.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                    id_rawmaterial: item.querySelector(`input[name="id_rawmaterial"]`).getAttribute("data-id"),
                };
                const errors = validate(data, rules);
                setValidationStyles(`input-edit-quantity-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
                setValidationStyles(`input-edit-rawmaterial-${index}`, errors?.id_rawmaterial ? errors.id_rawmaterial[0] : null);
            });
            if (!document.getElementById("add-recipe-edit-btn").dataset.listenerAttached) {
                document.getElementById("add-recipe-edit-btn").addEventListener("click", async () => {
                    index++;
                    document.getElementById("recipe-edit-container").innerHTML += elemenFormEditRecipe(index, null, "true");
                    feather.replace();
                    selectOptionAll(".select_options_edit_rawmaterial", "materia_prima", optionsRawMaterial);
                    InputPrice("[input_price]");
                    document.querySelectorAll(".recipe-edit").forEach((item, i) => {
                        item.querySelectorAll("input[type='text'], input[type='button']").forEach((input) => {
                            input.addEventListener("keyup", (e) => validateField(e, rules));
                        });
                    });
                    reindex("#recipe-edit-container .recipe-edit", "recipe-edit", index, "Item");
                    deleteItem();
                });
                document.getElementById("add-recipe-edit-btn").dataset.listenerAttached = "true";
            }
            const deleteItem = async () => {
                document.querySelectorAll(".remove-recipe").forEach((item, i) => {
                    item.addEventListener("click", async function () {
                        let conditions = item.getAttribute("isNew");
                        if (conditions == "true") {
                            item.closest(".recipe-edit").remove();
                            reindex("#recipe-edit-container .recipe-edit", "recipe-edit", index, "Item");
                        } else {
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
                                    let id = item.getAttribute("data-id");
                                    let data = new FormData();
                                    data.append(`id`, id);
                                    let petRes = myfecth(`Detalle_receta/delete`, {}, data).json()
                                    if (petRes.success == true) {
                                        item.closest(".recipe-edit").remove();
                                        reindex("#recipe-edit-container .recipe-edit", "recipe-edit", index, "Item");
                                    } else {
                                        Swal.fire({
                                            title: `Error!`,
                                            text: "El elemento no fue eliminado",
                                            icon: "error",
                                        });
                                    }
                                }
                            });


                        }
                    });
                });
            };
            deleteItem();

            let formEdit = document.getElementById("form-submit-edit-recipe");
            if (!formEdit.dataset.listenerAttached) {
                formEdit.addEventListener("submit", async function (e) {
                    e.preventDefault();
                    let formHasError = false;
                    let elementInsert = [];
                    let elementUpdate = [];
                    formEdit.querySelectorAll(".recipe-edit").forEach((recipe, i) => {
                        let conditions = recipe.querySelector("[isNew]").getAttribute("isNew")
                        let index = i + 1;
                        let data = {
                            cantidad: recipe.querySelector(`input[name="cantidad"]`).value.replace(/\./g, '').replace(',', '.'),
                            id_rawmaterial: recipe.querySelector(`input[name="id_rawmaterial"]`).getAttribute("data-id"),
                        };
                        const errors = validate(data, rules);
                        setValidationStyles(`input-edit-quantity-${index}`, errors?.cantidad ? errors.cantidad[0] : null);
                        setValidationStyles(`input-edit-rawmaterial-${index}`, errors?.id_rawmaterial ? errors.id_rawmaterial[0] : null);
                        if (errors) formHasError = true;
                        else {
                            formHasError = false;
                            if (conditions == "true") {
                                let id_receta = document.getElementById("input-id-recipe-edit").value;
                                elementInsert.push({ ...data, id_receta: id_receta });
                            } else {
                                let id = recipe.getAttribute("id_details");
                                elementUpdate.push({ ...data, id: id });
                            }
                        }
                    });
                    if (!formHasError) {
                        let petInsertAlert = null;
                        if (elementInsert.length != 0) {
                            let dataInsert = new FormData();
                            elementInsert.forEach((item, index) => {
                                dataInsert.append(`lista[${index}][cantidad]`, item.cantidad);
                                dataInsert.append(`lista[${index}][id_materia_prima]`, item.id_rawmaterial);
                                dataInsert.append(`lista[${index}][id_receta]`, item.id_receta);
                            });
                            let petResInsert = myfecth(`Detalle_receta/add_many`, {}, dataInsert).json()
                            petInsertAlert = petResInsert
                        }
                        let dataUpdate = new FormData();
                        elementUpdate.forEach((item, index) => {
                            dataUpdate.append(`lista[${index}][cantidad]`, item.cantidad);
                            dataUpdate.append(`lista[${index}][id_materia_prima]`, item.id_rawmaterial);
                            dataUpdate.append(`lista[${index}][id]`, item.id);
                        });
                        let petResUpdate = myfecth(`Detalle_receta/updateMany`, {}, dataUpdate).json()
                        console.log(petResUpdate);

                        if (petResUpdate.success == true) {
                            Swal.fire({
                                title: `Exito!`,
                                text: "El elemento fue actualizado correctamente",
                                icon: "success",
                            })
                            n.ajax.reload();
                            nuevaBitacora("Recetas", "Actualizar", "Se actualizo una receta")
                            bootstrap.Modal.getOrCreateInstance('#edit-recipe').hide()
                        } else {
                            Swal.fire({
                                title: `Error!`,
                                text: "El elemento no fue actualizado",
                                icon: "error",
                            });
                        }
                    }
                });
                formEdit.dataset.listenerAttached = "true";
            }
            bootstrap.Modal.getOrCreateInstance('#edit-recipe').show()
        });
        details_recipe()
        permission("Recetas")
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})
$('#searchRecipe').on('keyup', function () { n.search(this.value).draw() });

const details_recipe = () => {
    document.querySelectorAll(".details_recipe").forEach((item) => {
        if (!item.dataset.listenerAttached) {
            item.addEventListener("click", async () => {
                let id = item.getAttribute("data-id");
                document.querySelector(".btn-print-recipe").setAttribute("data-id", id);
                const data = await searchParam({ id_receta: id }, "Detalle_receta", 10000);
                let template = "";
                data.forEach((item, index) => {
                    template += `
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-body">
                                <div class="d-flex gap-3 align-items-center">
                                    <i data-feather="star"></i>
                                    <h5 class="card-title text-center mb-0">${item.ingrediente}</h5>
                                </div>
                                <p class="card-text mt-3">Cantidad: <strong class="text-uppercase">${item.cantidad} ${item.unidad}</strong></p>
                            </div>
                        </div>
                    </div>
                    `
                })
                document.querySelector("#details-recipe .modal-body .row").innerHTML = template
                feather.replace()
                bootstrap.Modal.getOrCreateInstance('#details-recipe').show()
                print_single_recipe()

            });
            item.dataset.listenerAttached = "true";
        }
    });
}
const print_single_recipe = () => {
    let btn = document.querySelector(".btn-print-recipe")
    if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => {
            let id = document.querySelector(".btn-print-recipe").getAttribute("data-id");
            let data = await searchParam({ id_receta: id }, "Detalle_receta", 10000);
            let nombre_producto = data[0].nombre.toUpperCase()
            recipe_detail(nombre_producto, data)
        })
        btn.dataset.listenerAttached = "true"
    }
}

const print_all_recipe = () => {
    let btn = document.querySelector(".btn_print_all_recipe")
    if (!btn.dataset.listenerAttached) {
        btn.addEventListener("click", async () => {
            let data = await searchParam({}, "Detalle_receta", 10000);
            let group = {}
            data.forEach(item => {
                if (!group[item.nombre]) group[item.nombre] = [{ ingrediente: item.ingrediente, cantidad: item.cantidad, unidad: item.unidad }];
                else group[item.nombre].push({ ingrediente: item.ingrediente, cantidad: item.cantidad, unidad: item.unidad });
            })
            group = Object.keys(group).map((item) => { return { name: item, data: group[item] } })
            recipe_detail_all(group)
        })
        btn.dataset.listenerAttached = "true"
    }
}
print_all_recipe()