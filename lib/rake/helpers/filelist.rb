# encoding: utf-8
require 'rake'

module Rake
    class FileList
        def self.get_ignored_dir_pattern(dir)
            Regexp.new("(^|[\\/\\\\])#{dir}([\\/\\\\]|$)", true)
        end
        IGNORE_GIT_PATTERN = get_ignored_dir_pattern('.git')
        DEFAULT_IGNORE_PATTERNS << IGNORE_GIT_PATTERN \
            if !DEFAULT_IGNORE_PATTERNS.include?(IGNORE_GIT_PATTERN)
    end
end
