#/!/usr/bin/env zsh

cd jarvis-fe || exit 1
npm run build
cd ..

export DOCKER_DEFAULT_PLATFORM=linux/amd64

docker build -t corka149/jarvis:$(cat version) -t corka149/jarvis:latest . 

gum confirm "Push images?" && docker push corka149/jarvis:$(cat version) && docker push corka149/jarvis:latest
