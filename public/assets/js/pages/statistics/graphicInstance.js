import { printPDF } from "./graphicPDF.js"
import { myfecth } from "../../Functions2.js"

const getNumeroSemana = (fecha) => {
    const inicioAño = new Date(fecha.getFullYear(), 0, 1);
    const diasTranscurridos = Math.floor((fecha - inicioAño) / (24 * 60 * 60 * 1000));
    const numeroSemana = Math.ceil((diasTranscurridos + inicioAño.getDay() + 1) / 7);
    return numeroSemana;
};
const searchProcedure = async (anio = new Date().getFullYear(), semana = getNumeroSemana(new Date()), mes = new Date().getMonth() + 1, statistics = "GastoClienteSemana") => {
    let data = new FormData();
    data.append("anio", anio)
    data.append("semana", semana)
    data.append("mes", mes)
    let response = myfecth(`estadisticas/${statistics}`, {}, data).json()
    return response
}
const leyendGrapic1 = async (max, maxLabel, min, minLabel, promedio, moda) => {
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-4">
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Mejor rendimiento</span>
            <span class="fs-6">${maxLabel} con ${max.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Peor rendimiento</span>
            <span class="fs-6 mesMin">${minLabel} con ${min.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Promedio</span>
            <span class="fs-6 promedio">${promedio.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Gasto recuerrente</span>
            <span class="fs-6 promedio">${moda}$</span>
        </div>
    </div>
`
    document.querySelector(".container-leyend_gasto_cliente").innerHTML = template
}
const leyendGrapic2 = async (array) => {
    let color = ["#FF4B00", "#FFB200", "#b41a1a"]
    let template3 = ``
    let template2 = ``
    let total = array.reduce((total, item) => total + item.total_ordenes, 0);
    template3 += `
        <div>
            <i class="fas fa-circle font-10 me-1" style="color: #0B1B21"></i>
            <span class="text-muted me-1 fs-6">ORDENES TOTALES</span>
            <span class="fs-6">${total}</span>
        </div>
    `
    array.forEach((item, index) => {
        template2 += `
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: ${color[index]}"></i>
            <span class="text-muted me-1 fs-6">${item.tipo_orden.toUpperCase()}</span>
            <span class="fs-6">${item.total_recaudado}$</span>
        </div>
        `
    })
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-3">
        ${template2}
        ${template3}
    </div>
`
    document.querySelector(".container_leyend_total_ventas").innerHTML = template
}
const leyendGrapic3 = async (max, maxLabel, min, minLabel, promedio, total_res) => {
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-4">
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Mejor rendimiento</span>
            <span class="fs-6">${maxLabel} con ${max.toFixed(2)} % de reservaciones</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Peor rendimiento</span>
            <span class="fs-6 mesMin">${minLabel} con ${min.toFixed(2)} % de reservaciones</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Promedio</span>
            <span class="fs-6 promedio">${promedio.toFixed(2)} % reservaciones</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Total de reservaciones</span>
            <span class="fs-6 promedio">${total_res}</span>
        </div>
    </div>
`
    document.querySelector(".container_leyend_porcentaje_reservas").innerHTML = template
}
const leyendGrapic4 = async (array) => {
    let color = ['#FF4B00', '#FFB200', "#b41a1a"]
    let template3 = ``
    let template2 = ``
    let total = array.reduce((total, item) => total + parseInt(item.cantidad_reservas), 0);
    template3 += `
        <div>
            <i class="fas fa-circle font-10 me-1" style="color: #0B1B21"></i>
            <span class="text-muted me-1 fs-6">RESERVAS TOTALES</span>
            <span class="fs-6">${total} RESERVAS</span>
        </div>
    `
    array.forEach((item, index) => {
        template2 += `
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: ${color[index]}"></i>
            <span class="text-muted me-1 fs-6">${item.metodo_pedido.toUpperCase()}</span>
            <span class="fs-6">${item.cantidad_reservas} RESERVAS</span>
        </div>
        `
    })
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-3">
        ${template2}
        ${template3}
    </div>
`
    document.querySelector(".container_leyend_reservas_metodo").innerHTML = template
}
const leyendGrapic5 = async (max, maxLabel, min, minLabel, promedio, product, product2) => {
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-3">
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Mejor rendimiento</span>
            <span class="fs-6">${maxLabel} con ${max} unidades vendidas</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Peor rendimiento</span>
            <span class="fs-6 mesMin">${minLabel} con ${min} unidades vendidas</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Promedio de ventas</span>
            <span class="fs-6 promedio">${promedio.toFixed(2)} unidades</span>
        </div>
       <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Producto mas vendido</span>
            <span class="fs-6 promedio">${product}</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Producto menos vendido</span>
            <span class="fs-6 promedio">${product2 == null ? "S/P" : product2}</span>
        </div>
    </div>
`
    document.querySelector(".container-leyend_product_more_sales").innerHTML = template
}
const leyendGrapic6 = async (max, maxLabel, min, minLabel, promedio, product, product2) => {
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-3">
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Mejor rendimiento</span>
            <span class="fs-6">${maxLabel} con ${max} unidades vendidas</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Peor rendimiento</span>
            <span class="fs-6 mesMin">${minLabel} con ${min} unidades vendidas</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Promedio de ventas</span>
            <span class="fs-6 promedio">${promedio.toFixed(2)} unidades</span>
        </div>
       <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Producto menos vendido</span>
            <span class="fs-6 promedio">${product}</span>
        </div>
    </div>
`
    document.querySelector(".container-leyend_product_min_sales").innerHTML = template
}
const leyendGrapic1Dashboard = async (max, maxLabel, min, minLabel, promedio, moda) => {
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-4">
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Mejor rendimiento</span>
            <span class="fs-6">${maxLabel} con ${max.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Peor rendimiento</span>
            <span class="fs-6 mesMin">${minLabel} con ${min.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Promedio</span>
            <span class="fs-6 promedio">${promedio.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Utilidad mas frecuente</span>
            <span class="fs-6 promedio">${moda}$</span>
        </div>
    </div>
`
    document.querySelector(".container-leyend_utilidad").innerHTML = template
}
const leyendGrapic2Dashboard = async (max, maxLabel, min, minLabel, promedio, moda) => {
    let template = `
    <div class="d-flex align-items-center flex-wrap gap-4 mt-4">
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Mejor rendimiento</span>
            <span class="fs-6">${maxLabel} con ${max.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Peor rendimiento</span>
            <span class="fs-6 mesMin">${minLabel} con ${min.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Promedio</span>
            <span class="fs-6 promedio">${promedio.toFixed(2)}$</span>
        </div>
        <div>
            <i class="fas fa-circle font-10 me-2" style="color: #FF4B00"></i>
            <span class="text-muted me-1 fs-6">Ingresos frecuentes</span>
            <span class="fs-6 promedio">${moda}$</span>
        </div>
    </div>
`
    document.querySelector(".container-leyend_ingresos").innerHTML = template
}
export default function graphicInstance() {
    let graphic1ChartInstance = null
    let graphic2ChartInstance = null
    let graphic3ChartInstance = null
    let graphic4ChartInstance = null
    let graphic5ChartInstance = null
    let graphic6ChartInstance = null
    let graphicDashboard1ChartInstance = null
    let graphicDashboard2ChartInstance = null

    async function graphic1(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        const ticketData = [];
        let res = await searchProcedure(anio, semana, mes, statistics)
        if (statistics == "GastoClienteSemana") {
            for (const element of res) {
                ticketLabels.push(element.dia);
                ticketData.push(element.total_dia);
            }
        } else if (statistics == "gastoClienteMes") {
            for (const element of res) {
                ticketLabels.push(element.semana);
                ticketData.push(element.total_semana);
            }
        } else {
            for (const element of res) {
                ticketLabels.push(element.mes);
                ticketData.push(element.total_mes);
            }
        }
        const promedio = ticketData.reduce((sum, val) => sum + val, 0) / ticketData.length;
        const frecuencia = {};
        ticketData.forEach(val => { frecuencia[val] = (frecuencia[val] || 0) + 1; });
        const maxFrecuencia = Math.max(...Object.values(frecuencia));
        const moda = Object.keys(frecuencia).filter(val => frecuencia[val] === maxFrecuencia).map(Number);
        const varianza = ticketData.reduce((acc, val) => acc + Math.pow(val - promedio, 2), 0) / ticketData.length;
        const desviacionEstandar = Math.sqrt(varianza);
        const max = Math.max(...ticketData);
        const min = Math.min(...ticketData);
        const maxLabels = ticketLabels.filter((_, i) => ticketData[i] === max);
        const minLabels = ticketLabels.filter((_, i) => ticketData[i] === min);
        leyendGrapic1(
            max,
            maxLabels.join(', '),
            min,
            minLabels.join(', '),
            promedio,
            moda
        );
        const datasetConfig = {
            label: 'Ticket Promedio ($)',
            data: ticketData,
            fill: false,
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 4,
            borderColor: 'rgb(255, 75, 0)',
            backgroundColor: 'rgb(255, 75, 0)'
        };

        const lineaPromedio = {
            label: 'Promedio',
            data: ticketLabels.map(() => promedio),
            borderWidth: 1,
            borderDash: [5, 5],
            borderColor: 'rgb(255, 178, 0)',
            pointRadius: 0,
            fill: true,
            datalabels: {
                display: (ctx) => ctx.dataIndex === ctx.chart.data.labels.length - 1,
                align: 'top',
                anchor: 'end',
                color: 'rgb(255, 178, 0)',
                font: { weight: 'bold', size: 12 },
                formatter: (value, ctx) => {
                    const dataset = ctx.chart.data.datasets[0].data;
                    const promedioActual = dataset.reduce((a, b) => a + b, 0) / dataset.length;
                    return `Promedio: $${promedioActual.toFixed(2)}`;
                }
            }
        };
        const optionsConfig = {
            plugins: {
                title: { display: false },
                tooltip: { enabled: true },
                legend: { display: false },
                datalabels: {
                    display: true,
                    anchor: 'end',
                    align: 'top',
                    color: 'rgba(255, 75, 0)',
                    formatter: value => `$${value}`,
                    font: { weight: 'bold', size: 12, }
                },
            },
            scales: {
                x: { grid: { display: false, }, title: { display: false, } },
                y: { beginAtZero: false, title: { display: false, } },
            },
            legend: { display: false },
            
        };
        const ctx = document.getElementById('ticketChart').getContext('2d');
        if (graphic1ChartInstance) {
            graphic1ChartInstance.data.labels = ticketLabels;
            graphic1ChartInstance.data.datasets[0].data = ticketData;
            graphic1ChartInstance.data.datasets[1].data = ticketLabels.map(() => promedio);
            graphic1ChartInstance.update();
        } else {
            graphic1ChartInstance = new Chart(ctx, {
                type: 'line',
                data: { labels: ticketLabels, datasets: [datasetConfig, lineaPromedio] },
                options: optionsConfig
            });
        }
        pdf()
        window.currentGraphic1Data = {
            gasto_max: max,
            gasto_max_labels: maxLabels.join(', '),
            gasto_min: min,
            gasto_min_labels: minLabels.join(', '),
            promedio: promedio,
            moda: moda
        };

    }
    async function graphic2(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        const ticketData = [];
        let pet = await searchProcedure(anio, semana, mes, statistics)
        pet.forEach(pet => {
            ticketLabels.push(pet.tipo_orden);
            ticketData.push(pet.total_recaudado);
        })
        leyendGrapic2(pet)
        const centerTextPlugin = {
            id: 'centerTextPlugin',
            beforeDraw(chart) {
                const { ctx, chartArea: { width, height, left, right, top, bottom } } = chart;
                ctx.save();
                ctx.font = 'bold 20px Arial';
                ctx.fillStyle = '#999';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                const centerX = (left + right) / 2;
                const centerY = (top + bottom) / 2;
                ctx.fillText('Ventas', centerX, centerY);
                ctx.restore();
            }
        };

        const ctx = document.getElementById('myDonutChart').getContext('2d');

        const data = {
            labels: ticketLabels,
            datasets: [{
                label: 'Ventas',
                data: ticketData,
                backgroundColor: ['#FF4B00', '#FFB200', "#b41a1a"],
                borderWidth: 2,
                borderColor: '#fff',
                cutout: '60%',
            }]
        };

        const config = {
            type: 'doughnut',
            data: data,
            options: {
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${label}: $${value} (${percentage}%)`;
                            }
                        }
                    },
                    datalabels: {
                        color: '#fff',
                        font: { weight: 'bold', size: 16 },
                        formatter: function (value) {
                            const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                            return (value / total * 100).toFixed(1) + '%';
                        }
                    }
                },
                cutout: '70%',
            },
            plugins: [ChartDataLabels, centerTextPlugin],
        };
        if (graphic2ChartInstance) {
            graphic2ChartInstance.data.labels = ticketLabels;
            graphic2ChartInstance.data.datasets[0].data = ticketData;
            graphic2ChartInstance.update();
        } else {
            graphic2ChartInstance = new Chart(ctx, config);
        }

        pdf()
        window.currentGraphic2Data = pet;
    }
    async function graphic3(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        const ticketData = [];
        let res = await searchProcedure(anio, semana, mes, statistics)
        for (const element of res) {
            ticketLabels.push(element.hora);
            ticketData.push(element.porcentaje);
        }

        const ctx = document.getElementById('ocupacionChart').getContext('2d');

        const data = {
            label: 'Tasa de ocupación (%)',
            data: ticketData,
            backgroundColor: '#FF4B00',
            borderColor: '#FF4B00',
            borderWidth: 1,
            barPercentage: 0.9,
            categoryPercentage: 0.8,
            barThickness: 50
        };

        const config = {
            layout: { padding: { top: 25, right: 50, bottom: 5, left: 0 } },
            scales: {
                y: {
                    beginAtZero: true,
                    max: 100,
                    ticks: {
                        callback: function (value) { return value + '%'; }
                    },
                    title: {
                        display: false,
                        text: 'Porcentaje de ocupación'
                    }
                },
                x: {
                    title: {
                        display: false,
                        text: 'Franja horaria'
                    },
                    grid: {
                        display: false
                    }
                }
            },
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: ctx => `Ocupación: ${ctx.parsed.y}%`
                    }
                },
                datalabels: {
                    color: 'white',
                    anchor: 'center',
                    align: 'center',
                    font: {
                        size: 10
                    },
                    formatter: value => `${value}%`
                }
            }
        }
        const promedio = res.reduce((sum, val) => sum + parseFloat(val.cantidad), 0) / res.length;
        const frecuencia = {};
        ticketData.forEach(val => { frecuencia[val] = (frecuencia[val] || 0) + 1; });
        const max = Math.max(...ticketData);
        const min = Math.min(...ticketData);
        const maxLabels = ticketLabels.filter((_, i) => ticketData[i] == max);
        const minLabels = ticketLabels.filter((_, i) => ticketData[i] == min);
        const total_res = res.reduce((sum, val) => sum + parseFloat(val.cantidad), 0);
        leyendGrapic3(
            max,
            maxLabels.join(', '),
            min,
            minLabels.join(', '),
            promedio,
            total_res
        );
        const lineaPromedio = {
            label: 'Promedio',
            type: 'line',
            data: ticketLabels.map(() => promedio),
            borderWidth: 1,
            borderDash: [5, 5],
            borderColor: 'rgb(255, 178, 0)',
            pointRadius: 0,
            fill: true,
            datalabels: {
                display: (ctx) => ctx.dataIndex === ctx.chart.data.labels.length - 1,
                align: 'top',
                anchor: 'end',
                color: 'rgb(255, 178, 0)',
                font: { weight: 'bold', size: 12 },
                formatter: (value, ctx) => {
                    return `Promedio: $${promedio.toFixed(2)}`;
                }
            }
        };
        if (graphic3ChartInstance) {
            graphic3ChartInstance.data.labels = ticketLabels;
            graphic3ChartInstance.data.datasets[0].data = ticketData;
            graphic3ChartInstance.update();
        } else {
            graphic3ChartInstance = new Chart(ctx, {
                type: 'bar',
                data: { labels: ticketLabels, datasets: [data, lineaPromedio] },
                options: config
            });
        }

        pdf()
        window.currentGraphic3Data = {
            gasto_max: max,
            gasto_max_labels: maxLabels.join(', '),
            gasto_min: min,
            gasto_min_labels: minLabels.join(', '),
            promedio: promedio,
            total_res: total_res
        }
    }
    async function graphic4(anio, semana, mes, statistics, pdf) {

        const ticketLabels = [];
        const ticketData = [];
        let res = await searchProcedure(anio, semana, mes, statistics)
        for (const element of res) {
            ticketLabels.push(element.metodo_pedido);
            ticketData.push(element.cantidad_reservas);
        }

        const ctx = document.getElementById('ReservasChart').getContext('2d');

        const data = {
            labels: ticketLabels,
            datasets: [{
                label: 'Tasa de ocupación (%)',
                data: ticketData,
                backgroundColor: ['#FF4B00', '#FFB200', "#b41a1a"],
                borderColor: '#FFB200',
                borderWidth: 1,
                barPercentage: 0.9,
                categoryPercentage: 0.8,
                barThickness: 30
            }]
        };
        leyendGrapic4(res)
        const config = {
            type: 'bar',
            data: data,
            options: {
                indexAxis: 'y',
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        title: {
                            display: false,
                            text: 'Porcentaje de ocupación'
                        }
                    },
                    x: {
                        title: {
                            display: false,
                            text: 'Franja horaria'
                        },
                        grid: {
                            display: false
                        }
                    }
                },
                plugins: {
                    legend: { display: false },
                    datalabels: {
                        color: 'white',
                        anchor: 'center',
                        align: 'center',
                        font: {
                            size: 12
                        },
                        formatter: value => {
                            const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                            return (value / total * 100).toFixed(1) + '%';
                        }
                    }
                }
            }
        }

        if (graphic4ChartInstance) {
            graphic4ChartInstance.data.labels = ticketLabels;
            graphic4ChartInstance.data.datasets[0].data = ticketData;
            graphic4ChartInstance.update();
        } else {
            graphic4ChartInstance = new Chart(ctx, config);
        }

        pdf()
        window.currentGraphic4Data = res;

    }
    async function graphic5(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        let pet = await searchProcedure(anio, semana, mes, statistics);
        let group = {}
        if (statistics == "productosVendidosAnual") {
            pet.forEach(element => {
                if (group[element.nombre_mes]) group[element.nombre_mes].push(element)
                else group[element.nombre_mes] = [element]
            })
        } else if (statistics == "productosVendidosMes") {
            pet.forEach(element => {
                if (group[element.semana_del_anio]) group[element.semana_del_anio].push(element)
                else group[element.semana_del_anio] = [element]
            })
        } else {
            pet.forEach(element => {
                if (group[element.dia]) group[element.dia].push(element)
                else group[element.dia] = [element]
            })
        }
        Object.keys(group).forEach(key => { ticketLabels.push(key) })
        const productosUnicos = [...new Set(Object.values(group).flat().map(p => p.producto))];
        const coloresBase = ["#AA7861", "#0f172a", "#facc15", "#f97316", "#991b1b"];
        const colores = {};
        productosUnicos.forEach((producto, index) => { colores[producto] = coloresBase[index % coloresBase.length]; });
        const datasets = productosUnicos.map(producto => {
            return {
                label: producto,
                data: ticketLabels.map(dia => {
                    const item = group[dia].find(p => p.producto === producto);
                    if (statistics == "productosVendidosAnual") return item ? item.unidades_vendidas : 0;
                    else if (statistics == "productosVendidosMes") return item ? item.unidades_vendidas : 0;
                    else return item ? item.unidades_vendidas : 0;
                }),
                backgroundColor: colores[producto] || "#888",
                datalabels: {
                    anchor: 'end',
                    align: 'top',
                    color: '#000',
                    font: { weight: 'bold' },
                    formatter: value => value > 0 ? value : ''
                }
            };
        });

        const resumenPorDia = Object.entries(group).map(([dia, productos]) => {
            const totalDia = productos.reduce((sum, p) => sum + p.unidades_vendidas, 0);
            const productoTop = productos.reduce((top, p) => p.unidades_vendidas > (top?.unidades_vendidas || 0) ? p : top, 0);
            return { dia, totalDia, productoTop };
        });
        const maxValor = Math.max(...resumenPorDia.map(r => r.totalDia));
        const minValor = Math.min(...resumenPorDia.map(r => r.totalDia));
        const diasMax = resumenPorDia.filter(r => r.totalDia === maxValor);
        const diasMin = resumenPorDia.filter(r => r.totalDia === minValor);
        const promedio = resumenPorDia.reduce((sum, r) => sum + r.totalDia, 0) / resumenPorDia.length;
        const frecuencia = {};
        resumenPorDia.forEach(r => {
            frecuencia[r.totalDia] = (frecuencia[r.totalDia] || 0) + 1;
        });
        const maxFrecuencia = Math.max(...Object.values(frecuencia));
        const moda = Object.keys(frecuencia).filter(val => frecuencia[val] == maxFrecuencia).map(Number);
        const ventasDiarias = resumenPorDia.map(r => r.productoTop.unidades_vendidas || 0);
        leyendGrapic5(
            maxValor,
            diasMax.map(r => r.dia).join(', '),
            minValor,
            diasMin.map(r => r.dia).join(', '),
            promedio,
            diasMax.map(r => r.productoTop.producto).join(', '),
            diasMin.map(r => r.productoTop.producto).join(', ')
        );

        const lineaPromedio = Array(ticketLabels.length).fill(promedio);
        datasets.push(
            {
                label: "Promedio de ventas",
                type: 'line',
                data: lineaPromedio,
                borderColor: 'rgb(255, 75, 0)',
                borderWidth: 1,
                fill: true,
                pointRadius: 0,
                borderDash: [5, 5],
                yAxisID: 'y',
                datalabels: {
                    display: (ctx) => ctx.dataIndex === ctx.chart.data.labels.length - 1,
                    align: 'top',
                    anchor: 'end',
                    color: 'rgb(255, 75, 0)',
                    font: { weight: 'bold', size: 12 },
                    formatter: (value, ctx) => {
                        const dataset = ctx.chart.data.datasets[ctx.datasetIndex].data;
                        const promedioActual = dataset.reduce((a, b) => a + b, 0) / dataset.length;
                        return `Promedio de ventas: ${promedioActual.toFixed(2)}`;
                    }
                }
            },
        );
        const ctx = document.getElementById("productMoreSales").getContext("2d");
        if (graphic5ChartInstance) {
            graphic5ChartInstance.data.labels = ticketLabels;
            graphic5ChartInstance.data.datasets = datasets;
            graphic5ChartInstance.update();
        } else {
            graphic5ChartInstance = new Chart(ctx, {
                type: 'bar',
                data: { labels: ticketLabels, datasets: datasets },
                options: {
                    plugins: {
                        title: { display: false },
                        legend: {
                            position: 'bottom', labels: { usePointStyle: true },
                        },
                        datalabels: { display: true }
                    },
                    responsive: true,
                    scales: {
                        x: { stacked: false },
                        y: { grid: { display: false }, beginAtZero: true, stacked: false }
                    },
                    layout: { padding: { top: 25, right: 80, bottom: 5, left: 0 } }
                },
                plugins: [ChartDataLabels]
            });
        }

        pdf()
        window.currentGraphic5Data = {
            valor_max: maxValor,
            valor_max_label: diasMax.map(r => r.dia).join(', '),
            valor_min: minValor,
            valor_min_label: diasMin.map(r => r.dia).join(', '),
            promedio: promedio,
            dias_max: diasMax.map(r => r.productoTop.producto).join(', '),
            dias_min: diasMin.map(r => r.productoTop.producto).join(', ')
        }
    }
    async function graphic6(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        let pet = await searchProcedure(anio, semana, mes, statistics);
        let group = {}
        if (statistics == "productosMenosVendidosAnual") {
            pet.forEach(element => {
                if (group[element.nombre_mes]) group[element.nombre_mes].push(element)
                else group[element.nombre_mes] = [element]
            })
        } else if (statistics == "productosMenosVendidosMes") {
            pet.forEach(element => {
                if (group[element.semana_del_anio]) group[element.semana_del_anio].push(element)
                else group[element.semana_del_anio] = [element]
            })
        } else {
            pet.forEach(element => {
                if (group[element.dia]) group[element.dia].push(element)
                else group[element.dia] = [element]
            })
        }
        Object.keys(group).forEach(key => { ticketLabels.push(key) });
        const productosUnicos = [...new Set(Object.values(group).flat().map(p => p.producto))];
        const coloresBase = ["#AA7861", "#0f172a", "#facc15", "#f97316", "#991b1b"];
        const colores = {};
        productosUnicos.forEach((producto, index) => { colores[producto] = coloresBase[index % coloresBase.length]; });
        const datasets = productosUnicos.map(producto => {
            return {
                label: producto,
                data: ticketLabels.map(dia => {
                    const item = group[dia].find(p => p.producto === producto);
                    if (statistics == "productosMenosVendidosAnual") return item ? item.unidades_vendidas : 0;
                    else if (statistics == "productosMenosVendidosMes") return item ? item.unidades_vendidas : 0;
                    else return item ? item.unidades_vendidas : 0;
                }),
                backgroundColor: colores[producto] || "#888",
                datalabels: {
                    anchor: 'end',
                    align: 'top',
                    color: '#000',
                    font: { weight: 'bold' },
                    formatter: value => value > 0 ? value : ''
                }
            };
        });

        const resumenPorDia = Object.entries(group).map(([dia, productos]) => {
            const totalDia = productos.reduce((sum, p) => sum + p.unidades_vendidas, 0);
            const productosFiltrados = productos.filter(p => p.unidades_vendidas > 0);
            const productoMenos = productosFiltrados.length > 0
                ? productosFiltrados.reduce((min, p) =>
                    p.unidades_vendidas < (min?.unidades_vendidas || Infinity) ? p : min, null)
                : { producto: ",", unidades_vendidas: 0 };
            return { dia, totalDia, productoMenos };
        });
        const maxValor = Math.max(...resumenPorDia.map(r => r.totalDia));
        const minValor = Math.min(...resumenPorDia.map(r => r.totalDia));
        const diasMax = resumenPorDia.filter(r => r.totalDia === maxValor);
        const diasMin = resumenPorDia.filter(r => r.totalDia === minValor);
        const promedio = resumenPorDia.reduce((sum, r) => sum + r.totalDia, 0) / resumenPorDia.length;
        const frecuencia = {};
        resumenPorDia.forEach(r => {
            frecuencia[r.totalDia] = (frecuencia[r.totalDia] || 0) + 1;
        });
        const maxFrecuencia = Math.max(...Object.values(frecuencia));
        const moda = Object.keys(frecuencia).filter(val => frecuencia[val] == maxFrecuencia).map(Number);
        leyendGrapic6(
            maxValor,
            diasMax.map(r => r.dia).join(', '),
            minValor,
            diasMin.map(r => r.dia).join(', '),
            promedio,
            diasMax.map(r => r.productoMenos.producto).join(', '),
            diasMin.map(r => r.productoMenos.producto).join(', ')
        );

        const lineaPromedio = Array(ticketLabels.length).fill(promedio);
        datasets.push(
            {
                label: "Promedio de ventas",
                type: 'line',
                data: lineaPromedio,
                borderColor: 'rgb(255, 75, 0)',
                borderWidth: 1,
                fill: true,
                pointRadius: 0,
                borderDash: [5, 5],
                yAxisID: 'y',
                datalabels: {
                    display: (ctx) => ctx.dataIndex === ctx.chart.data.labels.length - 1,
                    align: 'top',
                    anchor: 'end',
                    color: 'rgb(255, 75, 0)',
                    font: { weight: 'bold', size: 12 },
                    formatter: (value, ctx) => {
                        const dataset = ctx.chart.data.datasets[ctx.datasetIndex].data;
                        const promedioActual = dataset.reduce((a, b) => a + b, 0) / dataset.length;
                        return `Promedio de ventas: ${promedioActual.toFixed(2)}`;
                    }
                }
            },
        );
        const ctx = document.getElementById("productMinSales").getContext("2d");
        if (graphic6ChartInstance) {
            graphic6ChartInstance.data.labels = ticketLabels;
            graphic6ChartInstance.data.datasets = datasets;
            graphic6ChartInstance.update();
        } else {
            graphic6ChartInstance = new Chart(ctx, {
                type: 'bar',
                data: { labels: ticketLabels, datasets: datasets },
                options: {
                    plugins: {
                        title: { display: false },
                        legend: {
                            position: 'bottom', labels: { usePointStyle: true },
                        },
                        datalabels: { display: true }
                    },
                    responsive: true,
                    scales: {
                        x: { stacked: false },
                        y: { grid: { display: false }, beginAtZero: true, stacked: false }
                    },
                    layout: { padding: { top: 25, right: 80, bottom: 5, left: 0 } }
                },
                plugins: [ChartDataLabels]
            });
        }

        pdf()
        window.currentGraphic6Data = {
            valor_max: maxValor,
            valor_max_label: diasMax.map(r => r.dia).join(', '),
            valor_min: minValor,
            valor_min_label: diasMin.map(r => r.dia).join(', '),
            promedio: promedio,
            dias_max: diasMax.map(r => r.productoMenos.producto).join(', '),
            dias_min: diasMin.map(r => r.productoMenos.producto).join(', ')
        }
    }
    async function graphicDashboard1(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        const ticketData = [];
        let res = await searchProcedure(anio, semana, mes, statistics)
        if (statistics == "utilidadNetaSemana") {
            for (const element of res) {
                ticketLabels.push(element.dia);
                ticketData.push(element.utilidad_neta);
            }
        } else if (statistics == "utilidadNetaMes") {
            for (const element of res) {
                ticketLabels.push(element.semana);
                ticketData.push(element.utilidad_neta);
            }
        } else {
            for (const element of res) {
                ticketLabels.push(element.mes);
                ticketData.push(element.utilidad_neta);
            }
        }
        const promedio = ticketData.reduce((sum, val) => sum + val, 0) / ticketData.length;
        const frecuencia = {};
        ticketData.forEach(val => { frecuencia[val] = (frecuencia[val] || 0) + 1; });
        const maxFrecuencia = Math.max(...Object.values(frecuencia));
        const moda = Object.keys(frecuencia).filter(val => frecuencia[val] === maxFrecuencia).map(Number);
        const varianza = ticketData.reduce((acc, val) => acc + Math.pow(val - promedio, 2), 0) / ticketData.length;
        const desviacionEstandar = Math.sqrt(varianza);
        const max = Math.max(...ticketData);
        const min = Math.min(...ticketData);
        const maxLabels = ticketLabels.filter((_, i) => ticketData[i] === max);
        const minLabels = ticketLabels.filter((_, i) => ticketData[i] === min);

        leyendGrapic1Dashboard(
            max,
            maxLabels.join(', '),
            min,
            minLabels.join(', '),
            promedio,
            moda
        );

        const datasetConfig = {
            label: 'Utilidad ($)',
            data: ticketData,
            fill: false,
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 4,
            borderColor: 'rgb(255, 75, 0)',
            backgroundColor: 'rgb(255, 75, 0)'
        };

        const lineaPromedio = {
            label: 'Promedio',
            data: ticketLabels.map(() => promedio),
            borderWidth: 1,
            borderDash: [5, 5],
            borderColor: 'rgb(255, 178, 0)',
            pointRadius: 0,
            fill: true,
            datalabels: {
                display: (ctx) => ctx.dataIndex === ctx.chart.data.labels.length - 1,
                align: 'top',
                anchor: 'end',
                color: 'rgb(255, 178, 0)',
                font: { weight: 'bold', size: 12 },
                formatter: (value, ctx) => {
                    const dataset = ctx.chart.data.datasets[0].data;
                    const promedioActual = dataset.reduce((a, b) => a + b, 0) / dataset.length;
                    return `Promedio: $${promedioActual.toFixed(2)}`;
                }
            }
        };
        const optionsConfig = {
            plugins: {
                title: { display: false },
                tooltip: { enabled: true },
                legend: { display: false },
                datalabels: {
                    display: true,
                    anchor: 'end',
                    align: 'top',
                    color: 'rgba(255, 75, 0)',
                    formatter: value => `$${value}`,
                    font: { weight: 'bold', size: 12, }
                },
            },
            scales: {
                x: { grid: { display: false, }, title: { display: false, } },
                y: { beginAtZero: false, title: { display: false, } },
            },
            legend: { display: false },
            layout: { padding: { top: 25, right: 50, bottom: 5, left: 0 } }
        };
        const ctx = document.getElementById('utilityChart').getContext('2d');
        if (graphicDashboard1ChartInstance) {
            graphicDashboard1ChartInstance.data.labels = ticketLabels;
            graphicDashboard1ChartInstance.data.datasets[0].data = ticketData;
            graphicDashboard1ChartInstance.data.datasets[1].data = ticketLabels.map(() => promedio);
            graphicDashboard1ChartInstance.update();
        } else {
            graphicDashboard1ChartInstance = new Chart(ctx, {
                type: 'line',
                data: { labels: ticketLabels, datasets: [datasetConfig, lineaPromedio] },
                options: optionsConfig
            });
        }

        pdf()
        window.currentGraphic1DashboardData = {
            max: max,
            max_labels: maxLabels.join(', '),
            min: min,
            min_labels: minLabels.join(', '),
            promedio,
            moda
        }
    }
    async function graphicDashboard2(anio, semana, mes, statistics, pdf) {
        const ticketLabels = [];
        const ticketData = [];
        let res = await searchProcedure(anio, semana, mes, statistics)
        if (statistics == "utilidadNetaSemana") {
            for (const element of res) {
                ticketLabels.push(element.dia);
                ticketData.push(element.ingresos || 0);
            }
        } else if (statistics == "utilidadNetaMes") {
            for (const element of res) {
                ticketLabels.push(element.semana);
                ticketData.push(element.ingresos || 0);
            }
        } else {
            for (const element of res) {
                ticketLabels.push(element.mes);
                ticketData.push(element.ingresos || 0);
            }
        }
        const promedio = ticketData.reduce((sum, val) => sum + val, 0) / ticketData.length;
        const frecuencia = {};
        ticketData.forEach(val => { frecuencia[val] = (frecuencia[val] || 0) + 1; });
        const maxFrecuencia = Math.max(...Object.values(frecuencia));
        const moda = Object.keys(frecuencia).filter(val => frecuencia[val] === maxFrecuencia).map(Number);
        const varianza = ticketData.reduce((acc, val) => acc + Math.pow(val - promedio, 2), 0) / ticketData.length;
        const desviacionEstandar = Math.sqrt(varianza);
        const max = Math.max(...ticketData);
        const min = Math.min(...ticketData);
        const maxLabels = ticketLabels.filter((_, i) => ticketData[i] === max);
        const minLabels = ticketLabels.filter((_, i) => ticketData[i] === min);

        leyendGrapic2Dashboard(
            max,
            maxLabels.join(', '),
            min,
            minLabels.join(', '),
            promedio,
            moda
        );

        const datasetConfig = {
            label: 'Utilidad ($)',
            data: ticketData,
            fill: false,
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 4,
            borderColor: 'rgb(255, 75, 0)',
            backgroundColor: 'rgb(255, 75, 0)'
        };
        const lineaPromedio = {
            label: 'Promedio',
            data: ticketLabels.map(() => promedio),
            borderWidth: 1,
            borderDash: [5, 5],
            borderColor: 'rgb(255, 178, 0)',
            pointRadius: 0,
            fill: true,
            datalabels: {
                display: (ctx) => ctx.dataIndex === ctx.chart.data.labels.length - 1,
                align: 'top',
                anchor: 'end',
                color: 'rgb(255, 178, 0)',
                font: { weight: 'bold', size: 12 },
                formatter: (value, ctx) => {
                    const dataset = ctx.chart.data.datasets[0].data;
                    const promedioActual = dataset.reduce((a, b) => a + b, 0) / dataset.length;
                    return `Promedio: $${promedioActual.toFixed(2)}`;
                }
            }
        };
        const optionsConfig = {
            plugins: {
                title: { display: false },
                tooltip: { enabled: true },
                legend: { display: false },
                datalabels: {
                    display: true,
                    anchor: 'end',
                    align: 'top',
                    color: 'rgba(255, 75, 0)',
                    formatter: value => `$${value}`,
                    font: { weight: 'bold', size: 12, }
                },
            },
            scales: {
                x: { grid: { display: false, }, title: { display: false, } },
                y: { beginAtZero: false, title: { display: false, } },
            },
            legend: { display: false },
            layout: { padding: { top: 25, right: 50, bottom: 5, left: 0 } }
        };
        const ctx = document.getElementById('ingresosChart').getContext('2d');
        if (graphicDashboard2ChartInstance) {
            graphicDashboard2ChartInstance.data.labels = ticketLabels;
            graphicDashboard2ChartInstance.data.datasets[0].data = ticketData;
            graphicDashboard2ChartInstance.data.datasets[1].data = ticketLabels.map(() => promedio);
            graphicDashboard2ChartInstance.update();
        } else {
            graphicDashboard2ChartInstance = new Chart(ctx, {
                type: 'line',
                data: { labels: ticketLabels, datasets: [datasetConfig, lineaPromedio] },
                options: optionsConfig
            });
        }

        pdf()
        window.currentGraphic2DashboardData = {
            max: max,
            max_labels: maxLabels.join(', '),
            min: min,
            min_labels: minLabels.join(', '),
            promedio,
            moda
        }
    }
    function instance() {
        graphic1(new Date().getFullYear(), getNumeroSemana(new Date()), new Date().getMonth() + 1, "GastoClienteSemana", () => printPDF())
        graphic2(new Date().getFullYear(), getNumeroSemana(new Date()), new Date().getMonth() + 1, "totalVentaAnio", () => printPDF())
        graphic3(new Date().getFullYear(), getNumeroSemana(new Date()), new Date().getMonth() + 1, "ReservaHorarioAnio", () => printPDF())
        graphic4(new Date().getFullYear(), getNumeroSemana(new Date()), new Date().getMonth() + 1, "ReservasPorMetodoAnio", () => printPDF());
        graphic5(new Date().getFullYear(), getNumeroSemana(new Date()), new Date().getMonth() + 1, "productosVendidosAnual", () => printPDF())
        graphic6(new Date().getFullYear(), getNumeroSemana(new Date()), new Date().getMonth() + 1, "productosMenosVendidosAnual", () => printPDF())
    }
    return { instance, graphic1, graphic2, graphic3, graphic4, graphic5, graphic6, graphicDashboard1, graphicDashboard2 };
}