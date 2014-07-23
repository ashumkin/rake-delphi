# encoding: utf-8

require 'rake'
require 'rake/common/chdirtask'
require 'rake/common/logger'
require 'rake/delphi/envvariables'
require 'rake/delphi/resources'
require 'rake/delphi/dcc32tool'
require 'rake/delphi/dccaarmtool'
require 'rake/helpers/string'
require 'rake/helpers/rake'
require 'rake/helpers/raketask'

module Rake
  module Delphi
    class Dcc32Task < Rake::Task
        attr_accessor :systempath, :mainicon, :_source, :exeoutput, :bin
        attr_reader :dccTool

    private
        @@symbols = [:quiet, :assertions, :build, :optimization, :debug, :defines,
            :debuginfo, :localsymbols, :console, :warnings, :hints, :altercfg,
            :includepaths, :writeableconst,
            :map, :dcuoutput, :bploutput, :aliases, :platform, :namespaces,
            :dcpoutput, :dcu, :uselibrarypath, :uselibrarypath, :usecfg, :dcc_options]
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
            @platform = nil
            @platform_stripped = nil
            @dccToolClass = nil
            recreate_dcc_tool
        end

        def recreate_dcc_tool(checkExistance = false)
            @dccToolClass ||= Dcc32Tool
            @dccToolClass.reinit
            @dccTool = @dccToolClass.new(checkExistance)
        end

        # used in tests
        def reenable
            # recreate Dcc32Tool to reinitialize paths to tool
            recreate_dcc_tool(true)
            super
        end

        def versionInfoClass
            @dccTool.versionInfoClass
        end

        def createVersionInfo
            versionInfoClass.new(self)
        end

        def dcu=(value)
          # delete previously defined
          @prerequisites.delete_if do |d|
            if d.kind_of?(Rake::FileCreationTask)
               d.name.casecmp(@dcu) == 0
            end
          end
          @dcu = value
          dcu_task = directory @dcu
          enhance([dcu_task])
        end

        def platform=(value)
            @platform = value
            Logger.trace(Logger::DEBUG, 'PLATFORM set: ' + value)
            # strip digits from platform name Android
            @platform_stripped = @platform
            @platform_stripped = @platform.gsub(/\d/, '') if @platform.downcase.starts_with?('android')
            @dccToolClass = nil
            post_needed = false
            if @platform_stripped.downcase.to_sym == :android
                # set dccaarm compiler tool for Android platform
                @dccToolClass = DccARMTool
                post_needed = true
            end
            recreate_dcc_tool
            Logger.trace(Logger::DEBUG, 'DCC tool set: ' + @dccToolClass.to_s)
            # enable appropriate PAClientTask
            application[name + ':post'].needed = post_needed
            # for XE and above set default aliases and namespaces
            if ENV['DELPHI_VERSION'].to_i >= 14
                @aliases = 'Generics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Winapi.Windows;WinProcs=Winapi.Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE'
                @namespaces = 'Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Xml;Data;Datasnap;Web;Soap'
                Logger.trace(Logger::TRACE, 'Aliases and namespaces are set for Delphi XE')
            end
        end

        def exeoutput
            return @exeoutput || @bin
        end

    private
        def initvars
            @exeoutput = nil
            @@symbols.map do |sym|
                instance_variable_set("@#{sym.to_s}", nil)
            end
        end

        def delphilibs
            return [@dccTool.delphilib] | @dccTool.readLibraryPaths(@platform, @platform_stripped)
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

        def _aliases
            return @aliases ? Rake.quotepath('-A', @aliases) : ''
        end

        def _namespaces
            return @namespaces ? Rake.quotepath('-NS', @namespaces) : ''
        end

        def _dcuoutput
            return @dcuoutput || @dcu || @_source.pathmap('%d%sdcu')
        end

        def console?
          return @console.nil? ? '' : (@console ? '-CC' : '-CG')
        end

        def _map
            # segments -> -GS
            # publics   -> -GP
            # detailed  -> -GD
            return unless @map
            segments = @map.to_s[0..0].upcase
            return '-G' + segments
        end

        def _alldebuginfo
            return @debuginfo ? '-$D+ -$L+ -$YD' : '-$D- -$L- -$Y-'
        end

        def outputs
            os = []
            os << Rake.quotepath('-E', exeoutput)
            os << Rake.quotepath('-N', _dcuoutput)
            os << Rake.quotepath('-LE', @bploutput)
            return os
        end

        def _source
            return Rake.quotepath('', @_source.pathmap('%f'))
        end

        def _defines
            '-D' + @defines if @defines
        end

        def _writeableconst
            return '-$J' + (@writeableconst ? '+' : '-')
        end

        def build_args
            args = []
            args << @dccTool.options << dcc_options << build? << console? << warnings? << hints? << quiet? << debug? << _alldebuginfo << _map
            args << _defines << _writeableconst << _aliases << _namespaces
            args << _source << outputs << implicitpaths
            args.flatten
        end

    public
        def dpr
          @_source
        end

        def init(properties)
            Logger.trace(Logger::TRACE, properties)
            properties.map do |key, value|
                begin
                    send("#{key}=", value)
                rescue NoMethodError
                    instance_variable_set("@#{key}", value)
                end
            end
            @_source = properties[:projectfile].pathmap('%X.dpr')
            src = @_source.gsub('\\', '/')
            # make sure to create dir for output dcu
            # for now default is <PROJECTDIR>/dcu
            self.dcu = src.pathmap('%d%sdcu') unless @dcu
            # mainicon is usually requested by RCTemplate
            @mainicon ||= Rake.quotepath('', src.pathmap('%X.ico'))
            @rc_template_task.output = src
            @rc_template_task[:version] = properties[:version]
            @rc_template_task[:releaseCandidate] = properties[:releaseCandidate]
            @rc_task.input = src
            @rc_task.is_rc = properties[:releaseCandidate]
            @rc_task.mainicon_path = @mainicon
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
            super
            @dccTool.class.checkToolFailure(@dccTool.toolpath)
            fail "Could not find #{_source} to compile" unless @_source && File.exists?(@_source)
            init_libs
            args = build_args
            # on cygwin $D is assumed as shell var
            # so escape $
            args.map! { |a| a.gsub('$', '\$') if a.kind_of?(String) } unless application.windows?
            args.compact!
            cmd = Rake.quotepath('', @dccTool.toolpath)
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
