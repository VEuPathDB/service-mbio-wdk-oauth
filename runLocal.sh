#!/bin/bash

docker compose -p mbio_local -f docker-compose.yml -f docker-compose.ssh.yml -f docker-compose.dev.yml down -v

docker compose -p mbio_local -f docker-compose.yml -f docker-compose.ssh.yml -f docker-compose.dev.yml up
