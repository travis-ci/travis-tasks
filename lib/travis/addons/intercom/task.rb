module Travis
  module Addons
    module Intercom
      class Task < Travis::Task
        require 'travis/addons/intercom/client'

        def event
          params[:event]
        end

        def owner_id
          params[:owner_id]
        end

        private

        def process(timeout)
          client = Client.new(owner_id)
          client.public_send(event, params)
        end

      end
    end
  end
end
