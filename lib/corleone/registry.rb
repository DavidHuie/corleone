class Corleone::Registry

  def initialize
    @started = false
    @names = Set.new
    @m = Mutex.new
  end

  def check_in(name)
    @m.lock
    @names << name
    @m.unlock

    @started = true
  end

  def remove(name)
    @m.lock
    @names.delete(name)
    @m.unlock
  end

  def finished?
    (@names.length == 0) && @started
  end

end
