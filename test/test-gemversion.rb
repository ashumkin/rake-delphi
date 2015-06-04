# encoding: utf-8

require 'minitest/autorun'
require 'rake/helpers/gemversion'

class TestVersionImproved < MiniTest::Unit::TestCase
public
    def setup
    end

    def test_new_nil
        assert_equal '0.0.0.0', Gem::VersionImproved.new(nil).version
    end

    def test_new_empty_string
        assert_equal '0.0.0.0', Gem::VersionImproved.new('').version
    end

    def test_comma_nil
        assert_equal '0,0,0,0', Gem::VersionImproved.new(nil).comma
    end

    def test_comma_empty_string
        assert_equal '0,0,0,0', Gem::VersionImproved.new('').comma
    end

    def test_frozen_string
        assert_equal '1.2.3.4', Gem::VersionImproved.new('1.2.3.4'.freeze).to_s
    end

    def test_comma
        assert_equal '1,2,3,4', Gem::VersionImproved.new('1.2.3.4').comma
    end

    def test_build_num
        @version = Gem::VersionImproved.new('1.2.3.4')
        assert_equal 4, @version.build_num

        @version = Gem::VersionImproved.new('1.2.3')
        assert_equal nil, @version.build_num

        @version = Gem::VersionImproved.new('1.2')
        assert_equal nil, @version.build_num
    end

    def test_release_num
        @version = Gem::VersionImproved.new('1.2.3.4')
        assert_equal 3, @version.release_num

        @version = Gem::VersionImproved.new('1.2.3')
        assert_equal 2, @version.release_num

        @version = Gem::VersionImproved.new('1.2')
        assert_equal 1, @version.release_num
    end

    def test_prev_release
        @version = Gem::VersionImproved.new('1.2.3.4')
        assert_equal '1.2.2', @version.prev_release.version

        @version = Gem::VersionImproved.new('1.2.3')
        assert_equal '1.1', @version.prev_release.version

        @version = Gem::VersionImproved.new('1.2')
        assert_equal '0', @version.prev_release.version
    end

    def test_build
        @version = Gem::VersionImproved.new('1.2.3.4')
        assert_equal '1.2.3.4', @version.build.version

        @version = Gem::VersionImproved.new('1.2.3')
        assert_equal '1.2.3', @version.build.version

        @version = Gem::VersionImproved.new('1.2')
        assert_equal '1.2', @version.build.version

        @version = Gem::VersionImproved.new('1.2.3.a')
        assert_equal '1.2.4', @version.build.version

        @version = Gem::VersionImproved.new('1.2.x')
        assert_equal '1.3', @version.build.version

        @version = Gem::VersionImproved.new('1.x')
        assert_equal '2', @version.build.version
    end

    def test_major
        @version = Gem::VersionImproved.new('1.2.3.4')
        assert_equal 1, @version.major

        @version = Gem::VersionImproved.new('5.2.3')
        assert_equal 5, @version.major

        @version = Gem::VersionImproved.new('3.2')
        assert_equal 3, @version.major

        @version = Gem::VersionImproved.new('4')
        assert_equal 4, @version.major
    end

    def test_minor
        @version = Gem::VersionImproved.new('1.2.3.4')
        assert_equal 2, @version.minor

        @version = Gem::VersionImproved.new('5.4.3')
        assert_equal 4, @version.minor

        @version = Gem::VersionImproved.new('3.1')
        assert_equal 1, @version.minor

        @version = Gem::VersionImproved.new('4')
        assert_equal nil, @version.minor
    end
end
