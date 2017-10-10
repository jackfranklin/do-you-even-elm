module GithubHeaders exposing (headers)

import Http


headers : Maybe String -> List Http.Header
headers githubToken =
    case githubToken of
        Nothing ->
            []

        Just token ->
            [ Http.header "Authorization" ("token " ++ token) ]
