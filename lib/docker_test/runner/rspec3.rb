require 'stringio'
require 'rspec/core'

require_relative '../emitter/rspec3'

module DockerTest::Runner

  class RSpec < DockerTest::Emitter::RSpec

    def initialize(args, logger)
      super(args)
      @logger = logger
    end

    def configuration
      @rspec.instance_variable_get("@configuration")
    end

    def run_each(input_queue, output_queue)
      configuration.reporter.report(0) do |reporter|
        reporter.register_listener(Formatter.new(output_queue, @logger),
                                   :example_failed,
                                   :example_pending,
                                   :example_passed)
        begin
          @logger.debug("starting rspec runner")

          hook_context = ::RSpec::Core::SuiteHookContext.new
          configuration.hooks.run(:before, :suite, hook_context)
          loop do
            example = input_queue.pop
            @logger.debug("rspec example received: #{example}")
            break if example.instance_of?(DockerTest::Message::Stop)
            example.run(reporter)
          end
        ensure
          configuration.hooks.run(:after, :suite, hook_context)
        end
      end
    end

    class Formatter

      def initialize(output_queue, logger)
        @output_queue = output_queue
        @logger = logger
      end

      def self.cleanse_hash(h)
        new_h = h.clone
        new_h.each do |k, v|
          new_h.delete(k) if [Proc].include?(v.class)
          new_h[k] = cleanse_hash(v) if v.instance_of?(Hash)
        end
        new_h.default_proc = nil
        new_h
      end

      [:example_passed, :example_failed, :example_pending].each do |m|
        define_method(m) do |msg|
          result = DockerTest::Message::Result
            .new(self.class.cleanse_hash(msg.example.metadata))
          @logger.debug("emitting result message: #{result.payload}")
          @output_queue << result
        end
      end

    end

  end

end
