# encoding: utf-8

require 'fileutils'
require 'rake/common/classes'
require 'rake/helpers/raketask'

module Rake
  module Delphi
    class EchoToFile < BasicTask
        def initialize(task, ifile, ofile, vars)
            super(task)
            @task.out "#{ifile} -> #{ofile}"
            FileUtils.mkdir_p(File.dirname(ofile))
            File.open(ifile, 'r') do |f|
                File.open(ofile, 'w') do |w|
                    while (line = f.gets)
                        # replace ${var1.var2.var3} with its value from xml
                        line.gsub!(/\$\{(.+?)\}/) do |match|
                            val = nil
                            $1.split(".").each do |part|
                                val = val.nil? ? vars[part] : val[part]
                            end
                            match = val.nil? ? match : val
                        end if vars
                        w.puts line
                    end
                    w.close
                end
                f.close
            end
        end
    end
  end
end
