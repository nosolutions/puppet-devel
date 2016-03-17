require 'serverspec'

require 'puppetdevel/settings'

SETTINGS.gitlab_user      = 'root'
SETTINGS.gitlab_group     = 'undertest'
SETTINGS.gitlab_host      = 'localhost'
SETTINGS.gitlab_port      = 443
SETTINGS.gitlab_ssh_port  = 22
SETTINGS.gitlab_token     = SETTINGS.get_gitlab_token(password: '5iveL!fe')
SETTINGS.jenkins_host     = 'localhost'
SETTINGS.jenkins_port     = '8081'
SETTINGS.jenkins_user     = 'admin'
SETTINGS.jenkins_password = 'admin'

set :backend, :exec
