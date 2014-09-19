class DockerTest::Worker

  def initialize(runner_class, server)
    @runner_class = runner_class
    @server = server
    @input_queue = Queue.new
    @output_queue = Queue.new
  end

  def start_runner
    @runner_thread = Thread.new do
      @runner.run_each(@input_queue, @output_queue)
    end
  end

  def handle_message(message)
    case message
    when DockerTest::Message::Item
      handle_example(message)
    when DockerTest::Message::ZeroItems
      handle_zero_items(message.payload)
    when DockerTest::Message::Setup
      handle_setup(message.payload)
    else
      DockerTest.logger.info("invalid message: #{message}")
    end
  end

  def handle_example(message)
    @input_queue << message.payload
    message.num_responses.times { publish_result }
  end

  def handle_setup(payload)
    DockerTest.logger.debug("setup arguments: #{payload}")
    @runner = @runner_class.new(payload)
    start_runner
  end

  def handle_zero_items(payload)
    @quit = true
    @input_queue << DockerTest::Message::Stop.new
    @runner_thread.join
  end

  def publish_result
    @server.return_result(@output_queue.pop)
  end

  def start
    setup_message = @server.get_setup
    handle_message(setup_message)

    loop do
      message = @server.get_item
      handle_message(message)
      break if @quit
    end
  ensure
    @runner_thread.join if @runner_thread && @runner_thread.alive?
  end

end
