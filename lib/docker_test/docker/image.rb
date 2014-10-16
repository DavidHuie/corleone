class DockerTest::Docker::Image

  DOCKER_CODE_DIR = '/home/app'

  attr_accessor :alias, :image, :local_code_directory,
                :command, :container, :bundle_directory

  def initialize(args = {})
    @alias = args[:alias]
    @image = args[:image]
    @local_code_directory = args[:local_code_directory]
    @bundle_directory = args[:bundle_code_directory] || 'vendor/bundle'
    @command = args[:command]

    validate if @alias || @image
  end

  def args
    { alias: self.alias,
      image: image,
      local_code_directory: local_code_directory,
      command: command }
  end

  def clone
    self.class.new(args)
  end

  def validate
    raise 'image required' unless @image
    raise 'alias required' unless @alias
  end

  def name
    @name ||= @alias + '_' + SecureRandom.hex(6)
  end

  def all_image_repos
    Set.new([image])
  end

  def pull_all
    all_image_repos.each do |repo|
      DockerTest.logger.info("pulling image: #{repo}")
      Docker::Image.create('fromImage' => repo)
    end
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
  end

end
