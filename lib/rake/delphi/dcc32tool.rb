# encoding: utf-8

require 'rake/common/logger'
require 'rake/delphi/tool'

module Rake
  module Delphi
    class Dcc32Tool < CustomDelphiTool
        attr_reader :env

        def self.toolName
            'bin/dcc32.exe'
        end

        def delphidir
            @@delphidir
        end

        def delphilib
            ENV['BDSLIB']
        end

        def init_env
            @env ||= EnvVariables.new(self.class.rootForVersion(self.version) + '\Environment Variables', self.delphidir)
        end

        def readLibraryPaths(platform, platform_stripped)
            Logger.trace(Logger::TRACE, 'Reading library paths for platform: ' + platform.to_s)
            warn "WARNING! You are using Delphi XE or above but no platform defined!" if ENV['DELPHI_VERSION'].to_i >= DELPHI_VERSION_XE && ! platform

            platform = platform.to_s != '' ? '\\' + platform : ''
            # platform not used for old Delphis 'SearchPath'
            libpaths = self.class.readUserOption('Library' + platform, 'Search Path', self.version).split(';') \
                | self.class.readUserOption('Library', 'SearchPath', self.version).split(';')
            Logger.trace(Logger::TRACE, 'Library paths read:')
            Logger.trace(Logger::TRACE, libpaths)
            dev = init_env
            dev['PLATFORM'] = platform_stripped if platform_stripped
            libpaths.map! do |lp|
                unless lp.to_s.empty?
                    lp = dev.expand(lp)
                end
                lp
            end
            Logger.trace(Logger::TRACE, 'Library paths expanded:')
            Logger.trace(Logger::TRACE, libpaths)
            return libpaths
        end
    end
  end
end
