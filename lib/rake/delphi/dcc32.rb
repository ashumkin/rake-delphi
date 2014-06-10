# encoding: utf-8

require 'rake'
require 'rake/common/chdirtask'
require 'rake/common/logger'
require 'rake/delphi/envvariables'
require 'rake/delphi/resources'
require 'rake/delphi/tool'
require 'rake/helpers/rake'
require 'rake/helpers/raketask'

module Rake
  module Delphi
    class Dcc32Tool < CustomDelphiTool
        def self.toolName
            'bin/dcc32.exe'
        end

        def delphidir
            @@delphidir
        end

        def delphilib
            ENV['BDSLIB']
        end

        def readLibraryPaths
            libpaths = self.class.readUserOption('Library', 'Search Path', self.version).split(';') \
                | self.class.readUserOption('Library', 'SearchPath', self.version).split(';')
            dev = EnvVariables.new(self.class.rootForVersion(self.version) + '\Environment Variables', self.delphidir)
            libpaths.map! do |lp|
                unless lp.to_s.empty?
                    lp = dev.expand(lp)
                end
                lp
            end
            Logger.trace(Logger::TRACE, libpaths)
            return libpaths
        end
    end

    class Dcc32Task < Rake::Task
        attr_accessor :systempath, :mainicon, :_source, :exeoutput, :bin

    private
        @@symbols = [:quiet, :assertions, :build, :optimization, :debug, :defines,
            :debuginfo, :localsymbols, :console, :warnings, :hints, :altercfg,
            :includepaths, :writeableconst,
            :map, :dcuoutput, :bploutput,
            :dcpoutput, :dcu, :uselibrarypath, :uselibrarypath, :usecfg]
    public
        @@symbols.map do |sym|
            attr_accessor sym unless method_defined?(sym)
        end

        def initialize(name, application)
            super
            initvars
            @arg_names = [:verbose]
            @rc_template_task = application.define_task(RCTemplateTask, shortname + ':rc:template')
            @rc_task = application.define_task(RCTask, shortname + ':rc')
            enhance([@rc_template_task, @rc_task])
            @dcc32Tool = Dcc32Tool.new
        end

        # used in tests
        def reenable
            # recreate Dcc32Tool to reinitialize paths to tool
            @dcc32Tool = Dcc32Tool.new(true)
            super
        end

        def versionInfoClass
            @dcc32Tool.versionInfoClass
        end

    private
        def initvars
            @exeoutput = nil
            @@symbols.map do |sym|
                instance_variable_set("@#{sym.to_s}", nil)
            end
        end

        def delphilibs
            return [@dcc32Tool.delphilib] | @dcc32Tool.readLibraryPaths
        end

        def _paths(ppaths)
            ppaths.map! do |p|
                a = []
                ['U', 'I', 'R', 'O'].each do |s|
                    a << Rake.quotepath("-#{s}", p)
                end
                a
            end
            # unique paths only
            ppaths.flatten!.uniq!
            ppaths
        end

        def implicitpaths
            ipaths = ['.', '..']
            ipaths |= delphilibs if @uselibrarypath
            _paths(ipaths)
        end

        def paths
            @includepaths ||= []
            _paths(@includepaths)
        end

        def debug?
            return @debug ? '-$D+ -$L+ -$YD -$C+ -$Q+ -$R+ -$O- -GD' : ''
        end

        def build?
            return @build ? '-B' : '-M'
        end

        def warnings?
            return @warnings ? '-W-' : '-W+'
        end

        def hints?
            return @hints ? '-H-' : '-H+'
        end

        def quiet?
            return @quiet ? '-Q' : ''
        end

        def exeoutput
            return @exeoutput || @bin
        end

        def dcuoutput
            return @dcuoutput || @dcu || @_source.pathmap('%d%sdcu')
        end

        def map
            # segments -> -GS
            # publics   -> -GP
            # detailed  -> -GD
            return unless @map
            segments = @map.to_s[0..0].upcase
            return '-G' + segments
        end

        def alldebuginfo
            return @debuginfo ? '-$D+ -$L+ -$YD' : '-$D- -$L- -$Y-'
        end

        def outputs
            os = []
            os << Rake.quotepath('-E', exeoutput)
            os << Rake.quotepath('-N', dcuoutput)
            os << Rake.quotepath('-LE', @bploutput)
            return os
        end

        def _source
            return Rake.quotepath('', @_source)
        end

        def defines
            '-D' + @defines if @defines
        end

        def writeableconst
            return '-$J' + (@writeableconst ? '+' : '-')
        end

        def build_args
            args = []
            args << build? << warnings? << hints? << quiet? << debug? << alldebuginfo << map
            args << defines << writeableconst
            args << _source << outputs << implicitpaths
            args.flatten
        end

    public
        def init(properties)
            Logger.trace(Logger::TRACE, properties)
            properties.map do |key, value|
                instance_variable_set("@#{key}", value)
            end
            @_source = properties[:projectfile].pathmap('%X.dpr')
            src = @_source.gsub('\\', '/')
            dcu = src.pathmap('%d%sdcu')
            # make sure to create dir for output dcu
            # for now default is <PROJECTDIR>/dcu
            directory dcu
            enhance([dcu])
            # mainicon is usually requested by RCTemplate
            @mainicon ||= Rake.quotepath('', src.pathmap('%X.ico'))
            @rc_template_task.output = src
            @rc_template_task[:version] = properties[:version]
            @rc_template_task[:releaseCandidate] = properties[:releaseCandidate]
            @rc_task.input = src
            @rc_task.is_rc = properties[:releaseCandidate]
            return unless properties[:resources_additional]
            res_add = properties[:resources_additional]
            if res_add.kind_of?(String)
                res_add = res_add.split(';')
            end
            c = 0
            res_add.each do |res|
                if res.kind_of?(Symbol)
                    rc_task_add = res
                else
                    c = c.next
                    rc_task_add = application.define_task(RCTask, shortname + ':rc:add' + c.to_s)
                    rc_task_add.input = src.pathmap('%d%s') + res
                end
                enhance([rc_task_add])
            end
        end

        def init_libs(libs = nil)
            unless libs
                # call parent to find libs
                application[name.gsub(/:dcc32$/, '')].init_libs
            else
                # called from parent
                # set libs
                @includepaths = libs
            end
        end

        def execute(opts=nil)
            @dcc32Tool.class.checkToolFailure(@dcc32Tool.toolpath)
            fail "Could not find #{_source} to compile" unless @_source && File.exists?(@_source)
            init_libs
            args = build_args
            # on cygwin $D is assumed as shell var
            # so escape $
            args.map! { |a| a.gsub('$', '\$') if a.kind_of?(String) } unless application.windows?
            args.compact!
            cmd = Rake.quotepath('', @dcc32Tool.toolpath)
            cmd << ([''] | args).join(' ')
            ChDir.new(self, File.dirname(@_source)) do |dir|
                RakeFileUtils.verbose(Logger.debug?) do
                    begin
                        unless @usecfg
                            cfg = @systempath.pathmap('%X.cfg')
                            bak_cfg = @systempath.pathmap('%X.rake.cfg')
                            if File.exists?(cfg)
                                mv cfg, bak_cfg
                            else
                                warn "WARNING! Config #{cfg} is absent!"
                            end
                            if @altercfg
                                cp @altercfg, cfg
                            end
                            # on Windows there is some limit on command line parameters length
                            # so we just append path parameters to config file
                            File.open(cfg, 'a+') do |f|
                                paths.each do |p|
                                    f.write(p + "\n")
                                end
                            end
                        end
                        sh cmd
                    ensure
                        unless @usecfg
                            begin
                                cp cfg, cfg + '.1' if trace?
                            ensure
                                mv bak_cfg, cfg if File.exists?(bak_cfg)
                            end
                        end
                    end
                end
            end
            puts '' # make one empty string to separate from further lines
        end
    end
  end
end
