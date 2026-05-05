#!/bin/bash
set -e

CONTAINER_NAME="hunch_database"
IMAGE="mysql:8.0"

# 1. Start or create the MySQL container
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Container is already running."
elif [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    echo "Container exists but is stopped. Starting it..."
    docker start $CONTAINER_NAME
else
    echo "Creating and starting new container..."
    docker run --name $CONTAINER_NAME \
        -e MYSQL_ROOT_PASSWORD=password \
        -e MYSQL_DATABASE=hunch_data \
        -p 3306:3306 \
        -d $IMAGE
fi

# 2. Wait for MySQL to accept connections
echo "Waiting for MySQL to be ready..."
until docker exec $CONTAINER_NAME mysqladmin ping -u root -ppassword --silent 2>/dev/null; do
    echo "  ...not ready yet"
    sleep 2
done
echo "MySQL is ready."

# 3. Set up venv if not already in one
[[ "$VIRTUAL_ENV" == "" ]] && INVENV=0 || INVENV=1

if [ $INVENV -eq 1 ]; then
    echo "Already in a venv. Installing requirements..."
else
    echo "Creating venv..."
    python3 -m venv .venv
    source ./.venv/bin/activate
    echo "Venv created and activated."
fi

pip install -r requirements.txt
echo "Dependencies installed."

# 4. Run the program
echo "Running program..."
python Execution/main.py