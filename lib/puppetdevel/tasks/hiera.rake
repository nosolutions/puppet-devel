namespace :hiera do
  desc "clone the hiera data repository"
  task :clone do
    git = PuppetDevel::Git.new
    git.clone(SETTINGS.hiera_repository, 'hiera-data')
  end

  desc "deploy hiera data"
  task :deploy do
    PuppetDevel::Jenkins.pretty_status("hiera-data_unittest")
    error("Unitests are running or failed, i'm not going to deploy that shit!") unless PuppetDevel::Jenkins.success?("hiera-data_unittest")

    environment = PuppetDevel::Questioner.readline('What environment would you like to deploy to? ', SETTINGS.environments)
    branches    = PuppetDevel::Git.get_branches('hiera-data')
    branch      = PuppetDevel::Questioner.readline('Which branch would you like to deploy? ', branches)
    PuppetDevel::Jenkins.build(
      'puppet-deployment',
      {
        'PUPPET_ENVIRONMENT' => environment,
        'HIERA_BRANCH'       => branch,
        'HIERA_DEPLOYMENT'   => 'true',
      })
  end
end
