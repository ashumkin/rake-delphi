# encoding: utf-8

require 'inifile'
require 'rake/common/classes'

module Rake
  module Delphi
    class IniProperty < BasicTask
    private
        def self.parse(string)
            dir = File.dirname(string)
            file, section, valuename = string.gsub(dir, '').split(":")
            file = dir + '/' + File.basename(file)
            return file, section, valuename
        end
    public
        def self.get(string)
            file, section, valuename = parse(string)
            ini = IniFile.load(file)
            return ini[section][valuename]
        end

        def self.set(string, value)
            file, section, valuename = parse(string)
            ini = IniFile.load(file)
            ini[section][valuename] = value
            ini.write
        end
    end
  end
end
