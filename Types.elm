module Types exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { repositories : WebData Repositories
    , username : String
    , results : Maybe ElmRepoCalculation
    , githubProfile : WebData GithubProfile
    }


type alias ElmRepoCalculation =
    { totalRepositories : Int
    , elmRepositories : Int
    , percentage : Float
    , mostPopularElmRepo : Maybe Repository
    , latestElmRepo : Maybe Repository
    }


type alias GithubProfile =
    { url : String
    , avatar : String
    , name : String
    , bio : Maybe String
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
    | NewGithubProfile (WebData GithubProfile)


type alias GithubLinkHeader =
    { prevPage : Maybe Int
    , nextPage : Maybe Int
    , lastPage : Maybe Int
    , firstPage : Maybe Int
    }
