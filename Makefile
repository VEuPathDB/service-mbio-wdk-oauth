
IMAGE_VERSION = latest

dockernocache:
	docker build --no-cache --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" .

docker:
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" .
