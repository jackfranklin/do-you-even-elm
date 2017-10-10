module Github exposing (fetchGithubData, fetchGithubProfile)

import Types exposing (Repository, Repositories, Msg(..), GithubResponse, GithubProfile)
import Dict
import Task
import GithubRepositories
import RemoteData
import GithubHeaders
import Http
import GithubDecoders


githubProfileHttpRequest : Maybe String -> String -> Http.Request GithubProfile
githubProfileHttpRequest githubToken url =
    Http.request
        { method = "GET"
        , headers = GithubHeaders.headers githubToken
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson GithubDecoders.profile
        , timeout = Nothing
        , withCredentials = False
        }


fetchGithubProfile : Maybe String -> String -> Cmd Msg
fetchGithubProfile githubToken username =
    githubProfileHttpRequest githubToken ("https://api.github.com/users/" ++ username)
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


fetchGithubData : Maybe String -> String -> Int -> Cmd Msg
fetchGithubData githubToken username page =
    GithubRepositories.githubRepoRequest githubToken username page
        |> Http.toTask
        |> Task.attempt parseGithubRepoResponse
