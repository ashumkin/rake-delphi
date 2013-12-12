# encoding: utf-8

require 'digest'
require 'zlib'

class Digest::CRC32 < Digest::Class
    include Digest::Instance

    def update(str)
        @crc32 = Zlib.crc32(str, @crc32)
    end

    def initialize
        reset
    end

    def reset
        @crc32 = 0
    end

    def finish
        @crc32.to_s
    end

    def hexdigest_to_digest(h)
        h.unpack('a2' * (h.size / 2)).collect { |i| i.hex.chr }.join
    end
end
