class DockerTest::Runner

  def initialize(&block)
    @distribute_block = block
  end

  def setup_message; end

  def run
    @distribute_block.call(setup_message) if setup_message

    @examples.each do |ex|
      @distribute_block.call(DockerTest::Message.new(ex))
    end
  end

end
