class DockerTest::Runner

  def initialize(&block)
    @distribute_block = block
  end

  def run
    @examples.each do |ex|
      @distribute_block.call(DockerTest::Message.new(ex))
    end
  end

end
