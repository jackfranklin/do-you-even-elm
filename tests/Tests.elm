module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import ElmRepoRatio
import Types exposing (Repository)


august12 : String
august12 =
    "2016-06-12T09:39:35Z"


august13 : String
august13 =
    "2016-06-13T09:39:35Z"


elmRepoWithStars : String -> String -> Int -> Repository
elmRepoWithStars name date stars =
    Repository name "" stars (Just "elm") date


elmRepo : String -> String -> Repository
elmRepo name date =
    Repository name "" 1 (Just "elm") date


miscRepo : String -> String -> Repository
miscRepo name date =
    Repository name "" 1 (Just "javascript") date


noLangRepo : String -> String -> Repository
noLangRepo name date =
    Repository name "" 1 Nothing date


all : Test
all =
    describe "ElmRepoRatio.calculate"
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
                        , percentage = (2.0 / 3.0) * 100
                        , mostPopularElmRepo = Just mostPopular
                        , latestElmRepo = Just latestRepo
                        }
        ]
