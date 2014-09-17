require 'rubygems'
require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = 'docker_test'
  gem.homepage = 'http://github.com/DavidHuie/docker_test'
  gem.license = 'MIT'
  gem.summary = 'A toolkit for parallelizing tests among Docker containers'
  gem.description = 'A toolkit for parallelizing tests among Docker containers'
  gem.email = 'dahuie@gmail.com'
  gem.authors = ['David Huie']
end

Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task default: :spec
