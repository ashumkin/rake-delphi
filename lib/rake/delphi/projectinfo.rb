# encoding: utf-8

require 'xmlsimple'
require 'rake/helpers/rake'

module Rake
  module Delphi
    class ProjectVersionInfo
        def initialize(task)
            @info = Hash.new
            @file = task.systempath.pathmap('%X.' + self._ext)
            do_getcontent
        end

        def do_getcontent
            @content = nil
        end

        def _ext
            ''
        end

        def [](key)
            @info[key.to_sym]
        end

        def method_missing(name, *args, &block)
            @info[name]
        end
    end

    class BDSVersionInfo < ProjectVersionInfo
        def initialize(task)
            super(task)
            versioninfo = get_versioninfo_tag(@content)
            # no need to continue if no version info file
            return unless versioninfo
            ['Delphi.Personality', 'VersionInfoKeys', 'VersionInfoKeys'].each do |key|
              versioninfo = versioninfo[key]
              # test version info file validity
              # no need to continue if file not valid
              return unless versioninfo
            end
            use_encode = String.new.respond_to?(:encode)
            encoding = self.class.encoding
            if encoding && ! use_encode
                require 'iconv'
                iconv = Iconv.new(encoding, 'UTF-8')
            end
            versioninfo.each do |v|
                cv = v['content']
                cv = (use_encode ? cv.encode(encoding, 'UTF-8') : iconv.iconv(cv)) if cv && encoding
                @info[v['Name'].to_sym] = cv
            end
        end

        def get_versioninfo_tag(content)
            return content
        end

        def self.encoding
            # override to set your own encoding
            nil
        end

        def do_getcontent
            if File.exists?(@file)
                @content = XmlSimple.xml_in(@file, :ForceArray => false)
            else
                warn "WARNING! Version info file #{@file} does not exists"
                super
            end
        end

        def _ext
            return 'bdsproj'
        end
    end

    class RAD2007VersionInfo < BDSVersionInfo
        def _ext
            return 'dproj'
        end

        def get_versioninfo_tag(content)
            # .dproj file has more nesting levels
            return content['ProjectExtensions']['BorlandProject']['BorlandProject'] if content
        end
    end

    class RAD2010VersionInfo < RAD2007VersionInfo
        def get_versioninfo_tag(content)
            # .dproj file has more nesting levels
            return content['ProjectExtensions']['BorlandProject'] if content
        end
    end

    class XEVersionInfo < RAD2010VersionInfo
    private
      def read_file_class(platform, node, hash, key)
        platforms = node['Platform']
        unless platforms.kind_of?(Array)
          platforms = [platforms]
        end
        platforms.each do |plat|
          if plat['Name'].casecmp(platform) == 0
            # take filename from hash by key
            value = node.delete(key)
            # delete Name (it is a filtered platform)
            plat.delete('Name')
            # update Platform
            node['Platform'] = plat
            node.delete('Platform') if plat.empty?
            hash.merge!({ value => node })
          end
        end
      end

      def read_files_and_classes(deployment_content, platform)
        files = {}
        classes = {}
        deployment_content.each do |k, v|
          if k == 'DeployFile'
            v.each do |file|
              read_file_class(platform, file, files, 'LocalName')
            end
          elsif k == 'DeployClass'
            v.each do |_class|
              read_file_class(platform, _class, classes, 'Name')
            end
          end
        end
        return files, classes
      end

      def make_deployment(files, classes)
        r = []
        files.each do |file, value|
          value_class = value['Class']
          _class = classes[value_class]
          next if ['AndroidGDBServer', 'ProjectAndroidManifest'].include?(value_class)
          if value_class == 'AndroidClassesDexFile'
            # dirty hack for 'classes.dex'
            # usually .dproj has full path to it
            # but we may have another path
            # so remove 'first' part
            file = file.gsub(/^.+(\\lib\\android\\)/, '$(BDS)\1')
          end
          remote_name = value['Platform'] ? value['Platform']['RemoteName'] : file.pathmap('%f')
          if value_class == 'ProjectOutput'
            file = :project_so
          end
          r << { file => [_class['Platform']['RemoteDir'] + '\\', '1', remote_name] }
        end
        return r
      end

    public
      def deploymentfiles(platform)
        deployment = @content
        raise 'There is no deployment info! Cannot continue.' unless deployment
        ['ProjectExtensions', 'BorlandProject', 'Deployment'].each do |section|
          deployment = deployment[section]
          break unless deployment
        end
        warn "#{@file} have no deployment info" unless deployment
        files, classes = read_files_and_classes(deployment, platform)
        r = make_deployment(files, classes)
        return r
      end
    end

  end
end
