require 'base64'
require 'drb/drb'
require 'logger'
require 'securerandom'
require 'set'

module Corleone

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end

require 'corleone/server'
require 'corleone/message'
require 'corleone/worker'
require 'corleone/registry'
require 'corleone/pool'
