#!/usr/bin/env bash

set -x -e

cd /docker_test
bundle install --without=development --deployment
sudo -u app bundle exec $@
