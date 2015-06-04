# encoding: utf-8

=begin rdoc

=end

require 'rake'
require 'rake/delphi'
require 'rake/delphi/project'

if RAKEVERSION !~ /^0\.8/
    require 'rake/dsl_definition'
    include Rake::DSL
    Rake::TaskManager.record_task_metadata = true if Rake::TaskManager.respond_to?('record_task_metadata')
end

module TestModule
    PROJECT_NAME = 'Rake test project'
    PROJECT_FILE = 'testproject'

task :default => 'test:compile'

namespace :test do

    desc 'Compilation'
    _task = task :compile do |t|
        puts 'task %s executed' % t.name
    end

    desc 'Preparation'
    task :prepare, :useresources, :options do |t, opts|
        _task = Rake::Task['test:compile']
        dpr = Rake.application.define_task(Rake::Delphi::Project, (_task.name + ':delphi').to_sym)
        dpr[:quiet] = true
        dpr[:resources_additional] = []
        dpr[:resources_additional] << 'resources' if opts[:useresources]
        dpr[:resources_additional] << 'resources_ext:extended_resources.dres' if opts[:useresources] === 'ext'
        dpr[:resources_additional] = dpr[:resources_additional].join(';')
        if Rake::Delphi::EnvVariables.delphi_version >= Rake::Delphi::DELPHI_VERSION_XE
            dpr[:platform] = 'Win32'
        end
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

        directory dpr_vars[:bin_path]
        _task.enhance [dpr_vars[:bin_path], dpr]
    end

end

end
