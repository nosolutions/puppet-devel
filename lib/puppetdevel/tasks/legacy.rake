namespace :legacy do
  desc 'create a new release of legacy puppet modules'
  task :release do
    error('Please verify that you git ssh key is loaded!') unless PuppetDevel::Gitlab::Client.ping
    PuppetDevel::Jenkins.pretty_status("legacy-modules_unittest")
    error("Unitests are running or failed, i'm not going to create a new release!") unless PuppetDevel::Jenkins.success?("legacy-modules_unittest")

    puppetmodule = PuppetDevel::Modulefile.new("puppet/")

    # we have to explicitly set basedir and dashed_named
    # as the legacy modules are not real puppet modules.
    # git.rb expects a standalone puppet module...
    puppetmodule.basedir = './'
    puppetmodule.metadata.dashed_name = 'puppet'

    git = PuppetDevel::Git.new(puppetmodule)
    error('You have to checkout the development branch before creating a legacy release!') unless git.on_branch? 'development'

    puts "=> The current version of #{puppetmodule.metadata.name} is #{puppetmodule.metadata.version}."
    xyz = PuppetDevel::Questioner.ask 'Is this a major(x), minor(y) or bugfix(z) release (x/y/Z)', 'Z'
    version = puppetmodule.bump(xyz)

    git.commit("release #{version}")
    git.tag(version)
    git.push('development', update: false, tags: false)
    git.push('development', update: false, tags: true)
    puts "=> The current version of #{puppetmodule.metadata.name} is now #{puppetmodule.metadata.version}"
  end

  desc 'deploy the leagcy puppet modules'
  task :deploy do
    puppetmodule = PuppetDevel::Modulefile.new("puppet/")

    environments = ['production', 'testing', 'development']
    environment  = PuppetDevel::Questioner.readline('What environment would you like to deploy to? ', environments)
    versions     = PuppetDevel::Git.get_tags('puppet')
    versions     = versions.select! { |v| v[/^\d+\.\d+\.\d+$/] } # .sort { |x,y| PuppetDevel::VersionHelper.new(x) <=> PuppetDevel::VersionHelper.new(y) }
    version      = PuppetDevel::Questioner.readline('What version would you like to deploy? ', versions)
    PuppetDevel::Jenkins.build(
      'puppet-deployment',
      {
        'PUPPET_MODULE' => 'legacy',
        'PUPPET_ENVIRONMENT' => environment.strip,
        'PUPPET_MODULE_VERSION' => version.strip,
        'PUPPET_MODULE_REPOSITORY' => puppetmodule.metadata.source
      })
  end
end
