class DockerTest::Worker

  def initialize(runner_class, server)
    @name = `hostname`.strip
    @runner_class = runner_class
    @server = server
    @input_queue = Queue.new
    @output_queue = Queue.new
  end

  def logger
    @logger ||= RemoteServerLogger.new("WORKER #{@name}", @server)
  end

  def start_runner
    @runner_thread = Thread.new { @runner.run_each(@input_queue, @output_queue) }
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
      logger.warn("invalid received message: #{message}")
    end
  end

  def handle_example(message)
    @input_queue << message.payload
    message.num_responses.times { publish_result }
  end

  def handle_setup(payload)
    logger.debug("setup arguments: #{payload}")
    @runner = @runner_class.new(payload, logger)
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
    logger.info("starting worker")

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

  class RemoteServerLogger

    def initialize(prefix, server)
      @prefix = prefix
      @server = server
    end

    def wrapped_message(msg)
      "#{@prefix} - #{msg}"
    end

    [:debug, :info, :warn].each do |name|
      define_method(name) do |msg|
        @server.log(name, wrapped_message(msg))
      end
    end

  end

end
