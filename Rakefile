require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

desc 'Run RuboCop against the source code.'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << '--display-cop-names'
  task.options << '--display-style-guide'
end

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard) do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['-m', 'rdoc']
  t.stats_options = ['--list-undoc']
end

task default: %i[spec rubocop yard]
