module Travis
  module Addons
    module Intercom
      class Client

        def initialize(owner_id)
          @intercom = Intercom::Client.new(token: Travis.config.intercom.token)
          @user = get_user(owner_id)
        end

        def report_build(params)
          @user.custom_attributes['fisrt_build_at'] = params[:fisrt_build_at] if params[:fisrt_build_at]
          @user.custom_attributes['last_build_at'] = params[:last_build_at]
          update_user
        end

        def report_subscription(params)
          @user.custom_attributes['has_subscription'] = params[:has_subscription]
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
