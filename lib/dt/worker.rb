class DT::Worker

  def initialize(runner_class, server_uri)
    @name = `hostname`.strip + '-' + SecureRandom.hex
    @runner_class = runner_class
    @input_queue = Queue.new
    @output_queue = Queue.new
    @pool = DT::Pool.new do
      DRbObject.new_with_uri(server_uri)
    end
  end

  MAX_RETRIES = 50

  def block_until_server_ready
    loop do
      begin
        conn = @pool.get
        conn.ping
        break
      rescue DRb::DRbConnError
        Kernel.sleep(5)
      end
    end
  end

  def logger
    @logger ||= RemoteServerLogger.new("WORKER #{@name}", @pool.get)
  end

  def start_runner
    @runner_thread = Thread.new { @runner.run_each(@input_queue, @output_queue) }
  end

  def handle_message(message)
    case message
    when DT::Message::Item
      handle_example(message)
    when DT::Message::ZeroItems
      handle_zero_items
    when DT::Message::RunnerArgs
      handle_runner_args(message.payload)
    else
      logger.warn("invalid received message: #{message}")
    end
  end

  def handle_example(message)
    @input_queue << message.payload

    loop do
      result = @output_queue.pop
      break if result.instance_of?(DT::Message::Finished)
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
    @input_queue << DT::Message::Stop.new
    @runner_thread.join
  end

  def publish_result(result)
    conn = @pool.get
    conn.return_result(result)
  ensure
    @pool.return(conn)
  end

  def start
    logger.info("starting worker")
    conn = @pool.get

    conn.check_in(@name)
    runner_args = conn.get_runner_args
    handle_message(runner_args)

    loop do
      message = conn.get_item
      handle_message(message)
      break if @quit
    end

    conn.check_out(@name)
  rescue StandardError => e
    logger.warn("exception raised: #{e}")
    e.backtrace.each do |line|
      logger.warn("    #{line}")
    end
  ensure
    @pool.return(conn)
  end

  class RemoteServerLogger

    def initialize(prefix, conn)
      @prefix = prefix
      @conn = conn
    end

    def wrapped_message(msg)
      "#{@prefix} - #{msg}"
    end

    [:debug, :info, :warn].each do |name|
      define_method(name) do |msg|
        @conn.log(name, wrapped_message(msg))
      end
    end

  end

end
