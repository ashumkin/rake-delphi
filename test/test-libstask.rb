# encoding: utf-8

require 'rake'
require 'test/unit'
require 'rake/common/libstask'
require 'rake/helpers/unittest'

class TestLibsTask <  Test::Unit::TestCase
private
    def _dir
        return @dir ||= File.expand_path('../resources/libstask/', __FILE__)
    end
public
    def setup
        ENV['RAKE_DIR'] = _dir
        @task = Rake::Delphi::LibsTask.define('test-libs-task-' + name, Rake.application)
        @task.invoke
    end

    def test_define
        # define task second time
        task2 = Rake::Delphi::LibsTask.define('test-libs-task-test_define', Rake.application)
        # if name contains brackets (in Ruby 1.8.7 unit tests)
        if name =~ /[()]/
            assert_equal('test-libs-task-test_define(TestLibsTask)', task2.name)
        else
            assert_equal('test-libs-task-test_define', task2.name)
        end
        # already invoked
        assert_not_equal(nil, task2.libs)
        # not empty
        assert_not_equal([], task2.libs)
    end

    def test_libs_relative_not_executed
        task2 = Rake::Delphi::LibsTask.define('libs task not executed', Rake.application)
        assert_equal [], task2.libs
    end

    def test_libs_relative
        libs_rel = @task.libs_relative(0)
        assert_equal([
                "./lib/level-1", \
                "./lib/level-1/level-2-1", \
                "./lib/level-1/level-2-1/level-3-1",
                "./lib/level-1/level-2-1/level-3-2", \
                "./lib/level-1/level-2-2"],
            libs_rel)
    end

    def test_libs_relative_level
        libs_rel = @task.libs_relative(1)
        assert_equal([
                "./../lib/level-1", \
                "./../lib/level-1/level-2-1", \
                "./../lib/level-1/level-2-1/level-3-1",
                "./../lib/level-1/level-2-1/level-3-2", \
                "./../lib/level-1/level-2-2"],
            libs_rel)
    end
end
