# encoding: Windows-1251
# vim: set shiftwidth=2 tabstop=2 expandtab:

require 'rake'
require 'test/unit'
require 'rake/delphi'
require 'rake/delphi/projectinfo'
require 'rake/delphi/dcc32'
require 'rake/helpers/unittest'
require 'helpers/consts'
require 'helpers/verinfo'

module DelphiAndroidTests

  class TestXE7VersionInfo < DelphiTests::TestVerInfo
  private
    def version
      'XE7'
    end

  protected
    def delphi_version
      return '21'
    end

    def do_getinfo
      @info = Rake::Delphi::XEVersionInfo.new(@rake_task)
    end

    def project_path
      PROJECT_PATH
    end

    def project_name
      PROJECT_APK.pathmap('%n')
    end

  public
    def setup
      super
      @rake_task = Rake::Delphi::Dcc32Task.new('some-task-' + name, Rake.application)
      @rake_task.systempath = project_path + '/TestProject.dpr'
      do_getinfo
    end

    def test_info
      return unless prepare_ver_info_file?
      assert_equal '4.3.2.1', @info['FileVersion']
      assert_equal 'Rake', @info['CompanyName']
      assert_equal 'Test rake-delphi project %s description' % version, @info['FileDescription']
      assert_equal 'testproject.exe', @info['InternalName']
      assert_equal 'Copyright. Копирайт', @info['LegalCopyright']
      assert_equal 'Trademark. Торговая марка', @info['LegalTrademarks']
      assert_equal 'testproject.exe', @info['OriginalFilename']
      assert_equal 'Test rake-delphi project %s product name' % version, @info['ProductName']
      assert_equal '1.2.3.4', @info['ProductVersion']
      assert_equal 'Test project comment', @info['Comments']
    end

    def test_deploy_files
      tested_deploymentFiles = []
      tested_deploymentFiles_prefixes = { 36 => 'l', 48 => 'm', 72 => 'h', 96 => 'xh', 144 => 'xxh'}
      [36, 48, 72, 96, 144].each do |n|
        tested_deploymentFiles << '$(BDS)\bin\Artwork\Android\FM_LauncherIcon_%dx%d.png,res\drawable-%sdpi\,1,ic_launcher.png' % [n, n, tested_deploymentFiles_prefixes[n]]
      end
      tested_deploymentFiles << 'project_so,library\lib\armeabi\,1,libTestProject.so'
      tested_deploymentFiles << '$(BDS)\lib\android\debug\classes.dex,classes\,1,classes.dex'
      tested_deploymentFiles << 'external\module.ext,.\assets\internal\\\\,1,'
      tested_deploymentFiles << '$(BDS)\lib\android\debug\mips\libnative-activity.so,library\lib\mips\,1,libTestProject.so'
      tested_deploymentFiles << '$(BDS)\lib\android\debug\armeabi\libnative-activity.so,library\lib\armeabi\,1,libTestProject.so'
      deploymentfiles = @info.deploymentfiles('Android')
      assert deploymentfiles.kind_of?(Array), 'NOT an Array?!'
      assert_not_equal 0, deploymentfiles.size, 'No files?!'
      deploymentfiles.each do |dfile|
        assert dfile.kind_of?(Hash), 'NOT a Hash?!'
        assert_equal 1, dfile.keys.count, 'More than one value?!'
        assert dfile.keys.first.kind_of?(String) || dfile.keys.first.kind_of?(Symbol), 'Key is NOT a String or Symbol?!'
        assert dfile.values.first.kind_of?(Array), 'Value is NOT an Array?!'
        assert tested_deploymentFiles.include?(dfile.to_a.join(',')), dfile.to_a.join(',')
      end
    end
  end

end
