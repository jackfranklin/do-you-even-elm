module ViewHelpers exposing (heading, form, repositoriesView, statsView)

import Html exposing (..)
import Html.Attributes exposing (class, type', placeholder, value)
import Html.Events exposing (onInput, onSubmit)
import BootstrapHelpers exposing (..)
import Types exposing (Msg(..), Model, Repositories, ElmRepoCalculation)
import RemoteData exposing (RemoteData(..), WebData)
import Numeral


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


repositoriesView : WebData Repositories -> Html Msg
repositoriesView repos =
    case repos of
        NotAsked ->
            div [] [ text "Submit the form to find out how much you Elm!" ]

        Loading ->
            div [] [ text "Loading..." ]

        Failure err ->
            div [] [ text "Error" ]

        Success repos ->
            div [] [ text "Got repos" ]


statsView : Maybe ElmRepoCalculation -> Html Msg
statsView res =
    case res of
        Nothing ->
            div [] [ text "Awaiting results..." ]

        Just data ->
            div []
                [ div []
                    [ h1 [] [ text ((Numeral.format "0.00%" data.percentage) ++ "of your repos are Elm!") ]
                    ]
                ]
