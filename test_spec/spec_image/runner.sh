#!/usr/bin/env bash

set -x -e

cd /dt
bundle install
sudo -u app bundle exec $@
