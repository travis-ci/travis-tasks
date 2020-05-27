module Travis
  module Addons
    module Intercom

      class Task < Travis::Task
        require 'travis/addons/intercom/client'

        def process
          intercom = Client.new(user.id)
          intercom.report_last_build payload.build
        end

        def user
          params[:user]
        end

      end

    end
  end
end