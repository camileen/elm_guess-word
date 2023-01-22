module GuessWord exposing (..)

import Html exposing (Html, div, text)
import Json.Decode exposing (Decoder, list, string)
import Browser
import Http



-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view 
    , update = update 
    , subscriptions = subscriptions
    }



-- MODEL


-- Model : states of HTTP request for remote JSON file
type Model
  = Failure
  | Loading
  | Success Words

type alias Words = (List String)

init : () -> (Model, Cmd Msg)
init _ = 
  (Loading, getWords)



-- UPDATE


type Msg
  = GotWords (Result Http.Error Words)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      GotWords result ->
        case result of
            Ok words ->
              (Success words, Cmd.none)
            
            Err error ->
              (Failure, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  case model of
      Failure ->
        div []
          [ text "An error occured..." ]
      
      Loading ->
        div []
          [ text "Loading..." ]

      Success words ->
        div []
          [ text (String.join " " words) ]



-- HTTP

getWords : Cmd Msg
getWords =
  Http.get
    { url = "http://localhost:5000/words"
    , expect = Http.expectJson GotWords wordsDecoder
    }

wordsDecoder : Decoder Words
wordsDecoder =
  (list string)

