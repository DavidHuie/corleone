require 'stringio'
require 'rspec/core'

module DockerTest::Emitter

  class RSpec

    def initialize(args)
      @args = args
      options = ::RSpec::Core::ConfigurationOptions.new(args)
      @rspec = ::RSpec::Core::Runner.new(options)
      @rspec.setup(output_buffer, output_buffer)
      process_items
    end

    def item_queue
      @item_queue ||= Queue.new
    end

    def output_buffer
      @output_buffer ||= StringIO.new
    end

    def setup_message
      @setup_message ||= DockerTest::Message::Setup.new(@args)
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
      @rspec.instance_variable_get("@world").ordered_example_groups.each do |example|
        item_queue << example
      end
    end

  end

end
