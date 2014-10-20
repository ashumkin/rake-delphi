# encoding: utf-8

require 'rake/common/classes'
require 'rake/common/logger'
require 'rake/helpers/rake'

module Rake
  module Delphi
    class Git
        def self.version
            null = Rake.cygwin? ? '/dev/null' : 'nul'
            r = `git rev-parse 1>#{null} 2>&1 && git describe --abbrev=1 2>#{null}`
            # trim
            r.chomp!
            unless r.to_s.empty?
                # add ".0" for exact version (like v3.0.43)
                # example: v3.0.43-5-g3952dc
                # take text before '-g'
                r << '.0'
                r = r.split('-g')[0]
                # remove any non-digits in the beginning
                # remove any alpha-characters
                r.gsub!(/^\D+|[a-zA-Z]+/, '')
                # replace any non-digits with dots
                r.gsub!(/\D/, '.')
            end
        end
    end

    class GitChangelog < BasicTask

        attr_reader :opts, :changelog, :processed

        def initialize(task, opts)
            super(task)
            @opts = {:filter => '.', :format => '%B'}
            @opts.merge!(opts) if opts.kind_of?(Hash)
            @changelog = @processed = []
            get_changelog
            yield self if block_given?
        end

    def processed_string
        @processed.join("\n")
    end

    def changelog_string
        @changelog.join("\n")
    end

    private
        def get_changelog
            cmd = ['git']
            cmd << "-c i18n.logOutputEncoding=#{opts[:logoutputencoding]}" if opts[:logoutputencoding]
            # if :since is not set, do not use range
            rev = (opts[:since].to_s.empty? ? '' : "#{opts[:since]}..") + 'HEAD'
            cmd << 'log' << "--format=#{opts[:format]}" << rev
            Logger.trace(Logger::VERBOSE, cmd)
            @changelog=%x[#{cmd.join(' ')}].lines.to_a
            @changelog.map! do |line|
                line.chomp!
                if line.respond_to?(:force_encoding) \
                        && opts[:logoutputencoding]
                    line.force_encoding(opts[:logoutputencoding])
                end
                line
            end

            # delete empty lines
            @changelog.delete_if { |line| line.chomp.empty? }
            # unique lines only
            @changelog.uniq!
            do_filter
            do_process
            Logger.trace(Logger::TRACE, @changelog)
        end

        def charset
            opts[:logoutputencoding]
        end

        def do_filter
            @filter = Regexp.new(@opts[:filter])
            @changelog.delete_if { |line| ! @filter.match(line) }
        end

        def do_process
            @processed = []
            return unless @opts[:process] && @opts[:process].size > 0
            @processed = @changelog.map do |line|
                line = line.dup
                process = @opts[:process]
                process = [process] unless process.kind_of?(Array)
                process.each do |filters|
                    raise "`%s` must be a Hash" % [filters] unless filters.kind_of?(Hash)
                    filters.each do |filter, subst|
                        line.gsub!(filter, subst)
                    end
                end
                line
            end
        end
    end
  end
end
