#!/bin/bash

sudo docker build -t localhost:5000/docker_spec_test .
sudo docker push localhost:5000/docker_spec_test
