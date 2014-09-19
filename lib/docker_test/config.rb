class DockerTest::Config

  attr_reader :image

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

end
