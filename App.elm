module MyApp exposing (..)

import Html exposing (Html, text, div)
import BootstrapHelpers exposing (row, container, col6)
import Html.App
import Github exposing (Repositories)


type alias Model =
    { repositories : Maybe Repositories
    , username : String
    }


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
            [ (colMd [ div [] [ text "Hello World" ] ])
            ]
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
