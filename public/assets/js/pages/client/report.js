import functionGeneral from "../../Functions.js";
const { searchAll } = functionGeneral()
const { jsPDF } = window.jspdf;

const doc = new jsPDF();

let btn = document.getElementById("btn-report");
btn.addEventListener("click", async () => {
    doc.setFontSize(12);
    doc.setFont('Helvetica')
    doc.setTextColor(41, 40, 37)
    doc.addImage("./assets/img/reportes_banners/reporte_clientes.png", 'PNG', 0, 0, 210, 297);

    doc.text(`FECHA: ${new Date().toLocaleDateString()}`, 165, 37);

    doc.internal.events.subscribe('addPage', () => {
        doc.addImage("./assets/img/reportes_banners/reporte_clientes.png", 'PNG', 0, 0, 210, 297);
        doc.text(`FECHA: ${new Date().toLocaleDateString()}`, 165, 37);

    });
    const columns = ['Nombre', 'Documento', 'Telefono', 'Direccion'];
    const rows = [];
    let result = await searchAll("clientes", 1);
    result.forEach(element => {
        rows.push([element.nombre + " " + element.apellido, element.documento, element.telefono, element.direccion]);
    });

    const rowsPerPage = 20;
    const totalPages = Math.ceil(rows.length / rowsPerPage);


    for (let pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        if (pageIndex > 0) {
            doc.addPage();
        }
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

    doc.save('reporte_clientes.pdf');
});