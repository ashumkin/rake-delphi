# encoding: utf-8

module Rake
  module Delphi
    class Logger
      NORMAL = 0
      VERBOSE = 1
      DEBUG = 2
      TRACE = 3
      def self.debug?
        return ENV['RAKE_DELPHI_TRACE'].to_i >= DEBUG
      end

      def self.trace(level, msg)
        if ENV['RAKE_DELPHI_TRACE'].to_i >= level
          if msg.kind_of?(String)
            $stderr.puts(msg)
          else
            require 'pp'
            PP.pp(msg, $stderr)
          end
        end
      end
    end
  end
end
