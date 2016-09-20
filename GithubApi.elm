module GithubApi exposing (..)

import Task exposing (Task)
import Http
import Json.Decode
import Types exposing (GithubResponse, Repositories, GithubLinkHeader)
import RemoteData exposing (WebData)
import String
import Regex
import GithubToken


reposUrl : String -> Int -> String
reposUrl username page =
    "https://api.github.com/users/" ++ username ++ "/repos?per_page=100&page=" ++ (toString page)


requestSettings : String -> Http.Request
requestSettings url =
    { verb = "GET"
    , headers =
        [ ( "Authorization", GithubToken.token )
        ]
    , url = url
    , body = Http.empty
    }


sendRepoHttpRequest : String -> Int -> Task Http.RawError Http.Response
sendRepoHttpRequest username page =
    Http.send Http.defaultSettings (requestSettings (reposUrl username page))


sendProfileHttpRequest url =
    Http.send Http.defaultSettings (requestSettings url)


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
