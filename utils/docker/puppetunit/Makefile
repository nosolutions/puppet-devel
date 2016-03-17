PUPPET_UID := $(shell id -u)

all: dockerfile gemfile sshkey
	docker build -t="tosmi/puppetunit" .

dockerfile:
	cat Dockerfile.template | puppet_uid=$(PUPPET_UID) envsubst > Dockerfile

gemfile:
	cp -f ../../../Gemfile Gemfile

sshkey:
	cp -f $$HOME/.ssh/id_rsa id_rsa
