class DockerTest::Docker::Image

  attr_accessor :alias, :image, :binds, :dns, :volumes_from, :env,
                :command, :container

  def initialize(args = {})
    @alias = args[:alias]
    @image = args[:image]
    @binds = args[:binds]
    @dns = args[:dns]
    @volumes_from = args[:volumes_from]
    @env = args[:env]
    @command = args[:command]

    validate if @alias || @image
  end

  def args
    { alias: self.alias,
      image: image,
      binds: binds,
      dns: dns,
      volumes_from: volumes_from,
      env: env,
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
    args = { 'Image' => @image, 'name' => name, 'Hostname' => name, 'Volumes' => {}, 'Env' => env }
    args['Cmd'] = [@command] if @command

    if @binds
      @binds.each do |volume_pair|
        docker_path = volume_pair.split(':')[1]
        args['Volumes'][docker_path] = {}
      end
    end

    args
  end

  def start_container_args
    args = {
      'Binds' => @binds,
      'Dns' => @dns,
      'VolumesFrom' => @volumes_from,
    }

    args
  end

  def create_container
    @container = Docker::Container.create(create_container_args)
    @container.start(start_container_args)
    DockerTest.logger.info("container launched: #{name}")
  end

  def wait
    @container.wait
  end

  def kill
    DockerTest.logger.debug("destroying container: #{name}")
    @container.delete(force: true)
  end

  def kill_all
    kill
  end

end
