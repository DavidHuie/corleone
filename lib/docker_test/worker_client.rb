class DockerTest::WorkerClient

  LISTEN_IP = '0.0.0.0'

  def initialize(port)
    @port = port
  end

  def socket
    # TODO: retry
    @socket ||= TCPSocket.new(LISTEN_IP, @port)
  end

  def send_message(message, &block)
    msg = Marshal.dump(message)
    loop do
      continue if IO.select(nil, [socket], nil, SELECT_TIMEOUT).nil?
      puts "sending message: #{msg.inspect}"
      socket.puts(msg)
      # Thread.new { block.call(Marshal.load(read)) }
      block.call(Marshal.load(read))
      return
    end
  end

  private

  SELECT_TIMEOUT = 0.1

  def read
    loop do
      # TODO: raise exception after enough time
      next if IO.select([socket], nil, nil, SELECT_TIMEOUT).nil?
      response = socket.gets.strip
      return response
    end
  end

end
