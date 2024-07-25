#!/bin/bash

docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml down -v

docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml up --remove-orphans
