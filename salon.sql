#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU () {
  if [[ $1 ]] 
  then 
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read service_id BAR NAME 
  do
    echo "$service_id) $NAME"
  done 
  read SERVICE_ID_SELECTED 
  # if service id selected is not number 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    MAIN_MENU "Your number is not valid"
  else 
    SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE ]] 
    then 
      MAIN_MENU "I could not find that service. What would you like today?"
    else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CHECK_EXIST=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CHECK_EXIST ]] 
      then 
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        
        
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        NEW_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'");
        APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id , service_id , time) VALUES ($CUSTOMER_ID , $SERVICE_ID_SELECTED , '$SERVICE_TIME')")
        echo -e  "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else 
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'");
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'");
      APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id , service_id , time) VALUES ($CUSTOMER_ID , $SERVICE_ID_SELECTED , '$SERVICE_TIME')")
      echo -e  "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi 
  fi
}

MAIN_MENU 

