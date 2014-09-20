module DockerTest

  class Message

    attr_accessor :payload, :num_responses

    def initialize(payload = nil)
      @payload = payload
      @num_responses = 1
    end

    class Error < Message; end
    class Item < Message; end
    class Result < Message; end
    class RunnerArgs < Message; end
    class ConfigFile < Message; end
    class Stop < Message; end
    class ZeroItems < Message; end

  end

end
