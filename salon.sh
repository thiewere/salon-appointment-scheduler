#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

 PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

 MENU=$($PSQL "SELECT * FROM services")

 MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  
  echo "$MENU" | sed 's/|/) /'
  read SERVICE_ID_SELECTED

  # get service id
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if not exist
  if [[ -z $SERVICE_ID ]]
  then
    # send to main_menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get service_name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")

    # ask the phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # get customer infos
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if not exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask the customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      
      # register the new customer
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      if [[ $INSERT_CUSTOMER == 'INSERT 0 1' ]] 
      then
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # ask the time
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        # insert an appointment
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      
        if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
        then
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
      fi
    else
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")

      # ask the time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      
      # insert an appointment
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    
      if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
 


 }

 MAIN_MENU