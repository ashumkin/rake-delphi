# encoding: utf-8

# include this file
# to avoid errors like 'uninitialized constant Rake::DSL'
# on rake > v0.8.7
if RAKEVERSION !~ /^0\.8/
    require 'rake/dsl_definition'
    include Rake::DSL
    Rake::TaskManager.record_task_metadata = true if Rake::TaskManager.respond_to?('record_task_metadata')
end
