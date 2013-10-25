require "travis/tasks/config"

module Travis
  def self.config
    Tasks.config
  end

  module Tasks
    def self.config
      @config ||= Config.new
    end
  end
end
