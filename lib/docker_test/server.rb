class DockerTest::Server

  attr_accessor :config_file, :thread

  def initialize(emitter, collector, uri)
    @emitter = emitter
    @collector = collector
    @uri = uri
    @mutex = Mutex.new
    @runner_args = @emitter.runner_args
    @expected_result_count = 0
    @result_count = 0
  end

  def logger
    DockerTest.logger
  end

  def log(type, message)
    logger.send(type, message)
    return
  end

  def get_config_file
    msg = DockerTest::Message::ConfigFile.new(@config_file)
    logger.debug("emitting config_file message: #{msg.payload}")
    msg
  end

  def get_runner_args
    logger.debug("emitting runner args message: #{@runner_args.payload}")
    @runner_args
  end

  def get_item
    return DockerTest::Message::ZeroItems.new if @emitter.empty?
    message = @emitter.pop

    @mutex.lock
    @expected_result_count += message.num_responses
    @mutex.unlock

    logger.debug("emitting item message: #{message.payload}")
    message
  end

  def return_result(result)
    if result.instance_of?(DockerTest::Message::Result)
      logger.debug("result message received: #{result.payload}")
      @collector.process_result(result.payload)

      @mutex.lock
      @result_count += 1
      @mutex.unlock

      return
    end

    raise "result error: #{result}"
  end

  def finished?
    @emitter.empty? && (@expected_result_count == @result_count)
  end

  def kill
    @thread.kill
  end

  def alive?
    kill if finished?
    value = @thread.alive?
    value
  end

  def start
    logger.info("starting server")
    DRb.start_service(@uri, self)
    @thread = DRb.thread
  end

  def summarize
    @collector.summarize
  end

end
