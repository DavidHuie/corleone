#!/bin/bash

# Starts a Docker registry

sudo docker run --rm -p 5000:5000 -v /etc/docker-registry:/registry-config -v /registry:/registry -e STORAGE_PATH=/registry registry
