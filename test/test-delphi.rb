# encoding: utf-8

require 'rake'
require 'fileutils'
require 'test/unit'
require 'rake/delphi'
require 'rake/delphi/project'
require 'rake/delphi/tool'
require 'rake/helpers/unittest'
require 'helpers/consts'
require 'helpers/verinfo'

module DelphiTests

class TestDelphi < TestVerInfo
private
    def reenable_tasks(task)
        return unless task.class <= Rake::Task
        task.reenable
        task.prerequisites.each do |ptask|
            ptask.reenable if ptask.class < Rake::Task
            reenable_tasks(ptask)
        end
    end

    def _test_compile_and_output(prepare_args, output)
        args = [:altercfg, :usecfg, :defines, :debuginfo, :debug, :includepaths]
        # reinitialize arguments (even absent ones)
        args.each do |arg|
            prepare_args[arg] = prepare_args[arg]
        end

        bin_dir = File.dirname(exe)
        FileUtils.mkdir_p(bin_dir)
        # reenable task for subsequent calls
        prepare_task = ::Rake::Task['test:prepare']
        prepare_task.reenable
        # prepare arguments
        useresources = prepare_args[:useresources]
        prepare_args.delete(:useresources)
        prepare_args[:bin] = bin_dir

        prepare_task.invoke(useresources, prepare_args)

        # reenable tasks (!!! after invoking 'test:prepare')
        task = ::Rake::Task['test:compile']
        reenable_tasks(task)
        task.invoke

        assert(File.exists?(exe), 'File %s does not exist' % exe)
        out = `#{exe}`.chomp
        assert_equal output, out, 'exe output'
    end

    def exe
        return PROJECT_EXE % name.gsub(/[():]/, '_')
    end

public
    def setup
        Rake::Delphi::Dcc32Tool.reinit
        ENV['DELPHI_DIR'] = nil
        super
        ENV['RAKE_DIR'] = PROJECT_PATH
        File.unlink(exe) if File.exists?(exe)
        res = PROJECT_PATH + '/resources.res'
        File.unlink(res) if File.exists?(res)
        require PROJECT_PATH + '/Rakefile.rb'
    end

    def test_compile
        _test_compile_and_output({},
            'testproject works')
    end

    def test_compile_defines
        _test_compile_and_output({:defines => 'DEBUG'},
            'DEBUG: testproject works')
    end

    def test_compile_debug_info
        _test_compile_and_output({:debug => true, :debuginfo => true},
            'D+: testproject works')
    end

    def test_compile_with_resources
        _test_compile_and_output({:useresources => true, :defines => 'RESOURCES'},
            'testproject works-=WITH RESOURCES=-')
    end

    def test_compile_with_libs
        _test_compile_and_output({:useresources => true, :defines => 'LIBS'},
            'testproject works-=WITH LIBS=-')
    end

    def test_compile_with_resources_and_libs
        _test_compile_and_output({:useresources => true, :defines => 'RESOURCES,LIBS'},
            'testproject works-=WITH RESOURCES=--=WITH LIBS=-')
    end

    def test_compile_consts
        _test_compile_and_output({:defines => 'ASSIGNABLE_CONSTS', :writeableconst => true},
            'testproject works-=ASSIGNED CONST=-')
    end

    def test_compile_alter_cfg
        _test_compile_and_output({:altercfg => 'release.dcc.cfg'},
            'testproject works-=RELEASE=-')
    end

    def test_compile_use_config
        _test_compile_and_output({:usecfg => true},
            'testproject works-=CONFIG=-')
    end

    def test_compile_use_absent_config
        RakeFileUtils.verbose(Rake::Delphi::Logger.debug?) do
            mv PROJECT_PATH.pathmap('%p%s%f.cfg'), PROJECT_PATH.pathmap('%p%s%f.absent.cfg')
            begin
                _test_compile_and_output({:usecfg => true},
                    'testproject works')
            ensure
                mv PROJECT_PATH.pathmap('%p%s%f.absent.cfg'), PROJECT_PATH.pathmap('%p%s%f.cfg')
            end
        end
    end

    def test_compile_use_library_path
        # usually Indy components are in Delphi library paths
        _test_compile_and_output({:defines => 'INDY', :uselibrarypath => true},
            'testproject works-=indy#path=-')
    end

    def test_compile_with_explicit_libs
        paths = ['./ExplicitLib/']
        _test_compile_and_output({:defines => 'EXPLICIT_LIBS',
                :includepaths => paths},
            'testproject works-=WITH EXPLICIT LIBS=-')
    end

    def test_compile_with_explicit_and_implicit_libs
        paths = ['./ExplicitLib/']
        _test_compile_and_output({:defines => 'LIBS,EXPLICIT_LIBS',
                :includepaths => paths},
            'testproject works-=WITH LIBS=--=WITH EXPLICIT LIBS=-')
    end
end

class TestCustomDelphiTool <  Test::Unit::TestCase
private
public
    def test_checkToolFailure
        assert_nothing_raised RuntimeError do
            Rake::Delphi::CustomDelphiTool.checkToolFailure(__FILE__)
        end
    end

    def test_checkToolFailure_failure
        assert_raise RuntimeError do
            Rake::Delphi::CustomDelphiTool.checkToolFailure(__FILE__ + '.ext')
        end
    end
end

# extend Rake::Delphi::RCResourceCompiler with .delphidir method
# (just for tests)
module Rake::Delphi

class RCResourceCompiler
    def delphidir
        @@delphidir
    end
end

end

class TestRCResourceCompiler < Test::Unit::TestCase
private
public
    def setup
        Rake::Delphi::RCResourceCompiler.reinit
        ENV['DELPHI_DIR'] = File.expand_path('../FakeDelphi', PROJECT_PATH)
        ENV['DELPHI_VERSION'] = '10'
    end

    def test_find
        rc = Rake::Delphi::RCResourceCompiler.new
        assert_equal ENV['DELPHI_DIR'], rc.delphidir, 'delphi path'
        assert_equal '10', rc.version, 'delphi version'
        assert_equal ENV['DELPHI_DIR'] + 'bin/rc.exe', rc.toolpath, 'delphi path'
    end
end

end
