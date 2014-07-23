# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'rake/common/logger'
require 'rake/delphi/tool'

module Rake
  module Delphi
    class PAClientTool < CustomDelphiTool
      def initialize(checkExistance = false)
        self.class.reinit
        super
      end

      def self.toolName
        'bin/paclient.exe'
      end
    end
  end
end
