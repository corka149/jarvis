
# Define the path to your virtual environment
VENV := ./.venv/bin/activate
VERSION := $(shell uv version --short)

build:
	source $(VENV) && uv pip freeze > requirements.txt
	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker build -t corka149/jarvis:$(VERSION) -t corka149/jarvis:latest .
	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker push corka149/jarvis:$(VERSION) && docker push corka149/jarvis:latest
