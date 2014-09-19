$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'byebug'
require 'docker_test'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
