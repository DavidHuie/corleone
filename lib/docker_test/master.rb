class DockerTest::Master

  def initialize(runner_class)
    @worker_queue = Queue.new
    @runner = runner_class.new { |message| distribute_message(message) }
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
      message.process_response(response)
      return_worker(worker)
    end
  end

  def start
    @runner.run
  end

end
