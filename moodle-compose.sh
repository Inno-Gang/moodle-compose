#!/usr/bin/env bash

function on_stop {
  echo "Cancelled."
  exit 130
}

# Check that gum is installed.
if ! command -v gum &> /dev/null; then
  echo "gum could not be found. Make sure it is installed and in your PATH."
  exit
fi

FG_COLOR="#6B3"

function ask {
  gum style --bold --foreground "$FG_COLOR" "$1"
}

# Moodle version
ask "Which Moodle version to use?"
MOODLE_VERSION=$(gum input --placeholder "latest (default)")
if [ $? -eq 130 ]; then
  on_stop
fi
if [ -z "$MOODLE_VERSION" ]; then
  MOODLE_VERSION="latest"
fi
echo -e "${MOODLE_VERSION}\n"

# DBMS
DB_OPTION_MYSQL="MySQL"
DB_OPTION_POSTGRES="PostgreSQL"
ask "Which database to use?"
MOODLE_DB_TYPE=$(gum choose "$DB_OPTION_MYSQL" "$DB_OPTION_POSTGRES")
if [ $? -eq 130 ]; then
  on_stop
fi
echo -e "${MOODLE_DB_TYPE}\n"

# Moodle App
ask "Include Moodle App?"
WITH_MOODLE_APP=$(gum choose "No" "Yes")
if [ $? -eq 130 ]; then
  on_stop
fi
if [ "$WITH_MOODLE_APP" = "Yes" ]; then
  WITH_MOODLE_APP=1
  echo -e "Yes\n"
else
  WITH_MOODLE_APP=0
  echo -e "No\n"
fi

# Define where to export
OUTPUT_PATH="./docker-compose.yaml"
if [ -f "$OUTPUT_PATH" ]; then
  echo "$OUTPUT_PATH already exists. So, where to save?"
  OUTPUT_PATH_OLD=$OUTPUT_PATH
  OUTPUT_PATH=$(gum input --placeholder "$OUTPUT_PATH")
  if [ $? -eq 130 ]; then
    on_stop
  fi
  if [ -z "$OUTPUT_PATH" ]; then
    OUTPUT_PATH=$OUTPUT_PATH_OLD
  fi
fi

echo ""

# Default admin user info
MOODLE_USERNAME='user'
MOODLE_PASSWORD='password'
MOODLE_EMAIL='user@example.com'

MOODLE_PORT_HTTP=8080
MOODLE_PORT_HTTPS=8443
MOODLE_APP_PORT=8081

MOODLE_DB_USER='moodle_user'
MOODLE_DB_PASSWORD='moodle_pass'
MOODLE_DB_NAME='moodledb'

if [ "$MOODLE_DB_TYPE" = "$DB_OPTION_POSTGRES" ]; then
  MOODLE_DB_TYPE='pgsql'
  MOODLE_DB_PORT=5432

  # Identation is important!
  MOODLE_DB_SERVICE_CONFIG=$(cat << EOF
    image: postgres:14.7
    environment:
      - PGDATA=/var/lib/postgresql/data/pgdata
      - POSTGRES_DB=$MOODLE_DB_NAME
      - POSTGRES_USER=$MOODLE_DB_USER
      - POSTGRES_PASSWORD=$MOODLE_DB_PASSWORD
    volumes:
      - 'moodledb_data:/var/lib/postgresql/data'
EOF)
else
  MOODLE_DB_TYPE='mysqli'
  MOODLE_DB_PORT=3306

  # Identation is important!
  MOODLE_DB_SERVICE_CONFIG=$(cat << EOF
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=mysql-secret-pw
      - MYSQL_DATABASE=$MOODLE_DB_NAME
      - MYSQL_USER=$MOODLE_DB_USER
      - MYSQL_PASSWORD=$MOODLE_DB_PASSWORD
    volumes:
      - 'moodledb_data:/var/lib/mysql'
EOF)
fi

MOODLE_APP_SERVICE_CONFIG=
if [ "$WITH_MOODLE_APP" -eq 1 ]; then
  # Identation is important!
  MOODLE_APP_SERVICE_CONFIG=$(cat << EOF
  moodle_app:
    image: docker.io/moodlehq/moodleapp:latest
    ports:
      - '$MOODLE_APP_PORT:80'
EOF)
fi

cat << EOF > "$OUTPUT_PATH"
version: '3'
services:
  moodle:
    image: docker.io/bitnami/moodle:$MOODLE_VERSION
    ports:
      - '$MOODLE_PORT_HTTP:8080'
      - '$MOODLE_PORT_HTTPS:8443'
    environment:    
      - MOODLE_USERNAME=$MOODLE_USERNAME
      - MOODLE_PASSWORD=$MOODLE_PASSWORD
      - MOODLE_EMAIL=$MOODLE_EMAIL
      - MOODLE_DATABASE_TYPE=$MOODLE_DB_TYPE
      - MOODLE_DATABASE_HOST=moodle_db
      - MOODLE_DATABASE_PORT_NUMBER=$MOODLE_DB_PORT
      - MOODLE_DATABASE_NAME=$MOODLE_DB_NAME
      - MOODLE_DATABASE_USER=$MOODLE_DB_USER
      - MOODLE_DATABASE_PASSWORD=$MOODLE_DB_PASSWORD
    volumes:
      - 'moodle_data:/bitnami/moodle'
      - 'moodledata_data:/bitnami/moodledata'
    depends_on:
      - moodle_db
  moodle_db:
$MOODLE_DB_SERVICE_CONFIG
$MOODLE_APP_SERVICE_CONFIG
volumes:
  moodle_data:
  moodledata_data:
  moodledb_data:
EOF

echo "Docker Compose config saved to $OUTPUT_PATH"
echo "Run \"docker compose -f ${OUTPUT_PATH} up\" to start!"
echo ""
echo "Moodle will be running at http://localhost:$MOODLE_PORT_HTTP"
echo "Admin user credentials:"
echo "  Username: $MOODLE_USERNAME"
echo "  Password: $MOODLE_PASSWORD"
echo "  E-mail: $MOODLE_EMAIL"
echo ""
echo "Note that it might take a few minutes for Moodle to configure on first start"

if [ "$WITH_MOODLE_APP" -eq 1 ]; then
  echo ""
  echo "Moodle App will be at http://localhost:$MOODLE_APP_PORT"
fi
