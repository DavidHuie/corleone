class DockerTest::Pool

  def initialize(&block)
    @initializer = block
    @pool = []
    @m = Mutex.new
  end

  def get
    @m.lock
    return @pool.pop if @pool.length > 0
    @initializer.call
  ensure
    @m.unlock
  end

  def return(value)
    @m.lock
    @pool << value
  ensure
    @m.unlock
  end

end
