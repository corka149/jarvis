import {Socket} from "phoenix"
import "chart.js"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

window.createSocket = () => {
  let channel = socket.channel("measurement", {})
  channel.join()
    .receive("ok", resp => { 
      console.log("Joined successfully", resp) 
      initiateCharts(resp)
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on("measurement:new", (response) => {
    console.log("New measurement", response)
  })
}

function initiateCharts(initialValues) {

  let ctx = document.getElementById('myChart');
  let myChart = new Chart(ctx, {
      type: 'line',
      labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
      data: {
        labels: [1500,1600],
        datasets: [{ 
            data: [{
              x: 10,
              y: 20
            }, {
              x: 15,
              y: 66
            }],
            label: "Kitchen",
            borderColor: "#3e95cd",
            fill: false
          }, { 
            data: [{
              x: 10,
              y: 33
            }, {
              x: 15,
              y: 44
            }],
            label: "Living room",
            borderColor: "#8e5ea2",
            fill: false
          }
        ]
      },
      options: {
        elements: {
            line: {
                tension: 0 // disables bezier curves
            }
        }
    }
  });
}
