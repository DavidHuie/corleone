class DockerTest::Docker::Image

  DOCKER_CODE_DIR = '/home/app'

  def initialize(opts = {})
    @image = opts[:image]
    @local_code_directory = opts[:local_code_directory]
    @commands = opts[:commands]
  end

  def pull
    Docker::Image.import(@image)
  end

  def create_container
    cmd = @commands.join(' && ')
    container = Docker::Container.create('Image' => @image,
                                         'Cmd' => cmd,
                                         'Volumes' => { DOCKER_CODE_DIR => {} })
    container.start('Binds' => ["#{@local_code_directory}:#{DOCKER_CODE_DIR}"],
                    'NetworkMode' => 'host')
    container
  end

end
