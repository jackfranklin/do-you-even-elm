port module LocalStorage exposing (..)

import Types exposing (..)


port checkStorage : String -> Cmd msg


port saveResult : StorageResult -> Cmd msg


port storageResult : (( String, Maybe StorageResult ) -> msg) -> Sub msg
