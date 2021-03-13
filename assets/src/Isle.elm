module Isle exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- MODEL


type alias Model =
    { groups : List Group
    , isles : List Isle
    , selectedGroupId : Maybe Int
    , inputedIsleName : Maybe String
    }


type alias Group =
    { id : Int
    , name : String
    }


type alias Isle =
    { name : String
    , groupId : Int
    }


initialModel : Model
initialModel =
    { groups = getGroups
    , isles = []
    , selectedGroupId = Nothing
    , inputedIsleName = Nothing
    }



-- UPDATE


type Msg
    = SelectedGroup String
    | InputedIsleName String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedGroup groupId ->
            ( { model | selectedGroupId = String.toInt groupId }, Cmd.none )

        InputedIsleName updateName ->
            ( { model | inputedIsleName = Just updateName }, Cmd.none )



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
        , div [ class "button-bar" ]
            [ button [ class "pure-button secondary-button icon-button" ] [ i [ class "material-icons" ] [ text "arrow_back" ] ]
            ]
        , viewIsleForm model
        ]


viewIsleForm : Model -> Html Msg
viewIsleForm model =
    let
        selectId =
            "user-groups-select"

        nameId =
            "isle-name-input"
    in
    Html.form [ class "pure-form pure-form-aligned" ]
        [ fieldset []
            [ div [ class "pure-control-group" ]
                [ label [ for selectId ] [ text "Group" ]
                , viewUserGroups model selectId
                ]
            , div [ class "pure-control-group" ]
                [ label [ for nameId ] [ text "Isle name" ]
                , input [ id nameId, placeholder "Enter isle name here", onInput InputedIsleName ] []
                ]
            , div []
                [ button [ class "pure-button primary-button icon-button    " ] [ i [ class "material-icons" ] [ text "save" ] ]
                ]
            ]
        ]


viewHeader : Html.Html msg
viewHeader =
    Html.div []
        [ h1 [ class "content-subhead" ] [ text "Isles" ]
        ]


viewUserGroups : Model -> String -> Html.Html Msg
viewUserGroups model selectId =
    let
        options =
            List.map viewGroupOption model.groups
    in
    select [ onInput SelectedGroup, id selectId ]
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
