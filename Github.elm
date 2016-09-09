module Github exposing (Repository, Repositories)


type alias Repositories =
    List Repository


type alias Repository =
    { name : String
    , htmlUrl : String
    , starCount : Int
    , language : String
    , updatedAt : String
    , size : Int
    }
