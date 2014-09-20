class DockerTest::Docker::Image

  DOCKER_CODE_DIR = '/home/app'

  attr_accessor :alias, :image, :local_code_directory,
                :command, :linked_images, :links, :container,
                :bundle_directory

  def initialize(args = {})
    @alias = args[:alias]
    @image = args[:image]
    @local_code_directory = args[:local_code_directory]
    @bundle_directory = args[:bundle_code_directory] || 'vendor/bundle'
    @command = args[:command]
    @linked_images = []
    @links = []

    validate if @alias || @image
  end

  def args
    { alias: self.alias,
      image: image,
      local_code_directory: local_code_directory,
      command: command }
  end

  def clone
    c = self.class.new(args)
    @linked_images.each { |i| c.add_linked_image(i.clone) }
    c
  end

  def validate
    raise 'image required' unless @image
    raise 'alias required' unless @alias
  end

  def name
    @name ||= @alias + '_' + SecureRandom.hex(6)
  end

  def all_image_repos
    images = Set.new([image])
    @linked_images.each { |i| images.union(i.all_image_repos) }
    images
  end

  def pull_all
    all_image_repos.each do |repo|
      DockerTest.logger.info("pulling image: #{repo}")
      Docker::Image.create('fromImage' => repo)
    end
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
    args = { 'Image' => @image, 'name' => name, 'Hostname' => name, 'Volumes' => {} }
    args['Cmd'] = [@command] if @command
    args['Volumes'][DOCKER_CODE_DIR] = {} if @local_code_directory
    args['Volumes'][docker_bundle_dir] = {} if @bundle_directory
    args
  end

  def docker_bundle_dir
    File.join(DOCKER_CODE_DIR, @bundle_directory)
  end

  def local_bundle_dir
    File.join(@local_code_directory, @bundle_directory)
  end

  def start_container_args
    args = { 'Binds' => [] }
    if @local_code_directory
      args['Binds'] << "#{@local_code_directory}:#{DOCKER_CODE_DIR}"
    end
    if @bundle_directory
      args['Binds'] << "#{local_bundle_dir}:#{docker_bundle_dir}"
    end
    args['Links'] = links if links.any?
    args
  end

  def create_container
    @container = Docker::Container.create(create_container_args)
    @container.start(start_container_args)
    DockerTest.logger.info("container launched: #{name}")
  end

  def kill
    DockerTest.logger.debug("destroying container: #{name}")
    @container.delete(force: true)
  end

  def kill_all
    kill
    linked_images.each { |i| i.kill_all }
  end

end
