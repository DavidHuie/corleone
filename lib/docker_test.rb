require 'base64'
require 'logger'
require 'drb/drb'

module DockerTest

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end

require 'docker_test/server'
require 'docker_test/message'
require 'docker_test/worker'
