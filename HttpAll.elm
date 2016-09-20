module HttpAll exposing (makeRequest, HttpAllResponse)

import Http
import Task exposing (Task, andThen, mapError)
import Json.Decode


{- this module can return the data from an API request, parsed as JSON,
   along with all the headers and other raw data from the request.

   Any errors from elm-http are just passed through
-}


type alias HttpAllResponse a =
    { raw : Http.Response
    , data : a
    }


promoteRawError : Http.RawError -> Http.Error
promoteRawError e =
    case e of
        Http.RawTimeout ->
            Http.Timeout

        Http.RawNetworkError ->
            Http.NetworkError


parseResponse :
    Json.Decode.Decoder a
    -> Http.Response
    -> Task Http.Error (HttpAllResponse a)
parseResponse decoder response =
    case response.value of
        Http.Text str ->
            case Json.Decode.decodeString decoder str of
                Ok x ->
                    Task.succeed
                        ({ data = x
                         , raw = response
                         }
                        )

                Err e ->
                    Task.fail (Http.UnexpectedPayload e)

        _ ->
            Task.fail (Http.UnexpectedPayload "Expected string, got blob")


mapTask :
    Json.Decode.Decoder a
    -> Task Http.RawError Http.Response
    -> Task Http.Error (HttpAllResponse a)
mapTask successDecoder t =
    (mapError promoteRawError t) `andThen` parseResponse successDecoder


makeRequest :
    Json.Decode.Decoder a
    -> (Http.Error -> b)
    -> (HttpAllResponse a -> b)
    -> Task Http.RawError Http.Response
    -> Cmd b
makeRequest successDecoder onFail onSuccess request =
    Task.perform onFail onSuccess (mapTask successDecoder request)
