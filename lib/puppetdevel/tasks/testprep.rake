task :testprep do
  require 'puppetdevel/settings'

  SETTINGS.gitlab_host  = 'localhost'
  SETTINGS.gitlab_port  = '443'
  SETTINGS.gitlab_user  = 'root'
  SETTINGS.gitlab_token = SETTINGS.get_gitlab_token(password: '5iveL!fe')
  SETTINGS.jenkins_host = 'localhost'
  SETTINGS.jenkins_port = '8081'

  gitlab_ssh_key = File.read('/home/vagrant/.ssh/id_rsa.pub')
  gitlab = PuppetDevel::Gitlab::Client.new
  gitlab.add_key('testing key', gitlab_ssh_key)
  gitlab.create_user('jenkins@unittest.at', '5iveL!fe', username: 'jenkins', name: 'Jenkins')
end
