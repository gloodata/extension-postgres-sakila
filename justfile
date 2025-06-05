start-docker-postgres-sakila:
  docker run --platform linux/amd64 -e POSTGRES_PASSWORD=sakila -p 5432:5432 -d frantiseks/postgres-sakila

stop-docker-postgres-sakila:
  docker stop $(docker ps -a -q --filter "status=running" --filter "ancestor=frantiseks/postgres-sakila")

docker-rm-stopped-postgres-sakila:
  docker rm $(docker ps -a -q --filter "status=exited" --filter "ancestor=frantiseks/postgres-sakila")

run:
  uv run src/main.py --host 127.0.0.1 --port 8886


