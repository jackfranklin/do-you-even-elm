module MyApp exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import Html.App
import ViewHelpers
import Model exposing (Model)


initialModel : Model
initialModel =
    { repositories = Nothing
    , username = "jackfranklin"
    }


type Msg
    = FetchGithubData
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGithubData ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    container
        [ row
            [ col12 [ ViewHelpers.heading ]
            ]
        , row [ col12 [ ViewHelpers.form model ] ]
        ]


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
