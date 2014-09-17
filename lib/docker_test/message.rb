module DockerTest

  class Message
    attr_accessor :output, :timing, :payload
  end

  class ExitMessage < Message; end

end
