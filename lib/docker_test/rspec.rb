require 'rspec/core'

case ::RSpec::Core::Version::STRING.to_i
when 2
  require 'docker_test/collector/rspec2'
  require 'docker_test/emitter/rspec2'
  require 'docker_test/runner/rspec2'
when 3
  require 'docker_test/collector/rspec3'
  require 'docker_test/emitter/rspec3'
  require 'docker_test/runner/rspec3'
else
  fail 'requires rspec version 2 or 3'
end
