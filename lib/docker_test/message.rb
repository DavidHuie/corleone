module DockerTest

  class Message

    attr_reader :payload

    def initialize(payload = nil)
      @payload = payload
    end

    class Error < Message; end
    class Stop < Message; end
    class Item < Message; end
    class Result < Message; end
    class Setup < Message; end
    class ZeroItems < Message; end

  end

end
