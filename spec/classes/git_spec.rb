require 'spec_helper'

require 'puppetdevel/settings'
require 'puppetdevel/module'
require 'puppetdevel/modulefile'
require 'puppetdevel/gitlab/client'
require 'puppetdevel/git'

describe PuppetDevel::Git do
  describe '.create_repo' do
    before(:all) do
      @puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: 'oss-integrationtest',
        moduleauthor: 'Integrationtest',
        modulesummary: 'A test module',
        quiet: true
        )
    end

    after(:all) do
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: 'oss-integrationtest', quiet: true)
    end

    it do
      PuppetDevel::Git.create_repo(@puppetmodule)
      # expect{ PuppetDevel::Git.create_repo(@puppetmodule) }.to output(/initialized local git repo for module \w+/).to_stdout
    end

    describe file('/tmp/oss-integrationtest/.git') do
      it { should be_directory }
    end

    describe file('/tmp/oss-integrationtest/.git/config') do
      its(:content) { should match(/url =.*#{@puppetmodule.metadata.dashed_name}.git/) }
    end

    describe command('cd /tmp/oss-integrationtest; git --no-pager ls-files') do
      its(:stdout) { should match(/manifests\/init.pp/) }
    end

    describe command('cd /tmp/oss-integrationtest; git --no-pager log -n 1 --oneline') do
      its(:stdout) { should match(/Initial commit/) }
    end
  end

  describe '.config' do
    it 'querying user.name should return string 'do
      username = PuppetDevel::Git.get_config('user.name')
      expect(username).to match(/\S+/)
    end
  end

  describe '.clone_modules' do
    it do
      modulename = 'oss-gitlabclonetest'
      puppetmodule = PuppetDevel::PuppetModule.new({
          :name => modulename,
          :author => 'under test',
          :source => "ssh://git@#{SETTINGS.gitlab_host}/#{SETTINGS.gitlab_group}/#{modulename}.git"
        })
      PuppetDevel::Gitlab::Client.create_repo(puppetmodule)
      SETTINGS.add_module(name: 'gitclonemodule', repository: puppetmodule.metadata.source)

      expect {
        PuppetDevel::Git.clone_modules
      }.not_to raise_error
      PuppetDevel::Gitlab::Client.remove_repo(puppetmodule)
      PuppetDevel::Module.remove(modulename: modulename, quiet: true)
    end
  end

  describe '.inital_push' do
    it do
      modulename = 'oss-gitlabpushtest'
      puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
            interactive: false,
            modulename: modulename,
            moduleauthor: 'Integrationtest',
            modulesummary: 'A test module',
            quiet: true
        )
      PuppetDevel::Gitlab::Client.create_repo(puppetmodule)
      gitrepo = PuppetDevel::Git.create_repo(puppetmodule)
      expect {
        gitrepo.initial_push
      }.not_to raise_error
      PuppetDevel::Gitlab::Client.remove_repo(puppetmodule)
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: modulename, quiet: true)
    end
  end

  describe '.commit' do
    it do
      modulename = 'oss-committest'
      puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: modulename,
        moduleauthor: 'Integrationtest',
        modulesummary: 'A test module',
        quiet: true
        )

      modulefile = PuppetDevel::Modulefile.new("/tmp/#{modulename}")
      gitrepo = PuppetDevel::Git.create_repo(puppetmodule)
      modulefile.bump('z')
      gitrepo.commit('testcommit')
      output = `git --no-pager --git-dir="/tmp/#{modulename}/.git" log -n 1 --oneline`
      expect(output).to match /testcommit/
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: modulename, quiet: true)
    end
  end

  describe '.tag' do
    it do
      modulename = 'oss-tagtest'
      puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: modulename,
        moduleauthor: 'Integrationtest',
        modulesummary: 'A test module',
        quiet: true
        )

      gitrepo = PuppetDevel::Git.create_repo(puppetmodule)
      gitrepo.tag('testtag')
      output = `git --no-pager --git-dir="/tmp/#{modulename}/.git" tag -l testtag`
      expect(output).to match /testtag/
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: modulename, quiet: true)
    end
  end

  describe '.on_branch?' do
    it do
      modulename = 'oss-onbranchtest'
      puppetmodule = PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: modulename,
        moduleauthor: 'Integrationtest',
        modulesummary: 'A test module',
        quiet: true
        )
      gitrepo = PuppetDevel::Git.create_repo(puppetmodule)
      on_master = gitrepo.on_branch?('master')
      expect(on_master).to eql(true)
      PuppetDevel::Module.remove(basedir: '/tmp', modulename: modulename, quiet: true)
    end
  end
end
