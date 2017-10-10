module ProcessGithubResponse exposing (process)

import RemoteData exposing (WebData)
import ElmRepoRatio
import Github
import GithubRepositories
import Types exposing (Msg(..), StorageResult, Model, ElmRepoCalculation, Repositories)
import LocalStorage exposing (saveResult)


saveToCache : Model -> Cmd Msg
saveToCache model =
    case ( model.repositories, model.githubProfile ) of
        ( RemoteData.Success repos, RemoteData.Success profile ) ->
            saveResult <|
                { githubProfile = profile
                , githubRepositories = repos
                , username = model.username
                }

        _ ->
            Cmd.none


process :
    Model
    -> { linkHeader : Maybe String, repositories : WebData Repositories }
    -> ( Model, Cmd Msg )
process model { linkHeader, repositories } =
    let
        headers =
            GithubRepositories.parseLinkHeader linkHeader

        nextCommand =
            case headers of
                Just { nextPage } ->
                    case nextPage of
                        Just x ->
                            Github.fetchGithubData model.githubToken model.username x

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
            Cmd.batch [ nextCommand, saveToCache newModel ]
          else
            saveToCache newModel
        )


calculateResults : WebData Repositories -> Maybe ElmRepoCalculation
calculateResults repos =
    case repos of
        RemoteData.Success data ->
            Just (ElmRepoRatio.calculate data)

        _ ->
            Nothing


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
