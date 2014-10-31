class DockerTest::Worker

  def initialize(runner_class, server)
    @name = `hostname`.strip + '-' + SecureRandom.hex
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
      handle_zero_items
    when DockerTest::Message::RunnerArgs
      handle_runner_args(message.payload)
    else
      logger.warn("invalid received message: #{message}")
    end
  end

  def handle_example(message)
    @input_queue << message.payload

    loop do
      result = @output_queue.pop
      break if result.instance_of?(DockerTest::Message::Finished)
      publish_result(result)
    end
  end

  def handle_runner_args(payload)
    logger.debug("runner_args arguments: #{payload}")
    @runner = @runner_class.new(payload, logger)
    start_runner
  end

  def handle_zero_items
    @quit = true
    @input_queue << DockerTest::Message::Stop.new
    @runner_thread.join
  end

  def publish_result(result)
    @server.return_result(result)
  end

  def start
    logger.info("starting worker")

    @server.check_in(@name)
    runner_args = @server.get_runner_args
    handle_message(runner_args)

    loop do
      message = @server.get_item
      handle_message(message)
      break if @quit
    end
  rescue StandardError => e
    logger.warn("exception raised: #{e}")
  ensure
    @server.check_out(@name)
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
