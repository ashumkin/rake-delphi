# encoding: utf-8
# vim: set shiftwidth=2 tabstop=2 expandtab:

require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rake/testtask'

task :default => :test

task :"test:prerequisites" do
    raise 'Please define DELPHI_VERSION environment variable' \
		+ ' to run tests with appropriate Delphi compiler' unless ENV['DELPHI_VERSION']
end

Rake::TestTask.new('test:no:delphi') do |t|
    t.ruby_opts << '-d' if Rake.application.options.trace
    t.libs << 'test'
    t.test_files = FileList['test/test*'].delete_if do |f|
      # exclude "delphi" tests
      /delphi/.match(f)
    end
    t.verbose = true
end


desc 'Test on Travis CI (with no Delphi tests)'
task 'travis' => 'test:no:delphi'

Rake::TestTask.new do |t|
    t.ruby_opts << '-d' if Rake.application.options.trace
    t.libs << 'test'
    t.verbose = true
    Rake::application[t.name].enhance([:"test:prerequisites"])
end

desc 'Increase gem version'
task :'version:inc' do
  next_version = Gem::Version.new(Rake::Delphi::VERSION + '.0').bump
  puts "Version is #{next_version} now"
  version_file = File.expand_path('../lib/rake/delphi/version.rb', __FILE__)
  file_content = File.read(version_file).gsub(/(VERSION = )(.+)$/, "\\1'#{next_version}'")
  File.open(version_file, 'w') do |f|
    f.write(file_content)
  end
end
