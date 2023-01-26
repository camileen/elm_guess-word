# GuessWord Game
Simple game when you have to guess a word based on its definitions.
It is a little web application coded in elm.
Have fun!

## Requirements :
**You will have to launch a local json server.**
You can install the *json-server* package from npm with the following command: `npm install json-server -g`  
You can use any other json server package but be aware that **you have to use port 5000** to play the game.

**WARNING:** *json-server* requires at least version 12 of Node


## How to launch the game ?
1. Move to the directory
2. Open a terminal from there and launch a local json server with the following command : `json-server --watch words/words.json -p 5000`
3. Open another terminal and compile the GuessWord.elm file with the following command: `elm make src/GuessWord.elm`
3. Open another terminal and enter `elm reactor`
4. Follow the displayed localhost URL
5. Click on the index.html file
6. Feel free to play :)


## Contributors :
[Xinyi Zhao](https://github.com/Xinyi25) and [Camille Robinson](https://github.com/camileen)

## Mentions :
Specifications of the project can be found [here](https://github.com/camileen/elp/tree/master/elm/projet).
This project is an exercise, meant to learn the basics of elm language and to implement a first web application.  
Special mention to [INSA Lyon](https://www.insa-lyon.fr/[]) french engineering school and its department of Telecommunications.


