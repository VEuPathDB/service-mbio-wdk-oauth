
IMAGE_VERSION = latest

dockernocache:
	docker build --no-cache --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" .

docker:
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" .

oracleup: oracledown
	(docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom up --remove-orphans &)

oracledown:
	docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom down -v

postgresup: postgresdown
	(docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml -f docker-compose.postgres.yml --env-file env.dev.pg.base --env-file env.dev.pg.custom up --remove-orphans &)

postgresdown:
	docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml -f docker-compose.postgres.yml --env-file env.dev.pg.base --env-file env.dev.pg.custom down -v
