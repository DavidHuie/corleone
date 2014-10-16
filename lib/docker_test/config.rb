class DockerTest::Config

  attr_reader :raw_testing_image, :raw_bundle_image, :settings

  def initialize(logger)
    @logger = logger
  end

  def testing_image
    @raw_testing_image = DockerTest::Docker::Image.new
    yield(@raw_testing_image)
    raw_testing_image.validate
  end

  def bundle_image
    @raw_bundle_image = DockerTest::Docker::Image.new
    yield(@raw_bundle_image)
    raw_bundle_image.validate
  end

  def docker_settings
    @settings = Settings.new
    yield(@settings)
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

  class Settings

    attr_accessor :num_containers

    def initializer
      @num_containers = 1
    end

  end

end
