# encoding: utf-8

require 'rake'
require 'fileutils'
require 'rake/delphi'
require 'rake/delphi/project'
require 'rake/delphi/tool'
require 'rake/helpers/string'
require 'rake/helpers/unittest'
require 'rake/helpers/raketask'
require 'helpers/consts'
require 'helpers/verinfo'

module DelphiTests

class TestDelphi < TestVerInfo
private
    def _test_prepare(prepare_args)
        args = [:altercfg, :usecfg, :defines, :debuginfo, :debug, :includepaths]
        # reinitialize arguments (even absent ones)
        args.each do |arg|
            prepare_args[arg] = prepare_args[arg]
        end

        bin_dir = File.dirname(exe)
        dcu_dir_rel = '../../tmp/win32/dcu'
        dcu_dir = bin_dir + '/../../' + dcu_dir_rel
        FileUtils.mkdir_p(bin_dir)
        FileUtils.mkdir_p(dcu_dir)
        # reenable task for subsequent calls
        prepare_task = ::Rake::Task['test:prepare']
        prepare_task.reenable
        # prepare arguments
        useresources = prepare_args[:useresources]
        prepare_args.delete(:useresources)
        prepare_args.delete(:useresources_ext)
        prepare_args[:bin] = bin_dir
        prepare_args[:dcu] = dcu_dir_rel.unix2dos_separator

        prepare_task.invoke(useresources, prepare_args)
    end

    def _test_compile_and_output(prepare_args, output)
        _test_prepare(prepare_args)
        # reenable tasks (!!! after invoking 'test:prepare')
        task = ::Rake::Task['test:compile']
        task.reenable_chain
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
        [exe, PROJECT_PATH + '/resources.res', PROJECT_PATH + '/extended_resources.dres'].each do |file|
            File.unlink(file) if File.exists?(file)
        end
        require PROJECT_PATH + '/Rakefile.rb'
    end

    def test_all_delphi_libs_task_name
        namespace :test_name do
            Rake.application.define_task(Rake::Delphi::Project, :'project:delphi')
        end
        assert_equal 'test_name:project:delphi:all-delphi-libs', ::Rake::Task['test_name:project:delphi:all-delphi-libs'].name
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

    def test_compile_with_resources_ext
        _test_compile_and_output({:useresources => 'ext', :defines => 'RESOURCES_EXT'},
            'testproject works-=WITH EXTENDED RESOURCES=-')
    end

    def test_compile_with_resources_all
        _test_compile_and_output({:useresources => 'ext', :defines => 'RESOURCES,RESOURCES_EXT'},
            'testproject works-=WITH RESOURCES=--=WITH EXTENDED RESOURCES=-')
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

class TestCustomDelphiTool < MiniTest::Unit::TestCase
private
public
    def test_checkToolFailure
        Rake::Delphi::CustomDelphiTool.checkToolFailure(__FILE__)
    end

    def test_checkToolFailure_failure
        assert_raises RuntimeError do
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

class TestRCResourceCompiler < MiniTest::Unit::TestCase
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
