// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import LiveSocket from "phoenix_live_view"
import jsPDF from 'jspdf';
import 'jspdf-autotable';

import "./socket"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

function generatePdf() {
    let doc = new jsPDF();
    doc.autoTable({ 
        html: "#open-shopping-list",
        // didDrawCell: data => {
        //     console.info(data)
        //  },
         columns: [{header: 'Name', dataKey: 0}, {header: 'Amound', dataKey: 1}],
         columnStyles: {0: {halign: 'right'}, 1: {halign: 'left'}},
         headStyles: {0: {halign: 'right'}, 1: {halign: 'left'}}
    });
    let date = new Date();
    const month = to_two_digits(date.getMonth() + 1);
    const dateOfMonth = to_two_digits(date.getDate());
    const hours = to_two_digits(date.getHours());
    const minutes = to_two_digits(date.getMinutes());
    let dateStr = `${date.getFullYear()}-${month}-${dateOfMonth}_${hours}-${minutes}`;
    doc.save(dateStr + "_shopping-list.pdf");
}

function to_two_digits(number) {
    return number < 10 ? "0" + number : number;
}

function main() {
    if (!!document.getElementById("print-shopping-list")) {
        document.getElementById("print-shopping-list").onclick = generatePdf;
    }
}

main()