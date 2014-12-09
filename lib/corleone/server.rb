class Corleone::Server

  def initialize(emitter, collector, uri)
    @emitter = emitter
    @collector = collector
    @uri = uri
    @runner_args = @emitter.runner_args
    @registry = Corleone::Registry.new
  end

  def logger
    Corleone.logger
  end

  def log(type, message)
    logger.send(type, message)
    return
  end

  def check_in(name)
    logger.debug("worker checking in: #{name}")
    @registry.check_in(name)
  end

  def check_out(name)
    logger.debug("worker checking out: #{name}")
    @registry.remove(name)
  end

  def get_runner_args
    if @runner_args
      logger.debug("emitting runner args message: #{@runner_args.payload}")
    end

    @runner_args
  end

  def get_item
    return Corleone::Message::ZeroItems.new if @emitter.empty?
    message = @emitter.pop
    logger.debug("emitting item message: #{message.payload}")
    message
  end

  def return_result(result)
    if result.instance_of?(Corleone::Message::Result)
      logger.debug("result message received: #{result.payload}")
      @collector.process_result(result.payload)
      return
    end

    raise "result error: #{result}"
  end

  def finished?
    @emitter.empty? && @registry.finished?
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

  def ping; end

  def wait
    loop { alive? ? Kernel.sleep(0.1) : break }
  end

end
