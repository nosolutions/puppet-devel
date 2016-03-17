require 'gitlab'
require 'json'
require 'cgi'

require 'puppetdevel/error'
require 'puppetdevel/settings'

module PuppetDevel::Gitlab
  class Client
    attr_reader :puppetmodule, :endpoint, :per_page
    attr_accessor :gitlab_client

    def initialize(puppetmodule=nil)
      @per_page         = 1000
      @puppetmodule     = puppetmodule
      @endpoint         = config_endpoint
      @gitlab_client    = connect_to_gitlab
    end

    def self.create_repo(puppetmodule)
      client = Client.new(puppetmodule)
      client.create_repo
    end

    def self.remove_repo(puppetmodule)
      client = Client.new(puppetmodule)
      client.remove_repo
    end

    def self.ping
      return false if `ssh -Tp "#{SETTINGS.gitlab_ssh_port}" git@"#{SETTINGS.gitlab_host}"` =~ /Anonymous/
      true
    end

    public

    def create_repo
      project = add_project()
      add_hook(project, config_jenkins_hook_uri)
      add_hook(project, SETTINGS.reaktor_uri)
      add_team_member(project, 'jenkins')
    end

    def remove_repo
      project_id = find_repo_id
      gitlab_client.delete_project(project_id)
    rescue Gitlab::Error::BadRequest => e
      raise PuppetDevel::GitlabClientError, "could not remove repository: #{e}"
    end

    def connect_to_gitlab
      PuppetDevel::SSLHelper.disable_verify_peer
      @gitlab_client = Gitlab.client(endpoint: endpoint, private_token: SETTINGS.gitlab_token)
    end

    def add_key(title, key)
      if gitlab_client.ssh_keys.empty?
        gitlab_client.create_ssh_key(title, key)
      end
    end

    def create_user(username, password, options)
      gitlab_client.create_user(username,password, options)
    rescue Gitlab::Error::BadRequest => e
      raise PuppetDevel::GitlabClientError, "could not create user #{username}: #{e}"
    end

    def delete_user(username)
      id = get_user_id(username)
      gitlab_client.delete_user(id)
    end

    private

    def config_endpoint
      "https://#{SETTINGS.gitlab_host}:#{SETTINGS.gitlab_port}/api/v3"
    end

    def config_jenkins_hook_uri
      "http://#{SETTINGS.jenkins_host}/gitlab/build_now"
    end

    def find_or_create_group(group)
      begin
        group_id = find_group_id(SETTINGS.gitlab_group)
      rescue PuppetDevel::GitlabClientError
        group_id = create_group(group)
      end
      group_id
    end

    def add_project
      group_id = find_or_create_group(SETTINGS.gitlab_group)
      gitlab_client.create_project(
        puppetmodule.metadata.dashed_name,
        :namespace_id => group_id,
        :description => puppetmodule.metadata.summary,
        :visibility_level => 10)
    rescue Gitlab::Error::BadRequest => e
      raise PuppetDevel::GitlabClientError, "could not create repository: #{e}"
    end

    def add_hook(project, hook_uri)
      gitlab_client.add_project_hook(project.to_h['id'], hook_uri)
    end

    def add_team_member(project, user)
      user_id    = get_user_id(user)
      project_id = project.to_h['id']
      gitlab_client.add_team_member(project_id, user_id, '30')
    end

    def find_group_id(name)
      gitlab_client.groups(:per_page => 1000).each do |group|
        return group.to_h['id'] if group.to_h['name'].downcase == name.downcase
      end
      raise PuppetDevel::GitlabClientError, "Gitlab group #{name} not found!"
    end

    def create_group(projectname)
      group = gitlab_client.create_group(projectname, projectname)
      return group.to_h['id']
    end

    def find_repo_id
      projects = gitlab_client.project_search(puppetmodule.metadata.dashed_name)
      projects.each do |p|
        return p.to_h['id'] if p.to_h['path_with_namespace'] == "#{SETTINGS.gitlab_group}/#{puppetmodule.metadata.dashed_name}"
      end
      raise PuppetDevel::GitlabClientError, "Could not find repository #{SETTINGS.gitlab_group}/#{puppetmodule.metadata.dashed_name}"
    end

    def get_user_id(username)
      users = gitlab_client.users( {:per_page => per_page} )
      user = users.find { |i| i.to_h['username'] == username }
      return user.to_h['id'] if user

      raise PuppetDevel::GitlabClientError, "User #{username} not found in gitlab!"
    end

  end
end
