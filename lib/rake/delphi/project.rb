# encoding: utf-8

require 'rake'
require 'rake/common/classes'
require 'rake/common/libstask'
require 'rake/delphi/dcc32'
require 'rake/helpers/file'
require 'rake/helpers/raketask'
require 'rake/helpers/string'
require 'pp'

module Rake
  module Delphi
    class Project < Rake::Task
        attr_accessor :properties

        def initialize(name, app)
            super
            initvars
            @dcc = application.define_task(Dcc32Task, shortname + ':dcc32')
            @libs = LibsTask.define('all-delphi-libs', application)
            @level = 1
            enhance([@libs, @dcc])
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

        def init(module_name, rake_file, vars, level = 1)
            @level = level
            module_name = module_name.dup.pop.to_s
            self[:projectlabel] = eval("#{module_name}::PROJECT_NAME")
            projectfile = eval("#{module_name}::PROJECT_FILE")
            self[:projectfile] = File.dirname2(rake_file) + File.separator +  projectfile
            self[:sourcename] = File.dirname2(rake_file)
            @cdir = File.dirname(rake_file)
            self[:systempath] = @cdir + '/' + projectfile
            self[:altercfg].prepend(self[:sourcename] + '/') if self[:altercfg]
            [:version, :bin, :build, :dcu, :alldebuginfo, :map, :defines, :releaseCandidate].each do |k|
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
