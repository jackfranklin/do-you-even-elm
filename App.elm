module App exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import ViewHelpers
import Types exposing (Msg(..), Model, ElmRepoCalculation, Repositories)
import Github
import GithubApi
import RemoteData exposing (WebData)
import ElmRepoRatio


initialModel : Model
initialModel =
    { repositories = RemoteData.NotAsked
    , username = "jackfranklin"
    , results = Nothing
    , githubProfile = RemoteData.NotAsked
    }


calculateResults : WebData Repositories -> Maybe ElmRepoCalculation
calculateResults repos =
    case repos of
        RemoteData.Success data ->
            Just (ElmRepoRatio.calculate data)

        _ ->
            Nothing


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

        NoOp ->
            ( model, Cmd.none )

        NewGithubProfile profile ->
            ( { model | githubProfile = profile }, Cmd.none )

        NewGithubResponse { linkHeader, repositories } ->
            let
                headers =
                    GithubApi.parseLinkHeader linkHeader

                nextCommand =
                    case headers of
                        Just { nextPage } ->
                            case nextPage of
                                Just x ->
                                    Github.fetchGithubData model.username x

                                Nothing ->
                                    Cmd.none

                        Nothing ->
                            Cmd.none

                requestSucceeded =
                    RemoteData.isSuccess repositories

                mergedRepos =
                    appendRemoteDataRepositories model.repositories repositories

                newModel =
                    { model
                        | repositories = mergedRepos
                        , results = calculateResults mergedRepos
                    }
            in
                ( newModel
                , if requestSucceeded then
                    nextCommand
                  else
                    Cmd.none
                )


appendRemoteDataRepositories : WebData Repositories -> WebData Repositories -> WebData Repositories
appendRemoteDataRepositories first second =
    case first of
        RemoteData.Success repos ->
            case second of
                RemoteData.Success newRepos ->
                    RemoteData.Success (repos ++ newRepos)

                RemoteData.Failure e ->
                    RemoteData.Failure e

                _ ->
                    first

        _ ->
            second


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
