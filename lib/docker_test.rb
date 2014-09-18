require 'base64'
require 'logger'
require 'socket'

module DockerTest

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end

require 'docker_test/master'
require 'docker_test/worker'
require 'docker_test/worker_client'
require 'docker_test/message'
require 'docker_test/runner'
