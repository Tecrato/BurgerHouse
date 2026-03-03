import functionGeneral from "../../Functions.js";
import {myfecth, nuevaBitacora} from "../../Functions2.js";
import introTooltip from "../../intro-tooltip.js"
const { sessionInfo, binnacle, fecha, hora } = functionGeneral();
const { binnacleIntro } = introTooltip()
binnacleIntro('navbarDropdown')
let session = await sessionInfo();

let table = $('.table_binnacle_user').DataTable({
    language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
    "orden": [[0, "desc"]],
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        // obtener total vía la función síncrona myfecth (devuelve string)
        let totalRaw = myfecth("bitacora/count", {}, { id_usuario: session.message.id }, null, 'POST');
        console.log(totalRaw);
        
        let total = 0;
        try {
            total = JSON.parse(totalRaw);
        } catch (e) {
            total = parseInt(totalRaw) || 0;
        }
        const body = new FormData();
        body.append('id_usuario', session.message.id);
        fetch(`bitacora/get_all/${page}/${size}/id/asc`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: body,
        })
            .then(res => res.json())
            .then(resp => {
                console.log(resp);
                
                const out = {
                    draw: data.draw,
                    data: resp.data || resp || [],
                    recordsTotal: total || resp.total || resp.recordsTotal || (Array.isArray(resp) ? resp.length : 0),
                    recordsFiltered: total || resp.total || resp.recordsFiltered || (Array.isArray(resp) ? resp.length : 0)
                };
                callback(out);
            })
            .catch(err => {
                console.error(err);
                callback({ draw: data.draw, data: [], recordsTotal: total || 0, recordsFiltered: total || 0 });
            });
    },
    columns: [
        { data: "id" },
        { data: 'descripcion' },
        { data: null, render: function (data, type, row) { return fecha(data.fecha) } },
        { data: null, render: function (data, type, row) { return hora(data.fecha) } },
    ],
    "dom": 'tipr',
    "paging": true,
    "info": true,
});

let table2 = $('.table_binnacle_system').DataTable({
    language: { url: './assets/libs/extra-libs/datatables.net/js/es-Es.json' },
    "orden": [[0, "desc"]],
    processing: true,
    serverSide: true,
    pageLength: 10,
    ajax: function (data, callback, settings) {
        let page = Math.floor(data.start / data.length);
        let size = data.length;
        // obtener total para toda la bitacora (sistema)
        let totalRaw = myfecth("bitacora/count", {}, {}, null, 'POST');
        let total = 0;
        try {
            total = JSON.parse(totalRaw);
        } catch (e) {
            total = parseInt(totalRaw) || 0;
        }
        fetch(`bitacora/get_all/${page}/${size}/id/asc`, { method: 'POST' })
            .then(res => res.json())
            .then(resp => {
                const out = {
                    draw: data.draw,
                    data: resp.data || resp || [],
                    recordsTotal: total || resp.total || resp.recordsTotal || (Array.isArray(resp) ? resp.length : 0),
                    recordsFiltered: total || resp.total || resp.recordsFiltered || (Array.isArray(resp) ? resp.length : 0)
                };
                callback(out);
            })
            .catch(err => {
                console.error(err);
                callback({ draw: data.draw, data: [], recordsTotal: total || 0, recordsFiltered: total || 0 });
            });
    },
    columns: [
        { data: "id" },
        { data: null, render: function (data, type, row) { return `<span class="badge text-bg-success badge-pill">${data.nombre_usuario + " " + data.apellido_usuario}</span>` } },
        { data: 'descripcion' },
        { data: null, render: function (data, type, row) { return fecha(data.fecha) } },
        { data: null, render: function (data, type, row) { return hora(data.fecha) } },
    ],
    "dom": 'tipr',
    "paging": true,
    "info": true,
});
$('#searchBinnacleUser').on('keyup', function () {
    table.search(this.value).draw();
});
$('#searchBinnacleSystem').on('keyup', function () {
    table2.search(this.value).draw();
});

const algo = async () => {
    let pet = await fetch(`bitacora/get_all/0/10000000/id/asc`);
    let response = await pet.json()
    console.log(response)
}
// algo()