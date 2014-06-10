# encoding: utf-8

require 'rake'
require 'test/unit'
require 'rake/delphi/envvariables'
require 'rake/helpers/unittest'

class TestEnvVariables < Test::Unit::TestCase

    def setup
        ENV['BDS_PLATFORM'] = 'BDS platform'
    end

    def test_expands
        env_vars = Rake::Delphi::EnvVariables.new(nil, 'c:/delphi directory/')
        assert_equal('c:/delphi directory', env_vars['BDS'])
        assert_equal('c:/delphi directory/Lib', env_vars['BDSLIB'])
        assert_equal('Platform: BDS platform', env_vars.expand('Platform: $(BDS_PLATFORM)'))
        assert_equal('Env: $(BDS_NON_EXISTANT)', env_vars.expand('Env: $(BDS_NON_EXISTANT)'))
    end
end
