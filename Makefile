
VERSION := $(shell uv version --short)

build:
	export DOCKER_DEFAULT_PLATFORM=linux/amd64
	docker build -t corka149/jarvis:$(VERSION) -t corka149/jarvis:latest .
	docker push corka149/jarvis:$(VERSION) && docker push corka149/jarvis:latest
