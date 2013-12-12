# encoding: utf-8

require 'rake/common/exectask'
require 'rake/delphi/projectinfo'

module Rake
  module Delphi
    class CustomDelphiTool < CustomExec
        DelphiRegRoot =  'SOFTWARE\\Borland\\Delphi'
        BDSRegRoot = 'SOFTWARE\\Borland\\BDS'
        EDSRegRoot = 'SOFTWARE\\CodeGear\\BDS'

        # used mainly in tests
        def self.reinit
            @@version, @@delphidir, @@toolpath = nil, nil, nil
        end
        reinit

        def initialize
            @@version, @@delphidir, @@toolpath = self.class.find unless @@version
        end

        def self.toolName
            raise 'Abstract method "toolName". Override it'
        end

        def version
            @@version
        end

        def delphidir
            @@delphidir
        end

        def toolpath
            @@toolpath
        end

        def versionInfoClass
            return @@version.to_f < 11 ? BDSVersionInfo : RAD2007VersionInfo
        end

        def self.readUserOption(key, name, ver)
            begin
                require 'win32/registry'
                root = rootForVersion(ver) + '\\' + key
                begin
                    ::Win32::Registry::HKEY_CURRENT_USER.open(root) do |reg|
                        reg_typ, reg_val = reg.read(name)
                        return reg_val.gsub('\\', '/')
                    end
                rescue ::Win32::Registry::Error
                    return ''
                end
            rescue LoadError
                return ''
            end
        end

        def self.version4version(version)
            if version.to_f >= 9
                version = format('%.1f', version.to_f - 6)
            end
            if !version["."]
                version << ".0"
            end
            return version
        end

        def self.rootForVersion(version)
            if version.to_f < 9
                regRoot = DelphiRegRoot
            else
                if version.to_f < 12
                    regRoot = BDSRegRoot
                else
                    regRoot = EDSRegRoot
                end
            end
            version = version4version(version)
            return regRoot + '\\' + version
        end

        def self.readDelphiDir(ver)
            begin
                require 'win32/registry'
                [::Win32::Registry::HKEY_LOCAL_MACHINE, \
                        # for local/manual installations
                        ::Win32::Registry::HKEY_CURRENT_USER].each do |regRoot|
                    begin
                        regRoot.open(rootForVersion(ver)) do |reg|
                            reg_typ, reg_val = reg.read('RootDir')
                            return reg_val.gsub('\\', '/')
                        end
                    rescue ::Win32::Registry::Error
                    end
                end
                return nil
            rescue LoadError
                return nil
            end
        end

        def self.find(failIfNotFound = false)
            v = ENV['DELPHI_VERSION']
            if ENV['DELPHI_DIR']
                # append trailing path delimiter
                ENV['DELPHI_DIR'] = ENV['DELPHI_DIR'].gsub(/[^\/]$/, '\&/')
                tool = ENV['DELPHI_DIR'] + toolName
                checkToolFailure(tool) if failIfNotFound
                return v, ENV['DELPHI_DIR'], tool
            end
            if v.to_s.empty?
                v = []
                (4..14).each { |n| v << n.to_s }
                v.reverse!
            else
                v = [v]
            end
            v.each do |ver|
                path = readDelphiDir(ver)
                next unless path
                tool = path + toolName
                if File.exists?(tool) # found it !
                    ENV['DELPHI_VERSION'] = ver
                    ENV['DELPHI_DIR'] = path
                    return ver, path, tool
                end
            end
            checkToolFailure(nil) if failIfNotFound
            return nil
        end

        def self.checkToolFailure(toolpath)
            fail 'Could not find %s: (%s)' % [toolName, toolpath.to_s] unless File.exists?(toolpath.to_s)
        end

    end
  end
end
