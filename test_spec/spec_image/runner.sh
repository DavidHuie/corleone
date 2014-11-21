#!/usr/bin/env bash

set -x -e

cd /corleone
bundle install
sudo -u app bundle exec $@
