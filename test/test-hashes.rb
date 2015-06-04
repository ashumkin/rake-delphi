# encoding: utf-8

require 'rake'
require 'minitest/autorun'
require 'rake/common/hashtask'
require 'rake/helpers/unittest'

class CustomTestHashTask < MiniTest::Unit::TestCase
private
    def _file
        return @file ||= File.expand_path('../resources/hashes/hash.file', __FILE__)
    end
public
    def default_test
        # do not fail
    end
end

class TestHashTask <  CustomTestHashTask
    def test_hash_md5
        assert_equal '9893532233CAFF98CD083A116B013C0B', Rake::Delphi::HashTask.new(_file, 'md5').digest
    end

    def test_hash_sha1
        assert_equal '94E66DF8CD09D410C62D9E0DC59D3A884E458E05', Rake::Delphi::HashTask.new(_file, 'sha1').digest
    end

    def test_hash_crc32
        # other than `md5` or `sha1`
        assert_equal '431F313F', Rake::Delphi::HashTask.new(_file, nil).digest
        assert_equal '431F313F', Rake::Delphi::HashTask.new(_file, '').digest
        assert_equal '431F313F', Rake::Delphi::HashTask.new(_file, 'sha2').digest
        assert_equal '431F313F', Rake::Delphi::HashTask.new(_file, 'md4').digest
    end
end

class TestHashesTask <  CustomTestHashTask
public
    def setup
        super
        @rake_task = Rake::Task.new('some-task-' + name, Rake.application)
    end

    def test_hash_md5
        assert_equal({ _file => { 'MD5' => '9893532233CAFF98CD083A116B013C0B' } }, \
            Rake::Delphi::HashesTask.new(@rake_task, _file, 'md5').to_hash)
    end

    def test_hash_sha1_array
        file2 = File.expand_path('../hash.2.file', _file)
        files = [_file, file2]
        assert_equal({ _file => { 'SHA1' => '94E66DF8CD09D410C62D9E0DC59D3A884E458E05' }, \
                file2 => { 'SHA1' => '031DF9EE7F13F5CA460490E77FBFF9687975BACC' } }, \
            Rake::Delphi::HashesTask.new(@rake_task, files, 'sha1').to_hash)
    end
end
