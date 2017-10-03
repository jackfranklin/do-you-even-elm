module Main exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import ProcessGithubResponse
import ViewHelpers
import Types exposing (Msg(..), Model, ElmRepoCalculation, Repositories)
import Github
import RemoteData exposing (WebData)
import Navigation exposing (Location)
import String


initialModel : Model
initialModel =
    { repositories = RemoteData.NotAsked
    , username = ""
    , results = Nothing
    , githubProfile = RemoteData.NotAsked
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange newLocation ->
            let
                _ =
                    Debug.log "location" newLocation

                username =
                    String.dropLeft 1 newLocation.pathname

                newModel =
                    { model
                        | results = Nothing
                        , repositories = RemoteData.Loading
                        , githubProfile = RemoteData.Loading
                        , username = username
                    }
            in
                if String.isEmpty username then
                    ( model, Cmd.none )
                else
                    ( newModel
                    , Cmd.batch
                        [ Github.fetchGithubData username 1
                        , Github.fetchGithubProfile username
                        ]
                    )

        FetchGithubData ->
            ( model, Navigation.newUrl ("/" ++ model.username) )

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


init : Location -> ( Model, Cmd Msg )
init location =
    update (UrlChange location) initialModel


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
