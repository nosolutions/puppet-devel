task :module => :help
namespace :module do
  desc 'create a new standalone module'
  task :create, [:module] => [:checkuser] do |t, args|
    error('Please verify that you git ssh key is loaded!') unless PuppetDevel::Gitlab::Client.ping
    modulename = if args[:module]
                   args[:module]
                 else
                   nil
                 end
    puppetmodule = PuppetDevel::Module.create(modulename: modulename)
    PuppetDevel::Gitlab::Client.create_repo(puppetmodule)
    gitrepo = PuppetDevel::Git.create_repo(puppetmodule)
    gitrepo.initial_push
    PuppetDevel::Jenkins.create_jobs(puppetmodule)
    Rake::Task['fixmodulelinks'].execute
  end

  desc 'completely remove a module (local copy, repository and jenkins jobs)'
  task :remove, :module  do |t, args|
    error('Please verify that you git ssh key is loaded!') unless PuppetDevel::Gitlab::Client.ping
    puts "=> removing project #{args[:module]}"
    PuppetDevel::Module.remove(modulename: args[:module])

    mod = PuppetDevel::PuppetModule.new({:name => args[:module]})
    puppetmodule = PuppetDevel::Module.new(mod.metadata)
    PuppetDevel::Gitlab::Client.remove_repo(puppetmodule)
    PuppetDevel::Jenkins.remove_jobs(puppetmodule)
    FileUtils.rm("modules/#{puppetmodule.metadata.name}")
  end

  desc 'add an exising module you would like to work on'
  task :add do
    name = PuppetDevel::Questioner.ask 'Enter the module name'
    uri = PuppetDevel::Questioner.ask 'Where can I find the module'
    SETTINGS.add_module(name: name, repository: uri)
    SETTINGS.save
  end

  desc 'show the current build status for a module'
  task :status, :module do |t, args|
    check_module(args[:module])
    PuppetDevel::Jenkins.pretty_status("#{args[:module]}_unittest")
    PuppetDevel::Jenkins.pretty_status("#{args[:module]}_acceptance")
  end

  desc 'create a new release'
  task :release, :module do |t, args|
    check_module(args[:module])

    PuppetDevel::Jenkins.pretty_status("#{args[:module]}_unittest")
    PuppetDevel::Jenkins.pretty_status("#{args[:module]}_acceptance")
    error("Unitests are running or failed, i'm not going to create a new release for #{args[:module]}!") unless PuppetDevel::Jenkins.success?("#{args[:module]}_unittest")

    puppetmodule = PuppetDevel::Modulefile.new("modules/#{args[:module]}")
    git          = PuppetDevel::Git.new(puppetmodule)
    error('You have to checkout the master branch before creating a release!') unless git.on_branch? 'master'

    puts "=> The current version of #{puppetmodule.metadata.name} is #{puppetmodule.metadata.version}."
    xyz = PuppetDevel::Questioner.ask 'Is this a major(x), minor(y) or bugfix(z) release (x/y/Z)', 'Z'

    version = puppetmodule.bump(xyz)

    git.commit("release #{version}")
    git.tag(version)
    git.push(update: false)
    git.push(update: false, tags: true)
    puts "=> The current version of #{puppetmodule.metadata.name} is now #{puppetmodule.metadata.version}"
  end

  desc 'deploy a module'
  task :deploy, :module do |t, args|
    error('You must specify a module name') unless args[:module]
    PuppetDevel::Jenkins.pretty_status("#{args[:module]}_unittest")
    PuppetDevel::Jenkins.pretty_status("#{args[:module]}_acceptance")

    puppetmodule = PuppetDevel::Modulefile.new("modules/#{args[:module]}")
    environment  = PuppetDevel::Questioner.readline('What environment would you like to deploy to? ', SETTINGS.environments)
    versions     = PuppetDevel::Git.get_tags("modules/#{args[:module]}")
    version      = PuppetDevel::Questioner.readline('What version would you like to deploy? ', versions)
    PuppetDevel::Jenkins.build(
      'puppet-deployment',
      {
        'PUPPET_MODULE' => puppetmodule.metadata.name,
        'PUPPET_ENVIRONMENT' => environment.strip,
        'PUPPET_MODULE_VERSION' => version.strip,
        'PUPPET_MODULE_REPOSITORY' => puppetmodule.metadata.source
      })
  end

  desc 'trigger unit and acceptance tests for a module'
  task :test, :module do |t, args|
    error('You must specify a module name') unless args[:module]
    puppetmodule = PuppetDevel::Modulefile.new("modules/#{args[:module]}")
    job_prefix = puppetmodule.metadata.dashed_name
    PuppetDevel::Jenkins.build("#{job_prefix}_unittest", {})
    PuppetDevel::Jenkins.build("#{job_prefix}_acceptance", {})
  end
end
