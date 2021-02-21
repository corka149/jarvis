// Bundles all the elm-stuff together
import { Elm } from "../src/Main.elm"


const artworkNode = document.getElementById("artwork-main");
if (!!artworkNode) {
    var app = Elm.Artwork.init({
        node: artworkNode
    });
}
