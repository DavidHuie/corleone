class DockerTest::Server

  def initialize(runner, uri)
    @runner = runner
    @uri = uri
    @results = Queue.new
    @mutex = Mutex.new
    @runner_setup = @runner.setup_message
    @item_count = 0
    @result_count = 0
  end

  def get_setup
    DockerTest.logger.debug("emitting setup message: #{@runner_setup.payload}")
    @runner_setup
  end

  def get_item
    @mutex.lock
    return DockerTest::Message::ZeroItems.new if finished?
    @item_count += 1
    message = DockerTest::Message::Item.new(@runner.pop)
    DockerTest.logger.debug("emitting item message: #{message.payload.inspect}")
    message
  ensure
    @mutex.unlock
  end

  def return_result(result)
    @mutex.lock
    DockerTest.logger.debug("result message received: #{result}")

    if result.instance_of?(DockerTest::Message::Result)
      @results << result.payload
      @result_count += 1
      return
    end

    raise "result error: #{result.payload}"
  ensure
    @mutex.unlock
  end

  def finished?
    @runner.empty? && (@item_count == @result_count)
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
