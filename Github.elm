module Github exposing (fetchGithubData)

import Json.Decode exposing (succeed, (:=), oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import RemoteData exposing (RemoteData)
import Http
import Types exposing (Repository, Repositories, Msg(..), GithubResponse)
import Task exposing (Task, andThen)
import Dict


repositoryDecoder : Json.Decode.Decoder Repository
repositoryDecoder =
    succeed Repository
        |: ("name" := Json.Decode.string)
        |: ("html_url" := Json.Decode.string)
        |: ("stargazers_count" := Json.Decode.int)
        |: (maybe ("language" := Json.Decode.string))
        |: ("updated_at" := Json.Decode.string)


repositoriesDecoder : Json.Decode.Decoder Repositories
repositoriesDecoder =
    Json.Decode.list repositoryDecoder


sendHttpRequest : String -> Task Http.RawError Http.Response
sendHttpRequest username =
    Http.send Http.defaultSettings
        { verb = "GET"
        , headers = []
        , url = "https://api.github.com/users/" ++ username ++ "/repos"
        , body = Http.empty
        }


repoDecoder : String -> Result String Repositories
repoDecoder =
    Json.Decode.decodeString repositoriesDecoder


fetchGithubData : String -> Cmd Msg
fetchGithubData username =
    Task.perform
        (\e ->
            case e of
                Http.RawTimeout ->
                    NewGithubResponse (GithubResponse Nothing (RemoteData.Failure Http.Timeout))

                Http.RawNetworkError ->
                    NewGithubResponse (GithubResponse Nothing (RemoteData.Failure Http.NetworkError))
        )
        (\response ->
            NewGithubResponse
                { linkHeader = Dict.get "Link" response.headers
                , repositories =
                    case response.value of
                        Http.Text str ->
                            case repoDecoder str of
                                Ok repos ->
                                    RemoteData.Success repos

                                Err e ->
                                    RemoteData.Failure (Http.UnexpectedPayload e)

                        _ ->
                            RemoteData.Failure (Http.UnexpectedPayload "Bad Github response")
                }
        )
        (sendHttpRequest username)
