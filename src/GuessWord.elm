module GuessWord exposing (..)

import Json.Decode as JD exposing (Decoder, string, map2, field)
import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Events as HE exposing (onInput)
import Random.List
import Browser
import Random
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
type alias Model =
  { failure : Bool
  , loading : Bool
  , success : Words
  , word : Word
  , definitions : (List (List Meaning))
  , userInput : String
  , checkBox : Bool
  }

type alias Words = (List String)
type alias Word = String
type alias Meaning = 
  { nature : String
  , definitions : List Def
  }
type alias Def = String


  

init : () -> (Model, Cmd Msg)
init _ = 
  (
    { failure = False
    , loading = True
    , success = []
    , word = ""
    , definitions = []
    , userInput = ""
    , checkBox = False
    }
  , getWords
  )



-- UPDATE


type Msg
  = GotWords (Result Http.Error Words)
  | ChooseWord (Maybe Word, Words)
  | GotDef (Result Http.Error (List (List Meaning)))
  | User String
  | CheckBox Bool
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      GotWords result ->
        case result of
            Ok words ->
              ({ model | success = words }
              , Random.generate ChooseWord (Random.List.choose words)
              )
            
            Err _ ->
              ({ model | failure = True }, Cmd.none)
      
      ChooseWord (maybeWord, _) ->
        case maybeWord of
          Just word ->
            ({ model | word = word }, getDef word)
          Nothing ->
            ({ model | failure = True }, Cmd.none)
      
      GotDef result ->
        case result of
            Ok def ->
              ({ model | definitions = def }, Cmd.none)
            
            Err _ ->
              ({ model | failure = True }, Cmd.none)

      User userInput ->
        ({ model | userInput = userInput }, Cmd.none)
      
      CheckBox isChecked ->
        ({ model | checkBox = isChecked }, Cmd.none)
        


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW

view : Model -> Html Msg
view model =
  if model.loading then
    if List.isEmpty model.success then
      div []
        [ text "Loading..." ]
    else if String.isEmpty model.word then
        div []
          [ text "Choosing a random word..." ]
    else if List.isEmpty model.definitions then
            div []
              [ text "Looking for a definition..." ]
    else
        div []
        [ol[]
            [ viewHelper model.definitions
            ,div[]
              [p [ style "text-align" "center" ][strong [][text "The answer is: "]
              , input [ placeholder "Did you guess the word?", value model.userInput, onInput User] []
              , div [] [ text (checkInput model.userInput model.word) ]
              , p [ style "text-align" "left" ][input [ type_ "checkbox", HE.onCheck CheckBox, checked model.checkBox ] []
              , text (revealWord model.checkBox model.word)] ]]
            ]
        ]
  else 
    div []
          [ text "An error occured..." ]

checkInput : String -> Word -> String
checkInput input word =
  if input == word then
    "That's it!"
  else if String.isEmpty input then
    "Enter something, don't be scared!"
  else
    "Wrong..."

revealWord : Bool -> String -> String
revealWord isChecked word =
  if isChecked then
    "The word is: " ++ word
  else  
    "Check the box to reveal the word!"


viewHelper : (List (List Meaning)) -> Html Msg
viewHelper definitions =
  div []
    [ul []
      [ h2 [] [text "WORD GAME ^o^ !"]
      , h3 [] [ text "Meaning:" ] 
      , ul [] (List.map viewMeanings definitions)
      ]
    ]

viewMeanings : (List Meaning) -> Html Msg
viewMeanings meanings = 
  div []
    [ div [] (List.map viewMeaning meanings) ]

viewMeaning : Meaning -> Html Msg
viewMeaning meaning =
  div []
    [ div [] [ h5 [] [li[] [text meaning.nature]] ]
    , div [] [ol[] (List.map viewDef meaning.definitions)] 
    ]

viewDef : String -> Html Msg
viewDef def =
  li [] [ text def ]

        



-- HTTP

getWords : Cmd Msg
getWords =
  Http.get
    { url = "http://localhost:5000/words"
    , expect = Http.expectJson GotWords wordsDecoder
    }

wordsDecoder : Decoder Words
wordsDecoder =
  (JD.list string)

getDef : Word -> Cmd Msg
getDef word =
  Http.get
    { url = "https://api.dictionaryapi.dev/api/v2/entries/en/" ++ word
    , expect = Http.expectJson GotDef decoder
    }

decoder : Decoder (List (List Meaning))
decoder =
 JD.list (field "meanings" meaningDecoder)

meaningDecoder : Decoder (List Meaning)
meaningDecoder =
  JD.list 
    ( map2 Meaning
        (field "partOfSpeech" string)
        (field "definitions" defDecoder)
    )

defDecoder : Decoder (List Def)
defDecoder =
  JD.list (field "definition" string)