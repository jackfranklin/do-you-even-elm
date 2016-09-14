module MyApp exposing (..)

import Html exposing (Html, text, div, h1, p)
import BootstrapHelpers exposing (..)
import Html.App
import ViewHelpers
import Types exposing (Msg(..), Model, ElmRepoCalculation, Repositories)
import Github
import RemoteData exposing (WebData)
import Debug
import ElmRepoRatio


initialModel : Model
initialModel =
    { repositories = RemoteData.NotAsked
    , username = "jackfranklin"
    , results = Nothing
    }


calculateResults : WebData Repositories -> Maybe ElmRepoCalculation
calculateResults repos =
    case repos of
        RemoteData.Success data ->
            Just (ElmRepoRatio.calculate data)

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGithubData ->
            ( { model | results = Nothing, repositories = RemoteData.Loading }, Github.fetchGithubData model.username )

        UsernameChange username ->
            ( { model | username = username }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        NewGithubResponse { linkHeader, repositories } ->
            let
                _ =
                    Debug.log "linkHeader" linkHeader
            in
                ( { model
                    | repositories = repositories
                    , results = calculateResults repositories
                  }
                , Cmd.none
                )

        NewResult result ->
            ( { model | results = Just result }, Cmd.none )


view : Model -> Html Msg
view model =
    container
        [ row
            [ col12 [ ViewHelpers.heading ]
            ]
        , row [ col12 [ ViewHelpers.form model ] ]
        , row [ col12 [ ViewHelpers.repositoriesView model.repositories ] ]
        , row [ col12 [ ViewHelpers.statsView model.results ] ]
        ]


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
