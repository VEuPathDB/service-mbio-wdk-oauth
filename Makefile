
IMAGE_VERSION = latest

.PHONY: default
default:
	@echo
	@echo "Targets:"
	@echo
	@echo "docker"
	@echo "dockerlocal"
	@echo "dockerlocalnocache"
	@echo
	@echo "oracleclone"
	@echo "oracleup"
	@echo "oracledown"
	@echo "oraclelogs"
	@echo
	@echo "buildpostgresimage"
	@echo "postgresclone"
	@echo "postgresup"
	@echo "postgresdown"
	@echo "postgreslogs"
	@echo

dockerlocalnocache:
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" \
	--build-arg "BUILD_TYPE=local" --no-cache .

dockerlocal:
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" \
	--build-arg "BUILD_TYPE=local" .

docker:
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" \
	.

oracleup: oracledown
	(docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom up --remove-orphans &)

oracledown:
	docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom down -v

postgresup: postgresdown
	(docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.postgres.yml --env-file env.dev.pg.base --env-file env.dev.pg.custom up --remove-orphans &)

postgresdown:
	docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.postgres.yml --env-file env.dev.pg.base --env-file env.dev.pg.custom down -v

postgresclone:
	@bin/cloneProjects.sh postgres

oracleclone:
	@bin/cloneProjects.sh oracle

buildpostgresimage:
	docker compose -p mbio_local --env-file env.dev.pg.base --env-file env.dev.pg.custom -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.postgres.yml build

oraclelogs:
	docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml --env-file env.dev.ora.base --env-file env.dev.ora.custom logs

postgreslogs:
	docker compose -p mbio_local -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.ssh.yml -f docker-compose.postgres.yml --env-file env.dev.pg.base --env-file env.dev.pg.custom logs

