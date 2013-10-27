require "travis/notifications/config"

module Travis
  def self.config
    Notifications.config
  end

  module Notifications
    def self.config
      @config ||= Config.new
    end
  end
end
