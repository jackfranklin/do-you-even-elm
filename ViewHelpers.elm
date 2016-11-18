module ViewHelpers exposing (heading, form, repositoriesView, statsView, profileView)

import Html exposing (..)
import Html.Attributes exposing (class, type_, placeholder, value, href, src)
import Html.Events exposing (onInput, onSubmit)
import BootstrapHelpers exposing (..)
import Types exposing (Msg(..), Model, Repositories, ElmRepoCalculation, Repository, GithubProfile)
import RemoteData exposing (RemoteData(..), WebData)
import Date
import String
import Numeral
import Date.Format as DateFormat


heading : Html Msg
heading =
    well
        [ (h1 [] [ text "Do you even Elm?" ])
        , p [] [ text "Enter your GitHub name to see how Elm-ey you are!" ]
        , p []
            [ text "Built by "
            , a [ href "http://twitter.com/Jack_Franklin" ] [ text "Jack Franklin" ]
            , text ", written entirely in Elm and fully "
            , a [ href "http://github.com/jackfranklin/do-you-even-elm" ] [ text "open sourced on GitHub" ]
            , text "."
            ]
        ]


form : Model -> Html Msg
form model =
    inlineForm FetchGithubData
        [ formGroup
            [ inputGroup
                [ div [ class "input-group-addon" ] [ text "Press enter to search" ]
                , input [ type_ "text", class "form-control", placeholder "Username", value model.username, onInput UsernameChange ] []
                ]
            ]
        ]


profileView : WebData GithubProfile -> Html Msg
profileView profile =
    case profile of
        RemoteData.Loading ->
            div [] [ text "Loading your profile..." ]

        RemoteData.Success { avatar, name, bio, url } ->
            BootstrapHelpers.panel "GitHub Profile"
                [ div [ class "media" ]
                    [ div [ class "media-left" ]
                        [ img [ class "media-object", src avatar ] []
                        ]
                    , div [ class "media-body" ]
                        [ h4 [ class "media-heading" ] [ text name ]
                        , p [] [ text (Maybe.withDefault "" bio) ]
                        , p []
                            [ a [ href url ]
                                [ text "View profile on GitHub"
                                ]
                            , text "."
                            ]
                        ]
                    ]
                ]

        RemoteData.Failure e ->
            div [] [ text "Couldn't get your GitHub profile :(" ]

        RemoteData.NotAsked ->
            div [] []


repositoriesView : WebData Repositories -> Html Msg
repositoriesView repos =
    case repos of
        Loading ->
            div [] [ text "Loading..." ]

        Failure err ->
            div [] [ text "Sorry, an error occured. You should tweet @Jack_Franklin to let him know." ]

        _ ->
            div [] []


repoCount : ElmRepoCalculation -> Html Msg
repoCount { elmRepositories, totalRepositories } =
    let
        parts =
            [ "You have a total of "
            , toString totalRepositories
            , " repositories, of which "
            , toString elmRepositories
            , " are written in Elm."
            ]
    in
        text (String.join "" parts)


repositoryDateFormatted : String -> String
repositoryDateFormatted str =
    case Date.fromString str of
        Ok date ->
            DateFormat.format "%A %d %B %Y at %H:%M" date

        Err _ ->
            "Date parsing error :("


featuredRepoPanel : String -> Maybe Repository -> Html Msg
featuredRepoPanel heading repo =
    case repo of
        Just r ->
            BootstrapHelpers.panel heading
                [ p [] [ repoPanelLink r ]
                , p [] [ text ("Last pushed on " ++ (repositoryDateFormatted r.pushedAt) ++ ".") ]
                ]

        Nothing ->
            div [] []


mostPopularRepo : Maybe Repository -> Html Msg
mostPopularRepo =
    featuredRepoPanel "Your most popular Elm repository"


pluralize : String -> String -> number -> String
pluralize singular plural count =
    if count == 1 then
        "1 " ++ singular
    else
        (toString count) ++ " " ++ plural


repoPanelLink : Repository -> Html Msg
repoPanelLink { name, htmlUrl, starCount } =
    p []
        [ link name htmlUrl
        , text
            (String.join ""
                [ " with "
                , pluralize "star" "stars" starCount
                , "."
                ]
            )
        ]


link : String -> String -> Html Msg
link str url =
    a [ href url ] [ text str ]


latestElmRepo : Maybe Repository -> Html Msg
latestElmRepo =
    featuredRepoPanel "Your last updated Elm repository"


statsView : Maybe ElmRepoCalculation -> Html Msg
statsView res =
    case res of
        Nothing ->
            div [] []

        Just data ->
            div []
                [ BootstrapHelpers.panel ((Numeral.format "0.00%" data.percentage) ++ " of your repos are Elm!")
                    [ p [] [ repoCount data ]
                    ]
                , mostPopularRepo data.mostPopularElmRepo
                , latestElmRepo data.latestElmRepo
                ]
