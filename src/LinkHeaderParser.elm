module LinkHeaderParser exposing (parse, GithubLinkHeader)

import Regex
import List.Extra


type alias GithubLinkHeader =
    { prevPage : Maybe Int
    , nextPage : Maybe Int
    , lastPage : Maybe Int
    , firstPage : Maybe Int
    }


splitHeaderString : String -> List String
splitHeaderString =
    String.split ","


parse : String -> GithubLinkHeader
parse str =
    let
        headers =
            splitHeaderString str
    in
        { firstPage = findFirstPage headers
        , prevPage = findPrevPage headers
        , nextPage = findNextPage headers
        , lastPage = findLastPage headers
        }


runHeaderThroughRegex : String -> List Regex.Match
runHeaderThroughRegex =
    Regex.find (Regex.AtMost 1) (Regex.regex ".+&page=(\\d+).+rel=\"(\\w+)\"")


findSubMatchForString : String -> List Regex.Match -> Bool
findSubMatchForString str matches =
    List.any
        (\match ->
            List.any (\sub -> sub == Just str) match.submatches
        )
        matches


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


findPageByRel : String -> List String -> Maybe Int
findPageByRel rel headers =
    List.map runHeaderThroughRegex headers
        |> List.Extra.find (findSubMatchForString rel)
        |> Maybe.andThen List.head
        |> Maybe.andThen (\m -> List.head (List.filterMap identity m.submatches))
        |> Maybe.andThen (Result.toMaybe << String.toInt)
