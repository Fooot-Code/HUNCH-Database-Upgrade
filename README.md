# HUNCH-Database-Upgrade

### How to Setup
1. Install [Docker](https://docs.docker.com/engine/install/)
2. Run this command to start the SQL database
docker run --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=your_database \
  -p 3306:3306 \
  -d mysql:8.0