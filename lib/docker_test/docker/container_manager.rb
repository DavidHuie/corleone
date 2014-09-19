class DockerTest::Docker::ContainerManager

  DOCKER_CODE_DIR = '/home/app'

  def initialize(opts = {})
    @image = opts[:image]
    @local_code_directory = opts[:local_code_directory]
    @commands = opts[:commands]
    @containers = []
  end

  def pull
    Docker::Image.import(@image)
  end

  def create_containers(n)
    n.times { create_container }
  end

  def create_container
    cmd = @commands.join(' && ')
    container = Docker::Container.create('Image' => @image,
                                         'Cmd' => cmd,
                                         'Volumes' => { DOCKER_CODE_DIR => {} })
    container.start('Binds' => ["#{@local_code_directory}:#{DOCKER_CODE_DIR}"],
                    'NetworkMode' => 'host')
    @containers << container
  end

  def kill_containers
    @containers.each { |c| c.delete(:force => true) }
  end

end
