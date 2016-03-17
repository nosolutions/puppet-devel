require 'uri'
require 'erb'
require 'jenkins_api_client'

require 'puppetdevel/settings'

module PuppetDevel
  class Jenkins

    JENKINS_CREDENTIALS_KEY = 'jenkins-ssh-key'
    JENKINS_UNITTEST_CMD    = <<END_UNITTEST_CMD
CONTAINER=$(docker run -d -v "$WORKSPACE/:/workspace" tosmi/puppetunit /bin/bash -c 'source ~/.bashrc; cd /workspace && rake syntax && rake lint && rake spec')
docker attach $CONTAINER
RC=$(docker wait $CONTAINER)
docker rm $CONTAINER
exit $RC
END_UNITTEST_CMD

    attr_reader :modulename, :jenkins_host, :jenkins_port, :jenkins_user, :client, :project_uri

    def initialize(puppetmodule=nil)
      @puppetmodule    = puppetmodule

      @gitlab_ssh_uri  = "ssh://git@#{SETTINGS.gitlab_host}:#{SETTINGS.gitlab_ssh_port}"
      @project_uri     = "#{@gitlab_ssh_uri}/#{SETTINGS.gitlab_group}/#{modulename}" if puppetmodule
      @client          = nil
      @unitest_job     = nil
      @acceptance_job  = nil
    end

    def self.create_jobs(modulename)
      jenkins = Jenkins.new(modulename)
      jenkins.connect
      jenkins.create_jobs
    end

    def self.remove_jobs(modulename)
      jenkins = Jenkins.new(modulename)
      jenkins.connect
      jenkins.remove_jobs
    end

    def self.status(jobname)
      jenkins = Jenkins.new
      jenkins.connect
      jenkins.status(jobname)
    end

    def self.console(jobname)
      jenkins = Jenkins.new
      jenkins.connect
      jenkins.console(jobname)
    end

    def self.build(job, params)
      jenkins = Jenkins.new
      jenkins.connect
      jenkins.build(job, params)
    end

    def self.pretty_status(job)
      jenkins = Jenkins.new
      jenkins.connect
      status = jenkins.status(job)
      case status
      when 'failure', 'aborted'
        puts "Jenkins job #{job} is in status: " + status.red.blink
      when 'running'
        puts "Jenkins job #{job} is in status: " + status.yellow
      when 'success'
        puts "Jenkins job #{job} is in status: " + status.green
      else
        puts "Jenkins job #{job} is in status: " + status
      end
    end

    def self.success?(job)
      jenkins = Jenkins.new
      jenkins.connect
      jenkins.status(job).eql?('success')
    end

    def self.details(job)
      jenkins = Jenkins.new
      jenkins.connect
      jenkins.details(job)
    end

    def self.queued?(job)
      jenkins = Jenkins.new
      jenkins.connect
      jenkins.queued?(job)
    end

    public

    def connect
      # currently jenkins run without auth
      # so we do not provide a username/password
      #
      @client = JenkinsApi::Client.new(
        :server_ip   => SETTINGS.jenkins_host,
        :server_port => SETTINGS.jenkins_port,
        :log_level   => 3,
        :username    => SETTINGS.jenkins_user,
        :password    => SETTINGS.jenkins_password,
        )

      if @client.get_root.code == '401'
        puts
        puts "You are not authorized to talk to jenkins at #{@jenkins_host} as user #{@jenkins_user}"
        abort
      end
    end

    def create_jobs
      create_acceptancetest_job
      create_unittest_job
    end

    def remove_jobs
      remove_acceptancetest_job
      remove_unittest_job
    end

    def status(jobname)
      client.job.get_current_build_status(jobname)
    end

    def console(jobname)
      output = client.job.get_console_output(jobname)
      output['output'].split('\n')
    end

    def build(job, params)
      client.job.build(job, params)
    end

    def details(job)
      client.queue.get_details(job)
    end

    def queued?(job)
      jobdetails = details(job)
      return jobdetails unless jobdetails.empty?
      return false
    end

    private

    def create_unittest_job
      @uniitest_job = client.job.create_freestyle(
        :name              => "#{modulename}_unittest",
        :keep_dependencies => true,
        :concurrent_build  => true,
        :scm_provider      => "git",
        :scm_url           => project_uri,
        :scm_credentials_id => PuppetDevel::Jenkins::JENKINS_CREDENTIALS_KEY,
        :scm_branch        => "*/*",
        :shell_command     => PuppetDevel::Jenkins::JENKINS_UNITTEST_CMD
        )
    rescue JenkinsApi::Exceptions::JobAlreadyExists
      puts "===> acceptance test job for #{modulename} already exists, skipping!"
    end

    def create_acceptancetest_job
      @acceptance_job = client.job.create_freestyle(
        :name              => "#{modulename}_acceptance",
        :keep_dependencies => true,
        :concurrent_build  => true,
        :scm_provider      => "git",
        :scm_url           => project_uri,
        :scm_branch        => "*/*",
        :scm_credentials_id => PuppetDevel::Jenkins::JENKINS_CREDENTIALS_KEY,
        :shell_command     => "rake beaker",
        :restricted_node   => 'puppet_acceptance',
        )
    rescue JenkinsApi::Exceptions::JobAlreadyExists
      puts "===> acceptance test job for #{modulename} already exists, skipping!"
    end

    def modulename
      @puppetmodule.metadata.dashed_name
    end

    def remove_unittest_job
      client.job.delete("#{modulename}_unittest")
    rescue JenkinsApi::Exceptions::NotFound
    end

    def remove_acceptancetest_job
      client.job.delete("#{modulename}_acceptance")
    rescue JenkinsApi::Exceptions::NotFound
    end
  end
end
