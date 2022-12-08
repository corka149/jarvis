#/!/usr/bin/env zsh

docker build -t jarvis:$(cat version) -t jarvis:latest . 
