require 'stringio'
require 'rspec/core'

module DockerTest::Runner

  class RSpec

    def initialize(payload, logger)
      @payload = payload
      @logger = logger
    end

    def command(msg)
      files = msg.payload.join(' ')
      "rspec #{files}"
    end

    def run_each(input_queue, output_queue)
      loop do
        example = input_queue.pop
        @logger.debug("rspec examples received: #{example}")

        break if example.instance_of?(DockerTest::Message::Stop)

        system(command(example))

        output_queue << DockerTest::Message::Finished.new
      end
    end

  end

end
