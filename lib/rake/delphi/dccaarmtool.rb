# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'rake/delphi/dcc32tool'

module Rake
  module Delphi
    class DccARMTool < Dcc32Tool
      def self.toolName
        'bin/dccaarm.exe'
      end

      def options
        opts = []
        linker_path = ENV['DELPHI_ANDROID_SDK_LINKER']
        warn "Please, define DELPHI_ANDROID_SDK_LINKER environment variable.\n Otherwise you may get 'File not found: ldandroid.exe' error" unless linker_path
        lib_path = ENV['DELPHI_ANDROID_SDK_LIBPATH']
        warn 'Please, define DELPHI_ANDROID_SDK_LIBPATH environment variable' unless lib_path
        linker_option = ENV['DELPHI_ANDROID_SDK_LINKER_OPTION']
        warn 'Please, define DELPHI_ANDROID_SDK_LINKER_OPTION environment variable' unless linker_option
        opts << '-TX.so'
        opts << "--linker:\"#{linker_path}\""
        opts << "--libpath:\"#{lib_path}\""
        opts << "--linker-option:\"#{linker_option}\""
        return opts
      end
    end
  end
end
