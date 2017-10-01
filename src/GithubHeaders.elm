module GithubHeaders exposing (headers)

import Http
import GithubToken


headers : List Http.Header
headers =
    case GithubToken.token of
        "" ->
            []

        token ->
            [ Http.header "Authorization" token ]
