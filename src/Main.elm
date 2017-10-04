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


usernameFromLocation : Location -> Maybe String
usernameFromLocation { pathname } =
    case String.dropLeft 1 pathname of
        "" ->
            Nothing

        username ->
            Just username


startFetchingGithubData : Model -> String -> Model
startFetchingGithubData model newUsername =
    { model
        | results = Nothing
        , repositories = RemoteData.Loading
        , githubProfile = RemoteData.Loading
        , username = newUsername
    }


fetchGithubCommands : String -> Int -> Cmd Msg
fetchGithubCommands username page =
    Cmd.batch
        [ Github.fetchGithubData username page
        , Github.fetchGithubProfile username
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange newLocation ->
            case usernameFromLocation newLocation of
                Just name ->
                    ( startFetchingGithubData model name
                    , fetchGithubCommands name 1
                    )

                Nothing ->
                    ( model, Cmd.none )

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
