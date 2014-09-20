class DockerTest::Server

  attr_accessor :setup_file

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

  def get_setup_file
    msg = DockerTest::Message::SetupFile.new(@setup_file)
    logger.debug("emitting setup_file message: #{msg.payload}")
    msg
  end

  def get_runner_args
    logger.debug("emitting runner args message: #{@runner_args.payload}")
    @runner_args
  end

  def get_item
    @mutex.lock
    return DockerTest::Message::ZeroItems.new if @emitter.empty?
    message = @emitter.pop
    @expected_result_count += message.num_responses
    logger.debug("emitting item message: #{message.payload}")
    message
  ensure
    @mutex.unlock
  end

  def return_result(result)
    @mutex.lock
    if result.instance_of?(DockerTest::Message::Result)
      logger.debug("result message received: #{result.payload}")
      @collector.process_result(result.payload)
      @result_count += 1
      return
    end

    raise "result error: #{result}"
  ensure
    @mutex.unlock
  end

  def finished?
    @emitter.empty? && (@expected_result_count == @result_count)
  end

  def kill
    @thread.kill
  end

  def alive?
    @mutex.lock
    kill if finished?
    value = @thread.alive?
    @mutex.unlock
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
