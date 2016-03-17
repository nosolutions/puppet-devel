#!/bin/bash -x

check_rc() {
    if [ $1 -ne 0 ]; then
	exit $1
    fi
}

prepare() {
    GITLAB_KEY=utils/puppet/modules/puppetvagrant/files/gitlab
    vagrant destroy -f

    echo 'moving fixtures settings.yaml into place'
    cp spec/fixtures/settings.yaml .settings.yaml

    git config --global user.email "jenkins@localhost"
    git config --global user.name "Jenkins"

    chmod 0600 $GITLAB_KEY
    ssh-add $GITLAB_KEY
}

prepare

#---
# Test centos7
#
vagrant up centos7
check_rc $?

# now we try to deploy gitlab and jenkins
# and run rspec within the box
touch .puppetdeveldevel
vagrant provision centos7
check_rc $?
vagrant ssh centos7 -c 'ssh-keyscan -4p 22 localhost    >> ~/.ssh/known_hosts'
vagrant ssh centos7 -c 'ssh-keyscan -4p 22 127.0.0.1    >> ~/.ssh/known_hosts'
vagrant ssh centos7 -c 'git config --global push.default simple'
vagrant ssh centos7 -c 'cd /vagrant && rake testprep && rake spec'
check_rc $?

vagrant destroy -f centos7

rm .puppetdeveldevel

#---
# Test centos6
#
vagrant up centos6
check_rc $?

vagrant destroy -f centos6
