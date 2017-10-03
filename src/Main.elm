module Main exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import ProcessGithubResponse
import ViewHelpers
import Types exposing (Msg(..), Model, ElmRepoCalculation, Repositories)
import Github
import RemoteData exposing (WebData)


initialModel : Model
initialModel =
    { repositories = RemoteData.NotAsked
    , username = "jackfranklin"
    , results = Nothing
    , githubProfile = RemoteData.NotAsked
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGithubData ->
            ( { model
                | results = Nothing
                , repositories = RemoteData.Loading
                , githubProfile = RemoteData.Loading
              }
            , Cmd.batch
                [ Github.fetchGithubData model.username 1
                , Github.fetchGithubProfile model.username
                ]
            )

        UsernameChange username ->
            ( { model | username = username }, Cmd.none )

        NewGithubProfile profile ->
            ( { model | githubProfile = profile }, Cmd.none )

        NewGithubResponse data ->
            ProcessGithubResponse.process model data


view : Model -> Html Msg
view model =
    container
        [ row
            [ col12 [ ViewHelpers.heading ]
            ]
        , row [ col12 [ ViewHelpers.form model ] ]
        , row [ col12 [ ViewHelpers.profileView model.githubProfile ] ]
        , row [ col12 [ ViewHelpers.repositoriesView model.repositories ] ]
        , row [ col12 [ ViewHelpers.statsView model.results ] ]
        ]


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
