# encoding: utf-8
# vim: set shiftwidth=2 tabstop=2 expandtab:
#
require 'rake/delphi/dcc32tool'
require 'rake/helpers/rake'

module Rake
  module Delphi
    module Android
      class SDK < Dcc32Tool
        PROPERTIES = {
          :linker => 'NDKArmLinuxAndroidFile',
          :lib => 'DelphiNDKLibraryPath',
          :linker_option => 'DelphiNDKLibraryPath',
          :stripdebug => 'NDKArmLinuxAndroidStripFile',
          :aapt => 'SDKAaptPath',
          :platform => 'SDKApiLevelPath',
          :keystore => nil,
          :zipalign => 'SDKZipAlignPath',
          :jdk_path => 'JDKJarsignerPath'
        }

        PROPERTIES.keys.each do |prop|
          attr_accessor prop
        end

        def initialize
          super(false)
          read_properties
        end

        def read_default_config
          begin
            require 'win32/registry'
            [::Win32::Registry::HKEY_LOCAL_MACHINE, \
                # for local/manual installations
                ::Win32::Registry::HKEY_CURRENT_USER].each do |regRoot|
              begin
                key = 'Default_Android'
                Logger.trace(Logger::DEBUG, "Finding #{@platform_SDKs}\\#{key}")
                regRoot.open(@platform_SDKs) do |reg|
                    reg_typ, reg_val = reg.read(key)
                  Logger.trace(Logger::DEBUG, "Found '#{reg_val}'")
                  return reg_val
                end
              rescue ::Win32::Registry::Error
                Logger.trace(Logger::DEBUG, "No reg key '#{regRoot}'?!")
              end
            end
            return nil
          rescue LoadError
            Logger.trace(Logger::DEBUG, 'No `win32/registry` gem?!')
            return nil
          end
        end

        def read_properties
          @platform_SDKs = @@regroot + '\\PlatformSDKs'
          default_android = read_default_config
          return unless default_android
          reg_default = @platform_SDKs + '\\' + default_android
          begin
            require 'win32/registry'
            PROPERTIES.each do |prop, reg_key|
              next unless reg_key
              [::Win32::Registry::HKEY_LOCAL_MACHINE, \
                  # for local/manual installations
                  ::Win32::Registry::HKEY_CURRENT_USER].each do |regRoot|
                begin
                  Logger.trace(Logger::DEBUG, "Finding '#{reg_key}' for '#{prop}' in '#{reg_default}'")
                  regRoot.open(reg_default) do |reg|
                    reg_typ, reg_val = reg.read(reg_key)
                  Logger.trace(Logger::DEBUG, "Value=#{reg_val}")
                  send "#{prop}=", reg_val
                end
                rescue ::Win32::Registry::Error
                  Logger.trace(Logger::DEBUG, "No reg key '#{regRoot}'?!")
                end
              end
            end
          rescue LoadError
            Logger.trace(Logger::DEBUG, 'No `win32/registry` gem?!')
          end
        end

        def lib=(value)
          @lib, null  = value.split(';', 2)
        end

        def linker_option=(value)
          null, @linker_option = value.split(';', 2)
          @linker_option = ' -L \"' + @linker_option + '\"'
        end

        def linker
          @linker = ENV['DELPHI_ANDROID_SDK_LINKER'] || @linker
          warn "Please, define DELPHI_ANDROID_SDK_LINKER environment variable.\n Otherwise you may get 'File not found: ldandroid.exe' error" unless @linker
          @linker
        end

        def lib
          @lib = ENV['DELPHI_ANDROID_SDK_LIBPATH'] || @lib
          warn 'Please, define DELPHI_ANDROID_SDK_LIBPATH environment variable' unless @lib
          @lib
        end

        def linker_option
          @linker_option = ENV['DELPHI_ANDROID_SDK_LINKER_OPTION'] || @linker_option
          warn 'Please, define DELPHI_ANDROID_SDK_LINKER_OPTION environment variable' unless @linker_option
          @linker_option
        end

        def stripdebug
          @stripdebug = ENV['DELPHI_ANDROID_SDK_STRIPDEBUG'] || @stripdebug
          warn 'Please, set DELPHI_ANDROID_SDK_STRIPDEBUG to path where arm-linux-androideabi-strip.exe is located' unless @stripdebug
          @stripdebug
        end

        def aapt
          @aapt = ENV['DELPHI_ANDROID_SDK_BUILD_TOOLS_PATH'] || @aapt
          warn 'Please, set DELPHI_ANDROID_SDK_BUILD_TOOLS_PATH to path where aapt.exe is located' unless @aapt
          @aapt
        end

        def platform
          @platform = ENV['DELPHI_ANDROID_SDK_PLATFORM_PATH'] || @platform
          warn 'Please, set DELPHI_ANDROID_SDK_PLATFORM_PATH to the path where android.jar is located' unless @platform
          @platform
        end

        def keystore
          @keystore = ENV['DELPHI_ANDROID_KEYSTORE'] || @keystore
          warn 'Please, set DELPHI_ANDROID_KEYSTORE to the path where keystore (to sign application) located' unless @keystore
          @keystore
        end

        def zipalign
          @zipalign = ENV['DELPHI_ANDROID_SDK_PLATFORM_TOOLS'] || @zipalign
          warn 'Please, set DELPHI_ANDROID_SDK_PLATFORM_TOOLS to the path where zipalign.exe is located' unless @zipalign
          @zipalign
        end
      end # class SDK

      class DCC32SDKOptions < SDK
        def dcc32options
          opts = []
          opts << '-TX.so'
          opts << "--linker:\"#{linker}\""
          opts << "--libpath:\"#{lib}\""
          opts << "--linker-option:\"#{linker_option}\""
          opts
        end
      end # class DCC32SDKOptions

      class PAClientSDKOptions < SDK
        def stripdebug
          stripdebug = super
          return Rake.quotepath('', stripdebug.to_s)
        end

        def aapt
          aapt = super
          aapt = aapt.to_s + '\\aapt.exe' unless aapt.to_s.match(/aapt\.exe$/i)
          aapt = Rake.quotepath('', aapt)
        end

        def jar
          jar = platform.to_s + '\\android.jar'
          jar = Rake.quotepath('', jar)
        end

        def zipalign
          zip_align = super
          zip_align = zip_align.to_s + '\\zipalign.exe' unless zip_align.to_s.match(/zipalign\.exe$/i)
          zip_align = Rake.quotepath('', zip_align)
        end
      end  # class PAClientSDKOptions

      class JavaSDK < SDK
        def path
          @jdk_path = ENV['JAVA_SDK_PATH'] || @jdk_path
          warn 'Please, set JAVA_SDK_PATH to the path where jarsigner.exe is located' unless @jdk_path
          @jdk_path
        end

        def jarsigner
          jarsigner = path.to_s
          jarsigner += '\\jarsigner.exe' unless jarsigner.match(/jarsigner\.exe$/i)
          return Rake.quotepath('', jarsigner)
        end

        def keystore
          key_store = super
          key_store = Rake.quotepath('', key_store.to_s.double_delimiters)
        end

        def keystore_params
          key_store_params = ENV['DELPHI_ANDROID_KEYSTORE_PARAMS']
          warn 'Please, set DELPHI_ANDROID_KEYSTORE_PARAMS to alias,method,keystore_password,key_password' unless key_store_params
          key_alias, key_params = key_store_params.to_s.split(',', 2)
          return [key_alias, key_params]
        end
      end # class JavaSDK
    end # module Android
  end # module Delphi
end # module Rake
