# encoding: utf-8

require 'zlib'
require 'rake/common/classes'
require 'rake/common/logger'
require 'rake/helpers/raketask'

module Rake
  module Delphi
    class GZip < BasicTask
        def initialize(task, params)
            super(task)
            if params.kind_of?(String)
                gzip_file(params)
            elsif params.kind_of?(Array)
                params.each do |file|
                    gzip_file(file)
                end
            end
        end

    private
        def gzip_file(file)
            @task.out "GZip #{file} -> #{file}.gz"
            sfile = File.open(file + '.gz', "w+b")
            gzfile = Zlib::GzipWriter.wrap(sfile) do |gz|
                File.open(file, "rb") do |f|
                    gz.mtime = File.mtime(file)
                    gz.orig_name = File.basename(file)
                    gz.write(f.read)
                    gz.close
                end
            end
        end
    end

    class ZipTask < BasicTask
        def initialize(task, zipfile, files, options = nil)
            super(task)
            Logger.trace(Logger::VERBOSE, [zipfile, files])
            raise "zipfile name is not defined!" if zipfile.nil? || zipfile.empty?
            @norubyzip = nil
            @options = options || {}
            begin
                require 'zip/zip'
            rescue LoadError
                @norubyzip = true
            end
            raise "no ZIP library (rubyzip) found!" if @norubyzip
            # work with rubyzip
            Logger.trace(Logger::VERBOSE, '`rubyzip` gem is used')
            File.unlink(zipfile) if File.exists?(zipfile) && ! @options[:add]
            Zip.options[:continue_on_exists_proc] = true
            Zip::ZipFile.open(zipfile, Zip::ZipFile::CREATE) do |z|
                files.each do |f|
                    zip_addfile(z, f)
                end
            end
        end

    private
        def zip_addfile(zipfile, file)
            filename_set = false
            if file.kind_of?(Hash)
                filename = file.values.first
                file = file.keys.first
                filename_set = true
                # if directory name given append filename to its path
                if /\/$/.match(filename)
                  filename += File.basename(file)
                end
            else
                filename = File.basename(file)
            end
            return if ! File.exists?(file)
            if @options[:preserve_paths] && ! filename_set
                dir = File.dirname(file)
                # avoid "./<filename>" entries (instead of "<filename>")
                filename = File.join(dir, filename) if dir != '.'

                # remove leading slash (for absolute paths)
                filename.gsub!(/^\//, '')
            end
            # do not add directory entries
            return if File.directory?(file)
            @task.out "Zipping '#{file}' as '#{filename}'..."
            zipfile.add(filename, file)
        end
    end
  end
end
