require 'spec_helper'
require 'fileutils'

require 'puppetdevel/error'
require 'puppetdevel/settings'

describe PuppetDevel::Settings do
  context 'when user settings do not exist' do
    describe '.new' do
      it do
        expect {
          PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        }.not_to raise_error
      end
    end

    describe '#dump' do
      it do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')

        expect {
          settings.dump
        }.to output(/site_repository/).to_stdout
      end
    end

    describe '#site_repository' do
      it do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        expect(settings.site_repository).to match(/ssh/)
      end
    end

    describe '#site_repository=' do
      it do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        settings.site_repository = 'testrepo'
        expect(settings.site_repository).to eq 'testrepo'
      end
    end

    describe '#test_setting' do
      it do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        expect {
          settings.test_setting
        }.to raise_error PuppetDevel::SettingsError, /Setting test_setting not found/
      end
    end

    describe '#test_settings=' do
      it do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        settings.test_setting = 'value'
        expect(settings.test_setting).to eq 'value'
      end
    end

    describe '#[]' do
      context 'using a symbol' do
        it do
          settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
          expect(settings[:site_repository]).to match(/ssh/)
        end
      end

      context 'using a string' do
        it do
          settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
          expect(settings['site_repository']).to match(/ssh/)
        end
      end
    end

    describe '#[]=' do
      context 'using a symbol' do
        it do
          settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
          settings[:test_setting] = 'value'
          expect(settings.test_setting).to eq 'value'
        end
      end

      context 'using a string' do
        it do
          settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
          settings['test_setting'] = 'value'
          expect(settings.test_setting).to eq 'value'
        end
      end
    end

    describe '#gitlab_token' do
      it do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        settings.gitlab_user = 'root'
        settings.gitlab_host = 'localhost'
        settings.gitlab_port = '443'
        settings.gitlab_token = settings.get_gitlab_token(password: '5iveL!fe')

        expect(settings.gitlab_token).to match(/\w+/)
      end
    end

    describe '#save' do
      before(:each) do
        settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
        settings.test_setting1   = 'value1'
        settings[:test_setting2]  = 'value2'
        settings['test_setting3'] = 'value3'
        settings.save
      end

      after(:each) do
        FileUtils.rm('/tmp/user_settings.yaml')
      end

      describe file('/tmp/user_settings.yaml') do
        it { should be_a_file }
        it { should be_readable }
        it { should contain('site_repository:')}
        it { should contain('test_setting1: value1')}
        it { should contain('test_setting2: value2')}
        it { should contain('test_setting3: value3')}
      end
    end

    describe '#modules' do
      context 'no modules configured' do
        it do
          settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
          expect(settings.modules).to be_nil
        end
      end

      context 'adding a module' do
        it do
          settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
          settings.add_module(name: 'testmodule1', repository: 'https://test.com/git/testmodule1.git')
          settings.add_module(name: 'testmodule2', repository: 'https://test.com/git/testmodule2.git')
          expect(settings.modules['testmodule1']['name']).to eq 'testmodule1'
        end

        context 'when saving' do
          before(:all) do
            settings = PuppetDevel::Settings.new(user_settings_file: '/tmp/user_settings.yaml')
            settings.add_module(name: 'testmodule1', repository: 'https://test.com/git/testmodule1.git')
            settings.save
          end

          after(:all) do
            # FileUtils.rm('/tmp/user_settings.yaml')
          end

          describe file('/tmp/user_settings.yaml') do
            it { should be_a_file }
            it { should be_readable }
            it { should contain('modules:') }
            it { should contain('name: testmodule1') }
            its(:content) { should match(%r"repository: \"?https://test.com/git/testmodule1.git\"?") }
          end
        end
      end
    end
  end
end
