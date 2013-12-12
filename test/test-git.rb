# encoding: utf-8

require 'rake'
require 'test/unit'
require 'fileutils'
require 'rake/common/chdirtask'
require 'rake/common/git'
require 'rake/helpers/unittest'

class CustomTestGit <  Test::Unit::TestCase
private
    def init_test_dit_dir
        @test_git_dir = File.expand_path('../tmp', __FILE__)
        FileUtils.mkdir_p(@test_git_dir)
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            `rm -rf .git *`
            `git init .`
            `git config --global user.email "git@test.ru"`
            `git config --global user.name "Git test"`
            `echo file content > file.txt`
            `git add file.txt`
            `git commit -m "first commit"`
        end
    end

    def second_commit
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            `echo line added >> file.txt`
            `git commit -a -m "file content added"`
        end
    end

    def third_commit
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            `echo line two added >> file.txt`
            `git commit -a -m "line two added message"`
        end
    end

public
    def setup
        @rake_task = Rake::Task.new('some-task-' + name, Rake.application)
        init_test_dit_dir
    end

    def test_git
        # empty test to avoid failure
    end
end

class TestGit <  CustomTestGit
    def test_git
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            assert_equal nil, Rake::Delphi::Git.version
        end
    end

    def test_version_0_0_1_0
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            `git tag 0.0.1 -a -m "version 0.0.1"`
            assert_equal '0.0.1.0', Rake::Delphi::Git.version
        end
    end

    def test_version_0_0_1_1
        test_version_0_0_1_0
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            second_commit
            assert_equal '0.0.1.1', Rake::Delphi::Git.version
        end
    end
end

class TestGitChangelog <  CustomTestGit
private
public
    def setup
        super
        second_commit
        third_commit
        @opts = {:since => 'HEAD^^'}
    end

    def test_changelog_last
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            chlog = Rake::Delphi::GitChangelog.new(@rake_task, nil)
            assert_equal [], chlog.changelog, 'Changelog'
            assert_equal [], chlog.processed, 'Processed'
        end
    end

    def test_changelog_from_root
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            chlog = Rake::Delphi::GitChangelog.new(@rake_task, @opts)
            assert_equal ["line two added message", "file content added"], chlog.changelog, 'Changelog'
        end
    end

    def test_changelog_filter
        @opts.merge!({:filter => 'line' })
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            chlog = Rake::Delphi::GitChangelog.new(@rake_task, @opts)
            assert_equal ["line two added message"], chlog.changelog, 'Changelog'
        end
    end

    def test_changelog_processed_array
        @opts.merge!({ :process => [{'added' => 'deleted'}] })
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            chlog = Rake::Delphi::GitChangelog.new(@rake_task, @opts)
            assert_equal ["line two deleted message", "file content deleted"], chlog.processed, 'Changelog'
            # changelog must be unmodified
            assert_equal ["line two added message", "file content added"], chlog.changelog, 'Changelog unmodified'
        end
    end

    def test_changelog_processed_hash
        @opts.merge!({ :process => {'added' => 'deleted'} })
        Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
            chlog = Rake::Delphi::GitChangelog.new(@rake_task, @opts)
            assert_equal ["line two deleted message", "file content deleted"], chlog.processed, 'Changelog processed'
            # changelog must be unmodified
            assert_equal ["line two added message", "file content added"], chlog.changelog, 'Changelog unmodified'
        end
    end

    def test_changelog_processed_not_a_hash_string
        @opts.merge!({ :process => 'added'})
        assert_raise RuntimeError do
            Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
                chlog = Rake::Delphi::GitChangelog.new(@rake_task, @opts)
            end
        end
    end

    def test_changelog_processed_not_a_hash_array
        @opts.merge!({ :process => [['added']] })
        assert_raise RuntimeError do
            Rake::Delphi::ChDir.new(@rake_task, @test_git_dir) do
                chlog = Rake::Delphi::GitChangelog.new(@rake_task, @opts)
            end
        end
    end
end
