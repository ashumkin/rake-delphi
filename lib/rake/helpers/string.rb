# encoding: utf-8

# extend class String with a `prepend` method
class String
    if RUBY_VERSION =~ /^1\.8/
        def prepend(value)
            insert(0, value)
        end
    end

    def starts_with?(prefix)
        prefix = prefix.to_s
        self[0, prefix.length] == prefix
    end

    def double_delimiters
        gsub('\\', '\\\\\\')
    end

    def double_delimiters!
        replace(self.double_delimiters)
    end

    def dos2unix_separator
        gsub('\\', '/')
    end

    def unix2dos_separator
        gsub('/', '\\')
    end

    def dos2unix_separator!
        replace(self.dos2unix_separator)
    end

    def unix2dos_separator!
        replace(self.unix2dos_separator)
    end
end
