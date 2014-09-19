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
      item = item_queue.pop
      message = DockerTest::Message::Item.new(item)
      message.num_responses = item.examples.length
      message
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
      @configuration.reporter.report(0) do |reporter|
        reporter.register_listener(DockerTest::Runner::RSpec::Formatter.new(output_queue),
                                   :example_failed,
                                   :example_pending,
                                   :example_passed)

        begin
          DockerTest.logger.debug("starting rspec runner")

          hook_context = ::RSpec::Core::SuiteHookContext.new
          @configuration.hooks.run(:before, :suite, hook_context)
          responses = []

          loop do
            example = input_queue.pop
            DockerTest.logger.debug("rspec example received: #{example}")
            break if example.instance_of?(DockerTest::Message::Stop)
            responses << example.run(reporter)
          end

          @configuration.failure_exit_code if !responses.all?
        ensure
          @configuration.hooks.run(:after, :suite, hook_context)
        end
      end
    end

    class Formatter

      def initialize(output_queue)
        @output_queue = output_queue
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
          DockerTest.logger.debug("emitting result message: #{result.payload}")
          @output_queue << result
        end
      end

    end

  end

end
