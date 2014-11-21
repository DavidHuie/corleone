require 'base64'
require 'drb/drb'
require 'logger'
require 'securerandom'
require 'set'

module DT

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end

require 'dt/server'
require 'dt/message'
require 'dt/worker'
require 'dt/registry'
require 'dt/pool'
