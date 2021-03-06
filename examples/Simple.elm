module Simple exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser exposing (element)
import Cropper
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg
    = ToCropper Cropper.Msg
    | Zoom String


type alias Model =
    { cropper : Cropper.Model
    , test : Int
    }


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { cropper =
            Cropper.init
                { url = "assets/kittens-1280x711.jpg"
                , crop = { width = 720, height = 480 }
                }
      , test = 42
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ToCropper (Cropper.subscriptions model.cropper)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToCropper subMsg ->
            let
                ( updatedSubModel, subCmd ) =
                    Cropper.update subMsg model.cropper
            in
            ( { model | cropper = updatedSubModel }, Cmd.map ToCropper subCmd )

        Zoom zoom ->
            ( { model | cropper = Cropper.zoom model.cropper (Maybe.withDefault 0 (String.toFloat zoom)) }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ header [] [ h1 [] [ a [ href "simple.html" ] [ text "Elm Cropper Simple Example" ] ] ]
        , Cropper.view model.cropper |> Html.map ToCropper
        , div [ class "controls" ]
            [ p [ class "controls__row" ]
                [ label [] [ text "Z" ]
                , input
                    [ onInput Zoom
                    , type_ "range"
                    , Html.Attributes.min "0"
                    , Html.Attributes.max "1"
                    , Html.Attributes.step "0.0001"
                    , value (String.fromFloat model.cropper.zoom)
                    ]
                    []
                ]
            ]
        , code [ class "code" ] [ cropDataDump <| Cropper.cropData model.cropper ]
        ]


cropDataDump : Cropper.CropData -> Html Msg
cropDataDump data =
    let
        rectDebug rect =
            String.fromInt rect.width ++ "x" ++ String.fromInt rect.height

        pointDebug point =
            String.fromInt point.x ++ "|" ++ String.fromInt point.y
    in
    dl []
        [ dt [] [ text "url" ]
        , dd [] [ text data.url ]
        , dt [] [ text "size" ]
        , dd [] [ text <| rectDebug data.size ]
        , dt [] [ text "crop" ]
        , dd [] [ text <| rectDebug data.crop ]
        , dt [] [ text "resized" ]
        , dd [] [ text <| rectDebug data.resized ]
        , dt [] [ text "origin" ]
        , dd [] [ text <| pointDebug data.origin ]
        ]
