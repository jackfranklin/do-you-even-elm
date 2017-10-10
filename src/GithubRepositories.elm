module GithubRepositories exposing (..)

import Http
import Types exposing (GithubResponse, Repositories, Repository)
import GithubHeaders
import Dict exposing (Dict)
import LinkHeaderParser exposing (GithubLinkHeader)
import GithubDecoders
import Json.Decode


reposUrl : String -> Int -> String
reposUrl username page =
    "https://api.github.com/users/" ++ username ++ "/repos?per_page=100&page=" ++ (toString page)


githubRepoRequest :
    Maybe String
    -> String
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
githubRepoRequest githubToken username page =
    Http.request
        { method = "GET"
        , headers = GithubHeaders.headers githubToken
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
            Json.Decode.decodeString GithubDecoders.repositories rawResponse.body
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
