port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Util
import SelectList exposing (SelectList)
import Keyboard
import List.Extra
import Json.Encode


-- PORTS TO JAVASCRIPT


port playRange : ( Int, Int ) -> Cmd msg


port stopSound : () -> Cmd msg


port saveToLocalStorage : ( String, Json.Encode.Value ) -> Cmd msg



-- PORTS FROM JAVASCRIPT


port endOfChunk : (() -> msg) -> Sub msg



-- MODEL


type alias Chunk =
    { text : String
    , start : Int
    , end : Int
    , paragraph : Bool
    , id : Int
    , line : Int
    }


type alias Model =
    { chunks : SelectList Chunk
    , playing : Bool
    , playedOnce : Bool
    , debug : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        firstChunk =
            flags.chunks
                |> List.head
                |> Util.unwrapMaybe

        chunks =
            SelectList.fromLists [] firstChunk (List.drop 1 flags.chunks)
    in
        ( { playing =
                False
          , playedOnce =
                False
          , chunks =
                chunks
          , debug =
                flags.debug
          }
        , Cmd.none
        )



-- UPDATE


type Msg
    = NoOp
    | Play
    | PlayById Int
    | Pause
    | Back
    | Next
    | KeyPress Keyboard.KeyCode
    | ToggleDebug Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleDebug debug ->
            ( { model
                | debug = debug
              }
            , saveToLocalStorage ( "debug", Json.Encode.bool (debug) )
            )

        KeyPress code ->
            case code of
                -- P
                80 ->
                    if model.playing then
                        update Pause model
                    else
                        update Play model

                -- H
                72 ->
                    update Play model

                -- K
                75 ->
                    update Back model

                -- J
                74 ->
                    update Next model

                _ ->
                    ( model, Cmd.none )

        Back ->
            let
                oldId =
                    .id <| SelectList.selected model.chunks

                chunks_ =
                    model.chunks
                        |> SelectList.select (\chunk -> chunk.id == oldId - 1)

                { start, end } =
                    SelectList.selected chunks_
            in
                ( { model | playing = True, chunks = chunks_, playedOnce = True }
                , playRange ( start, end )
                )

        Next ->
            let
                oldId =
                    .id <| SelectList.selected model.chunks

                chunks_ =
                    model.chunks
                        |> SelectList.select (\chunk -> chunk.id == oldId + 1)

                { start, end } =
                    SelectList.selected chunks_
            in
                ( { model | playing = True, chunks = chunks_, playedOnce = True }
                , playRange ( start, end )
                )

        Pause ->
            ( { model
                | playing = False
              }
            , stopSound ()
            )

        PlayById id ->
            let
                chunks_ =
                    model.chunks
                        |> SelectList.select (\chunk -> chunk.id == id)

                { start, end } =
                    SelectList.selected chunks_
            in
                ( { model | playing = True, chunks = chunks_, playedOnce = True }
                , playRange ( start, end )
                )

        Play ->
            let
                { start, end } =
                    SelectList.selected model.chunks
            in
                ( { model
                    | playing = True
                    , playedOnce = True
                  }
                , playRange ( start, end )
                )



-- VIEW


viewChunk : Bool -> Int -> Chunk -> Html Msg
viewChunk debug currId { start, text, id, line } =
    Html.span
        [ Html.Attributes.classList
            [ ( "chunk", True )
            , ( "playing", id == currId )
            ]
        , Html.Events.onClick (PlayById id)
        ]
        [ if debug then
            Html.span
                [ Html.Attributes.class "line-number"
                ]
                [ Html.text (toString line)
                ]
          else
            Html.text ""
        , Html.text text
        ]


viewParagraph : Bool -> Int -> List Chunk -> Html Msg
viewParagraph debug currId chunks =
    Html.p
        []
        (List.intersperse (Html.text " ") <| List.map (viewChunk debug currId) chunks)


viewControlBar : Model -> Html Msg
viewControlBar model =
    Html.div
        [ Html.Attributes.classList
            [ ( "control-bar", True )
            , ( "playing", model.playing )
            , ( "played-once", model.playedOnce )
            ]
        ]
        [ if model.playedOnce then
            Html.button
                [ Html.Events.onClick Back
                ]
                [ Html.text "Back "
                , Html.kbd [] [ Html.text "K" ]
                ]
          else
            Html.text ""
        , if model.playedOnce then
            Html.button
                [ Html.Events.onClick Play
                ]
                [ Html.text "Repeat "
                , Html.kbd [] [ Html.text "H" ]
                ]
          else
            Html.button
                [ Html.Events.onClick Play
                ]
                [ Html.text "Play"
                ]
        , if model.playedOnce then
            Html.button
                [ Html.Events.onClick Next
                ]
                [ Html.text "Next "
                , Html.kbd [] [ Html.text "J" ]
                ]
          else
            Html.text ""
        ]


view : Model -> Html Msg
view model =
    Html.div
        []
        [ viewControlBar model
        , Html.div
            [ Html.Attributes.class "container grid-lg"
            ]
            [ let
                paragraphs : List (List Chunk)
                paragraphs =
                    model.chunks
                        |> SelectList.toList
                        |> List.Extra.groupWhileTransitively (\a b -> a.paragraph == True || b.paragraph == False)

                currId =
                    .id <| SelectList.selected model.chunks
              in
                Html.div
                    []
                    [ Html.div
                        []
                        (List.map (viewParagraph model.debug currId) paragraphs)
                    , viewFooter model.debug
                    ]
            ]
        ]


viewFooter : Bool -> Html Msg
viewFooter debug =
    Html.footer
        []
        [ Html.span
            [ Html.Attributes.style [ ( "display", "inline-block" ) ]
            ]
            [ Html.text "Source: "
            , Html.a
                [ Html.Attributes.href "https://github.com/danneu/slow-spanish" ]
                [ Html.text "danneu/slow-spanish" ]
            ]
        , Html.text " — "
        , Html.span
            [ Html.Attributes.style [ ( "display", "inline-block" ) ]
            ]
            [ Html.text "Story and audio from: "
            , Html.a
                [ Html.Attributes.href "http://www.thespanishexperiment.com/stories/threepigs" ]
                [ Html.text "thespanishexperiment.com" ]
            ]
        , Html.div
            []
            [ Html.label
                [ Html.Attributes.style [ ( "cursor", "pointer" ) ]
                , Html.Attributes.class "debug-label"
                ]
                [ Html.text "Debug: "
                , Html.input
                    [ Html.Attributes.type_ "checkbox"
                    , Html.Attributes.checked debug
                    , Html.Events.onCheck ToggleDebug
                    ]
                    []
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ endOfChunk (\_ -> Pause)
        , Keyboard.downs KeyPress
        ]


type alias Flags =
    { chunks : List Chunk
    , debug : Bool
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
