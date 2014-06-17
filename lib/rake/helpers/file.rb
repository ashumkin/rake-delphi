# encoding: utf-8

class File
	@@separator = nil
	def self.cygwin?
		RUBY_PLATFORM.downcase.include?('cygwin')
	end

	def self.separator
		return @@separator if @@separator
		# Return `backlash` for Cygwin and Windows (ALT_SEPARATOR)
		# otherwise - system separator
		return @@separator = cygwin? ? '\\' : (ALT_SEPARATOR ? ALT_SEPARATOR : SEPARATOR)
	end

	def self.cygpath(path, flag = nil)
		flag ||= '-w'
		# convert to Windows path
		path = `cygpath #{flag} "#{path}"`.chomp
	end

	def self.expand_path2(path, flag = nil)
		path = expand_path(path)
		return path unless cygwin?
		return cygpath(path, flag)
	end

	def self.dirname2(path, flag = nil)
		path = dirname(path)
		return path unless cygwin?
		path = cygpath(path, flag)
		path.gsub!('\\', '\\\\') unless flag
		path
	end
end
