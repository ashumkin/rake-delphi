# encoding: utf-8

require 'rake/common/classes'
require 'rake/helpers/rake'

module Rake
  module Delphi
    class Sendmail < BasicTask

        def initialize(task, opts)
            super(task)
            cmd = ''
            predefined = { :from => '-f', :"from.full" => '-F', :extra => nil, :to => nil }
            predefined.keys.sort{|a, b| a.to_s <=> b.to_s}.each do |k|
                cmd += "#{predefined[k]} #{opts[k]} " if opts[k]
            end
            cmd = "#{sendmail} -i #{cmd}"
            Logger.trace(Logger::VERBOSE, cmd)
            if @task.application.windows? && Rake.ruby18?
                require 'win32/open3'
            else
                require 'open3'
            end
            Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
                stdin.puts(opts[:text])
                stdin.close
                while s = stdout.gets
                    puts s
                end
                while s = stderr.gets
                    puts s
                end
            end
        end

        def sendmail
            ENV['SENDMAIL'] || 'sendmail'
        end
    end
  end
end
