require 'fileutils'
require 'test/unit'
require 'helpers/consts'
require 'rake/delphi/envvariables'

module DelphiTests

class TestVerInfo < Test::Unit::TestCase
    DPROJ_VERSIONS = { '10' => '2006.bdsproj', '11' => '2007.dproj' }

protected
    def delphi_version
        return Rake::Delphi::EnvVariables.delphi_version
    end
public
    def setup
        @saved_delphi_version = Rake::Delphi::EnvVariables.delphi_version
        ENV['DELPHI_VERSION'] = delphi_version
        template_ext = DPROJ_VERSIONS[delphi_version]
        raise 'DELPHI_VERSION unknown (%s). Please update tests' \
                % delphi_version \
            unless template_ext
        @ver_info_source = PROJECT_PATH.pathmap('%X%s%n.' + template_ext)
        @ver_info_file = PROJECT_PATH.pathmap('%X%s%n') + template_ext.pathmap('%x')
        FileUtils.cp(@ver_info_source, @ver_info_file)
    end

    def teardown
        File.unlink(@ver_info_file) if @ver_info_file
        ENV['DELPHI_VERSION'] = @saved_delphi_version
    end
end

end