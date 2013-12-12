# encoding: utf-8

require 'rake'
require 'test/unit'
require 'rake/common/initask'
require 'rake/helpers/unittest'

class TestIniProperty <  Test::Unit::TestCase
private
    def _file
        return @file ||= File.expand_path('../resources/ini/file.ini', __FILE__)
    end
public
    def test_read_ini
        assert_equal 'some ini value 1', Rake::Delphi::IniProperty.get('%s:%s:%s' % [_file, 'IniSection', 'IniValue1'])
        assert_equal 'ini section 2 value 2', Rake::Delphi::IniProperty.get('%s:%s:%s' % [_file, 'IniSection-2', 'IniValue2'])
    end
end
