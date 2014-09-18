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
    client = server.accept
    quit = false

    loop do
      if IO.select([client], nil, nil, SELECT_TIMEOUT)
        raw_message = client.gets
        next unless raw_message
        message = Marshal.load(raw_message)
        response = nil

        puts "received message #{message.class}: #{message.payload.inspect}"

        if message.instance_of?(DockerTest::Message::Exit)
          @input_queue << message
          @runner_thread.join
          response = DockerTest::Message::Success.new
          quit = true
        elsif message.instance_of?(DockerTest::Message::Setup)
          @runner = @runner_class.get_runner(message.payload)
          start_runner
          response = DockerTest::Message::Success.new
        else
          @input_queue << message
          response = @output_queue.pop
        end

        client.puts(Marshal.dump(response))
        break if quit
      end
    end

    client.close
  ensure
    @runner_thread.join
  end

end
