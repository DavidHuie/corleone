#!/usr/bin/env bash

set -x -e

cd /docker_test
bundle install
sudo -u app bundle exec $@
