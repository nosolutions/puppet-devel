require 'puppetdevel/sslhelper'
require 'puppetdevel/error'

module PuppetDevel::Gitlab

  class Token
    attr_reader :username, :password,  :session_uri

    def initialize(username, password, gitlab_host)
      @username = username if parameter_ok?(username)
      @password = password if parameter_ok?(password)
      @session_uri = "https://#{gitlab_host}/api/v3/session" if parameter_ok?(gitlab_host)
    end

    def self.get(username, password, gitlab_host)
      helper = Token.new(username, password, gitlab_host)
      helper.get_token()
    end

    public

    def get_token()
      get_token_from_gitlab
    end

    private

    def parameter_ok?(parameter)
      raise PuppetDevel::GitlabTokenError, 'Paramter is nil!' if parameter.nil?
      true
    end

    def get_token_from_gitlab
      PuppetDevel::SSLHelper.disable_verify_peer
      user = query_session()
      PuppetDevel::SSLHelper.restore_openssl_settings
      user['private_token']
    end

    def query_session
      require 'httparty'
      require 'json'

      response = HTTParty.post(session_uri,
        :body => {
          :login    => username,
          :password => password,
        }.to_json,
        :headers => { 'Content-Type' => 'application/json'} )
      raise PuppetDevel::GitlabTokenError, 'Could not query gitlab for an api token: unauthorized!' if response.code == 401
      JSON.parse(response.body)
    end
  end
end
