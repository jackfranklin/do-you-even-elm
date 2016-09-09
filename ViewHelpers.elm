module ViewHelpers exposing (heading, form)

import Model exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (class, type', placeholder, value)
import Html.Events exposing (onInput, onSubmit)
import BootstrapHelpers exposing (..)
import Msg exposing (Msg(..))


heading : Html Msg
heading =
    well
        [ (h1 [] [ text "Do you even Elm?" ])
        , (p [] [ text "Enter your GitHub name to see how Elm-ey you are!" ])
        ]


form : Model -> Html Msg
form model =
    inlineForm FetchGithubData
        [ formGroup
            [ inputGroup
                [ div [ class "input-group-addon" ] [ text "Press enter to search" ]
                , input [ type' "text", class "form-control", placeholder "Username", value model.username, onInput UsernameChange ] []
                ]
            ]
        ]
