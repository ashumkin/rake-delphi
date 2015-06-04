# encoding: utf-8

require 'rake'
require 'minitest/autorun'
require 'rake/helpers/unittest'
require 'rake/helpers/string'

class TestString < MiniTest::Unit::TestCase
    def test_prepend
        assert_equal('prefix_a', 'a'.prepend('prefix_'))
    end

    def test_starts_with
        assert 'android32'.starts_with?('android')
        assert 'android'.starts_with?('android')
        assert ! 'win'.starts_with?('android')
    end

    def test_double_delimilters
        s = 'a\\b\\c'
        assert_equal 'a\\\\b\\\\c', 'a\\b\\c'.double_delimiters
        # test s was not changed
        assert_equal 'a\\b\\c', s
        assert_equal 'a/b/c', 'a/b/c'.double_delimiters
        assert_equal 'a/b\\\\c', 'a/b\\c'.double_delimiters
    end

    def test_double_delimilters!
        s = 'a\\b\\c'
        s.double_delimiters!
        assert_equal 'a\\\\b\\\\c', s

        s = 'a/b/c'
        s.double_delimiters!
        assert_equal 'a/b/c', s

        s = 'a/b\\c'
        s.double_delimiters!
        assert_equal 'a/b\\\\c', s
    end
end
