module Github exposing (fetchGithubData, fetchGithubProfile)

import Json.Decode exposing (succeed, (:=), oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import Types exposing (Repository, Repositories, Msg(..), GithubResponse, GithubProfile)
import Dict
import GithubApi
import RemoteData
import Http
import HttpAll


repositoryDecoder : Json.Decode.Decoder Repository
repositoryDecoder =
    succeed Repository
        |: ("name" := Json.Decode.string)
        |: ("html_url" := Json.Decode.string)
        |: ("stargazers_count" := Json.Decode.int)
        |: (maybe ("language" := Json.Decode.string))
        |: ("pushed_at" := Json.Decode.string)


repositoriesDecoder : Json.Decode.Decoder Repositories
repositoriesDecoder =
    Json.Decode.list repositoryDecoder


profileDecoder : Json.Decode.Decoder GithubProfile
profileDecoder =
    succeed GithubProfile
        |: ("html_url" := Json.Decode.string)
        |: ("avatar_url" := Json.Decode.string)
        |: ("name" := Json.Decode.string)
        |: (maybe ("bio" := Json.Decode.string))


fetchGithubProfile : String -> Cmd Msg
fetchGithubProfile username =
    GithubApi.sendProfileHttpRequest ("https://api.github.com/users/" ++ username)
        |> Http.fromJson profileDecoder
        |> RemoteData.asCmd
        |> Cmd.map NewGithubProfile


fetchGithubData : String -> Int -> Cmd Msg
fetchGithubData username page =
    HttpAll.makeRequest repositoriesDecoder
        (\httpErr ->
            NewGithubResponse (GithubResponse Nothing (RemoteData.Failure httpErr))
        )
        (\response ->
            NewGithubResponse
                { linkHeader = Dict.get "Link" response.raw.headers
                , repositories = (RemoteData.Success response.parsed)
                }
        )
        (GithubApi.sendRepoHttpRequest username page)
