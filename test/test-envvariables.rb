# encoding: utf-8

require 'rake'
require 'test/unit'
require 'rake/delphi/envvariables'
require 'rake/helpers/unittest'

class TestEnvVariables < Test::Unit::TestCase

    def test_expands
        env_vars = Rake::Delphi::EnvVariables.new(nil, 'c:/delphi directory/')
        assert_equal('c:/delphi directory', env_vars['BDS'])
    end
end
