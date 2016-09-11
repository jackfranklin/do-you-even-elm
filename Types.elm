module Types exposing (..)

import Http


type alias Model =
    { repositories : Maybe Repositories
    , username : String
    }


type alias Repositories =
    List Repository


type alias Repository =
    { name : String
    , htmlUrl : String
    , starCount : Int
    , language : String
    , updated_at : String
    }


type Msg
    = FetchGithubData
    | UsernameChange String
    | FetchError Http.Error
    | NewGithubData Repositories
    | NoOp
