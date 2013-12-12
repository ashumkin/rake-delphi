# encoding: utf-8

require 'rake/common/classes'

module Rake
  module Delphi

    class CustomExec < BasicTask
    public
        def execute
        end

        def to_system_path(path, base = '')
            r = super(path, base)
            # quote path if it contains SPACE
            r = '"%s"' % r.strip if r[" "]
        end
    end
  end
end