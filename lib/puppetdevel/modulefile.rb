require 'json'
require 'ostruct'
require 'puppetdevel/version_helper'
require 'puppetdevel/error'

module PuppetDevel
  class Modulefile
    METADATA_JSON = 'metadata.json'

    attr_reader :modulefile, :metadata
    attr_accessor :basedir

    def initialize(moduledir)
      @basedir = File.dirname(moduledir)
      @modulefile = "#{moduledir}/#{METADATA_JSON}"

      # we use openstruct in this case so
      # Modulefile.metadata is a duck type for Module.metadata
      @metadata = OpenStruct.new load_modulefile
      @metadata.dashed_name = @metadata.name
      @metadata.name = @metadata.dashed_name.sub(/^[\w]+-/,'')
    end

    def bump(xyz)
      xyz.downcase!
      version_matrix = {
        :x => :major,
        :y => :minor,
        :z => :patch
      }
      raise PuppetDevel::ModulefileError, 'Please use x/y/z to specify a major/minor/patch version bump!' unless version_matrix[xyz.to_sym]
      version = PuppetDevel::VersionHelper.new(metadata.version).send("#{version_matrix[xyz.to_sym]}!").to_s
      @metadata.version = version
      save_modulefile
      version
    end

    private

    def load_modulefile
      content = File.read(modulefile)
      JSON.parse(content, symbolize_names: true)
    rescue => e
      raise PuppetDevel::ModulefileError, "Could not load metadata: #{e}"
    end

    def save_modulefile
      data = @metadata.to_h
      data[:name] = @metadata.dashed_name
      json = JSON.pretty_generate(data)

      File.open(modulefile, "w") {|file| file.puts json}
    end
  end
end
