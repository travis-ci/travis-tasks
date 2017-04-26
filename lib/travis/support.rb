require 'travis/logger'
require 'travis/support/exception_handling'
require 'travis/support/logging'

module Travis
  class << self
    def logger
      @logger ||= Logger.configure(Logger.new(STDOUT), config)
    end

    def logger=(logger)
      @logger = Logger.configure(logger, config)
    end
  end
end
