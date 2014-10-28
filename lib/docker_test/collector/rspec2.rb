module DockerTest::Collector

  class RSpec

    def initialize
      @passed = 0
      @failed = 0
      @pending = 0
      @mutex = Mutex.new
    end

    def process_result(result)
      raw_status = result[:execution_result][:status]

      @mutex.lock
      case raw_status
      when 'failed'
        @failed += 1
      when 'passed'
        @passed += 1
      when 'pending'
        @pending += 1
      else
        DockerTest.logger.warn("unknown rspec status encountered: #{raw_status}")
      end
      @mutex.unlock

      status = raw_status.to_s.upcase
      description = result[:full_description]
      DockerTest.logger.info("RSPEC EXAMPLE (#{status}): #{description}")
    end

    def summarize
      DockerTest.logger.info("RSPEC TESTING FINISHED")
      DockerTest.logger.info("PASSED: #{@passed}")
      DockerTest.logger.info("FAILED: #{@failed}")
      DockerTest.logger.info("PENDING: #{@pending}")
    end

  end

end
