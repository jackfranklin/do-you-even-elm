module BootstrapHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onSubmit)
import Types exposing (Msg)


row =
    div [ class "row" ]


well =
    div [ class "well" ]


container =
    div [ class "container" ]


col12 =
    div [ class "col-md-12" ]


col6 =
    div [ class "col-md-6" ]


formGroup =
    div [ class "form-group" ]


inputGroup =
    div [ class "input-group" ]


inlineForm onSubmitMsg =
    form [ class "inline-form", onSubmit onSubmitMsg ]


panel : String -> List (Html Msg) -> Html Msg
panel headingText bodyElements =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ]
            [ h3 [ class "panel-title" ] [ text headingText ]
            ]
        , div [ class "panel-body" ] bodyElements
        ]
