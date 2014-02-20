# encoding: utf-8
require 'rake'

# extend Rake task with a `set_non_standard_vars` method
module Rake
    def self.set_non_standard_vars
        # convert tasks to vars
        # and remove them from the list of tasks
        Rake.application.top_level_tasks.delete_if do |task|
            # if task name is like <var.with.dot>=<value>
            if /^[^.=][^=]+=.*/.match(task)
                name, value = task.split('=', 2)
                ENV[name] = value
                true
            end
        end
    end

    def self.quotepath(switch, path)
        return ! path.to_s.empty? ? "#{switch}\"#{path.to_s}\"" : ''
    end

    def self.ruby18?
        /^1\.8/.match(RUBY_VERSION)
    end

    def self.cygwin?
        RUBY_PLATFORM.downcase.include?('cygwin')
    end
end
