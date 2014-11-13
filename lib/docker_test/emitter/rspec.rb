require 'stringio'

module DockerTest::Emitter

  class RSpec

    def initialize(dir, workers)
      @dir = dir
      @workers = workers

      process_items
    end

    def spec_files
      Dir.glob(File.join(@dir, '**/*spec.rb'))
    end

    def spec_groups
      groups = @workers.times.map { [] }

      spec_files.shuffle.each_with_index do |item, i|
        groups[i % @workers] << item
      end

      groups
    end

    def item_queue
      @item_queue ||= Queue.new
    end

    def pop
      DockerTest::Message::Item.new(item_queue.pop)
    end

    def process_items
      spec_groups.each do |group|
        item_queue << DockerTest::Message::Item.new(group)
      end
    end

    def empty?
      item_queue.empty?
    end

    def runner_args
      DockerTest::Message::RunnerArgs.new(nil)
    end

  end

end
