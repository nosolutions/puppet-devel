require 'readline'
require 'colorize'
require 'fileutils'

require 'puppetdevel/module'
require 'puppetdevel/modulefile'
require 'puppetdevel/questioner'
require 'puppetdevel/gitlab/client'
require 'puppetdevel/git'
require 'puppetdevel/jenkins'
require 'puppetdevel/version_helper'

Dir.glob('lib/puppetdevel/tasks/*.rake').each { |r| load r}

task :default => [:help]

desc 'configure the development environment'
task :config do
  require 'puppetdevel/settings'
  SETTINGS.interview
end

desc 'clone configured git repositories'
task :clone do
  PuppetDevel::Git.clone_modules
  PuppetDevel::Git.clone_site
  puts '=> successfully cloned your modules'
  Rake::Task['fixmodulelinks'].execute
end

desc 'remove all cloned repositories'
task :clean do
  print "You sure [y/N] "
  PuppetDevel::RakeHelper.cleanup if STDIN.gets.strip =~ /[yY]/
end

desc 'fix links to local modules for puppet apply testing'
task :fixmodulelinks do
  Dir.chdir('modules/') do
    Dir.glob('*-*').each do |puppet_module|
      short_name = puppet_module.split('-')[1]
      FileUtils.ln_s(puppet_module, short_name) unless File.exists?(short_name)
    end
  end
end

task :checkuser do
  require 'etc'

  if Etc::getlogin() != 'vagrant'
    puts "=> Please run this target from within a vagrant box as user vagrant!"
    exit 1
  end
end

task :help do
  system("rake -T")
end

def error(message)
  STDERR.puts message
  exit 1
end

def check_module(modulename)
  error('Please verify that you git ssh key is loaded!') unless PuppetDevel::Gitlab::Client.ping
  error('You must specify a module name') unless modulename

  unit_details = PuppetDevel::Jenkins.queued?("#{modulename}_unittest")
  acceptance_details = PuppetDevel::Jenkins.queued?("#{modulename}_acceptance")
  error("Job #{modulename}_unitest is scheduled to run: #{unit_details['why']}") if unit_details
  error("Job #{modulename}_unitest is scheduled to run: #{acceptance_details['why']}") if acceptance_details
end
