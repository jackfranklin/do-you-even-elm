module Types exposing (..)

import RemoteData exposing (WebData)
import Navigation


type Msg
    = FetchGithubData
    | UsernameChange String
    | NewGithubResponse GithubResponse
    | NewGithubProfile (WebData GithubProfile)
    | UrlChange Navigation.Location


type alias Model =
    { repositories : WebData Repositories
    , username : String
    , results : Maybe ElmRepoCalculation
    , githubProfile : WebData GithubProfile
    , githubToken : Maybe String
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
    , pushedAt : String
    }


type alias GithubResponse =
    { linkHeader : Maybe String
    , repositories : WebData Repositories
    }
