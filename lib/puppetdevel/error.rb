module PuppetDevel

  class Error < StandardError
  end

  class ModuleExistsError < Error
  end

  class ModuleGenerateError < Error
  end

  class SettingsError < Error
  end

  class GitlabTokenError < Error
  end

  class GitlabClientError < Error
  end

  class GitError < Error
  end

  class ModulefileError < Error
  end

  class JenkinsError < Error
  end
end
