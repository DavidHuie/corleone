require 'stringio'
require 'rspec/core'

module DockerTest::Runner

  class RSpec < ::RSpec::Core::Runner

    def self.get_runner(args)
      options = ::RSpec::Core::ConfigurationOptions.new(args)
      runner = new(options)
      runner.setup(runner.output_buffer, runner.output_buffer)
      runner.process_items
      runner
    end

    def output_buffer
      @output_buffer ||= StringIO.new
    end

    def setup_message
      DockerTest::Message::Setup.new(ARGV)
    end

    def pop
      item_queue.pop
    end

    def item_queue
      @item_queue ||= Queue.new
    end

    def empty?
      item_queue.empty?
    end

    def process_items
      @world.ordered_example_groups.each do |example|
        item_queue << example
      end
    end

    def run_each(input_queue, output_queue)
      # formatter = DockerTest::Runner::RSpec::Formatter.new

      @configuration.reporter.report(0) do |reporter|
        # reporter.register_listener(formatter, :example_failed)

        begin
          DockerTest.logger.debug("starting rspec runner")

          hook_context = ::RSpec::Core::SuiteHookContext.new
          @configuration.hooks.run(:before, :suite, hook_context)
          failures = false

          loop do
            example = input_queue.pop
            DockerTest.logger.debug("rspec example received: #{example}")
            break if example.instance_of?(DockerTest::Message::Stop)
            # formatter.set_message_context(message)
            value = example.run(reporter)
            failures = true unless value
            DockerTest.logger.debug("emitting result message: #{value}")
            output_queue << DockerTest::Message::Result.new(value)
          end

          @configuration.failure_exit_code if failures
        ensure
          @configuration.hooks.run(:after, :suite, hook_context)
        end
      end
    end

    class Formatter

      def set_message_context(message)
        # @message = message
      end

      def example_failed(notification)
        @message.metadata = {
          exception: notification.exception,
          message_lines: notification.message_lines,
          formatted_backtrace: notification.formatted_backtrace,
        }
      end

    end

  end

end
