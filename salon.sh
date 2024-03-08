#!/bin/bash

PSQL="psql --tuples-only --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~ James' Salon! ~~~\n"

SERVICE_SELECTION_MENU() {

  # display service selection message
  echo -e "\n$1\n"

  # list available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # read user selection
  read SERVICE_ID_SELECTED

  # check that user selection is a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_SELECTION_MENU "You did not enter a number. Please select again."
  else
    # find service name
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    # check to see if service exists
    if [[ -z $SERVICE_NAME_SELECTED ]]
    # if does not exist, return to menu
    then
      SERVICE_SELECTION_MENU "That service does not exist. Please enter a number from the following options."
    else
      # read customer phone number
      echo "What's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

      # check to see if customer exists
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "We don't have you on file. What's your name?"
        read CUSTOMER_NAME
        # insert customer if they don't exist
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi

      # retrieve customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      
      # request time
      echo "What time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo "I have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

}

SERVICE_SELECTION_MENU "Welcome to James' Salon! What service do you require?"