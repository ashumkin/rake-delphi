# encoding: utf-8

module Rake
  module Delphi
    class Logger
      NORMAL = 0
      VERBOSE = 1
      DEBUG = 2
      TRACE = 3
      def self.trace(level, msg)
        if ENV['RAKE_DELPHI_TRACE'].to_i >= level
          $stderr.puts(msg)
        end
      end
    end
  end
end
