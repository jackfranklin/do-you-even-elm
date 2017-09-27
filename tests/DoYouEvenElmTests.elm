module DoYouEvenElmTests exposing (..)

import Test exposing (..)
import Expect
import ElmRepoRatio
import Types exposing (Repository)
import GithubApi


august12 : String
august12 =
    "2016-06-12T09:39:35Z"


august13 : String
august13 =
    "2016-06-13T09:39:35Z"


elmRepoWithStars : String -> String -> Int -> Repository
elmRepoWithStars name date stars =
    Repository name "" stars (Just "Elm") date


elmRepo : String -> String -> Repository
elmRepo name date =
    Repository name "" 1 (Just "Elm") date


miscRepo : String -> String -> Repository
miscRepo name date =
    Repository name "" 1 (Just "javascript") date


noLangRepo : String -> String -> Repository
noLangRepo name date =
    Repository name "" 1 Nothing date


all : Test
all =
    describe "Do you even Elm tests"
        [ describe "ElmRepoRatio.calculate"
            [ test "It calculates the ratio of Elm repos" <|
                \() ->
                    let
                        latestRepo =
                            elmRepo "foo" august13

                        mostPopular =
                            elmRepoWithStars "bar" august12 10

                        notElm =
                            miscRepo "baz" august12

                        repos =
                            [ latestRepo, mostPopular, notElm ]
                    in
                        Expect.equal (ElmRepoRatio.calculate repos)
                            { totalRepositories = 3
                            , elmRepositories = 2
                            , percentage = (2.0 / 3.0)
                            , mostPopularElmRepo = Just mostPopular
                            , latestElmRepo = Just latestRepo
                            }
            ]
        , describe "GithubApi.parseLinkHeader"
            [ test "When given nothing it returns nothing" <|
                \() ->
                    Expect.equal (GithubApi.parseLinkHeader Nothing) Nothing
            , test "When given a header it can parse it" <|
                \() ->
                    let
                        header =
                            "<https://api.github.com/user/193238/repos?per_page=100&page=2>; rel=\"next\", <https://api.github.com/user/193238/repos?per_page=100&page=3>; rel=\"last\""
                    in
                        Expect.equal (GithubApi.parseLinkHeader (Just header))
                            (Just
                                { firstPage = Nothing
                                , lastPage = Just 3
                                , nextPage = Just 2
                                , prevPage = Nothing
                                }
                            )
            ]
        ]
