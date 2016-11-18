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


isJust : Maybe a -> Bool
isJust a =
    case a of
        Just _ ->
            True

        Nothing ->
            False


keepValuesFromStringList : List (Maybe String) -> List String
keepValuesFromStringList list =
    list
        |> List.filter isJust
        |> List.map (Maybe.withDefault "")


findPageByRel : String -> List String -> Maybe Int
findPageByRel rel headers =
    List.map runHeaderThroughRegex headers
        |> List.Extra.find (findSubMatchForString rel)
        |> Maybe.andThen List.head
        |> Maybe.andThen (\m -> List.head (keepValuesFromStringList m.submatches))
        |> Maybe.andThen (\m -> Result.toMaybe (String.toInt m))
