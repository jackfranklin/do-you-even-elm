module Types exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { repositories : WebData Repositories
    , username : String
    , results : Maybe ElmRepoCalculation
    }


type alias ElmRepoCalculation =
    { totalRepositories : Int
    , elmRepositories : Int
    , percentage : Float
    , mostPopularElmRepo : Maybe Repository
    , latestElmRepo : Maybe Repository
    }


type alias Repositories =
    List Repository


type alias Repository =
    { name : String
    , htmlUrl : String
    , starCount : Int
    , language : Maybe String
    , updatedAt : String
    }


type alias GithubResponse =
    { linkHeader : Maybe String
    , repositories : WebData Repositories
    }


type Msg
    = FetchGithubData
    | UsernameChange String
    | NewGithubResponse GithubResponse
    | NoOp
