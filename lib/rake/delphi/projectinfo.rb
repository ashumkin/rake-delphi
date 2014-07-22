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
    end

  end
end
