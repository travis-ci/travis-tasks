module Travis
  module Addons
    module Intercom

      class Task < Travis::Task
        require 'travis/addons/intercom/client'

        def process
          puts "-----------------------------------"
          puts "Executes Intercom task"
          p payload
          puts "-----------------------------------"
          return unless user_id && build
          intercom = Client.new(user.id)
          intercom.report_last_build build.finished_at
        end

        def user_id
          payload[:owner].id
        end

        def build
          payload[:build]
        end

      end

    end
  end
end
