module DockerTest

  class Message

    attr_accessor :output, :timing, :payload

    def initialize(payload = nil)
      @payload = payload
    end

  end

  class ExitMessage < Message; end

end
