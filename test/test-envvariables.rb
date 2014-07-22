# encoding: utf-8

require 'rake'
require 'test/unit'
require 'rake/delphi/envvariables'
require 'rake/helpers/unittest'

class TestEnvVariables < Test::Unit::TestCase

    def setup
        ENV['BDS_PLATFORM'] = 'BDS platform'
        ENV['BDS_PLATFORM_CASE'] = 'BDS platform case'
    end

    def test_expands
        env_vars = Rake::Delphi::EnvVariables.new(nil, 'c:/delphi directory/')
        assert_equal('c:/delphi directory', env_vars['BDS'])
        assert_equal('c:/delphi directory/Lib', env_vars['BDSLIB'])
        assert_equal('Platform: BDS platform', env_vars.expand('Platform: $(BDS_PLATFORM)'))
        assert_equal('Platform: BDS platform case', env_vars.expand('Platform: $(bds_platform_case)'))

        assert_equal('Env: $(BDS_NON_EXISTANT)', env_vars.expand('Env: $(BDS_NON_EXISTANT)'))

        env_vars['BDS_PLATFORM_CASE_2'] = 'BDS Platform Case 2'
        # be sure there is no BDS_Platform_Case_2 defined
        assert_not_equal('BDS Platform Case 2', env_vars['BDS_Platform_Case_2'])
        # also freeze string (ENV vars are frozen strings)
        assert_equal('Platform: BDS Platform Case 2', env_vars.expand('Platform: $(BDS_Platform_Case_2)'.freeze))
    end
end
