require 'spec_helper'

require 'puppetdevel/settings'
require 'puppetdevel/error'
require 'puppetdevel/jenkins'
require 'puppetdevel/module'

describe PuppetDevel::Jenkins do
  describe '.connect' do
    it do
      modulename = 'oss-jenkinstest'
      puppetmodule = PuppetDevel::PuppetModule.new({
          :name => modulename,
          :author => 'under test',
          :source => "ssh://git@#{SETTINGS.gitlab_host}/#{SETTINGS.gitlab_group}/#{modulename}.git"
        })

      jenkins = PuppetDevel::Jenkins.new(puppetmodule)
      expect {
        jenkins.connect
      }.not_to raise_error
    end
  end

  describe '.create_jobs' do
    it do
      modulename = 'oss-jenkinstest'
      puppetmodule = PuppetDevel::PuppetModule.new({
          :name => modulename,
          :author => 'under test',
          :source => "ssh://git@#{SETTINGS.gitlab_host}/#{SETTINGS.gitlab_group}/#{modulename}.git"
        })
      jenkins = PuppetDevel::Jenkins.new(puppetmodule)
      jenkins.connect

      expect {
        jenkins.create_jobs
      }.not_to raise_error

      jenkins.remove_jobs
    end
  end

  describe '.remove_jobs' do
    it do
      modulename = 'oss-jenkinstest'
      puppetmodule = PuppetDevel::PuppetModule.new({
          :name => modulename,
          :author => 'under test',
          :source => "ssh://git@#{SETTINGS.gitlab_host}/#{SETTINGS.gitlab_group}/#{modulename}.git"
        })
      jenkins = PuppetDevel::Jenkins.new(puppetmodule)
      jenkins.connect
      jenkins.create_jobs

      expect {
        jenkins.remove_jobs
      }.not_to raise_error
    end
  end
end
