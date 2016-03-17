require 'spec_helper'

require 'puppetdevel/module'
require 'puppetdevel/modulefile'

describe PuppetDevel::Modulefile do
  describe '#new' do
    context 'load valid metadata' do
      before(:each) do
        PuppetDevel::Module.create(
          basedir: '/tmp',
          interactive: false,
          modulename: 'oss-releasetest',
          moduleauthor: 'Releasetest',
          modulesummary: 'A test module to be released'
          )
        @puppetmodule = PuppetDevel::Modulefile.new('/tmp/oss-releasetest')
      end

      after(:each) do
        FileUtils.rm_rf('/tmp/oss-releasetest', :secure => true)
      end

      it do
        expect {
          PuppetDevel::Modulefile.new('/tmp/oss-releasetest')
        }.not_to raise_error
      end

      it { expect(@puppetmodule.metadata.name).to eq "releasetest" }
      it { expect(@puppetmodule.metadata.dashed_name).to eq "oss-releasetest" }
      it { expect(@puppetmodule.metadata.author).to eq "Releasetest" }
    end

    context 'loading non-existing metadata' do
      it do
        expect {
          PuppetDevel::Modulefile.new('/tmp/oss-notreleasetest')
        }.to raise_error(PuppetDevel::ModulefileError, /Could not load metadata/)
      end
    end
  end

  describe '.bump' do
    before(:each) do
      PuppetDevel::Module.create(
        basedir: '/tmp',
        interactive: false,
        modulename: 'oss-releasetest',
        moduleauthor: 'Releasetest',
        modulesummary: 'A test module to be released'
        )
      @puppetmodule = PuppetDevel::Modulefile.new('/tmp/oss-releasetest')
    end

    after(:each) do
      FileUtils.rm_rf('/tmp/oss-releasetest', :secure => true)
    end

    it do
      @puppetmodule.bump('x')
      expect(@puppetmodule.metadata.version).to eq('1.0.0')
    end

    it do
      @puppetmodule.bump('y')
      expect(@puppetmodule.metadata.version).to eq('0.2.0')
    end

    it do
      @puppetmodule.bump('z')
      expect(@puppetmodule.metadata.version).to eq('0.1.1')
    end

    describe file('/tmp/oss-releasetest/metadata.json') do
      it do
        @puppetmodule.bump('z')
        should contain '0.1.1'
      end
    end

    describe file('/tmp/oss-releasetest/metadata.json') do
      it do
        @puppetmodule.bump('z')
        should contain '"name": "oss-releasetest"'
      end
    end
  end
end
