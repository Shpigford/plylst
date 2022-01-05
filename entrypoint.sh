#!/bin/sh

# Prepare database
bin/rails db:prepare

# Precompile assets
bin/rails assets:precompile

# Starts webserver and background jobs
foreman start