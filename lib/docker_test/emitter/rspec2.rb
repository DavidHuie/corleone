require 'stringio'

module DockerTest::Emitter

  class RSpec

    def initialize(args)
      @args = args
      @emitter = ::RSpec::Core::CommandLine.new(args)
      configuration.output_stream = output_buffer
      configuration.error_stream = output_buffer

      process_items
    end

    def emitter_var(var_name)
      @emitter.instance_variable_get(var_name.to_sym)
    end

    def configuration
      emitter_var(:@configuration)
    end

    def example_groups
      emitter_var(:@options).configure(configuration)
      configuration.load_spec_files
      emitter_var(:@world).announce_filters
      emitter_var(:@world).example_groups
    end

    def item_queue
      @item_queue ||= Queue.new
    end

    def output_buffer
      STDOUT
      # @output_buffer ||= StringIO.new
    end

    def runner_args
      @runner_args ||= DockerTest::Message::RunnerArgs.new(@args)
    end

    def pop
      item = item_queue.pop
      message = DockerTest::Message::Item.new(item)
      message.num_responses = item.examples.length
      message
    end

    def empty?
      item_queue.empty?
    end

    def process_items
      example_groups.each do |example|
        item_queue << example
      end
    end

  end

end
