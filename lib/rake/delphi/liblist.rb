# encoding: utf-8

require 'rake/helpers/filelist'
require 'rake/common/logger'

module Rake
  module Delphi
        class LibList < FileList
            def read_ignored_libs
                libs = []
                file = (ENV['RAKE_DIR'] || Rake.original_dir) + '/.rake.ignored.libs'
                unless File.exists?(file)
                  Logger.trace(Logger::TRACE, "File #{file} not found")
                  return libs
                end
                Logger.trace(Logger::TRACE, "Reading #{file}")
                IO.readlines(file).each do |line|
                    # skip comment lines (started with # or ;)
                    if /^\s*[#;]/.match(line)
                      Logger.trace(Logger::TRACE, "Line #{line} ignored as a comment")
                      next
                    end
                    libs << FileList.get_ignored_dir_pattern(line.chomp)
                end
                libs
            end

            alias_method :initialize_base, :initialize

            def initialize(*patterns)
                initialize_base(patterns)
                @exclude_patterns |= read_ignored_libs
                @exclude_procs << proc do |fn|
                  ! File.directory?(fn)
                end
            end
        end
  end
end
