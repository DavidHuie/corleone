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

  def for_all_workers
    workers = []
    threads = []
    loop do
      break if @worker_queue.empty?
      worker = @worker_queue.pop
      threads << Thread.new { yield(worker) }
      workers << worker
    end
    threads.map(&:join)
    workers.each { |w| @worker_queue << w }
  end

  def distribute_message(message)
    worker = checkout_worker
    worker.send_message(message) do |response|
      validate_response(response)
      return_worker(worker)
    end
  end

  def distribute_messages
    @runner.items.each do |item|
      message = DockerTest::Message.new(item)
      distribute_message(message)
    end
  end

  def validate_response(response)
    raise 'error sending message' if response.instance_of?(DockerTest::Message::Error)
  end

  def stop
    for_all_workers do |worker|
      worker.send_message(DockerTest::Message::Exit.new) { |response| validate_response(response) }
    end
  end

  def setup
    for_all_workers do |worker|
      worker.send_message(@runner.setup_message) { |response| validate_response(response) }
    end
  end

  def start
    setup
    distribute_messages
    stop
  end

end
