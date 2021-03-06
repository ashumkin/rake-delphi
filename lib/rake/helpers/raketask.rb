# encoding: utf-8
require 'rake'
require 'rake/helpers/logger'

# extend Rake task with a logger
module Rake
    class Task
        alias_method :initialize_base, :initialize
        alias_method :execute_base, :execute
        attr_reader :logger

        def initialize(name, app)
            @logger = Logger.new(STDOUT)
            @enabled = true
            initialize_base(name, app)
        end

        def needed?
            @enabled
        end

        def needed=(value)
            @enabled = value
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

        def reenable_chain
            reenable
            prerequisites.each do |ptask|
                ptask.reenable_chain if ptask.class < Rake::Task
            end
        end
    end
end
