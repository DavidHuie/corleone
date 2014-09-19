require 'securerandom'
require 'base64'
require 'docker'
require 'drb/drb'
require 'logger'

module DockerTest

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  module Docker; end

end

require 'docker_test/server'
require 'docker_test/message'
require 'docker_test/worker'
require 'docker_test/docker/container_manager'
