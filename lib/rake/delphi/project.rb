# encoding: utf-8

require 'rake'
require 'rake/common/classes'
require 'rake/common/libstask'
require 'rake/delphi/dcc32'
require 'rake/delphi/paclient'
require 'rake/helpers/file'
require 'rake/helpers/raketask'
require 'rake/helpers/string'

module Rake
  module Delphi
    class Project < Rake::Task
        attr_accessor :properties

        def initialize(name, app)
            super
            initvars
            @dcc = application.define_task(Dcc32Task, shortname + ':dcc32')
            @libs = LibsTask.define(shortname + ':all-delphi-libs', application)
            @post = application.define_task(PAClientTask, @dcc.shortname + ':post')
            @level = 1
            enhance([@libs, @dcc, @post])
        end

        def initvars
            @properties = {
                :build => true,
                :warnings => false,
                :hints => false,
                :includepaths => nil
            }
            @cdir = ''
        end

        def init_libs
            self[:includepaths] = ['.'] unless self[:includepaths]
            self[:includepaths] |= @libs.libs_relative(@level)
            @dcc.init_libs(self[:includepaths])
        end

        def init(module_name, rake_file, vars, level)
            @level = level
            module_name = module_name.dup.shift.to_s
            self[:projectlabel] = eval("#{module_name}::PROJECT_NAME")
            projectfile = eval("#{module_name}::PROJECT_FILE")
            self[:projectfile] = File.dirname2(rake_file) + File.separator +  projectfile
            self[:sourcename] = File.dirname2(rake_file)
            @cdir = File.dirname(rake_file)
            self[:systempath] = @cdir + '/' + projectfile
            self[:altercfg].prepend(self[:sourcename] + '/') if self[:altercfg]
            [:version, :bin, :build, :dcu, :debug, :debuginfo, :map, :defines, :releaseCandidate].each do |k|
                self[k] = vars[k] if vars.has_key?(k)
            end if vars

            @dcc.init(@properties)
        end

        def []=(key, value)
            @properties[key.to_sym] = value
        end

        def [](key)
            return @properties[key]
        end
    end
  end
end
