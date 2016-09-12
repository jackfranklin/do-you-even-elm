module Types exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { repositories : WebData Repositories
    , username : String
    }


type alias Repositories =
    List Repository


type alias Repository =
    { name : String
    , htmlUrl : String
    , starCount : Int
    , language : Maybe String
    , updated_at : String
    }


type Msg
    = FetchGithubData
    | UsernameChange String
    | NewGithubData (WebData Repositories)
    | NoOp
