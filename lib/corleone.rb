require 'base64'
require 'drb/drb'
require 'logger'
require 'securerandom'
require 'set'

Thread.abort_on_exception = true

module Corleone

  def self.logger
    @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::INFO }
  end

  def self.server_uri
    ENV['SERVER_URI'] || 'druby://0.0.0.0:7000'
  end

  def self.workers
    (ENV['WORKERS'] || 1).to_i
  end

end

if ENV['DEBUG']
  Corleone.logger.level = Logger::DEBUG
end

require 'corleone/server'
require 'corleone/message'
require 'corleone/worker'
require 'corleone/registry'
require 'corleone/pool'
