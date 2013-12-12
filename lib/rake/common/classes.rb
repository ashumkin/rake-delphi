# encoding: utf-8

module Rake
  module Delphi
    class BasicTask
        def initialize(task)
            @task = task
        end

        def trace?
            @task.application.options.trace || $DEBUG || false
        end
    end
  end
end
