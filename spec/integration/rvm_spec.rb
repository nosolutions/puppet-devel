require 'spec_helper'

context 'checking rvm installation' do
  describe command('rvm list strings') do
    its(:stdout) { should match /ruby-2\.1\.6/ }
  end
end
