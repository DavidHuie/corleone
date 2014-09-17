require 'rspec/core'

class DockerTest::Runner::RSpec < DockerTest::Runner

  def initialize(&block)
    super(&block)
    @rspec = DockerRunner.new
    @examples = @rspec.example_groups
  end

  class DockerRunner < ::RSpec::Core::Runner

    def initialize
      super(ARGV)
      @configuration.output_stream = $stdout
      @configuration.error_stream  = $stderr
    end

    def example_groups
      @world.ordered_example_groups
    end

    def run_each(input_queue, output_queue)
      @configuration.reporter.report(@world.example_count(example_groups)) do |reporter|
        begin
          hook_context = SuiteHookContext.new
          @configuration.hooks.run(:before, :suite, hook_context)
          failures = 0

          loop do
            message = input_queue.pop

            break if message.is_a?(ExitMessage)

            print message.payload.description
            start = Time.now
            ret = message.payload.run(reporter)
            failures += 1 unless ret
            diff = Time.now - start

            message.output = ret
            message.timing = diff

            output_queue << message
          end

          @configuration.failure_exit_code if failures > 0
        ensure
          @configuration.run_hook(:after, :suite)
        end
      end
    end

  end

end
