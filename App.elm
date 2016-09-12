module MyApp exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import Html.App
import ViewHelpers
import Types exposing (Msg(..), Model)
import Github
import RemoteData


initialModel : Model
initialModel =
    { repositories = RemoteData.NotAsked
    , username = "jackfranklin"
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGithubData ->
            ( model, Github.fetchGithubData model.username )

        UsernameChange username ->
            ( { model | username = username }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        NewGithubData repos ->
            ( { model | repositories = repos }, Cmd.none )


view : Model -> Html Msg
view model =
    container
        [ row
            [ col12 [ ViewHelpers.heading ]
            ]
        , row [ col12 [ ViewHelpers.form model ] ]
        , row [ col12 [ ViewHelpers.repositoriesView model.repositories ] ]
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
