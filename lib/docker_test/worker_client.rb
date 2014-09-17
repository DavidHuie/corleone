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
    socket.puts(Marshal.dump(message))
    Thread.new { block.call(read) }
  end

  private

  SELECT_TIMEOUT = 0.1

  def read
    loop do
      # TODO: raise exception after enough time
      continue if IO.select([socket], nil, nil, SELECT_TIMEOUT).nil?
      return socket.gets.strip
    end
  end

end
