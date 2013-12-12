# encoding: utf-8

require 'rake'
require 'test/unit'
require 'rake/common/ziptask'
require 'rake/helpers/unittest'

class TestZipTask <  Test::Unit::TestCase
private
public
    def setup
        @rake_task = Rake::Task.new('some-task-' + name, Rake.application)
        @zip = __FILE__.pathmap('%X.zip')
        File.unlink(@zip) if File.exists?(@zip)
    end

    def test_zip_no_task
        assert_raise NoMethodError do
            # first argument must be a Rake::Task
            # "undefined method `application' for nil:NilClass" must be raised
            Rake::Delphi::ZipTask.new(nil, nil, nil)
        end
    end

    def test_zip_no_filename
        assert_raise RuntimeError do
            # second argument must be non-empty
            Rake::Delphi::ZipTask.new(@rake_task, nil, nil)
        end
    end

    def test_zip_empty_filename
        assert_raise RuntimeError do
            # second argument must be non-empty
            Rake::Delphi::ZipTask.new(@rake_task, '', nil)
        end
    end

    def test_zip_file
        Rake::Delphi::ZipTask.new(@rake_task, @zip, [__FILE__])
        assert(File.exists?(@zip))
    end
end
