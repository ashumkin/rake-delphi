# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'fileutils'
require 'tempfile'
require 'rake'
require 'rake/helpers/rake'
require 'rake/helpers/raketask'
require 'rake/helpers/string'
require 'rake/common/chdirtask'
require 'rake/delphi/paclienttool'
require 'rake/delphi/androidmanifest'

module Rake
  module Delphi
    class PAClientTask < Rake::Task
    public
      attr_reader :dccTask
      attr_accessor :suffix
      attr_reader :deploymentfiles
      attr_accessor :noclean # for debugging

      def initialize(name, application)
        super
        @last_put_arg_index = 0
        @suffix = 'AndroidPackage'
        @manifest = application.define_task(AndroidManifestTask, shortname + ':manifest')
        enhance([@manifest])
        self.needed = false
        dccTaskName = name.gsub(/:post$/, '')
        @dccTask = application[dccTaskName]
        @deploymentfiles = nil
      end

      def needed=(value)
        Logger.trace(Logger::DEBUG, name + ': .needed set to ' + value.to_s)
        super
        @manifest.needed = value
      end

    private
      def expand_vars(deploymentfiles)
        @dccTask.dccTool.init_env
        deploymentfiles.collect! do |value|
          file, dfile = [value.keys.first, value.values.first]
          if file.kind_of?(String)
            file = @dccTask.dccTool.env.expand(file)
          end
          # return expanded path
          { file => dfile }
        end
        return deploymentfiles
      end

      def put_args
        @deploymentfiles ||= @dccTask.createVersionInfo.deploymentfiles('Android')
        r = expand_vars(@deploymentfiles)
        @manifest_hash ||= { :manifest => ['.\\', '1'] }
        # add unless already added before
        r << @manifest_hash unless r.include?(@manifest_hash)
        return r
      end

      def steps
        r = [:Clean]
        # add appropriate 'put' commands count
        put_args.each do |arg|
          r << :put
        end
        r << [:stripdebug, :aaptpackage, :jarsign, :zipalign]
        r.flatten!
        return r
      end

      def get_Clean_arg(paclientTool)
        return '' if @noclean
        tempfile = Tempfile.new('paclient')
        tempfile.close
        tempfile = File.expand_path2(tempfile.path)
        tempfile.double_delimiters!
        output = @dccTask.exeoutput
        output += '\\' + @suffix
        output.double_delimiters!
        output = Rake.quotepath('', output)
        return [output, tempfile].join(',')
      end

      def get_put_arg(paclientTool)
        output = @dccTask.exeoutput
        next_put_arg = put_args[@last_put_arg_index]
        if next_put_arg.kind_of?(Hash)
          src, out = next_put_arg.to_a.first
          out = out.dup
          if src == :project_so
            src = out.last
            src = output + '\\' + src
          elsif src.kind_of?(Symbol)
            src = self.send(src)
            out << src
          end
          out = output + '\\' + @suffix + '\\' + out.join(',')
          arg = src + ',' + out
        else
          arg = next_put_arg
        end
        arg.double_delimiters!
        arg = Rake.quotepath('', arg)
        @last_put_arg_index += 1
        return arg
      end

      def find_project_so(deploymentfiles)
        deploymentfiles.each do |file|
          return file[:project_so] if file[:project_so]
        end
        fail 'Cannot find :project_so in files'
      end

      def get_stripdebug_arg(paclientTool)
        stripdebug_path = ENV['DELPHI_ANDROID_SDK_STRIPDEBUG']
        warn 'Please, set DELPHI_ANDROID_SDK_STRIPDEBUG to path where arm-linux-androideabi-strip.exe is located' unless stripdebug_path
        stripdebug_path = Rake.quotepath('', stripdebug_path.to_s)
        output_dest = find_project_so(@deploymentfiles).dup
        output = @dccTask.exeoutput + '\\' + output_dest.last
        # remove '1' string
        output_dest.delete_at(1)
        output_dest.unshift @dccTask.exeoutput + '\\' + @suffix + '\\'
        args = [stripdebug_path.double_delimiters, output.double_delimiters, output_dest.join.double_delimiters]
        return args.join(',')
      end

      def aapt_args
        r = ['library', 'classes', 'res', 'assets', :manifest, :jar, :output]
        return r
      end

      def manifest
        'AndroidManifest.xml'
      end

      def unsigned_path(full = false)
        r = @dccTask.dpr.pathmap('%n-unsigned.apk')
        r = @dccTask.exeoutput + '/' + @suffix + '/' + r if full
        return r
      end

      def get_aaptpackage_arg(paclientTool)
        output = @dccTask.exeoutput
        output_platform = File.expand_path2(output, '-u')
        apt_path = ENV['DELPHI_ANDROID_SDK_BUILD_TOOLS_PATH']
        warn 'Please, set DELPHI_ANDROID_SDK_BUILD_TOOLS_PATH to path where aapt.exe is located' unless apt_path
        apt_path = apt_path.to_s + '\\aapt.exe'
        apt_path  = Rake.quotepath('', apt_path)
        args = [apt_path.double_delimiters]
        args += aapt_args.map do |a|
           to_mkdir = false
           out = true
           if a == :output
             a = unsigned_path
           elsif a == :jar
             platform = ENV['DELPHI_ANDROID_SDK_PLATFORM_PATH']
             warn 'Please, set DELPHI_ANDROID_SDK_PLATFORM_PATH to the path where android.jar is located' unless platform
             a = platform.to_s + '\\android.jar'
             a = Rake.quotepath('', a)
             out = false
           else
             if a.kind_of?(Symbol)
               a = self.send(a)
             else
               # mkdir dirs represented by strings
               to_mkdir = true
             end
           end
           if out
             a = '/' + @suffix + '/' + a
             a_platform = output_platform + a
             a = output + a
             if to_mkdir
               mkdir a_platform unless File.exists?(a_platform)
             end
           end
           a.gsub!('/', '\\')
           a.double_delimiters!
           a
        end
        return args.join(',')
      end

      def get_jarsign_arg(paclientTool)
        jdk_path = ENV['JAVA_SDK_PATH']
        warn 'Please, set JAVA_SDK_PATH to the path where jarsigner.exe is located' unless jdk_path
        args = [Rake.quotepath('', jdk_path.to_s + '\\jarsigner.exe')]
        args << unsigned_path(true).double_delimiters
        key_store = ENV['DELPHI_ANDROID_KEYSTORE']
        warn 'Please, set DELPHI_ANDROID_KEYSTORE to the path where keystore (to sign application) located' unless key_store
        key_store = Rake.quotepath('', key_store.double_delimiters)
        key_store_params = ENV['DELPHI_ANDROID_KEYSTORE_PARAMS']
        warn 'Please, set DELPHI_ANDROID_KEYSTORE_PARAMS to alias,method,keystore_password,key_password' unless key_store_params
        key_alias, key_params = key_store_params.split(',', 2)
        args << key_alias << key_store << key_params
        return args.join(',')
      end

      def get_zipalign_arg(paclientTool)
        zip_align = ENV['DELPHI_ANDROID_SDK_PLATFORM_TOOLS']
        warn 'Please, set DELPHI_ANDROID_SDK_PLATFORM_TOOLS to the path where zipalign.exe is located' unless zip_align
        args = [Rake.quotepath('', zip_align.to_s + '\\zipalign.exe')]
        args << unsigned_path(true).double_delimiters
        zip_aligned_out = @dccTask.exeoutput + '\\' + @suffix + '\\' + @dccTask.dpr.pathmap('%n.apk')
        zip_aligned_out_platform = File.expand_path2(zip_aligned_out, '-u')
        FileUtils.rm zip_aligned_out_platform if File.exists?(zip_aligned_out_platform)
        zip_aligned_out.double_delimiters!
        args << zip_aligned_out
        args << '4'
        return args.join(',')
      end

      def build_args(paclientTool, step)
        r = ['']
        arg = ''
        if step.kind_of?(Symbol)
          arg = self.send("get_#{step.to_s}_arg", paclientTool)
        else
          arg = ''
        end
        r << "--#{step.to_s}=#{arg}"
        return r
      end

    public
      def execute(args = nil)
        super
        paclientTool = PAClientTool.new
        paclientTool.class.checkToolFailure(paclientTool.toolpath)
        exe_cmd = Rake.quotepath('', paclientTool.toolpath)
        _source = @dccTask.dpr
        ChDir.new(self, File.dirname(_source)) do |dir|
          RakeFileUtils.verbose(Logger.debug?) do
            @last_put_arg_index = 0
            steps.each do |step|
              args = build_args(paclientTool, step)
              args.compact!
              sh exe_cmd + args.join(' ')
            end
            output_platform = File.expand_path2(@dccTask.exeoutput, '-u')
            mv output_platform.pathmap('%p%s') + @suffix + _source.pathmap('%s%n.apk'), output_platform
          end
        end
        # reset files (for reusage, mainly in tests)
        @deploymentfiles = nil
      end
    end # class PAClientTask
  end
end
