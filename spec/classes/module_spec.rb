require 'spec_helper'
require 'stringio'
require 'puppetdevel/module'
require 'puppetdevel/error'

describe PuppetDevel::Module do
  context 'when creating a standalone module' do
    describe '.create' do

      after(:all) do
        FileUtils.rm_r('/tmp/oss-integrationtest')
      end

      it do
        expect {
          PuppetDevel::Module.create(
            basedir: '/tmp',
            interactive: false,
            modulename: 'oss-integrationtest',
            moduleauthor: 'Integrationtest',
            modulesummary: 'A test module'
            )
        }.not_to raise_error
      end

      it do
        expect {
          PuppetDevel::Module.create(
            basedir: '/tmp',
            interactive: false,
            modulename: 'oss-integrationtest',
            moduleauthor: 'Integrationtest',
            modulesummary: 'A test module',
            quiet: true
            )
        }.to raise_error(PuppetDevel::ModuleExistsError, /already exists/)
      end

      context 'after creating a module' do
        describe file('/tmp/oss-integrationtest') do
          it { should be_directory }
        end

        describe file('/tmp/oss-integrationtest/.fixtures.yml') do
          it { should exist }
        end

        describe file('/tmp/oss-integrationtest/metadata.json') do
          it { should exist }
        end

        describe file('/tmp/oss-integrationtest/tests/init.pp') do
          it { should exist }
        end

        describe file('/tmp/oss-integrationtest/manifests/init.pp') do
          it { should exist }
        end

        describe file('/tmp/oss-integrationtest/spec/classes') do
          it { should be_directory }
        end
      end
    end

    describe '.remove' do
      before(:all) do
        PuppetDevel::Module.create(
          basedir: '/tmp',
          interactive: false,
          modulename: 'oss-integrationtest',
          moduleauthor: 'Integrationtest',
          modulesummary: 'A test module',
          quiet: true,
          )
      end

      it do
        expect {
          PuppetDevel::Module.remove(modulename: 'oss-integrationtest', basedir: '/tmp')
        }.not_to raise_error
      end

      describe file('/tmp/oss-integrationtest') do
        it { should_not exist }
      end
    end
  end

  context 'when creating a site module' do
    before(:all) do
      PuppetDevel::Git.clone_site
    end

    after(:all) do
      FileUtils.rm_rf('puppet/site/sitemodule', :secure => true)
    end

    it do
      expect {
        PuppetDevel::Module.create(
          basedir: 'puppet/site',
          sitemodule: true,
          interactive: false,
          modulename: 'oss-sitemodule',
          moduleauthor: 'Integration Test',
          modulesummary: 'Integration Test Module'
          )
      }.not_to raise_error
    end

    context 'when recreating the same module again' do
      it do
        expect {
          PuppetDevel::Module.create(
            basedir: 'puppet/site',
            sitemodule: true,
            interactive: false,
            modulename: 'oss-sitemodule',
            moduleauthor: 'Integration Test',
            modulesummary: 'Integration Test Module',
            quiet: true
            )
        }.to raise_error(PuppetDevel::ModuleExistsError, /already exists/)
      end
    end

    describe file('puppet/site/sitemodule') do
      it { should be_directory }
    end

    describe file('puppet/site/sitemodule/manifests/init.pp') do
      it { should be_file }
    end

    describe file('puppet/site/sitemodule/tests/init.pp') do
      it { should be_file }
    end

    describe file('puppet/site/sitemodule/spec/classes') do
      it { should be_directory }
    end

    describe file('puppet/site/sitemodule/Gemfile') do
      it { should_not exist }
    end

    describe file('puppet/site/sitemodule/.travis.yml') do
      it { should_not exist }
    end

    describe file('puppet/site/sitemodule/metadata.json') do
      it { should_not exist }
    end

    describe file('puppet/site/sitemodule/LICENSE') do
      it { should_not exist }
    end

    describe file('puppet/site/sitemodule/CHANGELOG') do
      it { should_not exist }
    end

    describe file('puppet/site/sitemodule/CONTRIBUTORS') do
      it { should_not exist }
    end

    describe file('puppet/site/sitemodule/CONTRIBUTING.md') do
      it { should_not exist }
    end
  end
end
