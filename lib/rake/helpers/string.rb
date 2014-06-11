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
end
