#!/bin/bash

docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom down -v
docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom up --remove-orphans
