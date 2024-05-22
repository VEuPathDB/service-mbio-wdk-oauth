
PROJECTS_RELEASE_BRANCH = mbio-container
IMAGE_VERSION = 1.0

docker:
	bin/cloneProjects.sh $(PROJECTS_RELEASE_BRANCH)
	docker build --progress=plain --tag "mbio-wdk:$(IMAGE_VERSION)" --build-arg "GITHUB_USERNAME=${GITHUB_USERNAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN}" .
