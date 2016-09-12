module Github exposing (fetchGithubData)

import Json.Decode exposing (succeed, (:=), oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import RemoteData
import Http
import Types exposing (Repository, Repositories, Msg(..))


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
    Http.get repositoriesDecoder ("http://localhost:8080/github-repos.json")
        |> RemoteData.asCmd
        |> Cmd.map NewGithubData
