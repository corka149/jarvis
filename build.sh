#/!/usr/bin/env zsh

docker build -t corka149/jarvis:$(cat version) -t corka149/jarvis:latest . 

gum confirm "Push images?" && docker push corka149/jarvis:$(cat version) && docker push corka149/jarvis:latest
