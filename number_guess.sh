#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU() {
  echo Enter your username:
  read USERNAME

  PLAYER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  if [[ $PLAYER_ID ]]
  then
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    INSERT_PLAYER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$PLAYER_ID")

    GAME $PLAYER_ID $BEST_GAME #$RANDOM_NUMBER "$MESSAGE"
    else
    INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 1)")

    if [[ $INSERT_PLAYER_RESULT == "INSERT 0 1" ]]
    then
      PLAYER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

      echo "Welcome, $USERNAME! It looks like this is your first time here."

      GAME $PLAYER_ID $BEST_GAME #$RANDOM_NUMBER "$MESSAGE"
    fi
  fi
}

GAME() {

  RANDOM_NUMBER=$((RANDOM % 1000 + 1))
  echo "Guess the secret number between 1 and 1000:"

  SOLVED=0

  GUESSES=0


  while [[ $SOLVED == 0 ]]
  do
    read NUMBER_SELECTED
    GUESSES=$((GUESSES + 1))
    if [[ $NUMBER_SELECTED =~ ^[0-9]+$ ]]
    then
      if [[ $NUMBER_SELECTED == $RANDOM_NUMBER ]]
      then
        echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
        SOLVED=1
        if [[ -z $2 || $GUESSES -lt $2 ]]
        then
          INSERTED_GUESSES=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE user_id=$1")
          if [[ $INSERTED_GUESSES == "UPDATE 1" ]]
          then
            exit 0
          fi
        fi
        elif [[ $NUMBER_SELECTED -gt $RANDOM_NUMBER ]]
        then
        echo "It's lower than that, guess again:"
        elif [[ $NUMBER_SELECTED -lt $RANDOM_NUMBER ]]
        then
        echo "It's higher than that, guess again:"
      fi
      else
      GUESSES=$((GUESSES-1))
      echo "That is not an integer, guess again:"
    fi
  done
}

MAIN_MENU