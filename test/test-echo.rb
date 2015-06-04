# encoding: utf-8

require 'rake'
require 'minitest/autorun'
require 'rake/common/echotask'
require 'rake/helpers/unittest'

class TestEchoToFileTask < MiniTest::Unit::TestCase
private
    def file_in
        return @file_in ||= File.expand_path('../resources/echo/file.in', __FILE__)
    end

    def file_out
        return @file_out ||= File.expand_path('../tmp/file.out', __FILE__)
    end
public
    def setup
        @rake_task = Rake::Task.new('some-task-' + name, Rake.application)
    end

    def test_nil_vars
        Rake::Delphi::EchoToFile.new(@rake_task, file_in, file_out, nil)
        lines = IO.readlines(file_out)
        assert_equal "${echo_variable} must be replaced by its <value>\n", lines[0]
    end

    def test_vars
        Rake::Delphi::EchoToFile.new(@rake_task, file_in, file_out, {'echo_variable' => 'echo_variable_value'})
        lines = IO.readlines(file_out)
        assert_equal "echo_variable_value must be replaced by its <value>\n", lines[0]
    end
end
