require 'fileutils'
require 'test/unit'
require 'helpers/consts'
require 'rake/delphi/envvariables'

module Rake
    module Delphi
        class BDSVersionInfo
            # override method
            def self.encoding
                'Windows-1251'
            end
        end
    end
end

module DelphiTests

class TestVerInfo < Test::Unit::TestCase
    DPROJ_VERSIONS = { '10' => '2006.bdsproj', '11' => '2007.dproj', \
                       '13' => '2010.dproj', '18' => 'xe5.dproj' }

protected
    def delphi_version
        return Rake::Delphi::EnvVariables.delphi_version
    end

    def prepare_ver_info_file?
        return true
    end

    def project_path
        PROJECT_PATH
    end

    def project_name
        PROJECT_EXE.pathmap('%n')
    end

public
    def setup
        @saved_delphi_version = Rake::Delphi::EnvVariables.delphi_version
        ENV['DELPHI_VERSION'] = delphi_version

        template_ext = DPROJ_VERSIONS[delphi_version]
        raise 'DELPHI_VERSION unknown (%s). Please update tests' \
                % delphi_version \
            unless template_ext
        @ver_info_source = project_path.pathmap('%X%s') + project_name + '.' + template_ext
        @ver_info_file = project_path.pathmap('%X%s') + project_name + template_ext.pathmap('%x')

        FileUtils.cp(@ver_info_source, @ver_info_file) if prepare_ver_info_file?
    end

    def teardown
        File.unlink(@ver_info_file) if @ver_info_file && prepare_ver_info_file?
        ENV['DELPHI_VERSION'] = @saved_delphi_version if @saved_delphi_version
    end
end

end
