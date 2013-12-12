# encoding: utf-8

class Logger
    class Formatter
        # following manipulations with $-v
        # are suppressing warning "already initialized constant"
        ov = $-v
        begin
            $-v = nil
            Format = "%6$s\n"
        ensure
            $-v = ov
        end
    end
end
