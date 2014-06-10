# encoding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

task :"test:prerequisites" do
    raise 'Please define DELPHI_VERSION environment variable' \
		+ ' to run tests with appropriate Delphi compiler' unless ENV['DELPHI_VERSION']
end

Rake::TestTask.new('test') do |t|
    t.ruby_opts << '-d' if Rake.application.options.trace
    t.libs << 'test'
    t.verbose = true
    Rake::application[t.name].enhance([:"test:prerequisites"])
end
