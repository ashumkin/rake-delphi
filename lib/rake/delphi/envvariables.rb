# encoding: utf-8
require 'rake/common/logger'

module Rake
  module Delphi
    class EnvVariables < ::Hash
        def self.delphi_version
            ENV['DELPHI_VERSION']
        end

        def initialize(regpath, delphidir)
            readreg(regpath)
            _dir = delphidir.gsub(/\/$/, '')
            add('DELPHI', _dir)
            add('BDS', _dir)
            add('BDSLIB', _dir + '/Lib')
            expand_vars
            Logger.trace(Logger::TRACE, self)
        end

        def expand(value)
            self.each do |name, val|
                value.gsub!("$(#{name})", val)
                value = expand_global(value)
            end
            value
        end

    private
        def readreg(regpath)
            return unless regpath
            begin
                require 'win32/registry'
                Logger.trace(Logger::DEBUG, "Reading environment variables from '#{regpath}'")
                begin
                    ::Win32::Registry::HKEY_CURRENT_USER.open(regpath) do |reg|
                        reg.each do |name|
                            reg_type, value = reg.read(name)
                            value.gsub!('\\', '/')
                            add(name, value)
                        end
                    end
                rescue ::Win32::Registry::Error
                    Logger.trace(Logger::DEBUG, "No reg key '%s'?!" % regpath)
                end
            rescue LoadError
                Logger.trace(Logger::DEBUG, 'No `win32/registry` gem?!')
            end
        end

        def add(var, value)
            self[var] = value
        end

        def expand_global(value)
            value.gsub!(/\$\((?'env_name'\w+)\)/) do |match|
                name = Regexp.last_match[:env_name].upcase
                ENV[name] || match
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
