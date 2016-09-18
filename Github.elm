module Github exposing (fetchGithubData, fetchGithubProfile)

import Json.Decode exposing (succeed, (:=), oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import Types exposing (Repository, Repositories, Msg(..), GithubResponse, GithubProfile)
import Task exposing (Task)
import Dict
import GithubApi
import RemoteData
import Http


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


profileDecoder : Json.Decode.Decoder GithubProfile
profileDecoder =
    succeed GithubProfile
        |: ("html_url" := Json.Decode.string)
        |: ("avatar_url" := Json.Decode.string)
        |: ("name" := Json.Decode.string)
        |: ("bio" := Json.Decode.string)


fetchGithubProfile : String -> Cmd Msg
fetchGithubProfile username =
    Http.get profileDecoder ("https://api.github.com/users/" ++ username)
        |> RemoteData.asCmd
        |> Cmd.map NewGithubProfile


fetchGithubData : String -> Int -> Cmd Msg
fetchGithubData username page =
    Task.perform (NewGithubResponse << GithubApi.promoteRawErrorToGithubResponse)
        (\response ->
            NewGithubResponse
                { linkHeader = Dict.get "Link" response.headers
                , repositories = GithubApi.parseRepositories repositoriesDecoder response
                }
        )
        (GithubApi.sendRepoHttpRequest username page)
