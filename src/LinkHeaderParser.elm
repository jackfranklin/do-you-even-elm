module LinkHeaderParser exposing (parse, GithubLinkHeader)

import LinkHeader exposing (WebLink, LinkRel(..))
import List.Extra


type alias GithubLinkHeader =
    { prevPage : Maybe Int
    , nextPage : Maybe Int
    , lastPage : Maybe Int
    , firstPage : Maybe Int
    }


parse : String -> GithubLinkHeader
parse str =
    let
        webLinks =
            LinkHeader.parse str
    in
        { firstPage = findHeaderAndGetNumber LinkHeader.webLinkIsFirst webLinks
        , lastPage = findHeaderAndGetNumber LinkHeader.webLinkIsLast webLinks
        , nextPage = findHeaderAndGetNumber LinkHeader.webLinkIsNext webLinks
        , prevPage = findHeaderAndGetNumber LinkHeader.webLinkIsPrev webLinks
        }


findHeaderAndGetNumber : (WebLink -> Bool) -> List WebLink -> Maybe Int
findHeaderAndGetNumber isWebLink webLinks =
    List.Extra.find isWebLink webLinks |> Maybe.map .rel |> Maybe.map LinkHeader.getIntegerForRel
