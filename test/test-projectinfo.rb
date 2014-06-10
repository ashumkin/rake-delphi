# encoding: Windows-1251

require 'rake'
require 'test/unit'
require 'rake/delphi'
require 'rake/delphi/projectinfo'
require 'rake/delphi/dcc32'
require 'rake/helpers/unittest'
require 'helpers/consts'
require 'helpers/verinfo'

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

class TestBDSVersionInfo < TestVerInfo
private
    def version
        '2006'
    end
protected
    def delphi_version
        return '10'
    end

    def do_getinfo
        @info = Rake::Delphi::BDSVersionInfo.new(@rake_task)
    end
public
    def setup
        super
        @rake_task = Rake::Delphi::Dcc32Task.new('some-task-' + name, Rake.application)
        @rake_task.systempath = PROJECT_PATH + '/testproject.dpr'
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
end

class TestRAD2007VersionInfo < TestBDSVersionInfo
private
    def version
        '2007'
    end
protected
    def do_getinfo
        @info = Rake::Delphi::RAD2007VersionInfo.new(@rake_task)
    end

    def delphi_version
        return '11'
    end
public
    def test_info
        super
    end
end

class TestRAD2010VersionInfo < TestBDSVersionInfo
private
    def version
        '2010'
    end
protected
    def do_getinfo
        @info = Rake::Delphi::RAD2010VersionInfo.new(@rake_task)
    end

    def delphi_version
        return '13'
    end
public
    def test_info
        super
    end
end

class TestBDSVersionInfoAbsent < TestBDSVersionInfo
protected
    def prepare_ver_info_file?
        return false
    end
end

class TestRAD2007VersionInfoAbsent < TestRAD2007VersionInfo
protected
    def prepare_ver_info_file?
        return false
    end
end

class TestRAD2010VersionInfoAbsent < TestRAD2010VersionInfo
protected
    def prepare_ver_info_file?
        return false
    end
end

end
