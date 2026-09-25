#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Migrate all databases (primary, cache, queue, cable)
bundle exec rake db:prepare
bundle exec rake db:cache:prepare
bundle exec rake db:queue:prepare
bundle exec rake db:cable:prepare