class DockerTest::Setup

  def initialize(logger)
    @logger = logger
  end

  def define_setup(&block)
    @setup_block = block
  end

  def define_teardown(&block)
    @teardown_block = block
  end

  def setup
    @logger.debug("performing setup")
    @setup_block.call if @setup_block
  end

  def teardown
    @logger.debug("performing teardown")
    @teardown_block.call if @teardown_block
  end

end
