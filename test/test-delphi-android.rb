# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'rake'
require 'fileutils'
require 'test/unit'
require 'rake/delphi/dccaarmtool'
require 'rake/delphi/envvariables'
require 'rake/helpers/unittest'
require 'rake/helpers/raketask'
require 'helpers/consts'
require 'helpers/verinfo'
require 'zip/zip'
require 'apktools/apkxml'
require 'xmlsimple'

module DelphiAndroidTests

  class TestDelphiAndroid < DelphiTests::TestVerInfo
  public
    def project_path
      PROJECT_PATH
    end

    def project_name
      PROJECT_APK.pathmap('%n')
    end

  private
    REQUIRED_FILES = %Q[META-INF/MANIFEST.MF
        META-INF/ANDROIDD.SF
        META-INF/ANDROIDD.RSA
        lib/armeabi/libTestProject.so
        AndroidManifest.xml
        classes.dex
        resources.arsc
        res/drawable-hdpi/ic_launcher.png
        res/drawable-ldpi/ic_launcher.png
        res/drawable-mdpi/ic_launcher.png
        res/drawable-xhdpi/ic_launcher.png
        res/drawable-xxhdpi/ic_launcher.png].split(/\s+/)

    def _test_apk(apk)
      entries = []
      Zip::ZipFile.open(apk) do |zip|
        zip.each do |entry|
          # test all files in .apk
          assert REQUIRED_FILES.include?(entry.to_s), entry.to_s
          entries << entry.to_s
        end
      end
      REQUIRED_FILES.each do |file|
        # test all required file
        assert entries.include?(file), file
      end
      xml = ApkXml.new(apk)
      manifest = xml.parse_xml('AndroidManifest.xml')
      xml_hash = XmlSimple.xml_in(manifest, :ForceArray => false)
      assert_equal '0x2', xml_hash['android:versionCode'], 'versionCode'
      assert_equal '1.3.2.4', xml_hash['android:versionName'], 'versionName'
      assert_equal 'TestProject', xml_hash['application']['activity']['meta-data']['android:value'], '<application><meta-data android:value>'
    end

    def _test_compile_and_output(prepare_args, output)
      args = [:altercfg, :usecfg, :defines, :debuginfo, :debug, :includepaths]
      # reinitialize arguments (even absent ones)
      args.each do |arg|
        prepare_args[arg] = prepare_args[arg]
      end

      bin_dir = File.dirname(apk)
      dcu_dir_rel = '../../tmp/android/dcu'
      dcu_dir = bin_dir + '/../../' + dcu_dir_rel
      FileUtils.mkdir_p(bin_dir)
      FileUtils.mkdir_p(dcu_dir)
      # reenable task for subsequent calls
      prepare_task = ::Rake::Task['test_android:prepare']
      prepare_task.reenable
      # prepare arguments
      useresources = prepare_args[:useresources]
      prepare_args.delete(:useresources)
      prepare_args[:bin] = bin_dir
      prepare_args[:version] = '1.3.2.4'
      prepare_args[:dcu] = dcu_dir_rel.gsub('/', '\\')

      prepare_task.invoke(useresources, prepare_args)

      # reenable tasks (!!! after invoking 'test_android:prepare')
      task = ::Rake::Task['test_android:compile']
      task.reenable_chain
      task.invoke

      assert(File.exists?(apk), 'File %s does not exist' % apk)

      _test_apk(apk)
    end

    def apk
      return PROJECT_APK % name.gsub(/[():]/, '_')
    end

  public
    def setup
      fail 'Cannot compile this project with Delphi below XE5' if Rake::Delphi::EnvVariables.delphi_version < Rake::Delphi::DELPHI_VERSION_XE5
      Rake::Delphi::DccARMTool.reinit
      ENV['DELPHI_DIR'] = nil
      super
      ENV['RAKE_DIR'] = PROJECT_PATH
      File.unlink(apk) if File.exists?(apk)
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
        cfg = PROJECT_PATH.pathmap('%p%s') + PROJECT_APK.pathmap('%n.cfg')
        mv cfg, cfg.pathmap('%X.absent.cfg')
        begin
          _test_compile_and_output({:usecfg => true},
                                   'testproject works')
        ensure
          mv cfg.pathmap('%X.absent.cfg'), cfg
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

end
