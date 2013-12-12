# encoding: utf-8

require 'rake/helpers/filelist'

module Rake
  module Delphi
        class LibList < FileList
            def read_ignored_libs
                libs = []
                file = (ENV['RAKE_DIR'] || Rake.original_dir) + '/.rake.ignored.libs'
                return libs unless File.exists?(file)
                IO.readlines(file).each do |line|
                    # skip comment lines (started with # or ;)
                    next if /^\s*[#;]/.match(line)
                    libs << FileList.get_ignored_dir_pattern(line.chomp)
                end
                libs
            end

            alias_method :initialize_base, :initialize

            def initialize(*patterns)
                initialize_base(patterns)
                @exclude_patterns |= read_ignored_libs
                @exclude_procs << proc { |fn| File.file?(fn) }
            end
        end
  end
end
