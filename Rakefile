require 'rubygems'
require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = 'corleone'
  gem.homepage = 'http://github.com/DavidHuie/corleone'
  gem.license = 'MIT'
  gem.summary = 'A toolkit for distributing tasks among workers'
  gem.description = 'A toolkit for distributing tasks among workers'
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
