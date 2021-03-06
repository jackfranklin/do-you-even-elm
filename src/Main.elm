module Main exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import ProcessGithubResponse
import ViewHelpers
import Types exposing (Msg(..), StorageResult, Model, ElmRepoCalculation, Repositories)
import Github
import RemoteData exposing (WebData)
import Navigation exposing (Location)
import String
import ElmRepoRatio
import LocalStorage exposing (checkStorage, storageResult)


type alias Flags =
    { githubToken : String
    }


initialModel : Model
initialModel =
    { repositories = RemoteData.NotAsked
    , username = ""
    , results = Nothing
    , githubProfile = RemoteData.NotAsked
    , githubToken = Nothing
    }


usernameFromLocation : Location -> Maybe String
usernameFromLocation { pathname } =
    case String.dropLeft 1 pathname of
        "" ->
            Nothing

        username ->
            Just username


fetchGithubCommands : Maybe String -> String -> Int -> Cmd Msg
fetchGithubCommands githubToken username page =
    Cmd.batch
        [ Github.fetchGithubData githubToken username page
        , Github.fetchGithubProfile githubToken username
        ]


fetchInitialDataForUser : Model -> String -> ( Model, Cmd Msg )
fetchInitialDataForUser model name =
    ( updateModelForLoadingData model name
    , fetchGithubCommands model.githubToken name 1
    )


updateModelForLoadingData : Model -> String -> Model
updateModelForLoadingData model name =
    { model
        | results = Nothing
        , repositories = RemoteData.Loading
        , githubProfile = RemoteData.Loading
        , username = name
    }


updateModelFromCache : StorageResult -> Model -> Model
updateModelFromCache storageResult model =
    { model
        | githubProfile = RemoteData.succeed storageResult.githubProfile
        , results = Just (ElmRepoRatio.calculate storageResult.githubRepositories)
        , repositories = RemoteData.succeed storageResult.githubRepositories
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange newLocation ->
            case usernameFromLocation newLocation of
                Just name ->
                    ( updateModelForLoadingData model name
                    , checkStorage name
                    )

                Nothing ->
                    ( model, Cmd.none )

        FetchGithubData ->
            ( model, Navigation.newUrl ("/" ++ model.username) )

        NewStorageResult ( username, result ) ->
            case result of
                Just data ->
                    ( updateModelFromCache data model, Cmd.none )

                Nothing ->
                    fetchInitialDataForUser model username

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


updateModelWithToken : String -> Model -> Model
updateModelWithToken token model =
    { model | githubToken = (Just token) }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    initialModel
        |> updateModelWithToken flags.githubToken
        |> update (UrlChange location)


subscriptions : Model -> Sub Msg
subscriptions model =
    storageResult NewStorageResult


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
