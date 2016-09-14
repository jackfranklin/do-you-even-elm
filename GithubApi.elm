module GithubApi exposing (..)

import Task exposing (Task)
import Http
import Json.Decode
import Types exposing (GithubResponse, Repositories)
import RemoteData exposing (WebData)


reposUrl : String -> String
reposUrl username =
    "https://api.github.com/users/" ++ username ++ "/repos"


sendRepoHttpRequest : String -> Task Http.RawError Http.Response
sendRepoHttpRequest username =
    Http.send Http.defaultSettings
        { verb = "GET"
        , headers = []
        , url = reposUrl username
        , body = Http.empty
        }


promoteRawErrorToGithubResponse : Http.RawError -> GithubResponse
promoteRawErrorToGithubResponse e =
    case e of
        Http.RawTimeout ->
            GithubResponse Nothing (RemoteData.Failure Http.Timeout)

        Http.RawNetworkError ->
            GithubResponse Nothing (RemoteData.Failure Http.NetworkError)


parseRepositories : Json.Decode.Decoder Repositories -> Http.Response -> WebData Repositories
parseRepositories decoder response =
    case response.value of
        Http.Text str ->
            case Json.Decode.decodeString decoder str of
                Ok repos ->
                    RemoteData.Success repos

                Err e ->
                    RemoteData.Failure (Http.UnexpectedPayload e)

        _ ->
            RemoteData.Failure (Http.UnexpectedPayload "Bad Github response")
