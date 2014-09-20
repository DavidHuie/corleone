class DockerTest::Config

  attr_reader :image, :settings

  def initialize
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

  class Settings

    attr_accessor :num_containers

    def initializer
      @num_containers = 1
    end

  end

end
