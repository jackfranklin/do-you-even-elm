module BootstrapHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onSubmit)
import Bootstrap.Html exposing (..)
import Types exposing (Msg)


row =
    row_


well =
    well_


container =
    container_


col12 =
    colMd_ 12 12 12


col6 =
    colMd_ 6 6 6


formGroup =
    formGroup_


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
