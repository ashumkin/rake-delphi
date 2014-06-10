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
    'test/*', 'test/helpers/*', 'test/resources/**/*', 'test/resources/**/.gitkeep']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
