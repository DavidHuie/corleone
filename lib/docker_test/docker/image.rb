class DockerTest::Docker::Image

  DOCKER_CODE_DIR = '/home/app'

  attr_accessor :alias, :image, :local_code_directory,
                :command, :container, :linked_images, :links

  def initialize(args = {})
    @alias = args[:alias]
    @image = args[:image]
    @local_code_directory = args[:local_code_directory]
    @command = args[:command]
    @linked_images = []
    @links = []
    validate if @alias || @image
  end

  def validate
    raise 'image required' unless @image
    raise 'alias required' unless @alias
  end

  def name
    @name ||= @alias + '_' + SecureRandom.hex(6)
  end

  def pull
    Docker::Image.create('fromImage' => @image)
  end

  def add_linked_image(image)
    @linked_images << image
  end

  def create_linked_containers
    @linked_images.each do |image|
      image.create_container
      @links << "#{image.name}:#{image.alias}"
    end
    DockerTest.logger.debug("#{name} links: #{@links}")
  end

  def create_container_args
    args = { 'Image' => @image, 'name' => name }
    args['Cmd'] = [@command] if @command
    args['Volumes'] = { DOCKER_CODE_DIR => {} } if @local_code_directory
    args
  end

  def start_container_args
    args = {}
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

  def kill_linked
    @linked_images.each { |i| i.kill }
  end

end
