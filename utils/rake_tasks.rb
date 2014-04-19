require 'rake'
require 'yaml'

$module_name = nil

def puppet_module(option)
  puppet_module = YAML.load_file('puppet-module.yml')['puppetmodule']
  puppet_module[option]
end

task :default => [:help]

desc 'clone the git repository configured in puppet-module.yml'
task :clone do
  repo = puppet_module('repository')
  $module_name = File.basename(repo,".*")

  system("git clone #{repo}") if not File.directory? $module_name
end

task :symlink => [:clone] do
  symlink = puppet_module('symlink')
  if not File.symlink? "fixtures/modules/#{symlink}"
    File.symlink("../../#{$module_name}", "fixtures/modules/#{symlink}")
  end
end

desc 'run rspec with the vagrant vm for the puppet module'
task :spec => [:clone, :symlink] do
  system("vagrant ssh -c 'cd /vagrant/#{$module_name}; rake spec'")
end

desc 'prepare to run rspec tests'
task :spec_prep => [:clone, :symlink] do
  system("vagrant ssh -c 'cd /vagrant/#{$module_name}; rake spec_prep'")
end


desc 'run rspec tests on an existing fixtures directory (use spec_prep before)'
task :spec_standalone => [:clone, :symlink] do
  system("vagrant ssh -c 'cd /vagrant/#{$module_name}; rake spec_standalone'")
end

task :help do
  system("rake -T")
end
