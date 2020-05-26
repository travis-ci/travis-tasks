module Travis
  module Addons
    module Intercom

      class Task < Travis::Task

        def process
          
        end

        def user
          params[:user]
        end

      end

    end
  end
end