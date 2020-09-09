FROM python:3.8-slim-buster

# Prepare
RUN apt update
RUN apt install -y libpq-dev

RUN mkdir /jarvis
ADD . /jarvis
