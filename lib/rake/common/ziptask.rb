# encoding: utf-8

require 'zlib'
require 'rake/common/classes'
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
            pp [zipfile, files] if trace?
            raise "zipfile name is not defined!" if zipfile.nil? || zipfile.empty?
            @norubyzip = nil
            @options = options || {}
            begin
                require 'zipruby'
            rescue LoadError
                begin
                    require 'zip/zip'
                rescue LoadError
                    @norubyzip = true
                end
            end
            raise "no ZIP library (nor zipruby nor rubyzip) found!" if @norubyzip
            if defined? Zip::Archive
                # zipruby used
                $stderr.puts '`zipruby` gem is used' if trace?
                Zip::Archive.open(zipfile, Zip::CREATE | Zip::TRUNC) do |z|
                    files.each do |f|
                        zip_addfile(z, f)
                    end
                end
            else
                # work with rubyzip
                $stderr.puts '`rubyzip` gem is used' if trace?
                File.unlink(zipfile) if File.exists?(zipfile)
                Zip.options[:continue_on_exists_proc] = true
                Zip::ZipFile.open(zipfile, Zip::ZipFile::CREATE) do |z|
                    files.each do |f|
                        zip_addfile(z, f)
                    end
                end
            end
        end

    private
        def zip_addfile(zipfile, file)
            return if ! File.exists?(file)
            filename = File.basename(file)
            @task.out "Zipping #{file}..."
            if defined? Zip::Archive
                if @options[:preserve_paths]
                    if ! zipfile.locate_name(File.dirname(file))
                        zipfile.add_dir(File.dirname(file))
                    end
                    filename = file
                end
                zipfile.add_file(filename, file)
            else
                if @options[:preserve_paths]
                    dir = File.dirname(file)
                    # avoid "./<filename>" entries (instead of "<filename>")
                    filename = File.join(dir, filename) if dir != '.'
                end
                zipfile.add(filename, file)
            end
        end
    end
  end
end
