#!/usr/bin/env bash

set -x -e

cd /home/app
bundle install --without=development
sudo -u app bundle exec $@
