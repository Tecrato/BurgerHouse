import FunctionGeneral from "../../Functions.js";
import { myfecth } from "../../Functions2.js";
const { fecha, binnacle, sessionInfo } = FunctionGeneral()
const session = await sessionInfo()
let tableActive = $(".table_notifications").DataTable({
    order: [[0, "desc"]],
    language: {
        url: './assets/libs/extra-libs/datatables.net/js/es-Es.json'
    },
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        let totalRaw = myfecth("notification/count", {}, {}, null, 'POST');
        let total = 0;
        try {
            total = JSON.parse(totalRaw);
        } catch (e) {
            total = parseInt(totalRaw) || 0;
        }
        myfecth(
            `notification/get_all/${page}/${size}/${settings.aoColumns[data.order[0].column].data}/${data.order[0].dir}`,
            {},
            {},
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
        {
            data: null, render: function (data, type, row, meta) {
                return `
            <div class="form-check">
                <input class="form-check-input check-table-item" type="checkbox" data-id="${data.id}">
            </div>
            `
            }
        },
        { data: 'id' },
        { data: null, render: function (data, type, row, meta) { return fecha(data.fecha) } },
        { data: 'mensaje' },
        {
            data: null, render: function (data, type, row, meta) {
                return `
            <button class="btn bh_1 btn-circle text-white trash_btn_datatable" data-id="${data.id}">
                <i data-feather="trash" class="svg-icon"></i>
            </button>
            `
            }
        },
    ],
    drawCallback: function (settings) {
        feather.replace();
        document.querySelectorAll(".trash_btn_datatable").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                Swal.fire({
                    title: "¿Deseas eliminar la notificacion?",
                    icon: "warning",
                    showCancelButton: true,
                    confirmButtonText: "Si, estoy seguro",
                    cancelButtonText: "Cancelar",
                    confirmButtonColor: "#FF4B00",
                }).then(async (result) => {
                    if (result.isConfirmed) {
                        Swal.fire({
                            title: 'Procesando...',
                            text: 'Por favor espera',
                            allowOutsideClick: false,
                            didOpen: () => { Swal.showLoading() }
                        });
                        let id = btn.getAttribute("data-id");
                        let data = new FormData()
                        data.append('id', id)
                        let response = myfecth('notification/delete', {}, data).json()
                        if (response.success == true) {
                            Swal.fire({
                                title: "Exito!",
                                text: "El elemento fue eliminado correctamente",
                                icon: "success",
                            })
                            tableActive.ajax.reload()
                            binnacle(session.message, "Notificaciones", "Eliminacion", "Se elimino la notificacion " + id)
                            Swal.close();
                        } else {
                            Swal.fire({
                                title: "Error!",
                                text: "El elemento no fue eliminado",
                                icon: "error",
                            })
                            Swal.close();
                        }
                    }
                });
            })
        })

        document.querySelectorAll(".check-table-item").forEach((btn) => {
            btn.addEventListener("change", async (e) => {
                if (btn.checked == true) document.querySelector(".btn_deleteAll").disabled = false
                else document.querySelector(".btn_deleteAll").disabled = true
                document.querySelector(".btn_deleteAll").addEventListener("click", async (e) => {
                    Swal.fire({
                        title: "¿Deseas eliminar las notificaciones?",
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonText: "Si, estoy seguro",
                        cancelButtonText: "Cancelar",
                        confirmButtonColor: "#FF4B00",
                    }).then(async (result) => {
                        if (result.isConfirmed) {
                            Swal.fire({
                                title: 'Procesando...',
                                text: 'Por favor espera',
                                allowOutsideClick: false,
                                didOpen: () => { Swal.showLoading() }
                            });
                            let data = new FormData()
                            let items = document.querySelectorAll(".check-table-item")
                            items.forEach((item, index) => {
                                if (item.checked) data.append(`lista[${index}][id]`, item.getAttribute("data-id"))
                            })
                            let response = myfecth('notification/delete_many', {}, data).json()
                            if (response.status == "success") {
                                Swal.fire({
                                    title: "Exito!",
                                    text: "Los elementos fueron eleminados correctamente",
                                    icon: "success",
                                })
                                tableActive.ajax.reload()
                                items.forEach((item) => { item.checked = false })
                                document.querySelector(".btn_deleteAll").disabled = true
                                Swal.close();
                                binnacle(session.message, "Notificaciones", "Eliminacion", "Se eliminaron " + items.length + " notificaciones")
                            } else {
                                Swal.fire({
                                    title: "Error!",
                                    text: "Los elementos no fueron eliminados",
                                    icon: "error",
                                })
                                Swal.close();
                            }
                        }
                    });
                })
            })
        })

        document.querySelector(".check_all").addEventListener("change", async (e) => {
            if (e.target.checked == true) {
                document.querySelectorAll(".check-table-item").forEach((item) => { item.checked = true })
                document.querySelector(".btn_deleteAll").disabled = false
                document.querySelector(".btn_deleteAll").addEventListener("click", async (e) => {
                    Swal.fire({
                        title: "¿Deseas eliminar las notificaciones?",
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonText: "Si, estoy seguro",
                        cancelButtonText: "Cancelar",
                        confirmButtonColor: "#FF4B00",
                    }).then(async (result) => {
                        if (result.isConfirmed) {
                            Swal.fire({
                                title: 'Procesando...',
                                text: 'Por favor espera',
                                allowOutsideClick: false,
                                didOpen: () => { Swal.showLoading() }
                            });
                            let data = new FormData()
                            let items = document.querySelectorAll(".check-table-item")
                            items.forEach((item, index) => {
                                if (item.checked) data.append(`lista[${index}][id]`, item.getAttribute("data-id"))
                            })
                            let response = myfecth('notification/check', {}, data).json()
                            if (response.status == "success") {
                                Swal.fire({
                                    title: "Exito!",
                                    text: "Los elementos fueron eleminados correctamente",
                                    icon: "success",
                                })
                                tableActive.ajax.reload()
                                items.forEach((item) => { item.checked = false })
                                document.querySelector(".btn_deleteAll").disabled = true
                                Swal.close();
                                binnacle(session.message, "Notificaciones", "Eliminacion", "Se eliminaron " + items.length + " notificaciones")
                            } else {
                                Swal.fire({
                                    title: "Error!",
                                    text: "Los elementos no fueron eliminados",
                                    icon: "error",
                                })
                                Swal.close();
                            }
                        }
                    });
                })
            } else {
                document.querySelectorAll(".check-table-item").forEach((item) => { item.checked = false })
                document.querySelector(".btn_deleteAll").disabled = true
            }
        })
    },
    "dom": 'tipr',
    "paging": true,
    "info": true,
})

$('#searchNotification').on('keyup', function () { tableActive.search(this.value).draw() });
