# encoding: utf-8

require 'rake/common/classes'
require 'rake/helpers/digest'

module Rake
  module Delphi
    class HashTask < BasicTask
        def initialize(file, alg)
            @file = file
            @alg = alg
        end

        def digest
            if ['md5', 'sha1'].include?(@alg)
                require 'digest/' + @alg
                return eval("Digest::#{@alg.upcase}.file(@file).hexdigest.upcase")
            else
                return "%02X" % Digest::CRC32.file(@file).digest.to_i
            end
        end
    end

    class HashesTask < BasicTask
        def initialize(task, files, alg)
            super(task)
            @hashes = {}
            calc_hashes(files, alg)
        end

        def calc_hashes(files, alg)
            files = [files] unless files.kind_of?(Array)
            files.each do |f|
                @hashes[f] = { alg.upcase => HashTask.new(f, alg).digest }
            end
        end

        def to_hash
            @hashes
        end
    end
  end
end
