class DockerTest::Docker::Image

  DOCKER_CODE_DIR = '/home/app'

  attr_reader :alias, :container, :dependent_images, :links

  def initialize(args = {})
    @alias = args[:alias]
    @image = args[:image]
    @local_code_directory = args[:local_code_directory]
    @command = args[:command]
    @dependent_images = []
    @links = []

    raise 'alias required' unless @alias
  end

  def name
    @name ||= @alias + '_' + SecureRandom.hex(6)
  end

  def pull
    Docker::Image.create('fromImage' => @image)
  end

  def add_linked_image(image)
    @dependent_images << image
  end

  def create_linked_containers
    @dependent_images.each do |image|
      image.create_container
      @links << "#{image.name}:#{image.alias}"
    end
    DockerTest.logger.debug("#{name} links: #{@links}")
  end

  def create_container_args
    args = { 'Image' => @image, 'name' => name }
    args['Cmd'] = @command if @command
    args['Volumes'] = { DOCKER_CODE_DIR => {} } if @local_code_directory
    args
  end

  def start_container_args
    args = { 'NetworkMode' => 'host' }
    if @local_code_directory
      args['Binds'] = ["#{@local_code_directory}:#{DOCKER_CODE_DIR}"]
    end
    args['Links'] = links if links.any?
    args
  end

  def create_container
    @container = Docker::Container.create(create_container_args)
    @container.start(start_container_args)
    DockerTest.logger.debug("started container: #{container.id}")
    @container
  end

  def kill
    DockerTest.logger.debug("destroying container: #{@container.id}")
    @container.delete(force: true)
  end

end
