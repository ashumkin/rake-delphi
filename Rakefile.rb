# encoding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new('test') do |t|
    t.ruby_opts << '-d' if Rake.application.options.trace
    t.libs << 'test'
    t.verbose = true
end
