class DockerTest::Config

  attr_reader :image, :settings

  def initialize(logger)
    @logger = logger
    @image = DockerTest::Docker::Image.new
  end

  def docker_image
    yield(@image)
    @image.validate
  end

  def linked_image
    linked_image = DockerTest::Docker::Image.new
    yield(linked_image)
    linked_image.validate
    @image.add_linked_image(linked_image)
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
