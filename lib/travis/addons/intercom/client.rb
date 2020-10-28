module Travis
  module Addons
    module Intercom
      class Client
        require 'travis/addons/intercom/client'

        def initialize(owner_id)
          @intercom = ::Intercom::Client.new(token: Travis.config.intercom.token)
          @user = get_user(owner_id)
        end

        def report_build(params)
          @user.custom_attributes['last_build_at'] = params[:last_build_at]
          update_user
        end

        private

        def get_user(id)
          @intercom.users.find(user_id: id)
        rescue Intercom::ResourceNotFound
          nil
        end

        def update_user
          @intercom.users.save(@user)
        end

      end
    end
  end
end
