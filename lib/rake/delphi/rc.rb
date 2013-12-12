# encoding: utf-8

require 'rake/delphi/tool'

module Rake
  module Delphi
    class RCResourceCompiler < CustomDelphiTool
        def self.toolName
            'bin/rc.exe'
        end
    end

    class BorlandResourceCompiler < RCResourceCompiler
        def self.toolName
            'bin/brcc32.exe'
        end
    end

    class GOResourceCompiler < RCResourceCompiler
        def self.toolName
            'bin/gorc.exe'
        end
    end
  end
end
