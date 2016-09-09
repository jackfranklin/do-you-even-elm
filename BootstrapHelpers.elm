module BootstrapHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Bootstrap.Html exposing (..)


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


inlineForm =
    form [ class "inline-form" ]
