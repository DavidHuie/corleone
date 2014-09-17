module DockerTest

  class Message

    attr_accessor :output, :timing, :payload

    def initialize(payload = nil)
      @payload = payload
    end

    class Error < Message; end
    class Success < Message; end
    class Setup < Message; end
    class Exit < Message; end

  end

end
