require 'spec_helper'

context 'checking packages' do
  describe package('git') do
    it { should be_installed }
  end

  describe package('jenkins') do
    it { should be_installed }
  end

  describe package('gitlab-ce') do
    it { should be_installed }
  end
end
