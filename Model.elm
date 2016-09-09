module Model exposing (Model)

import Github exposing (Repositories)


type alias Model =
    { repositories : Maybe Repositories
    , username : String
    }
