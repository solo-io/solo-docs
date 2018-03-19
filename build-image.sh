#!/bin/bash

docker build -t soloio/gloo-docs:latest .
docker push soloio/gloo-docs:latest
