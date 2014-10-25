require 'rspec/core'

RSPEC_VERSION = ::RSpec::Core::Version::STRING.to_i

unless [2, 3].include?(RSPEC_VERSION)
  fail 'requires rspec version 2 or 3'
end

require "docker_test/emitter/rspec#{RSPEC_VERSION}"
require "docker_test/collector/rspec#{RSPEC_VERSION}"
require "docker_test/runner/rspec#{RSPEC_VERSION}"
