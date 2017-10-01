module Github exposing (fetchGithubData, fetchGithubProfile)

import Types exposing (Repository, Repositories, Msg(..), GithubResponse, GithubProfile)
import Dict
import Task
import GithubRepositories
import RemoteData
import GithubHeaders
import Http
import GithubDecoders


githubProfileHttpRequest : String -> Http.Request GithubProfile
githubProfileHttpRequest url =
    Http.request
        { method = "GET"
        , headers = GithubHeaders.headers
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson GithubDecoders.profile
        , timeout = Nothing
        , withCredentials = False
        }


fetchGithubProfile : String -> Cmd Msg
fetchGithubProfile username =
    githubProfileHttpRequest ("https://api.github.com/users/" ++ username)
        |> Http.toTask
        |> RemoteData.asCmd
        |> Cmd.map NewGithubProfile


parseGithubRepoResponse :
    Result Http.Error
        { parsed : Repositories
        , raw : Http.Response String
        }
    -> Msg
parseGithubRepoResponse res =
    case res of
        Err e ->
            NewGithubResponse (GithubResponse Nothing (RemoteData.Failure (Debug.log "error" e)))

        Ok data ->
            NewGithubResponse
                { linkHeader = Dict.get "link" data.raw.headers
                , repositories = (RemoteData.Success data.parsed)
                }


fetchGithubData : String -> Int -> Cmd Msg
fetchGithubData username page =
    GithubRepositories.githubRepoRequest username page
        |> Http.toTask
        |> Task.attempt parseGithubRepoResponse
