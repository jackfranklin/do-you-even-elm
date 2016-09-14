module Github exposing (fetchGithubData)

import Json.Decode exposing (succeed, (:=), oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import Types exposing (Repository, Repositories, Msg(..), GithubResponse)
import Task exposing (Task)
import Dict
import GithubApi


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


fetchGithubData : String -> Cmd Msg
fetchGithubData username =
    Task.perform (NewGithubResponse << GithubApi.promoteRawErrorToGithubResponse)
        (\response ->
            NewGithubResponse
                { linkHeader = Dict.get "Link" response.headers
                , repositories = GithubApi.parseRepositories repositoriesDecoder response
                }
        )
        (GithubApi.sendRepoHttpRequest username)
