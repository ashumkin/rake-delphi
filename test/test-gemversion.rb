# encoding: utf-8

require 'test/unit'
require 'rake/helpers/gemversion'

class TestVersionImproved <  Test::Unit::TestCase
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

    def test_comma
        assert_equal '1,2,3,4', Gem::VersionImproved.new('1.2.3.4').comma
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
end
