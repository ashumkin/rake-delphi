# encoding: utf-8
require 'rake/common/logger'

module Rake
  module Delphi
    class EnvVariables < ::Hash
        def self.delphi_version
            ENV['DELPHI_VERSION']
        end

        def initialize(regpath, delphidir)
            _dir = delphidir.gsub(/\/$/, '')
            add('DELPHI', _dir)
            add('BDS', _dir)
            add('BDSLIB', _dir + '/Lib')
            expand_vars
            Logger.trace(Logger::TRACE, self)
        end

        def add(var, value)
            self[var] = value
        end

        def expand_global(value)
            value.gsub!(/\$\((?'env_name'\w+)\)/) do |match|
                ENV[Regexp.last_match[:env_name]] || match
            end
            value
        end

        def expand(value)
            self.each do |name, val|
                value.gsub!("$(#{name})", val)
                value = expand_global(value)
            end
            value
        end

        def expand_vars
            self.each do |name, value|
                self[name] = expand(value)
            end
        end
    end
  end
end
