# encoding: utf-8

require 'rake/common/classes'

module Rake
  module Delphi
    class ChDir < BasicTask
        def initialize(task, dir)
            super(task)
            return unless block_given?
            od = Dir.pwd
            begin
                Dir.chdir(dir)
                yield dir
            ensure
                Dir.chdir(od)
            end
        end
    end
  end
end
