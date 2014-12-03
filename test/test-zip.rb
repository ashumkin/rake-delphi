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
        assert(File.exists?(@zip), "File #{@zip} not created")
    end

    def test_zip_file_twice
        test_zip_file
        test_zip_file
    end

    def test_add_to_zip_file
        test_zip_file
        Rake::Delphi::ZipTask.new(@rake_task, @zip, [__FILE__], { :preserve_paths => true, :add => true })
        assert(File.exists?(@zip))
        Zip::ZipFile.open(@zip) do |z|
            assert_equal 2, z.entries.length, 'Files in an archive'
        end
    end

    def test_add_to_zip_file_customname
        test_add_to_zip_file
        Rake::Delphi::ZipTask.new(@rake_task, @zip, [{__FILE__ => 'folder/custom_name'}], { :preserve_paths => true, :add => true })
        assert(File.exists?(@zip))
        Zip::ZipFile.open(@zip) do |z|
            assert_equal 3, z.entries.length, 'Files in an archive'
        end
    end

    def test_add_to_zip_file_customname_foldername
        test_add_to_zip_file
        Rake::Delphi::ZipTask.new(@rake_task, @zip, [{__FILE__ => 'folder/custom_name/'}], { :preserve_paths => true, :add => true })
        assert(File.exists?(@zip))
        Zip::ZipFile.open(@zip) do |z|
            assert_equal 3, z.entries.length, 'Files in an archive'
        end
    end
end
