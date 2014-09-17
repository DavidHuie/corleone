require 'rspec/core'

class DockerTest::Runner::RSpec < DockerTest::Runner

  def initialize(&block)
    super(&block)
    @rspec = DockerRunner.get_runner(ARGV)
    @examples = @rspec.example_groups
  end

  class DockerRunner < ::RSpec::Core::Runner

    def self.get_runner(args, err=$stderr, out=$stdout)
      options = ::RSpec::Core::ConfigurationOptions.new(args)
      runner = new(options)
      runner.setup(err, out)
      runner
    end

    def example_groups
      @world.ordered_example_groups
    end

    def run_each(input_queue, output_queue)
      @configuration.reporter.report(0) do |reporter|
        begin
          # hook_context = SuiteHookContext.new
          # @configuration.hooks.run(:before, :suite) #, hook_context)
          failures = 0

          loop do
            message = input_queue.pop

            break if message.instance_of?(DockerTest::ExitMessage)

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
          # @configuration.hooks.run(:after, :suite)
        end
      end
    end

  end

end
