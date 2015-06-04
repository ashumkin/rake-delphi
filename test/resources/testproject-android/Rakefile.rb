# vim: set shiftwidth=2 tabstop=2 expandtab:
# encoding: utf-8

require 'rake'
require 'rake/delphi'
require 'rake/delphi/project'

if RAKEVERSION !~ /^0\.8/
  require 'rake/dsl_definition'
  include Rake::DSL
  Rake::TaskManager.record_task_metadata = true if Rake::TaskManager.respond_to?('record_task_metadata')
end

module TestAndroidModule
  PROJECT_NAME = 'Rake test project for Android'
  PROJECT_FILE = 'TestProject'

  task :default => 'test_android:compile'

  namespace :test_android do

    desc 'Compilation'
    _task = task :compile do |t|
      puts 'task %s executed' % t.name
    end

    desc 'Preparation'
    task :prepare, :useresources, :options do |t, opts|
      fail 'Cannot compile this project with Delphi below XE5' if Rake::Delphi::EnvVariables.delphi_version < Rake::Delphi::DELPHI_VERSION_XE5
      _task = Rake::Task['test_android:compile']
      dpr = Rake.application.define_task(Rake::Delphi::Project, (_task.name + ':delphi').to_sym)
      dpr[:quiet] = true
      dpr[:resources_additional] = 'resources' if opts[:useresources]
      dpr[:platform_configuration] = 'Debug'
      dpr[:platform] = 'Android32'
      # always use library path for Android
      dpr[:uselibrarypath] = true
      options = opts[:options] || {}
      if options.kind_of?(String)
        options = eval(options)
      end
      options.each do |k, v|
        dpr[k] = v
      end
      dpr_vars = {}
      dpr_vars[:bin_path] = options[:bin] || File.expand_path(File.dirname(__FILE__) + '/bin')

      dpr_vars[:bin] = File.expand_path2(dpr_vars[:bin_path])
      dpr.init(Module.nesting, File.expand_path(__FILE__), dpr_vars, 0)
      dpr.application[dpr.name + ':dcc32'].namespaces << ';FMX'

      directory dpr_vars[:bin_path]
      _task.enhance [dpr_vars[:bin_path], dpr]
    end

  end

end
