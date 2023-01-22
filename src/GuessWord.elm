module GuessWord exposing (..)

import Json.Decode exposing (Decoder, list, string, map2, field)
import Html exposing (Html, div, text)
import Random.List
import Browser
import Random
import Http




-- MAIN


main : Program () (Model a) Msg
main =
  Browser.element
    { init = init
    , view = view 
    , update = update 
    , subscriptions = subscriptions
    }



-- MODEL


-- Model : states of HTTP request for remote JSON file
type Model a
  = Failure
  | Loading
  | Success Words
  | RandWord Word
  | Definitions (List (List Meaning))

type alias Words = (List String)
type alias Word = String
type alias Meaning = 
  { nature : String
  , definitions : List Def
  }
type alias Def = String

  

init : () -> (Model a, Cmd Msg)
init _ = 
  (Loading, getWords)



-- UPDATE


type Msg
  = GotWords (Result Http.Error Words)
  | ChooseWord (Maybe Word, Words)
  | GotDef (Result Http.Error (List (List Meaning)))
update : Msg -> Model a -> (Model a, Cmd Msg)
update msg model =
  case msg of
      GotWords result ->
        case result of
            Ok words ->
              (Success words
              , Random.generate ChooseWord (Random.List.choose words)
              )
            
            Err error ->
              (Failure, Cmd.none)
      
      ChooseWord (maybeWord, words) ->
        case maybeWord of
          Just word ->
            (RandWord word, getDef word)
          Nothing ->
            (Failure, Cmd.none)
      
      GotDef result ->
        case result of
            Ok def ->
              (Definitions def, Cmd.none)
            
            Err error ->
              (Failure, Cmd.none)
        


-- SUBSCRIPTIONS


subscriptions : Model a -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model a -> Html Msg
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
          [ text "Choosing a random word..." ]
      
      RandWord word ->
        div []
          [ text word ]

      Definitions def ->
        div []
          [ viewHelper def ]

viewHelper : (List (List Meaning)) -> Html Msg
viewHelper definitions =
  div []
    [ text "Meaning:"
    , div [] (List.map viewMeanings definitions)
    ]

viewMeanings : (List Meaning) -> Html Msg
viewMeanings meanings = 
  div []
    [ div [] (List.map viewMeaning meanings) ]

viewMeaning : Meaning -> Html Msg
viewMeaning meaning =
  div []
    [ div [] [ text meaning.nature ]
    , div [] (List.map viewDef meaning.definitions) 
    ]

viewDef : String -> Html Msg
viewDef def =
  div [] [ text def ]

        



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

getDef : Word -> Cmd Msg
getDef word =
  Http.get
    { url = "https://api.dictionaryapi.dev/api/v2/entries/en/center"
    , expect = Http.expectJson GotDef decoder
    }

decoder : Decoder (List (List Meaning))
decoder =
 list (field "meanings" meaningDecoder)

meaningDecoder : Decoder (List Meaning)
meaningDecoder =
  list 
    ( map2 Meaning
        (field "partOfSpeech" string)
        (field "definitions" defDecoder)
    )

defDecoder : Decoder (List Def)
defDecoder =
  list (field "definition" string)