class DockerTest::Server

  def initialize(runner, uri)
    @runner = runner
    @uri = uri
    @results = Queue.new
    @mutex = Mutex.new
    @runner_setup = @runner.setup_message
    @expected_result_count = 0
    @result_count = 0
  end

  def get_setup
    DockerTest.logger.debug("emitting setup message: #{@runner_setup.payload}")
    @runner_setup
  end

  def get_item
    @mutex.lock
    return DockerTest::Message::ZeroItems.new if finished?
    message = @runner.pop
    @expected_result_count += message.num_responses
    DockerTest.logger.debug("emitting item message: #{message.payload}")
    message
  ensure
    @mutex.unlock
  end

  def return_result(result)
    @mutex.lock
    if result.instance_of?(DockerTest::Message::Result)
      DockerTest.logger.debug("result message received: #{result.payload}")
      @results << result.payload
      @result_count += 1
      return
    end

    raise "result error: #{result}"
  ensure
    @mutex.unlock
  end

  def finished?
    @runner.empty? && (@expected_result_count == @result_count)
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
    DockerTest.logger.info("starting server")
    DRb.start_service(@uri, self)
    @thread = DRb.thread
  end

end
