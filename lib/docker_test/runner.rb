class DockerTest::Runner

  def initialize(&block)
    @distribute_block = block
  end

  def run
    @examples.each { |ex| @distribute_block.call(DockerTest::Message.new(example)) }
    @distribute_block.call(DockerTest::ExitMessage.new)
  end

end
