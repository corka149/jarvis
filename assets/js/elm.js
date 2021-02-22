// Bundles all the elm-stuff together
import { Elm } from "../src/Main.elm"


// Artwork app
const artworkNode = document.getElementById("artwork-app");
if (!!artworkNode) {
    var app = Elm.Artwork.init({
        node: artworkNode
    });
}

// Isle app
const isleNode = document.getElementById("isle-app");
if (!!isleNode) {
    var app = Elm.Isle.init({
        node: isleNode
    });
}
