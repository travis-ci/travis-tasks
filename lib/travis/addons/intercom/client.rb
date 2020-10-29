require 'intercom'

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
          return unless @user
          @user.custom_attributes['fisrt_build_at'] = params[:fisrt_build_at] if params[:fisrt_build_at]
          @user.custom_attributes['last_build_at'] = params[:last_build_at]
          update_user
        end

        def report_subscription(params)
          return unless @user
          @user.custom_attributes['has_subscription'] = params[:has_subscription]
          update_user
        end

        private

        def get_user(id)
          @intercom.users.find(user_id: id)
        rescue ::Intercom::ResourceNotFound
          @intercom.users.create(user_id: id) # Create an empty user to save events, name and email will be added by other sources, e.g. web
        rescue
          nil
        end

        def update_user
          @intercom.users.save(@user)
        end

      end
    end
  end
end
