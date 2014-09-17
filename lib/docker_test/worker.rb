class DockerTest::Worker

  LISTEN_IP = '0.0.0.0'

  def initialize(port, runner_class)
    @port = port
    @runner_class = runner_class
    @input_queue = Queue.new
    @output_queue = Queue.new
  end

  def start_runner
    @runner_thread = Thread.new { @runner.run_each(@input_queue, @output_queue) }
  end

  def server
    @server ||= TCPServer.new(LISTEN_IP, @port)
  end

  SELECT_TIMEOUT = 0.1

  def start
    start_runner
    client = server.accept
    quit = false

    loop do
      if IO.select([client], nil, nil, SELECT_TIMEOUT)
        raw_message = client.gets
        next unless raw_message
        message = Marshal.load(raw_message)
        @input_queue << message
        response = nil

        if message.instance_of?(DockerTest::Message::Exit)
          @runner_thread.join
          response = DockerTest::Message::Success.new
          quit = true
        else
          response = @output_queue.pop
        end

        client.puts(Marshal.dump(response))
        break if quit
      end
    end

    client.close
  end

end
