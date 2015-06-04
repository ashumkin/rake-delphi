# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'rake/delphi/dcc32tool'
require 'rake/delphi/android/sdk'

module Rake
  module Delphi
    class DccARMTool < Dcc32Tool
      def self.toolName
        'bin/dccaarm.exe'
      end

      def options
        return Android::DCC32SDKOptions.new.dcc32options
      end
    end # class DccARMTool
  end # module Delphi
end # moddule Rake
