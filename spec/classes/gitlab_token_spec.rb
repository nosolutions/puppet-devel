require 'spec_helper'

require 'puppetdevel/settings'
require 'puppetdevel/gitlab/token'

describe PuppetDevel::Gitlab::Token do
  describe '.get' do
    settings_file = '/tmp/user_settings_token.yaml'

    before(:each) do
      settings = PuppetDevel::Settings.new(user_settings_file: settings_file)
      settings.gitlab_token = PuppetDevel::Gitlab::Token.new('root', '5iveL!fe', 'localhost').get_token
      settings.save
    end

    describe file(settings_file) do
      its(:content) { should match(%r"gitlab_token: \"?\w+\"?")}
    end
  end
end
