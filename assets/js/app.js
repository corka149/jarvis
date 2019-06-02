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

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

function generatePdf() {
    let doc = new jsPDF();
    doc.autoTable({ 
        html: "#open-shopping-list",
        didDrawCell: data => {
            console.info(data)
         },
         columns: [{header: 'Name', dataKey: 0}, {header: 'Amound', dataKey: 1}]
    });
    let date = new Date();
    let dateStr = `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}_${date.getHours()}-${date.getMinutes()}`;
    doc.save(dateStr + "_shopping-list.pdf");
}

function main() {
    if (!!document.getElementById("print-shopping-list")) {
        document.getElementById("print-shopping-list").onclick = generatePdf;
    }
}

main()