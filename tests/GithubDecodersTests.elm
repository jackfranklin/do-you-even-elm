module GithubDecodersTests exposing (all)

import Test exposing (..)
import Expect
import Types exposing (..)
import GithubDecoders
import Json.Decode exposing (decodeString)


userWithNoName : ( String, GithubProfile )
userWithNoName =
    ( """
    { "html_url": "github.com/foo",
    "avatar_url": "foo.jpg",
    "name": null,
    "bio": "developer" }
    """
    , GithubProfile "github.com/foo" "foo.jpg" "(No name given)" (Just "developer")
    )


userWithName : ( String, GithubProfile )
userWithName =
    ( """
    { "html_url": "github.com/foo",
    "avatar_url": "foo.jpg",
    "name": "jack",
    "bio": "developer" }
    """
    , GithubProfile "github.com/foo" "foo.jpg" "jack" (Just "developer")
    )


repositories : ( String, Repositories )
repositories =
    let
        repo =
            """
            { "name": "elm-thing",
              "html_url": "github.com",
              "stargazers_count": 20,
              "language": "Elm",
              "updated_at": "20-04-17"}
            """
    in
        ( "[" ++ repo ++ "]"
        , [ Repository "elm-thing" "github.com" 20 (Just "Elm") "20-04-17"
          ]
        )


assertDecoderOutput : Json.Decode.Decoder a -> ( String, a ) -> Expect.Expectation
assertDecoderOutput decoder ( input, output ) =
    Expect.equal
        (decodeString decoder input)
        (Ok output)


all : Test
all =
    describe "decoders"
        [ describe "decoding a user profile"
            [ test "It can deal with a user with no `name`" <|
                \() ->
                    assertDecoderOutput GithubDecoders.profile userWithNoName
            , test "It can parse out a name" <|
                \() ->
                    assertDecoderOutput GithubDecoders.profile userWithName
            ]
        , describe "decoding repositories"
            [ test "It can parse repos" <|
                \() ->
                    assertDecoderOutput GithubDecoders.repositories repositories
            ]
        ]
