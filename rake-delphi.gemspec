# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake/delphi/version'

Gem::Specification.new do |spec|
  spec.name          = "rake-delphi"
  spec.version       = Rake::Delphi::VERSION
  spec.authors       = ['Alexey Shumkin']
  spec.email         = ['Alex.Crezoff@gmail.com']
  spec.description   = 'Tasks for building Delphi projects'
  spec.summary       = 'Tasks for building Delphi projects'
  spec.homepage      = 'http://github.com/ashumkin/rake-delphi.gem'
  spec.license       = 'MIT'

  spec.files         = Dir['*', 'lib/**/*.*rb',
    'test/*.rb', 'test/helpers/*.rb', 'test/resources/**/*', 'test/resources/**/.gitkeep']
  # avoid adding redundant files
  spec.files.delete_if do |f|
    match = false
    [/\/test\/tmp\//, /\/dcu\//, /\.(drc|res|exe|orig)$/].each do |re|
      match = re.match(f)
      break if match
    end
    match
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "bundler", "~> 1.3"
  spec.add_runtime_dependency "rake", "~> 10.0.4"
  spec.add_runtime_dependency "xml-simple"
  spec.add_runtime_dependency "inifile"
  spec.add_development_dependency "minitest", "~> 4.3"
  spec.add_development_dependency "rubyzip", "~> 0.9.9"
  spec.add_development_dependency "apktools"
end
