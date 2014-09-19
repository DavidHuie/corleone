#!/usr/bin/env bash

set -x -e

cd /home/app
bundle install --jobs=8
sudo -u app bundle exec $@
