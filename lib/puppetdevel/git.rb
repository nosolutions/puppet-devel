require 'puppetdevel/settings'

module PuppetDevel
  class Git
    attr_reader :puppetmodule

    def initialize(puppetmodule=nil)
      @puppetmodule = puppetmodule
    end

    def self.create_repo(puppetmodule)
      repo = Git.new(puppetmodule)
      repo.init
      repo.initial_commit('Initial commit')
      repo.add_remote
      repo
    end

    def self.clone_site
      repo = Git.new
      repo.clone(SETTINGS.site_repository, 'puppet')
    end

    def self.clone_modules
      repo = Git.new
      raise PuppetDevel::GitError, 'no modules configured, run rake config or rake addmodule!' unless SETTINGS.modules
      SETTINGS.modules.values.each do |mod|
        repo.clone mod['repository']
        repo.make_symlink mod['symlink'], mod['repository']
      end
    end

    def self.get_config(key)
      `git config --get #{key}`.strip.chomp
    end

    def self.get_tags(repo)
      output = `git --git-dir="#{repo}/.git" tag`
      output.split
    end

    def self.get_branches(repo)
      output = `git --git-dir="#{repo}/.git" branch --no-color`
      output.split.drop(1)
    end

    public

    def init
      within_repo { execute("git init --quiet") }
    end

    def initial_commit(message)
      within_repo do
        execute("git add -A")
        execute("git commit --quiet -m '#{message}'")
      end
    end
    alias_method :commit, :initial_commit

    def add_remote
      within_repo { execute("git remote add origin #{ssh_uri()}") }
    end

    def initial_push(branch='master', update: true, tags: false)
      cmd = update ? "git push --quiet -u" : "git push --quiet"
      cmd = tags ? "#{cmd} --tags origin #{branch}" : "#{cmd} origin #{branch}"
      within_repo { execute(cmd) }
    end
    alias_method :push, :initial_push

    def clone(repo, target=nil)
      target = "modules/#{repo_base(repo)}" if target.nil?
      return if File.directory? target
      execute("git clone --quiet #{repo} #{target}")
    end

    def make_symlink(link, base)
      target = "modules/#{link}"
      FileUtils.ln_s "#{repo_base(base)}", target if not File.exists? target
    end

    def tag(tag)
      within_repo { execute "git tag -a #{tag} -m \"created #{tag}\""}
    end

    def on_branch?(branch)
      raise PuppetDevel::GitError, "Need to specify a branch name for on_branch?!" unless branch
      current_branch = `git --git-dir "#{puppetmodule.basedir}/#{puppetmodule.metadata.dashed_name}/.git" rev-parse  --abbrev-ref HEAD`.strip
      return true if current_branch == branch

      false
    end

    private

    def within_repo
      Dir.chdir "#{puppetmodule.basedir}/#{puppetmodule.metadata.dashed_name}" do
        yield
      end
    end

    def execute(command)
      system(*command.split(/\s(?=(?:[^"']|"[^"']*")*$)/))
      raise PuppetDevel::GitError, "Executing #{command} failed: #{$?.exitstatus}!" unless $?.exitstatus.zero?
    rescue ArgumentError => e
      raise PuppetDevel::GitError, "Executing #{command} with wrong arguments: #{e}!"
    end

    def ssh_uri
      "ssh://git@#{URI(puppetmodule.metadata.source).host}:#{SETTINGS.gitlab_ssh_port}/#{SETTINGS.gitlab_group}/#{puppetmodule.metadata.dashed_name}.git"
    end

    def repo_base(repo)
      repo.split('/').last.sub(/\.git$/,'')
    end
  end
end
