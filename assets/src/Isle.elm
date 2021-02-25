module Isle exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (targetValueIntParse)
import Json.Decode



-- MODEL


type alias Model =
    { groups : List Group
    }


type alias Group =
    { id : Int
    , name : String
    }


initialModel : Model
initialModel =
    { groups = getGroups
    }



-- UPDATE


type Msg
    = SelectedGroup Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( initialModel, Cmd.none )



-- COMMANDS


getGroups : List Group
getGroups =
    [ Group 0 "Admin"
    , Group 1 "User"
    , Group 2 "Guest"
    ]



-- VIEW


view : Model -> Html.Html Msg
view model =
    div []
        [ viewHeader
        , viewUserGroups model
        ]


viewHeader : Html.Html msg
viewHeader =
    Html.div []
        [ h1 [ class "center-align" ] [ text "Isles" ]
        ]


viewUserGroups : Model -> Html.Html Msg
viewUserGroups model =
    let
        options =
            List.map viewGroupOption model.groups
    in
    select [ on "change" (Json.Decode.map SelectedGroup targetValueIntParse) ]
        options


viewGroupOption : Group -> Html.Html Msg
viewGroupOption group =
    option
        [ value (String.fromInt group.id)
        ]
        [ text group.name ]



-- MAIN


init : () -> ( Model, Cmd msg )
init _ =
    ( initialModel, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
