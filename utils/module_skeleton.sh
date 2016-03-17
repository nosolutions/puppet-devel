#!/bin/bash

PATH=/bin:/usr/bin

. /usr/local/rvm/scripts/rvm

rvm use ruby-2.1.6@puppet

cd ~vagrant || exit 1

git clone https://github.com/garethr/puppet-module-skeleton.git
( cd puppet-module-skeleton && find skeleton -type f | git checkout-index --stdin --force --prefix="../.puppet/var/puppet-module/" -- )

rm -rf puppet-module-skeleton
