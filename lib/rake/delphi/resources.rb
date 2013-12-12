# encoding: utf-8

require 'erb'
require 'rake/common/classes'
require 'rake/delphi/rc'
require 'rake/helpers/gemversion'
require 'rake/helpers/rake'

module Rake
  module Delphi
    class RCTemplate
        attr_reader :language, :sublanguage, :lang, :codepage, :filetype
        alias :method_missing_base :method_missing

        def initialize(owner)
            @owner = owner
            # English
            @language = '0x19'
            @sublanguage = '0x01'
            # Russian
            @lang = '0419'
            # Russian
            @codepage = '04E3'
            # exe
            @filetype = '0x1'
            @versioninfo = nil
            @extra = {}
            @main_owner_task_name = @owner.name.gsub(/:rc:template$/, '')
            @main_owner_task = nil
        end

        def get_binding
            binding
        end

        def main_owner_task
            @main_owner_task ||= @owner.application[@main_owner_task_name]
        end

        def mainicon
            # take dcc33 task
            icon = main_owner_task.mainicon
        end

        def version
            Gem::VersionImproved.new(@extra[:version])
        end

        def versioninfo
            @versioninfo ||= main_owner_task.versionInfoClass.new(main_owner_task)
        end

        def product
            Gem::VersionImproved.new(self.versioninfo['ProductVersion'])
        end

        def []=(key, value)
            @extra[key] = value || ''
        end

        def method_missing(name, *args, &block)
            if args.empty? && @extra[name]
                @extra[name]
            elsif
                @source.name
            end
        end
    end

    class RCTemplateTask < Rake::Task
        def initialize(name, app)
            super
            @output = nil
            @template_file = File.expand_path('../../templates/project.erb', __FILE__)
            @template_obj = RCTemplate.new(self)
        end

        def output=(value)
            @output = value.pathmap('%X.rc')
        end

        def []=(key, value)
            @template_obj[key] = value
        end

        def execute(args=nil)
            erb = ERB.new(IO.read(@template_file))
            text = erb.result(@template_obj.get_binding)
            File.open(@output, 'w') do |f|
                f.write(text)
            end
        end
    end

    class RCTask < Rake::Task
        attr_accessor :output, :input
        def initialize(name, app)
            super
            @output = nil
            @is_rc = false
        end

        def input=(value)
            @input = value.pathmap('%X.rc')
            @output = @input.pathmap('%X.res')
        end

        def is_rc=(value)
            @is_rc = ! value.to_s.empty?
        end

        def execute(args=nil)
            v, path, tool = RCResourceCompiler.find(true)
            a = []
            a << '/dRC' if @is_rc
            a |= ['/fo', Rake.quotepath('', output), '/r', Rake.quotepath('', input) ]
            opts = { :args => a }
            opts.merge!(args)
            cmd = ([Rake.quotepath('', tool)] | opts[:args]).join(' ')
            RakeFileUtils.verbose(trace?) do
                sh cmd
            end
        end
    end
  end
end
