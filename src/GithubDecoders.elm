module GithubDecoders exposing (profile, repositories)

import Json.Decode exposing (succeed, field, oneOf, maybe)
import Json.Decode.Extra exposing ((|:))
import Types exposing (GithubProfile, Repository, Repositories)


profile : Json.Decode.Decoder GithubProfile
profile =
    succeed GithubProfile
        |: (field "html_url" Json.Decode.string)
        |: (field "avatar_url" Json.Decode.string)
        |: (field "name" (oneOf [ Json.Decode.string, Json.Decode.null "(No name given)" ]))
        |: (maybe (field "bio" Json.Decode.string))


repository : Json.Decode.Decoder Repository
repository =
    succeed Repository
        |: (field "name" Json.Decode.string)
        |: (field "html_url" Json.Decode.string)
        |: (field "stargazers_count" Json.Decode.int)
        |: (maybe (field "language" Json.Decode.string))
        |: (field "updated_at" Json.Decode.string)


repositories : Json.Decode.Decoder Repositories
repositories =
    Json.Decode.list repository
