class DockerTest::Worker

  LISTEN_IP = '0.0.0.0'

  def initialize(port, runner)
    @port = port
    @runner = runner
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

    loop do
      if IO.select([client], nil, nil, SELECT_TIMEOUT)
        raw_message = client.gets
        next unless raw_message
        puts "raw message: #{raw_message.inspect}"
        message = Marshal.load(raw_message)
        @input_queue << message

        if message.is_a?(DockerTest::ExitMessage)
          @runner_thread.join
          return
        end

        response = @output_queue.pop
        client.puts(Marshal.dump(response))
      end
    end

    client.close
  end

end
