# encoding: utf-8

require 'logger'
require 'rake/helpers/logger'

# extend Rake task with a logger
module Rake
    class Task
        alias_method :initialize_base, :initialize
        alias_method :execute_base, :execute
        attr_reader :logger

        def initialize(name, app)
            @logger = Logger.new(STDOUT)
            initialize_base(name, app)
        end

        # replace execute to indicate what method is executed
        def execute(args=nil)
            puts "Executing #{name}"
            execute_base(args)
        end

        def out(msg)
            logger.info(msg)
        end

        def trace?
            application.options.trace || $DEBUG || false
        end

        def shortname
            scope = @scope.dup.pop.to_s
            n = name.dup
            n.gsub!(scope + ':', '') unless scope.empty?
            return n
        end
    end
end
