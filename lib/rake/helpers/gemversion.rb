# encoding: utf-8

module Gem
    class VersionImproved < Version
        def initialize(version)
            # dup version
            # to avoid error on earlier versions of Gem::Version with frozen strings
            super(version.nil? ? version : version.dup)
            @version = '0.0.0.0' if @version.empty?
            # avoid bug when Gem::Version <= 1.3.7
            @segments = nil
        end

        ##
        # Return a new version object where the previous to the last revision
        # number is one lower (e.g., 5.3.1 => 5.2).
        #
        # Pre-release (alpha) parts, e.g, 5.3.1.b.2 => 5.2, are ignored.
        def prev_release
            segments = self.segments.dup
            segments.pop while segments.any? { |s| String === s }
            segments.pop if segments.size > 1

            segments[-1] = segments[-1].to_i.pred.to_s
            self.class.new segments.join(".")
        end

        ##
        # The build for this version (e.g. 1.2.0.a -> 1.2.1).
        # Non-prerelease versions return themselves.
        def build
            return self unless prerelease?

            segments = self.segments.dup
            segments.pop while segments.any? { |s| String === s }
            segments[-1] = segments[-1].succ
            self.class.new segments.join('.')
        end

        ##
        # The build number
        def build_num
            segments = self.segments.dup
            segments.pop while segments.any? { |s| String === s }
            segments.pop while segments.size > 4

            segments.size == 4 ? segments[-1] : nil
        end

        ##
        # Returns release only part
        # (e.g. 1.2.3.4 -> 3, 1.2.3 -> 2)
        def release_num
            segments = self.segments.dup
            segments.pop while segments.any? { |s| String === s }
            segments.pop if segments.size > 1

            segments[-1]
        end

        def major
            segments = self.segments.dup
            segments.pop while segments.any? { |s| String === s }
            segments.pop while segments.size > 1

            segments[-1]
        end

        def minor
            segments = self.segments.dup
            segments.pop while segments.any? { |s| String === s }
            segments.pop while segments.size > 2

            segments.size == 2 ? segments[-1] : nil
        end

        def comma
            segments.dup.join(',')
        end
    end
end
