
IMAGE_VERSION = latest

docker:
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" .
