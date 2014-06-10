# encoding: utf-8

module Rake
  module Delphi
    class EnvVariable
        attr_reader :name
        attr_accessor :value

        def initialize(name, value)
            @name, @value = name, value
        end
    end

    class EnvVariables < ::Array
        def self.delphi_version
            ENV['DELPHI_VERSION']
        end

        def initialize(regpath, delphidir)
            _dir = delphidir.gsub(/\/$/, '')
            add('DELPHI', _dir)
            add('BDS', _dir)
            expand_vars
        end

        def add(var, value)
            self << EnvVariable.new(var, value)
        end

        def expand(value)
            self.each do |ev|
                value.gsub!("$(#{ev.name})", ev.value)
            end
            value
        end

        def expand_vars
            self.map! do |v|
                v.value = expand(v.value)
                v
            end
        end
    end
  end
end
