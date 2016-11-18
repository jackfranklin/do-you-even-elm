module Github exposing (fetchGithubData, fetchGithubProfile)

import Types exposing (Repository, Repositories, Msg(..), GithubResponse, GithubProfile)
import Dict
import Task
import GithubApi
import GithubToken
import RemoteData
import Http
import Json.Decode exposing (succeed, field, oneOf, maybe)
import Json.Decode.Extra exposing ((|:))


profileDecoder : Json.Decode.Decoder GithubProfile
profileDecoder =
    succeed GithubProfile
        |: (field "html_url" Json.Decode.string)
        |: (field "avatar_url" Json.Decode.string)
        |: (field "name" Json.Decode.string)
        |: (maybe (field "bio" Json.Decode.string))


githubProfileHttpRequest : String -> Http.Request GithubProfile
githubProfileHttpRequest url =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" GithubToken.token ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson profileDecoder
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
            NewGithubResponse (GithubResponse Nothing (RemoteData.Failure e))

        Ok data ->
            NewGithubResponse
                { linkHeader = Dict.get "Link" data.raw.headers
                , repositories = (RemoteData.Success data.parsed)
                }


fetchGithubData : String -> Int -> Cmd Msg
fetchGithubData username page =
    GithubApi.githubRepoRequest username page
        |> Http.toTask
        |> Task.attempt parseGithubRepoResponse



-- HttpAll.makeRequest repositoriesDecoder
--     (\httpErr ->
--         NewGithubResponse (GithubResponse Nothing (RemoteData.Failure httpErr))
--     )
--     (\response ->
--         NewGithubResponse
--             { linkHeader = Dict.get "Link" response.raw.headers
--             , repositories = (RemoteData.Success response.parsed)
--             }
--     )
--     (GithubApi.sendRepoHttpRequest username page)
