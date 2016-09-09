module ViewHelpers exposing (heading, form)

import Model exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (class, type', placeholder)
import BootstrapHelpers exposing (..)


heading : Html a
heading =
    well
        [ (h1 [] [ text "Do you even Elm?" ])
        , (p [] [ text "Enter your GitHub name to see how Elm-ey you are!" ])
        ]


form : Model -> Html a
form model =
    inlineForm
        [ formGroup
            [ inputGroup
                [ div [ class "input-group-addon" ] [ text "Press enter to search" ]
                , input [ type' "text", class "form-control", placeholder "Username" ] []
                ]
            ]
        ]
