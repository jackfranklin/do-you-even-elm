module GithubApi exposing (..)

import Http
import Json.Decode exposing (succeed, field, oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import Types exposing (GithubResponse, Repositories, Repository)
import String
import Regex
import GithubToken
import Dict exposing (Dict)
import LinkHeaderParser exposing (GithubLinkHeader)


reposUrl : String -> Int -> String
reposUrl username page =
    "https://api.github.com/users/" ++ username ++ "/repos?per_page=100&page=" ++ (toString page)


repositoryDecoder : Json.Decode.Decoder Repository
repositoryDecoder =
    succeed Repository
        |: (field "name" Json.Decode.string)
        |: (field "html_url" Json.Decode.string)
        |: (field "stargazers_count" Json.Decode.int)
        |: (maybe (field "language" Json.Decode.string))
        |: (field "updated_at" Json.Decode.string)


repositoriesDecoder : Json.Decode.Decoder Repositories
repositoriesDecoder =
    Json.Decode.list repositoryDecoder


githubRepoRequest :
    String
    -> Int
    -> Http.Request
        { parsed : Repositories
        , raw :
            { headers : Dict String String
            , status : { code : Int, message : String }
            , url : String
            , body : String
            }
        }
githubRepoRequest username page =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" GithubToken.token ]
        , url = reposUrl username page
        , body = Http.emptyBody
        , expect = Http.expectStringResponse parseGithubResponse
        , timeout = Nothing
        , withCredentials = False
        }


parseGithubResponse :
    Http.Response String
    -> Result String { parsed : Repositories, raw : Http.Response String }
parseGithubResponse rawResponse =
    let
        parsed =
            Json.Decode.decodeString repositoriesDecoder rawResponse.body
    in
        case parsed of
            Err e ->
                Err e

            Ok repos ->
                Ok
                    { raw = rawResponse
                    , parsed = repos
                    }


parseLinkHeader : Maybe String -> Maybe GithubLinkHeader
parseLinkHeader =
    Maybe.map LinkHeaderParser.parse
