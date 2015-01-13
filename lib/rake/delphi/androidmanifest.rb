# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'erb'
require 'rake/helpers/raketask'
require 'rake/helpers/gemversion'
require 'rake/common/chdirtask'

module Rake
  module Delphi
    class AndroidManifestInfo
      attr_accessor :version

      def initialize(owner)
        @owner = owner
      end

      def get_binding
        binding
      end

      def version
        Gem::VersionImproved.new(@version)
      end

      def libname
        @owner.dccTask.dpr.pathmap('%n')
      end
    end

    class AndroidManifestTask < Rake::Task
      attr_reader :output, :dccTask
    public
      def initialize(name, application)
        super
        self.needed = false
        @template = 'AndroidManifest.erb'
        @output = 'AndroidManifest.xml'
        @template_obj = AndroidManifestInfo.new(self)
      end

      def execute(args = nil)
        super
        paclientTaskName = name.gsub(/:manifest$/, '')
        @dccTask = application[paclientTaskName].dccTask
        projectTaskName = @dccTask.name.gsub(/:dcc32$/, '')
        projectTask = application[projectTaskName]
        @template_obj.version = projectTask.properties[:version]
        ChDir.new(self, File.dirname(@dccTask.dpr)) do |dir|
          RakeFileUtils.verbose(Logger.debug?) do
            erb = ERB.new(IO.read(@template))
            text = erb.result(@template_obj.get_binding)
            File.open(@output, 'w') do |f|
              f.write(text)
            end
          end
        end
      end
    end # class AndroidManifestTask
  end
end
