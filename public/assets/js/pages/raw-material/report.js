import { Poppins_normal } from "../../../libs/libs/jspdf/poppins.js"
import { poppins_bold } from "../../../libs/libs/jspdf/poppins_bold.js"
import { myfecth } from "../../Functions2.js"
const { jsPDF } = window.jspdf;
const info = () => {
    let response = myfecth(`entrada_materia_prima/inventario`).json();
    return response
}
const doc = new jsPDF();
let btn = document.getElementById("btn-report");
btn.addEventListener("click", async () => {
    let result = await info();
    let valor_total = []
    const columns = ["Materia Prima", "Entradas", "Salidas", "Valor de stock", "Stock actual"];
    const rows = [];
    result.forEach(element => {
        valor_total.push(parseFloat(element.valor_stock))
        rows.push([
            element.materia_prima,
            element.entradas + " " + element.unidad,
            element.salidas + " " + element.unidad,
            element.valor_stock + " USD",
            element.stock_actual + " " + element.unidad
        ]);
    });
    doc.addFileToVFS("Poppins-Regular.ttf", Poppins_normal);
    doc.addFont("Poppins-Regular.ttf", "Poppins", "normal");
    doc.addFileToVFS("Poppins-Bold.ttf", poppins_bold);
    doc.addFont("Poppins-Bold.ttf", "Poppins", "bold");
    doc.setFont("Poppins", "bold");
    doc.setTextColor(41, 40, 37)
    doc.addImage("./assets/img/reportes_banners/reporte_inventario_mp.webp", 'WEBP', 0, 0, 210, 297);
    doc.setFontSize(12);
    doc.text(`FECHA: ${new Date().toLocaleDateString()}`, 165, 37);
    doc.text(`VALOR TOTAL DE INVENTARIO: ${(valor_total.reduce((a, b) => a + b, 0)).toFixed(2)} $`, 15, 80);
    doc.internal.events.subscribe('addPage', () => {
        doc.addImage("./assets/img/reportes_banners/reporte_inventario_mp.webp", 'WEBP', 0, 0, 210, 297);
        doc.text(`FECHA: ${new Date().toLocaleDateString()}`, 165, 37);
    });
    doc.setFont("Poppins", "normal");
    const rowsPerPage = 20;
    const totalPages = Math.ceil(rows.length / rowsPerPage);
    for (let pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        if (pageIndex > 0) doc.addPage();
        const start = pageIndex * rowsPerPage;
        const end = start + rowsPerPage;
        const chunk = rows.slice(start, end);
        const isFirstPage = (pageIndex === 0);
        const marginTop = isFirstPage ? 85 : 85;
        const margin = {
            top: marginTop,
            left: 15,
            right: 15,
            bottom: 20
        };
        doc.autoTable({
            head: [columns],
            body: chunk,
            startY: margin.top,
            headStyles: {
                fillColor: [255, 75, 0],
                textColor: 255,
            },
            margin,
            theme: 'striped',
            showHead: 'everyPage',
            pageBreak: 'auto'
        });
    }
    // doc.save('reporte_cinven.pdf');
    window.open(doc.output('bloburl'), '_blank');
});