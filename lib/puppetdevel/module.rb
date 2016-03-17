require 'uri'
require 'fileutils'

require 'puppet'
require 'puppet/settings'
require 'puppet/module_tool/metadata'
require 'puppet/face'
require 'puppet/face/module/generate'

require 'puppetdevel/settings'
require 'puppetdevel/error'
require 'puppetdevel/git'
require 'puppetdevel/questioner'

module PuppetDevel
  class PuppetModule
    attr_reader :metadata

    def initialize(data={})
      initialize_puppet

      @metadata = Puppet::ModuleTool::Metadata.new.update(
        'name'         => data[:name],
        'license'      => 'Apache-2.0',
        'version'      => '0.1.0',
        'author'       => data[:author]  || PuppetDevel::Git.get_config('user.name'),
        'summary'      => data[:summary] || 'I was too lazy for a summary',
        'source'       => data[:source]  || "",
        'dependencies' => [
          { 'name' => 'puppetlabs-stdlib', 'version_requirement' => '>= 1.0.0' }
        ]
        )
    end

    private

    def initialize_puppet
      # Only call Puppet.initialze_settings once
      # If new gets called a second time for another
      # module this raises an error. Dunno how
      # to check if puppet was already initialzed
      begin
        Puppet.initialize_settings
      rescue Puppet::DevError
      end
    end
  end

  class Module
    include Puppet::ModuleTool::Generate

    attr_reader :metadata, :basedir, :sitemodule, :quiet, :gitlab_project_uri, :gitlab_ssh_project_uri

    def initialize(metadata, basedir: nil, sitemodule: false, quiet: false)
      @metadata               = metadata
      @basedir                = basedir
      @sitemodule             = sitemodule
      @quiet                  = quiet
      @gitlab_project_uri     = "https://#{SETTINGS.gitlab_host}:#{SETTINGS.gitlab_port}/#{SETTINGS.gitlab_group}"
      @gitlab_ssh_project_uri = "ssh://git@#{SETTINGS.gitlab_host}:#{SETTINGS.gitlab_ssh_port}/#{SETTINGS.gitlab_group}"
    end

    def self.create(
        basedir: "#{File.dirname(__FILE__)}/../../modules",
        sitemodule: false,
        interactive: true,
        modulename: nil,
        moduleauthor: nil,
        modulesummary: nil,
        quiet: false
        )

      moduledata = {
        :name => modulename,
        :author => moduleauthor,
        :summary => modulesummary
      }
      metadata = PuppetDevel::PuppetModule.new(moduledata).metadata

      puppetmodule = Module.new(metadata, basedir: basedir, sitemodule: sitemodule, quiet: quiet)
      puppetmodule.interview if interactive
      puppetmodule.finalize
      puppetmodule.summary if interactive
      puppetmodule.create
      puppetmodule.fix_sitemodule if sitemodule
      puppetmodule
    end

    def self.remove(basedir: "#{File.dirname(__FILE__)}/../../modules", modulename: nil, quiet: false)
      module_path = "#{basedir}/#{modulename}"
      return if not File.directory? module_path
      FileUtils.rm_rf(module_path, :secure => true)
    end

    public

    def interview
      metadata.update 'name' => ask('What is the name of the new module') unless self.metadata.dashed_name
      metadata.update 'author' => ask('Who wrote this module', metadata.author)
      metadata.update 'summary' => ask('Please enter a short summary for this module', 'I was to lazy for a summary!')
    end

    def finalize
      metadata.update 'source' => "#{gitlab_ssh_project_uri}/#{metadata.dashed_name}.git"
      metadata.update 'project_page' => "#{gitlab_project_uri}/#{metadata.dashed_name}"
      metadata.update 'issues_url' => "#{gitlab_project_uri}/#{metadata.dashed_name}/issues"
    end

    def summary
      puts
      puts '-' * 40
      puts metadata.to_json
      puts '-' * 40
      input = ask('About to generate this module; continue','Yes')
      if input !~ /^y(es)?$/i
        puts "Aborting..."
        exit 0
      end
    end

    def fix_sitemodule
      module_dir     = "#{basedir}/#{metadata.dashed_name}"
      module_dir_new = "#{basedir}/#{metadata.name}"

      return if not File.directory? module_dir
      FileUtils.mv(module_dir, module_dir_new)

      cleanup_sitemodule
    end

    def create
      exists?
      Dir.chdir basedir do
        generate(metadata, true)
        raise PuppetDevel::ModuleGenerateError, "module #{basedir}/#{metadata.dashed_name} not created!" unless File.exist? "#{metadata.dashed_name}"
      end
    end

    private

    def ask(question, default=nil)
      PuppetDevel::Questioner.ask(question, default)
    end

    def exists?
      modulename = sitemodule ? metadata.name : metadata.dashed_name
      raise PuppetDevel::ModuleExistsError, "module #{basedir}/#{modulename} already exists!" if File.exists? "#{basedir}/#{modulename}"
    end

    def cleanup_sitemodule
      module_dir = "#{basedir}/#{metadata.name}"
      FileUtils.remove_file("#{module_dir}/Gemfile")
      FileUtils.remove_file("#{module_dir}/.travis.yml")
      FileUtils.remove_file("#{module_dir}/metadata.json")
      FileUtils.remove_file("#{module_dir}/LICENSE")
      FileUtils.remove_file("#{module_dir}/CHANGELOG")
      FileUtils.remove_file("#{module_dir}/CONTRIBUTORS")
      FileUtils.remove_file("#{module_dir}/CONTRIBUTING.md")
    end
  end
end
