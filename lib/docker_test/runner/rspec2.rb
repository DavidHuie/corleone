require 'stringio'
require 'rspec/core'

module DockerTest::Runner

  class RSpec < DockerTest::Emitter::RSpec

    def initialize(args, logger)
      super(args)
      read_spec_files
      @logger = logger
    end

    def run_each(input_queue, output_queue)
      configuration.reporter.report(0, configuration.randomize? ? configuration.seed : nil) do |reporter|
        reporter.register_listener(Formatter.new(output_queue, @logger),
                                   :example_failed,
                                   :example_pending,
                                   :example_passed)

        begin
          @logger.debug("starting rspec runner")
          configuration.run_hook(:before, :suite)

          loop do
            example = input_queue.pop
            @logger.debug("rspec example received: #{example}")
            break if example.instance_of?(DockerTest::Message::Stop)
            example.run(reporter)
          end
        ensure
          configuration.run_hook(:after, :suite)
        end
      end
    end

    class Formatter

      def initialize(output_queue, logger)
        @output_queue = output_queue
        @logger = logger
      end

      def self.clean_hash(h)
        new_h = h.clone
        new_h.each do |k, v|
          new_h.delete(k) if [Proc].include?(v.class)
          new_h[k] = clean_hash(v) if v.instance_of?(Hash)
        end
        new_h
      end

      [:example_passed, :example_failed, :example_pending].each do |m|
        define_method(m) do |msg|
          result = DockerTest::Message::Result
            .new(self.class.clean_hash(msg.metadata))
          @logger.debug("emitting result message: #{result}")
          @output_queue << result
        end
      end

    end

  end

end
