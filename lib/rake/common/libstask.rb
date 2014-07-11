# encoding: utf-8

require 'rake/common/classes'
require 'rake/delphi/liblist'

module Rake
  module Delphi
    class LibsTask < Rake::Task
        attr_reader :libs

        def initialize(name, app)
            super
            @original_dir = ENV['RAKE_DIR'] || Rake.original_dir
        end

        def self.define(name, app)
            app.tasks.each do |t|
                # if there is a task with a name like a searched one
                return t if t.name.index(name)
            end
            # else - define a new task
            app.define_task(LibsTask, name)
        end

        def libs_relative(level)
            @libs.map { |d| d.gsub(@original_dir, '.' + '/..' * level)}
        end

        def execute(args = nil)
            super
            mask = @original_dir + '/lib/**/**'
            @libs = LibList.new(mask)
        end
    end
  end
end
