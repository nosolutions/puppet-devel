require 'pp'
require 'yaml'

require 'puppetdevel/error'
require 'puppetdevel/questioner'
require 'puppetdevel/gitlab/token'

module PuppetDevel
  class Settings
    @@settings_file      = "#{File.dirname(__FILE__)}/../../.settings.yaml"
    @@user_settings_file = "#{File.dirname(__FILE__)}/../../.user_settings.yaml"

    attr_reader :skip_interview, :user_settings_file, :modules

    def initialize(settings_file: @@settings_file, user_settings_file: @@user_settings_file, skip_interview: false)
      @skip_interview  = skip_interview
      @user_settings_file = user_settings_file
      @modules = load_settings(user_settings_file, section: 'modules')

      @settings = load_settings(settings_file)
      user_settings = load_settings(user_settings_file)
      @settings = user_settings.merge(@settings) if user_settings
    end

    public

    def method_missing(method_sym, *args, &block)
      attribute = method_sym.to_s
      if attribute[-1,1] == "="
        @settings[attribute.chop] = args[0]
        return
      else
        return @settings[attribute] if @settings.has_key? attribute
      end
      raise PuppetDevel::SettingsError, "Setting #{attribute} not found, try running `rake config`!"
    end

    def dump
      pp @settings
    end

    def [](key)
      attribute = key.to_s
      return @settings[attribute] if @settings.has_key? attribute
      raise PuppetDevel::SettingsError, "Setting #{key} not found, try running `rake config`!"
    end

    def []=(key, value)
      @settings[key.to_s] = value
    end

    def has_key?(key)
      return true if @settings.has_key?(key.to_s)
      false
    end

    def save
      settings = {
        'modules'  => if @modules
                        sym_to_s(@modules)
                      else
                        nil
                      end,
        'settings' => sym_to_s(@settings)
      }
      File.open(user_settings_file, 'w') { |f| f.write YAML.dump(settings) }
    end

    def interview
      @settings['gitlab_host']      = ask 'What is your gitlab host', @settings['default_gitlab_host']
      @settings['gitlab_port']      = ask 'On what port is gitlab listing on', @settings['default_gitlab_port']
      @settings['gitlab_ssh_port']  = ask 'What is your gitlab ssh port', @settings['default_gitlab_ssh_port']
      @settings['gitlab_group']     = ask 'What is your gitlab group', @settings['default_gitlab_group']
      @settings['gitlab_user']      = ask 'What is your gitlab username'
      @settings['gitlab_token']     = get_gitlab_token
      @settings['jenkins_host']     = ask 'What is your jenkins host', @settings['default_jenkins_host']
      @settings['jenkins_port']     = ask 'On what port is jenkins listing on', @settings['default_jenkins_port']
      @settings['jenkins_user']     = ask 'What is your jenkins username', @settings['default_jenkins_user']
      @settings['jenkins_password'] = ask_password "Please enter your the Jenkins password for user #{SETTINGS.jenkins_user}"
      save
    end

    def get_gitlab_token(password: nil)
      password = ask_password 'Please enter your Gitlab password' if password.nil?
      PuppetDevel::Gitlab::Token.get(@settings['gitlab_user'], password, @settings['gitlab_host'])
    end

    def add_module(name: nil, repository: nil)
      @modules = Hash.new unless @modules
      @modules[name] = {
        'name'       => name,
        'repository' => repository
      }
    end

    private

    def load_settings(file, section: 'settings')
      return nil if not File.exists? file
      data = YAML.load_file(file)
      data[section] ? data[section] : {}
    end

    def sym_to_s(hash)
      Hash[hash.map { |k, v| [k.to_s, v]}]
    end

    def ask(question, default=nil)
      PuppetDevel::Questioner.ask question, default
    end

    def ask_password(question)
      PuppetDevel::Questioner.ask_password question
    end

  end
end

SETTINGS = PuppetDevel::Settings.new
