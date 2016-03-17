namespace :console do
  desc 'show the console output of the unittest job for a module'
  task :unittest, :module do |t, args|
    check_module(args[:module])
    PuppetDevel::Jenkins.console("#{args[:module]}_unittest").each do |line|
      puts "==> #{line}"
    end
  end

  desc 'show the console output of the acceptance job for a module'
  task :acceptance, :module do |t, args|
    check_module(args[:module])
    PuppetDevel::Jenkins.console("#{args[:module]}_acceptance").each do |line|
      puts "==> #{line}"
    end
  end

  desc 'show the console output of the deployment job'
  task :deployment do
    details = PuppetDevel::Jenkins.details("puppet-deployment")
    error("Deployment job is scheduled to run: #{details['why']}") unless details.empty?
    PuppetDevel::Jenkins.console("puppet-deployment").each do |line|
      puts "==> #{line}"
    end
  end

  desc 'show the console output of the legacy modules unittest job'
  task :legacy  do
    PuppetDevel::Jenkins.console("legacy-modules_unittest").each do |line|
      puts "==> #{line}"
    end
  end

  desc 'show the console output of the hiera-data unittest job'
  task :hiera  do
    PuppetDevel::Jenkins.console("hiera-data_unittest").each do |line|
      puts "==> #{line}"
    end
  end
end
