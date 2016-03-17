require 'spec_helper'

require 'puppetdevel/error'
require 'puppetdevel/settings'
require 'puppetdevel/module'
require 'puppetdevel/gitlab/client'

describe PuppetDevel::Gitlab::Client do

  describe '.create_repo' do
    before(:all) do
      @modulename = 'oss-gitlabcreate'
      @puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: @modulename,
        moduleauthor: 'Integrationtest',
        modulesummary: 'A test module',
        quiet: true
        )
    end

    after(:all) do
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: 'oss-gitlabcreate', quiet: true)
      PuppetDevel::Gitlab::Client.remove_repo(@puppetmodule)
    end

    it do
      expect {
        PuppetDevel::Gitlab::Client.create_repo(@puppetmodule)
      }.not_to raise_error

      expect {
        PuppetDevel::Gitlab::Client.create_repo(@puppetmodule)
      }.to raise_error PuppetDevel::GitlabClientError, /could not create repo.*limit_reached/
    end
  end

  describe '.delete_repo' do
    before(:all) do
      @puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: 'oss-gitlabdelete',
        moduleauthor: 'Integrationtest',
        modulesummary: 'A test module',
        quiet: true
        )
      PuppetDevel::Gitlab::Client.create_repo(@puppetmodule)
    end

    after(:all) do
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: 'oss-gitlabdelete', quiet: true)
    end

    it do
      expect {
        PuppetDevel::Gitlab::Client.remove_repo(@puppetmodule)
      }.not_to raise_error

      expect {
        PuppetDevel::Gitlab::Client.remove_repo(@puppetmodule)
      }.to raise_error PuppetDevel::GitlabClientError, /Could not find repository/
    end
  end

  describe '.create_user' do
    it do
      gitlab = PuppetDevel::Gitlab::Client.new
      expect {
        gitlab.create_user('testuser@test.com', 'testpass', username: 'testuser', name: 'Test User')
      }.not_to raise_error

      gitlab.delete_user('testuser')
    end
  end

  describe '.delete_user' do
    it do
      gitlab = PuppetDevel::Gitlab::Client.new
      gitlab.create_user('deleteme@test.com', 'testpass', username: 'deleteme', name: 'Test User')
      expect {
        gitlab.delete_user('deleteme')
      }.not_to raise_error
    end
  end
end
