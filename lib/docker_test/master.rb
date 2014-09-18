class DockerTest::Master

  def initialize(runner)
    @worker_queue = Queue.new
    @runner = runner
  end

  def add_worker(port)
    @worker_queue << DockerTest::WorkerClient.new(port)
  end

  def checkout_worker
    @worker_queue.pop
  end

  def return_worker(worker)
    @worker_queue << worker
  end

  def distribute_message(message)
    worker = checkout_worker
    worker.send_message(message) do |response|
      raise 'error sending message' if response.instance_of?(DockerTest::Message::Error)
      return_worker(worker)
    end
  end

  def distribute_messages
    @runner.items.each do |item|
      message = DockerTest::Message.new(item)
      distribute_message(message)
    end
  end

  def stop
    worker = checkout_worker
    worker.send_message(DockerTest::Message::Exit.new) { return_worker(worker) }
  end

  def setup
    worker = checkout_worker
    worker.send_message(@runner.setup_message) { return_worker(worker) }
  end

  def start
    setup
    distribute_messages
    stop
  end

end
