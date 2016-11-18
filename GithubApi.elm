module GithubApi exposing (..)

import Http
import Json.Decode exposing (succeed, field, oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import Types exposing (GithubResponse, Repositories, GithubLinkHeader, Repository)
import String
import Regex
import GithubToken
import Dict exposing (Dict)


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
    Maybe.map parseLinkHeaderResult


parseLinkHeaderResult : String -> GithubLinkHeader
parseLinkHeaderResult str =
    let
        headers =
            String.split "," str
    in
        { firstPage = findFirstPage headers
        , prevPage = findPrevPage headers
        , nextPage = findNextPage headers
        , lastPage = findLastPage headers
        }


runHeaderThroughRegex : String -> List Regex.Match
runHeaderThroughRegex =
    Regex.find Regex.All (Regex.regex ".+&page=(\\d+).+rel=\"(\\w+)\"")


findSubMatchForString : String -> List Regex.Match -> Bool
findSubMatchForString str matches =
    List.any
        (\match ->
            List.any (\sub -> sub == Just str) match.submatches
        )
        matches


maybeFlatten : Maybe (Maybe a) -> Maybe a
maybeFlatten m =
    case m of
        Just (Just v) ->
            Just v

        _ ->
            Nothing


findNextPage : List String -> Maybe Int
findNextPage =
    findPageByRel "next"


findPrevPage : List String -> Maybe Int
findPrevPage =
    findPageByRel "prev"


findFirstPage : List String -> Maybe Int
findFirstPage =
    findPageByRel "first"


findLastPage : List String -> Maybe Int
findLastPage =
    findPageByRel "last"



-- TODO: the amount of flattens is pretty rubbish
-- got to be a better way to work with this data


findPageByRel : String -> List String -> Maybe Int
findPageByRel rel headers =
    List.map runHeaderThroughRegex headers
        |> List.filter (findSubMatchForString rel)
        |> List.head
        |> Maybe.map List.head
        |> maybeFlatten
        |> Maybe.map (\m -> List.head m.submatches)
        |> maybeFlatten
        |> maybeFlatten
        |> Maybe.map (\m -> Result.toMaybe (String.toInt m))
        |> maybeFlatten
