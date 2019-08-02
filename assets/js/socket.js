import {Socket} from "phoenix"
let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

window.createSocket = () => {
  let channel = socket.channel("measurement", {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on("measurement:new", (response) => {
    console.log("New measurement", response)
  })
}

