#!/bin/bash

PATH=/bin:/usr/bin
export PATH

. /usr/local/rvm/scripts/rvm

cd /vagrant && rvm use puppet && bundle install --system --binstubs
