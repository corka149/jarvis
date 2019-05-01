#!/usr/bin/env bash

docker run --rm --name jarvis-postgres -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=jarvis_dev -p 5432:5432 postgres
